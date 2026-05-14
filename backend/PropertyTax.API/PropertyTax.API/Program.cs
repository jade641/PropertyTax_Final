using System.Data.Common;
using System.Net.Sockets;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using MySqlConnector;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using PropertyTax.API.Data;
using PropertyTax.API.DTOs;
using PropertyTax.API.Models;
using PropertyTax.API.Services;

const uint DatabaseConnectionTimeoutSeconds = 60;
const string DatabaseUnreachableMessage = "Database is not reachable from the application host.";

var builder = WebApplication.CreateBuilder(args);
var listenPort = ResolveListenPort(builder.Configuration);

if (listenPort.HasValue && string.IsNullOrWhiteSpace(builder.Configuration["ASPNETCORE_URLS"]))
{
    builder.WebHost.ConfigureKestrel(options =>
    {
        options.ListenAnyIP(listenPort.Value);
    });
}

var configuredConnectionString = ResolveConnectionString(builder.Configuration);
var connectionString = CreateMySqlConnectionString(configuredConnectionString);
var databaseServerVersion = ResolveDatabaseServerVersion(builder.Configuration);

var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException("Missing JWT key.");

if (Encoding.UTF8.GetByteCount(jwtKey) < 32)
{
    throw new InvalidOperationException("JWT signing key must be at least 256 bits long.");
}

var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "PropertyTax.API";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "PropertyTax.Client";
var frontendBaseUrl = ResolveFrontendBaseUrl(builder.Configuration);
var corsOrigins = ResolveCorsOrigins(builder.Configuration, frontendBaseUrl);
var maxUploadBytes = long.TryParse(builder.Configuration["FileStorage:MaxUploadBytes"], out var configuredMaxUploadBytes)
    ? configuredMaxUploadBytes
    : 10 * 1024 * 1024;
var uploadRootPath = ResolveUploadRootPath(builder.Environment.ContentRootPath, builder.Configuration["FileStorage:UploadRoot"]);
var dataProtectionKeyPath = ResolveDataProtectionKeyPath(
    builder.Environment.ContentRootPath,
    builder.Configuration["DataProtection:KeyPath"],
    uploadRootPath);
var requireConnectionOnStartup = builder.Configuration.GetValue(
    "Database:RequireConnectionOnStartup",
    builder.Environment.IsDevelopment());
var runInitializationOnStartup = builder.Environment.IsDevelopment()
    && builder.Configuration.GetValue("Database:RunInitializationOnStartup", false);

Directory.CreateDirectory(uploadRootPath);
Directory.CreateDirectory(dataProtectionKeyPath);

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(
        connectionString,
        databaseServerVersion,
        mySqlOptions =>
        {
            mySqlOptions.EnableRetryOnFailure(
                5,
                TimeSpan.FromSeconds(10),
                null
            );
        });

    if (builder.Environment.IsDevelopment())
{
    options.EnableDetailedErrors();
}
});

builder.Services.AddIdentityCore<ApplicationUser>(options =>
    {
        options.Password.RequiredLength = 8;
        options.Password.RequireDigit = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireUppercase = true;
        options.Password.RequireNonAlphanumeric = true;
        options.Password.RequiredUniqueChars = 1;
        options.User.RequireUniqueEmail = true;
        options.Lockout.AllowedForNewUsers = true;
        options.Lockout.MaxFailedAccessAttempts = 5;
        options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
        options.ClaimsIdentity.UserIdClaimType = System.Security.Claims.ClaimTypes.NameIdentifier;
        options.ClaimsIdentity.UserNameClaimType = System.Security.Claims.ClaimTypes.Name;
        options.ClaimsIdentity.RoleClaimType = System.Security.Claims.ClaimTypes.Role;
    })
    .AddRoles<IdentityRole>()
    .AddEntityFrameworkStores<AppDbContext>()
    .AddDefaultTokenProviders();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            NameClaimType = System.Security.Claims.ClaimTypes.Name,
            RoleClaimType = System.Security.Claims.ClaimTypes.Role,
            ClockSkew = TimeSpan.Zero,
        };
    });

builder.Services.AddAuthorization();

if (corsOrigins.Length > 0)
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("Frontend", policy =>
        {
            policy.WithOrigins(corsOrigins)
                .WithHeaders("Authorization", "Content-Type", "Accept")
                .WithMethods("GET", "POST", "PUT", "DELETE", "OPTIONS");
        });
    });
}

builder.Services.Configure<FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = maxUploadBytes;
});

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

builder.Services.AddDataProtection()
    .SetApplicationName("PropertyTax.API")
    .PersistKeysToFileSystem(new DirectoryInfo(dataProtectionKeyPath));

builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Values
                .SelectMany(value => value.Errors)
                .Select(error => string.IsNullOrWhiteSpace(error.ErrorMessage) ? "Invalid request payload." : error.ErrorMessage)
                .ToArray();

            return new BadRequestObjectResult(ApiResponse<object?>.Fail("Validation failed.", errors));
        };
    });

builder.Services.AddHttpContextAccessor();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "PropertyTax.API",
        Version = "v1",
        Description = "Property Tax Web API",
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Description = "Enter a valid Bearer token.",
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer",
                },
            },
            Array.Empty<string>()
        }
    });
});

builder.Services.AddScoped<DbInitializer>();
builder.Services.AddScoped<SampleDataSeeder>();
builder.Services.AddScoped<AuditLogService>();
builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<PropertyService>();
builder.Services.AddScoped<LocationService>();
builder.Services.AddScoped<TaxService>();
builder.Services.AddScoped<PaymentService>();

var app = builder.Build();

if (corsOrigins.Length == 0)
{
    app.Logger.LogWarning(
    "No CORS origins are configured. Browser clients will remain blocked until FrontendBaseUrl, FRONTEND_BASE_URL, Cors:AllowedOrigins, or CORS_ALLOWED_ORIGINS is set.");
}

app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
        var logger = context.RequestServices.GetRequiredService<ILoggerFactory>()
            .CreateLogger("GlobalExceptionHandler");

        if (exception is not null)
        {
            logger.LogError(exception, "Unhandled exception while processing {Method} {Path}", context.Request.Method, context.Request.Path);
        }

        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
        context.Response.ContentType = "application/json";

        var response = ApiResponse<object?>.Fail("An unexpected server error occurred.");

        await context.Response.WriteAsJsonAsync(response);
    });
});

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseForwardedHeaders();

if (!app.Environment.IsDevelopment() && !listenPort.HasValue)
{
    app.UseHttpsRedirection();
}

app.UseRouting();

if (corsOrigins.Length > 0)
{
    app.UseCors("Frontend");
}

app.UseAuthentication();
app.UseAuthorization();

using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>().CreateLogger("Startup");

    try
    {
        var dbTest = await TestDatabaseConnectionAsync(connectionString, CancellationToken.None);

        if (!dbTest.Success)
        {
            if (requireConnectionOnStartup)
            {
                logger.LogError(
                    "Database startup validation failed: {Message}. Reason: {FailureReason}",
                    dbTest.Message,
                    dbTest.FailureReason ?? "No additional error detail was returned.");

                throw new InvalidOperationException(dbTest.Message);
            }

            logger.LogWarning(
                "Database startup validation failed: {Message}. Reason: {FailureReason}. The application will continue because Database:RequireConnectionOnStartup is disabled by configuration.",
                dbTest.Message,
                dbTest.FailureReason ?? "No additional error detail was returned.");
        }
        else
        {
            logger.LogInformation("Database connection established. Server version: {ServerVersion}", dbTest.ServerVersion);

            if (runInitializationOnStartup)
            {
                var init = scope.ServiceProvider.GetRequiredService<DbInitializer>();
                await init.InitializeAsync();
            }
            else
            {
                logger.LogInformation("Database initialization on startup is disabled by configuration.");
            }
        }
    }
    catch (Exception exception)
    {
        logger.LogCritical(exception, "Database startup validation failed. Application will stop.");
        throw;
    }
}

app.MapGet("/api/db-test", async (CancellationToken cancellationToken) =>
{
    var dbTest = await TestDatabaseConnectionAsync(connectionString, cancellationToken);
    var response = new
    {
        success = dbTest.Success,
        message = dbTest.Message,
        serverVersion = dbTest.ServerVersion,
    };

    return dbTest.Success
        ? Results.Ok(response)
        : Results.Json(response, statusCode: StatusCodes.Status503ServiceUnavailable);
});

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.MapControllers();
app.Run();

static string? ResolveFrontendBaseUrl(IConfiguration configuration)
{
    var candidates = new[]
    {
        configuration["FrontendBaseUrl"],
        configuration["FRONTEND_BASE_URL"],
        configuration["PUBLIC_FRONTEND_URL"],
    };

    foreach (var candidate in candidates)
    {
        if (!string.IsNullOrWhiteSpace(candidate))
        {
            return candidate.Trim().TrimEnd('/');
        }
    }

    return null;
}

static string[] ResolveCorsOrigins(IConfiguration configuration, string? fallbackOrigin)
{
    var configuredOrigins = configuration.GetSection("Cors:AllowedOrigins")
        .Get<string[]>()?
        .Where(origin => !string.IsNullOrWhiteSpace(origin))
        .Select(origin => origin.TrimEnd('/'))
        .Distinct(StringComparer.OrdinalIgnoreCase)
        .ToArray();

    if (configuredOrigins is { Length: > 0 })
    {
        return configuredOrigins;
    }

    var inlineConfiguredOrigins = ParseDelimitedValues(
            configuration["Cors:AllowedOrigins"],
            configuration["CORS_ALLOWED_ORIGINS"])
        .Select(origin => origin.TrimEnd('/'))
        .Distinct(StringComparer.OrdinalIgnoreCase)
        .ToArray();

    if (inlineConfiguredOrigins.Length > 0)
    {
        return inlineConfiguredOrigins;
    }

    if (!string.IsNullOrWhiteSpace(fallbackOrigin))
    {
        return [fallbackOrigin];
    }

    return [];
}

static string ResolveUploadRootPath(string contentRootPath, string? configuredUploadRoot)
{
    if (!string.IsNullOrWhiteSpace(configuredUploadRoot))
    {
        return ResolvePath(contentRootPath, configuredUploadRoot);
    }

    if (Directory.Exists("/var/data"))
    {
        return "/var/data/uploads";
    }

    var uploadRoot = "uploads";

    return Path.GetFullPath(Path.Combine(contentRootPath, uploadRoot));
}

static string ResolveDataProtectionKeyPath(string contentRootPath, string? configuredKeyPath, string uploadRootPath)
{
    if (!string.IsNullOrWhiteSpace(configuredKeyPath))
    {
        return ResolvePath(contentRootPath, configuredKeyPath);
    }

    if (Directory.Exists("/var/data"))
    {
        return "/var/data/data-protection-keys";
    }

    return Path.GetFullPath(Path.Combine(uploadRootPath, ".keys"));
}

static string ResolvePath(string contentRootPath, string configuredPath)
{
    return Path.IsPathRooted(configuredPath)
        ? Path.GetFullPath(configuredPath)
        : Path.GetFullPath(Path.Combine(contentRootPath, configuredPath));
}

static IEnumerable<string> ParseDelimitedValues(params string?[] candidates)
{
    foreach (var candidate in candidates)
    {
        if (string.IsNullOrWhiteSpace(candidate))
        {
            continue;
        }

        foreach (var value in candidate.Split([',', ';', '\n', '\r'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            if (!string.IsNullOrWhiteSpace(value))
            {
                yield return value;
            }
        }
    }
}

static int? ResolveListenPort(IConfiguration configuration)
{
    var configuredPort = configuration["PORT"];

    if (string.IsNullOrWhiteSpace(configuredPort))
    {
        return null;
    }

    if (!int.TryParse(configuredPort, out var port) || port is < 1 or > 65535)
    {
        throw new InvalidOperationException("The PORT environment variable must be a valid TCP port number.");
    }

    return port;
}

static string ResolveConnectionString(IConfiguration configuration)
{
    var candidates = new[]
    {
        configuration.GetConnectionString("DefaultConnection"),
        configuration["ConnectionStrings:DefaultConnection"],
        configuration["DefaultConnection"],
        configuration["DATABASE_URL"],
    };

    foreach (var candidate in candidates)
    {
        if (!string.IsNullOrWhiteSpace(candidate))
        {
            return candidate;
        }
    }

    throw new InvalidOperationException(
        "Missing connection string. Set ConnectionStrings:DefaultConnection or ConnectionStrings__DefaultConnection, or provide DATABASE_URL in MySQL connection-string or mysql:// form.");
}

static ServerVersion ResolveDatabaseServerVersion(IConfiguration configuration)
{
    var configuredVersion = configuration["Database:ServerVersion"];

    if (string.IsNullOrWhiteSpace(configuredVersion))
    {
        return new MySqlServerVersion(new Version(8, 0, 36));
    }

    if (!Version.TryParse(configuredVersion, out var parsedVersion))
    {
        throw new InvalidOperationException("Database:ServerVersion must be a valid semantic version such as 8.0.36 or 10.11.15.");
    }

    var databaseEngine = configuration["Database:Engine"];

    return string.Equals(databaseEngine, "MariaDb", StringComparison.OrdinalIgnoreCase)
        || string.Equals(databaseEngine, "MariaDB", StringComparison.OrdinalIgnoreCase)
        ? new MariaDbServerVersion(parsedVersion)
        : new MySqlServerVersion(parsedVersion);
}

static string CreateMySqlConnectionString(string configuredConnectionString)
{
    var normalizedConnectionString = NormalizeMySqlConnectionString(configuredConnectionString);
    var connectionStringBuilder = new MySqlConnectionStringBuilder(normalizedConnectionString);

    if (!ContainsConnectionOption(normalizedConnectionString, "ConnectionTimeout", "Connection Timeout", "Connect Timeout"))
    {
        connectionStringBuilder.ConnectionTimeout = DatabaseConnectionTimeoutSeconds;
    }

    if (!ContainsConnectionOption(normalizedConnectionString, "DefaultCommandTimeout", "Default Command Timeout"))
    {
        connectionStringBuilder.DefaultCommandTimeout = DatabaseConnectionTimeoutSeconds;
    }

    if (!ContainsConnectionOption(normalizedConnectionString, "SslMode", "Ssl Mode"))
    {
        connectionStringBuilder.SslMode = MySqlSslMode.Preferred;
    }

    return connectionStringBuilder.ConnectionString;
}

static string NormalizeMySqlConnectionString(string configuredConnectionString)
{
    if (!Uri.TryCreate(configuredConnectionString, UriKind.Absolute, out var databaseUrl)
        || (!string.Equals(databaseUrl.Scheme, "mysql", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(databaseUrl.Scheme, "mariadb", StringComparison.OrdinalIgnoreCase)))
    {
        return configuredConnectionString;
    }

    if (string.IsNullOrWhiteSpace(databaseUrl.Host))
    {
        throw new InvalidOperationException("DATABASE_URL must include a database host.");
    }

    var credentials = databaseUrl.UserInfo.Split(':', 2, StringSplitOptions.None);
    var connectionStringBuilder = new MySqlConnectionStringBuilder
    {
        Server = databaseUrl.Host,
        Port = databaseUrl.Port > 0 ? checked((uint)databaseUrl.Port) : 3306u,
        UserID = credentials.Length > 0 ? Uri.UnescapeDataString(credentials[0]) : string.Empty,
        Password = credentials.Length > 1 ? Uri.UnescapeDataString(credentials[1]) : string.Empty,
    };

    var databaseName = databaseUrl.AbsolutePath.Trim('/');

    if (!string.IsNullOrWhiteSpace(databaseName))
    {
        connectionStringBuilder.Database = Uri.UnescapeDataString(databaseName);
    }

    foreach (var queryParameter in QueryHelpers.ParseQuery(databaseUrl.Query))
    {
        var value = queryParameter.Value.ToString();

        if (string.IsNullOrWhiteSpace(value))
        {
            continue;
        }

        try
        {
            connectionStringBuilder[queryParameter.Key] = value;
        }
        catch (ArgumentException exception)
        {
            throw new InvalidOperationException(
                $"DATABASE_URL includes unsupported MySQL option '{queryParameter.Key}'.",
                exception);
        }
    }

    return connectionStringBuilder.ConnectionString;
}

static bool ContainsConnectionOption(string connectionString, params string[] optionNames)
{
    if (Uri.TryCreate(connectionString, UriKind.Absolute, out var databaseUrl)
        && (string.Equals(databaseUrl.Scheme, "mysql", StringComparison.OrdinalIgnoreCase)
            || string.Equals(databaseUrl.Scheme, "mariadb", StringComparison.OrdinalIgnoreCase)))
    {
        var queryParameterNames = QueryHelpers.ParseQuery(databaseUrl.Query)
            .Keys
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        return optionNames.Any(queryParameterNames.Contains);
    }

    var connectionStringBuilder = new DbConnectionStringBuilder
    {
        ConnectionString = connectionString,
    };

    return optionNames.Any(connectionStringBuilder.ContainsKey);
}

static async Task<DatabaseConnectionTestResult> TestDatabaseConnectionAsync(
    string connectionString,
    CancellationToken cancellationToken)
{
    try
    {
        await using var connection = new MySqlConnection(connectionString);
        await connection.OpenAsync(cancellationToken);

        return new DatabaseConnectionTestResult(
            Success: true,
            Message: "Database connection successful.",
            ServerVersion: connection.ServerVersion,
            FailureReason: null);
    }
    catch (Exception exception)
    {
        var message = IsReachabilityFailure(exception)
            ? DatabaseUnreachableMessage
            : "Database connection failed.";

        return new DatabaseConnectionTestResult(
            Success: false,
            Message: message,
            ServerVersion: null,
            FailureReason: exception.Message);
    }
}

static bool IsReachabilityFailure(Exception exception)
{
    return exception is TimeoutException
        || exception is SocketException
        || exception.Message.Contains("Unable to connect to any of the specified MySQL hosts", StringComparison.OrdinalIgnoreCase)
        || exception.Message.Contains("timeout", StringComparison.OrdinalIgnoreCase)
        || exception.Message.Contains("No such host is known", StringComparison.OrdinalIgnoreCase)
        || exception.Message.Contains("actively refused", StringComparison.OrdinalIgnoreCase)
        || (exception.InnerException is not null && IsReachabilityFailure(exception.InnerException));
}

internal sealed record DatabaseConnectionTestResult(
    bool Success,
    string Message,
    string? ServerVersion,
    string? FailureReason);
