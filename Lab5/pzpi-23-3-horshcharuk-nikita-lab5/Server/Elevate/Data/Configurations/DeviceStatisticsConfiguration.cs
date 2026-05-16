using Elevate.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Elevate.Data.Configurations;

public class DeviceStatisticsConfiguration : IEntityTypeConfiguration<DeviceStatistics>
{
    public void Configure(EntityTypeBuilder<DeviceStatistics> builder)
    {
        builder.HasKey(ds => ds.DeviceStatisticsID);

        builder.HasOne(ds => ds.Device)
            .WithMany()
            .HasForeignKey(ds => ds.DeviceID)
            .OnDelete(DeleteBehavior.Cascade)
            .IsRequired();

        builder.HasOne(ds => ds.Team)
            .WithMany()
            .HasForeignKey(ds => ds.TeamID)
            .OnDelete(DeleteBehavior.NoAction)
            .IsRequired();

        builder.HasIndex(ds => new { ds.DeviceID, ds.RecordedAt });
        builder.HasIndex(ds => ds.RecordedAt);

        builder.Property(ds => ds.RecordedAt)
            .HasDefaultValueSql("SYSUTCDATETIME()");
    }
}
