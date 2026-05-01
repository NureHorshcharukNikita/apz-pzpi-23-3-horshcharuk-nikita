using Elevate.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Elevate.Data.Configurations;

public class TeamJoinRequestConfiguration : IEntityTypeConfiguration<TeamJoinRequest>
{
    public void Configure(EntityTypeBuilder<TeamJoinRequest> builder)
    {
        builder.ToTable("TeamJoinRequests");
        builder.HasKey(x => x.TeamJoinRequestID);

        builder.Property(x => x.Status).HasMaxLength(32).IsRequired();

        builder.HasOne(x => x.Team)
            .WithMany()
            .HasForeignKey(x => x.TeamID)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserID)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(x => new { x.TeamID, x.UserID, x.Status });
    }
}
