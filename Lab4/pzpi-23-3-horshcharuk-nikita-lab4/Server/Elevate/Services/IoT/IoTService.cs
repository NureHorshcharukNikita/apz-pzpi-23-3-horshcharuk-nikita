using Elevate.Data;
using Elevate.Dtos.Actions;
using Elevate.Dtos.IoT;
using Elevate.Dtos.Teams;
using Elevate.Entities;
using Elevate.Mappings.IoT;
using Elevate.Services.Actions;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.IoT;

public class IoTService : IIoTService
{
    private readonly ElevateDbContext _dbContext;
    private readonly IActionEventService _actionEventService;

    public IoTService(
        ElevateDbContext dbContext,
        IActionEventService actionEventService)
    {
        _dbContext = dbContext;
        _actionEventService = actionEventService;
    }

    public async Task<IotScanResultDto> ProcessScanAsync(
        string deviceKey,
        int userId,
        CancellationToken cancellationToken)
    {
        var device = await GetDeviceAsync(deviceKey, cancellationToken);

        var user = await _dbContext.Users
            .FirstOrDefaultAsync(u => u.UserID == userId, cancellationToken);

        if (user == null)
            throw new InvalidOperationException("User not found");

        var teamMember = await _dbContext.TeamMembers
            .Include(tm => tm.TeamLevel)
            .FirstOrDefaultAsync(tm => tm.TeamID == device.TeamID && tm.UserID == userId, cancellationToken)
            ?? throw new InvalidOperationException("User is not a member of device team");

        var scan = new DeviceScan
        {
            DeviceID = device.DeviceID,
            TeamID = device.TeamID,
            UserID = user.UserID,
            ScannedAt = DateTime.UtcNow
        };

        _dbContext.DeviceScans.Add(scan);

        device.LastSeenAt = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);

        var recentBadges = await _dbContext.UserTeamBadges
            .AsNoTracking()
            .Include(utb => utb.TeamBadge)
            .Where(utb => utb.TeamID == device.TeamID && utb.UserID == user.UserID)
            .OrderByDescending(utb => utb.AwardedAt)
            .Take(5)
            .Select(utb => utb.TeamBadge.Name)
            .ToListAsync(cancellationToken);

        return new IotScanResultDto
        {
            UserId = userId,
            TeamId = device.TeamID,
            FullName = $"{user.FirstName} {user.LastName}",
            TeamPoints = teamMember.TeamPoints,
            TeamLevelName = teamMember.TeamLevel?.Name,
            RecentBadges = recentBadges
        };
    }

    public async Task<DeviceScanResponseDto> ProcessScanAsync(
        DeviceScanRequestDto dto,
        CancellationToken cancellationToken)
    {
        var device = await GetDeviceAsync(dto.DeviceKey, cancellationToken);
        var membership = await GetMembershipAsync(device.TeamID, dto.UserId, cancellationToken);

        var deviceScan = new DeviceScan
        {
            DeviceID = device.DeviceID,
            TeamID = device.TeamID,
            UserID = dto.UserId
        };

        _dbContext.DeviceScans.Add(deviceScan);

        if (!string.IsNullOrWhiteSpace(dto.ActionCode))
        {
            await TryCreateActionEventAsync(dto, device, cancellationToken);
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        var updatedMembership = await GetMembershipAsync(device.TeamID, dto.UserId, cancellationToken);
        var recentBadges = await GetRecentBadgesAsync(device.TeamID, dto.UserId, cancellationToken);

        return IoTMappings.ToDeviceScanResponseDto(updatedMembership!, recentBadges);
    }

    public async Task<IReadOnlyCollection<LeaderboardEntryDto>> GetLeaderboardAsync(
        int teamId,
        CancellationToken cancellationToken)
    {
        var members = await _dbContext.TeamMembers
            .AsNoTracking()
            .Where(tm => tm.TeamID == teamId)
            .Include(tm => tm.User)
            .Include(tm => tm.TeamLevel)
            .OrderByDescending(tm => tm.TeamPoints)
            .Take(5)
            .ToListAsync(cancellationToken);

        return members
            .Select((tm, index) => IoTMappings.ToLeaderboardEntryDto(tm, index + 1))
            .ToArray();
    }

    public async Task<IReadOnlyCollection<LeaderboardEntryDto>> GetLeaderboardByDeviceKeyAsync(
        string deviceKey,
        CancellationToken cancellationToken)
    {
        var device = await GetDeviceAsync(deviceKey, cancellationToken);
        return await GetLeaderboardAsync(device.TeamID, cancellationToken);
    }

    private async Task<Device> GetDeviceAsync(string key, CancellationToken ct)
    {
        var device = await _dbContext.Devices
            .AsNoTracking()
            .Include(d => d.Team)
            .FirstOrDefaultAsync(d => d.DeviceKey == key && d.IsActive, ct);

        return device ?? throw new InvalidOperationException("Unknown device");
    }

    private async Task<TeamMember?> GetMembershipAsync(int teamId, int userId, CancellationToken ct)
    {
        return await _dbContext.TeamMembers
            .AsNoTracking()
            .Include(tm => tm.TeamLevel)
            .Include(tm => tm.Team)
            .Include(tm => tm.User)
            .FirstOrDefaultAsync(tm => tm.TeamID == teamId && tm.UserID == userId, ct)
            ?? throw new UnauthorizedAccessException("User is not part of the device team");
    }

    private async Task TryCreateActionEventAsync(
        DeviceScanRequestDto dto,
        Device device,
        CancellationToken ct)
    {
        var actionType = await _dbContext.ActionTypes
            .AsNoTracking()
            .FirstOrDefaultAsync(
                at => at.TeamID == device.TeamID && at.Code == dto.ActionCode,
                ct);

        if (actionType is null)
            return;

        await _actionEventService.CreateActionEventAsync(
            new CreateActionEventDto
            {
                UserId = dto.UserId,
                TeamId = device.TeamID,
                ActionTypeId = actionType.ActionTypeID,
                SourceType = "IoT",
                Comment = $"IoT device {device.Name}"
            },
            authenticatedUserId: null,
            cancellationToken: ct);
    }

    private async Task<IReadOnlyCollection<string>> GetRecentBadgesAsync(
        int teamId,
        int userId,
        CancellationToken ct)
    {
        return await _dbContext.UserTeamBadges
            .AsNoTracking()
            .Where(utb => utb.TeamID == teamId && utb.UserID == userId)
            .OrderByDescending(utb => utb.AwardedAt)
            .Take(5)
            .Select(utb => utb.TeamBadge.Name)
            .ToListAsync(ct);
    }

    public async Task SaveDeviceStatsAsync(
        IotDeviceStatsDto stats,
        CancellationToken cancellationToken)
    {
        var device = await GetDeviceAsync(stats.DeviceKey, cancellationToken);

        device.LastSeenAt = DateTime.UtcNow;

        var today = DateTime.UtcNow.Date;
        var todayEnd = today.AddDays(1);

        var existingStats = await _dbContext.DeviceStatistics
            .FirstOrDefaultAsync(
                ds => ds.DeviceID == device.DeviceID &&
                      ds.RecordedAt >= today &&
                      ds.RecordedAt < todayEnd,
                cancellationToken);

        if (existingStats != null)
        {
            existingStats.RecordedAt = DateTime.UtcNow;

            existingStats.TotalScans = stats.TotalScans;
            existingStats.SuccessfulScans = stats.SuccessfulScans;
            existingStats.FailedScans = stats.FailedScans;
            existingStats.DailyScans = stats.DailyScans;

            int totalCount = existingStats.TotalScans > 0 ? existingStats.TotalScans : 1;
            existingStats.SuccessRate = (float)existingStats.SuccessfulScans * 100.0f / totalCount;

            existingStats.AverageScansPerHour = stats.AverageScansPerHour;
            existingStats.DeviceEfficiency = stats.DeviceEfficiency;
            existingStats.PeakHour = stats.PeakHour;
            existingStats.ActivityTrend = stats.ActivityTrend;
            existingStats.UptimeMs = stats.UptimeMs;
        }
        else
        {
            var deviceStats = new DeviceStatistics
            {
                DeviceID = device.DeviceID,
                TeamID = device.TeamID,
                RecordedAt = DateTime.UtcNow,
                TotalScans = stats.TotalScans,
                SuccessfulScans = stats.SuccessfulScans,
                FailedScans = stats.FailedScans,
                DailyScans = stats.DailyScans,
                AverageScansPerHour = stats.AverageScansPerHour,
                SuccessRate = stats.SuccessRate,
                DeviceEfficiency = stats.DeviceEfficiency,
                PeakHour = stats.PeakHour,
                ActivityTrend = stats.ActivityTrend,
                UptimeMs = stats.UptimeMs
            };

            _dbContext.DeviceStatistics.Add(deviceStats);
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IotDeviceStatsDto?> GetTodayDeviceStatsAsync(
        string deviceKey,
        CancellationToken cancellationToken)
    {
        var device = await GetDeviceAsync(deviceKey, cancellationToken);

        var today = DateTime.UtcNow.Date;
        var todayEnd = today.AddDays(1);

        var stats = await _dbContext.DeviceStatistics
            .AsNoTracking()
            .Where(ds => ds.DeviceID == device.DeviceID &&
                        ds.RecordedAt >= today &&
                        ds.RecordedAt < todayEnd)
            .OrderByDescending(ds => ds.RecordedAt)
            .FirstOrDefaultAsync(cancellationToken);

        if (stats == null)
        {
            return null;
        }

        return new IotDeviceStatsDto
        {
            DeviceKey = deviceKey,
            TotalScans = stats.TotalScans,
            SuccessfulScans = stats.SuccessfulScans,
            FailedScans = stats.FailedScans,
            DailyScans = stats.DailyScans,
            AverageScansPerHour = stats.AverageScansPerHour,
            SuccessRate = stats.SuccessRate,
            DeviceEfficiency = stats.DeviceEfficiency,
            PeakHour = stats.PeakHour,
            ActivityTrend = stats.ActivityTrend,
            UptimeMs = stats.UptimeMs
        };
    }

    public async Task<IReadOnlyCollection<TeamLevelDto>> GetTeamLevelsAsync(
        int teamId,
        CancellationToken cancellationToken)
    {
        var levels = await _dbContext.TeamLevels
            .AsNoTracking()
            .Where(l => l.TeamID == teamId)
            .OrderBy(l => l.OrderIndex)
            .Select(l => new TeamLevelDto
            {
                Id = l.TeamLevelID,
                Name = l.Name,
                RequiredPoints = l.RequiredPoints,
                OrderIndex = l.OrderIndex
            })
            .ToListAsync(cancellationToken);

        return levels;
    }

    public async Task<IReadOnlyCollection<TeamLevelDto>> GetTeamLevelsByDeviceKeyAsync(
        string deviceKey,
        CancellationToken cancellationToken)
    {
        var device = await GetDeviceAsync(deviceKey, cancellationToken);
        return await GetTeamLevelsAsync(device.TeamID, cancellationToken);
    }
}
