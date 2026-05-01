using Elevate.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Elevate.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasIndex(u => u.Login)
            .IsUnique();

        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.Property(u => u.Role)
            .HasDefaultValue("User");

        builder.Property(u => u.Avatar)
            .HasColumnType("varbinary(max)")
            .IsRequired(false);

        builder.Property(u => u.PasswordPlain)
            .HasMaxLength(256)
            .IsRequired(false);
    }
}
