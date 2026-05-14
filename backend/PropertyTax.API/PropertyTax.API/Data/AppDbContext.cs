using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PropertyTax.API.Models;

namespace PropertyTax.API.Data;

public class AppDbContext : IdentityDbContext<ApplicationUser, IdentityRole, string>
{
    public DbSet<Property> Properties => Set<Property>();
    public DbSet<Taxpayer> Taxpayers => Set<Taxpayer>();
    public DbSet<TaxAssessment> TaxAssessments => Set<TaxAssessment>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<PropertyDocument> PropertyDocuments => Set<PropertyDocument>();
    public DbSet<Province> Provinces => Set<Province>();
    public DbSet<CityMunicipality> CitiesMunicipalities => Set<CityMunicipality>();
    public DbSet<Barangay> Barangays => Set<Barangay>();

    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<ApplicationUser>().ToTable("Users");
        builder.Entity<IdentityRole>().ToTable("Roles");
        builder.Entity<IdentityUserRole<string>>().ToTable("UserRoles");
        builder.Entity<IdentityUserClaim<string>>().ToTable("UserClaims");
        builder.Entity<IdentityUserLogin<string>>().ToTable("UserLogins");
        builder.Entity<IdentityUserToken<string>>().ToTable("UserTokens");
        builder.Entity<IdentityRoleClaim<string>>().ToTable("RoleClaims");

        builder.Entity<Property>(entity =>
        {
            entity.HasIndex(x => x.Pin).IsUnique();
            entity.HasIndex(x => x.TaxDeclarationNumber).IsUnique();
            entity.Property(x => x.TaxDeclarationNumber).HasMaxLength(50);
            entity.Property(x => x.ZoningClassification).HasMaxLength(100);
            entity.Property(x => x.Remarks).HasMaxLength(500);
            entity.Property(x => x.MarketValue).HasPrecision(18, 2);
            entity.Property(x => x.TaxRate).HasPrecision(10, 4);
            entity.Property(x => x.AssessmentLevel).HasPrecision(10, 4);
            entity.Property(x => x.AreaSquareMeters).HasPrecision(18, 2);

            entity.HasOne(x => x.Taxpayer)
                .WithMany(x => x.Properties)
                .HasForeignKey(x => x.TaxpayerId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(x => x.BarangayLocation)
                .WithMany(x => x.Properties)
                .HasForeignKey(x => x.BarangayId)
                .OnDelete(DeleteBehavior.SetNull);
        });

            builder.Entity<Taxpayer>(entity =>
            {
                entity.ToTable("property_owners");
            });

        builder.Entity<Province>(entity =>
        {
            entity.ToTable("provinces");
            entity.HasIndex(x => x.PsgcCode).IsUnique();
            entity.Property(x => x.RegionCode).HasMaxLength(20);
            entity.Property(x => x.PsgcCode).HasMaxLength(20);
            entity.Property(x => x.Name).HasMaxLength(100);
        });

        builder.Entity<CityMunicipality>(entity =>
        {
            entity.ToTable("cities_municipalities");
            entity.HasIndex(x => x.PsgcCode).IsUnique();
            entity.HasIndex(x => new { x.ProvinceId, x.Name });
            entity.Property(x => x.PsgcCode).HasMaxLength(20);
            entity.Property(x => x.Name).HasMaxLength(100);
            entity.Property(x => x.LguType).HasMaxLength(30);

            entity.HasOne(x => x.Province)
                .WithMany(x => x.CitiesMunicipalities)
                .HasForeignKey(x => x.ProvinceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<Barangay>(entity =>
        {
            entity.ToTable("barangays");
            entity.HasIndex(x => x.PsgcCode).IsUnique();
            entity.HasIndex(x => new { x.CityMunicipalityId, x.Name });
            entity.Property(x => x.PsgcCode).HasMaxLength(20);
            entity.Property(x => x.Name).HasMaxLength(100);

            entity.HasOne(x => x.CityMunicipality)
                .WithMany(x => x.Barangays)
                .HasForeignKey(x => x.CityMunicipalityId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<TaxAssessment>(entity =>
        {
            entity.Property(x => x.MarketValue).HasPrecision(18, 2);
            entity.Property(x => x.AssessmentLevel).HasPrecision(10, 4);
            entity.Property(x => x.AssessedValue).HasPrecision(18, 2);
            entity.Property(x => x.TaxRate).HasPrecision(10, 4);
            entity.Property(x => x.TaxDue).HasPrecision(18, 2);

            entity.HasOne(x => x.Property)
                .WithMany(x => x.TaxAssessments)
                .HasForeignKey(x => x.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        builder.Entity<Payment>(entity =>
        {
            entity.HasIndex(x => x.OfficialReceiptNumber).IsUnique();
            entity.Property(x => x.AmountDue).HasPrecision(18, 2);
            entity.Property(x => x.AmountPaid).HasPrecision(18, 2);
            entity.Property(x => x.Penalty).HasPrecision(18, 2);
            entity.Property(x => x.ReferenceNumber).HasMaxLength(100);
            entity.Property(x => x.BankName).HasMaxLength(120);

            entity.HasOne(x => x.Property)
                .WithMany(x => x.Payments)
                .HasForeignKey(x => x.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(x => x.Taxpayer)
                .WithMany(x => x.Payments)
                .HasForeignKey(x => x.TaxpayerId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        builder.Entity<PropertyDocument>(entity =>
        {
            entity.Property(x => x.SizeInBytes).HasColumnType("bigint");

            entity.HasOne(x => x.Property)
                .WithMany(x => x.Documents)
                .HasForeignKey(x => x.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}