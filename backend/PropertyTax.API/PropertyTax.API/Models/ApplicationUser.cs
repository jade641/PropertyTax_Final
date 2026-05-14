using Microsoft.AspNetCore.Identity;

namespace PropertyTax.API.Models;

public class ApplicationUser : IdentityUser
{
    public string FullName { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;
}

public static class SystemRoles
{
    public const string Admin = "Admin";
    public const string Staff = "Staff";
    public const string Accountant = "Accountant";
    public const string Auditor = "Auditor";

    public static readonly string[] All =
    {
        Admin,
        Staff,
        Accountant,
        Auditor
    };
}