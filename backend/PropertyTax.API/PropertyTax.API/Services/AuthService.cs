using System.Net;
using Microsoft.AspNetCore.Identity;
using MimeKit;
using MailKit.Net.Smtp;
using PropertyTax.API.DTOs;
using PropertyTax.API.Models;

namespace PropertyTax.API.Services;

public class AuthService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;
    private readonly TokenService _tokenService;
    private readonly AuditLogService _auditLogService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        UserManager<ApplicationUser> userManager,
        RoleManager<IdentityRole> roleManager,
        TokenService tokenService,
        AuditLogService auditLogService,
        IConfiguration configuration,
        ILogger<AuthService> logger)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _tokenService = tokenService;
        _auditLogService = auditLogService;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<(bool Success, string Message, AuthResponseDto? Response, IEnumerable<string>? Errors)> LoginAsync(LoginDto loginDto)
    {
        var identifier = loginDto.Username.Trim();
        var user = await FindByUsernameOrEmailAsync(identifier);

        if (user is null)
        {
            await _auditLogService.LogAsync("LoginFailed", "Authentication", null, $"Failed login attempt for {identifier}", false, username: identifier);
            return (false, "Invalid username or password.", null, null);
        }

        if (!user.IsActive)
        {
            await _auditLogService.LogAsync("LoginBlocked", "Authentication", user.Id, $"Inactive account attempted sign-in for {identifier}", false, user.Id, user.UserName, null);
            return (false, "This user account is inactive.", null, null);
        }

        var passwordIsValid = await _userManager.CheckPasswordAsync(user, loginDto.Password);

        if (!passwordIsValid)
        {
            await _auditLogService.LogAsync("LoginFailed", "Authentication", user.Id, $"Failed login attempt for {identifier}", false, user.Id, user.UserName, null);
            return (false, "Invalid username or password.", null, null);
        }

        var roles = await _userManager.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? SystemRoles.Staff;
        var token = await _tokenService.CreateTokenAsync(user);

        await _auditLogService.LogAsync("LoginSucceeded", "Authentication", user.Id, $"Successful login for {identifier}", true, user.Id, user.UserName, role);

        return (true, "Login successful.", new AuthResponseDto
        {
            Token = token,
            UserId = user.Id,
            Username = user.UserName ?? user.Email ?? user.Id,
            DisplayName = user.FullName,
            Email = user.Email ?? string.Empty,
            Role = role,
        }, null);
    }

    public async Task<(bool Success, string Message, UserDto? User, IEnumerable<string>? Errors)> RegisterAsync(RegisterDto registerDto)
    {
        var normalizedRole = NormalizeRole(registerDto.Role);

        if (normalizedRole is null)
        {
            return (false, "Invalid role supplied.", null, ["Role must be Admin, Staff, Accountant, or Auditor."]);
        }

        if (!await _roleManager.RoleExistsAsync(normalizedRole))
        {
            await _roleManager.CreateAsync(new IdentityRole(normalizedRole));
        }

        if (await FindByUsernameOrEmailAsync(registerDto.Username.Trim()) is not null)
        {
            return (false, "A user with the supplied username already exists.", null, ["Username is already in use."]);
        }

        if (await _userManager.FindByEmailAsync(registerDto.Email.Trim()) is not null)
        {
            return (false, "A user with the supplied email already exists.", null, ["Email address is already in use."]);
        }

        var user = new ApplicationUser
        {
            UserName = registerDto.Username.Trim(),
            Email = registerDto.Email.Trim(),
            FullName = registerDto.FullName.Trim(),
            EmailConfirmed = true,
            IsActive = registerDto.IsActive,
        };

        var createResult = await _userManager.CreateAsync(user, registerDto.Password);

        if (!createResult.Succeeded)
        {
            var errors = createResult.Errors.Select(error => error.Description).ToArray();
            return (false, "User registration failed.", null, errors);
        }

        var roleResult = await _userManager.AddToRoleAsync(user, normalizedRole);

        if (!roleResult.Succeeded)
        {
            var errors = roleResult.Errors.Select(error => error.Description).ToArray();
            await _userManager.DeleteAsync(user);
            return (false, "Role assignment failed.", null, errors);
        }

        await _auditLogService.LogAsync("UserCreated", "User", user.Id, $"Created user {user.UserName} with role {normalizedRole}");

        return (true, "User created successfully.", MapUser(user, normalizedRole), null);
    }

    public async Task<(bool Success, string Message)> ForgotPasswordAsync(ForgotPasswordDto forgotPasswordDto)
    {
        var email = forgotPasswordDto.Email.Trim();
        var genericMessage = "If a matching account exists, password reset instructions will be sent to the registered email address.";
        var user = await _userManager.FindByEmailAsync(email);

        if (user is null)
        {
            await _auditLogService.LogAsync("ForgotPasswordRequested", "Authentication", null, $"Password reset requested for unknown email {email}", true, username: email);
            return (true, genericMessage);
        }

        var token = await _userManager.GeneratePasswordResetTokenAsync(user);
        var frontendBaseUrl = _configuration["FrontendBaseUrl"];

        if (string.IsNullOrWhiteSpace(frontendBaseUrl))
        {
            _logger.LogWarning(
                "FrontendBaseUrl is not configured. Skipping password reset email for {Email}.",
                user.Email);

            await _auditLogService.LogAsync(
                "ForgotPasswordRequested",
                "Authentication",
                user.Id,
                $"Password reset requested for {user.Email}, but FrontendBaseUrl is not configured.",
                true,
                user.Id,
                user.UserName,
                null);

            return (true, genericMessage);
        }

        var resetUrl = $"{frontendBaseUrl.TrimEnd('/')}/reset-password?email={WebUtility.UrlEncode(user.Email)}&token={WebUtility.UrlEncode(token)}";

        await SendResetPasswordEmailAsync(user, resetUrl);
        await _auditLogService.LogAsync("ForgotPasswordRequested", "Authentication", user.Id, $"Password reset requested for {user.Email}", true, user.Id, user.UserName, null);

        return (true, genericMessage);
    }

    public async Task<(bool Success, string Message, IEnumerable<string>? Errors)> ChangePasswordAsync(string userId, ChangePasswordDto changePasswordDto)
    {
        var user = await _userManager.FindByIdAsync(userId);

        if (user is null)
        {
            return (false, "Authenticated user not found.", null);
        }

        if (!user.IsActive)
        {
            return (false, "This user account is inactive.", null);
        }

        if (changePasswordDto.CurrentPassword == changePasswordDto.NewPassword)
        {
            return (false, "New password must be different from the current password.", null);
        }

        var changePasswordResult = await _userManager.ChangePasswordAsync(
            user,
            changePasswordDto.CurrentPassword,
            changePasswordDto.NewPassword);

        if (!changePasswordResult.Succeeded)
        {
            var errors = changePasswordResult.Errors.Select(error => error.Description).ToArray();
            await _auditLogService.LogAsync("PasswordChangeFailed", "Authentication", user.Id, $"Password change failed for {user.UserName}", false, user.Id, user.UserName, null);
            return (false, "Password change failed.", errors);
        }

        await _auditLogService.LogAsync("PasswordChanged", "Authentication", user.Id, $"Password changed for {user.UserName}", true, user.Id, user.UserName, null);
        return (true, "Password updated successfully.", null);
    }

    private async Task<ApplicationUser?> FindByUsernameOrEmailAsync(string identifier)
    {
        var user = await _userManager.FindByNameAsync(identifier);

        if (user is not null)
        {
            return user;
        }

        return await _userManager.FindByEmailAsync(identifier);
    }

    private async Task SendResetPasswordEmailAsync(ApplicationUser user, string resetUrl)
    {
        var smtpHost = _configuration["Smtp:Host"];
        var senderEmail = _configuration["Smtp:SenderEmail"];

        if (string.IsNullOrWhiteSpace(smtpHost) || string.IsNullOrWhiteSpace(senderEmail))
        {
            _logger.LogInformation("SMTP is not configured. Password reset link for {Email}: {ResetUrl}", user.Email, resetUrl);
            return;
        }

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(
            _configuration["Smtp:SenderName"] ?? "TaxSync Property Taxation System",
            senderEmail));
        message.To.Add(MailboxAddress.Parse(user.Email!));
        message.Subject = "TaxSync Password Reset";
        message.Body = new BodyBuilder
        {
            HtmlBody = $"<p>Hello {WebUtility.HtmlEncode(user.FullName)},</p><p>You requested a password reset for TaxSync.</p><p><a href=\"{resetUrl}\">Reset your password</a></p><p>If you did not request this change, you can ignore this email.</p>",
        }.ToMessageBody();

        using var smtpClient = new SmtpClient();
        var port = int.TryParse(_configuration["Smtp:Port"], out var configuredPort) ? configuredPort : 587;
        var useSsl = bool.TryParse(_configuration["Smtp:UseSsl"], out var configuredSsl) && configuredSsl;

        await smtpClient.ConnectAsync(smtpHost, port, useSsl);

        var username = _configuration["Smtp:Username"];
        var password = _configuration["Smtp:Password"];

        if (!string.IsNullOrWhiteSpace(username))
        {
            await smtpClient.AuthenticateAsync(username, password ?? string.Empty);
        }

        await smtpClient.SendAsync(message);
        await smtpClient.DisconnectAsync(true);
    }

    private static string? NormalizeRole(string role)
    {
        return SystemRoles.All.FirstOrDefault(candidate =>
            string.Equals(candidate, role.Trim(), StringComparison.OrdinalIgnoreCase));
    }

    private static UserDto MapUser(ApplicationUser user, string role)
    {
        return new UserDto
        {
            Id = user.Id,
            Username = user.UserName ?? string.Empty,
            Email = user.Email ?? string.Empty,
            FullName = user.FullName,
            Role = role,
            IsActive = user.IsActive,
            CreatedAtUtc = user.CreatedAtUtc,
        };
    }
}