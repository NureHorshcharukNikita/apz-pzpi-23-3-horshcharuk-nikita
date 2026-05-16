using Elevate.Data;
using Elevate.Dtos.Admin.Devices;
using Elevate.Entities;
using Elevate.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Admin;

public class AdminDeviceService : IAdminDeviceService
{
    private readonly ElevateDbContext _dbContext;

    public AdminDeviceService(ElevateDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    public async Task<Device> CreateDeviceAsync(string name, int teamId, string? location, CancellationToken ct = default)
    {
        var n = name.Trim();
        if (string.IsNullOrWhiteSpace(n))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        var device = new Device
        {
            Name = n,
            TeamID = teamId,
            Location = location,
            DeviceKey = Guid.NewGuid().ToString("N"),
            IsActive = true,
            LastSeenAt = null
        };

        _dbContext.Devices.Add(device);
        await _dbContext.SaveChangesAsync(ct);

        return device;
    }

    public async Task UpdateDeviceAsync(int deviceId, string name, int teamId, string? location, CancellationToken ct = default)
    {
        var device = await _dbContext.Devices.FirstOrDefaultAsync(d => d.DeviceID == deviceId, ct)
                     ?? throw new ClientErrorException("admin.apiErrorDeviceNotFound");

        var teamExists = await _dbContext.Teams.AnyAsync(t => t.TeamID == teamId, ct);
        if (!teamExists)
            throw new ClientErrorException("admin.apiErrorDeviceTeamNotFound");

        var n = name.Trim();
        if (string.IsNullOrWhiteSpace(n))
        {
            throw new ClientErrorException("admin.apiErrorRequiredName");
        }

        device.Name = n;
        device.TeamID = teamId;
        device.Location = location;
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task DeleteDeviceAsync(int deviceId, CancellationToken ct = default)
    {
        var device = await _dbContext.Devices.FirstOrDefaultAsync(d => d.DeviceID == deviceId, ct)
                     ?? throw new ClientErrorException("admin.apiErrorDeviceNotFound");

        _dbContext.Devices.Remove(device);
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task SetDeviceActiveAsync(int deviceId, bool isActive, CancellationToken ct = default)
    {
        var device = await _dbContext.Devices.FirstOrDefaultAsync(d => d.DeviceID == deviceId, ct)
                      ?? throw new ClientErrorException("admin.apiErrorDeviceNotFound");

        device.IsActive = isActive;
        await _dbContext.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<Device>> GetAllDevicesAsync(CancellationToken ct = default)
    {
        return await _dbContext.Devices
            .OrderBy(d => d.DeviceID)
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<DeviceStatisticsDto>> GetDeviceStatisticsAsync(
        int? deviceId,
        int? teamId,
        DateTime? from,
        DateTime? to,
        int? limit,
        CancellationToken ct = default)
    {
        var query = _dbContext.DeviceStatistics
            .AsNoTracking()
            .Include(ds => ds.Device)
            .Include(ds => ds.Team)
            .AsQueryable();

        if (deviceId.HasValue)
        {
            query = query.Where(ds => ds.DeviceID == deviceId.Value);
        }

        if (teamId.HasValue)
        {
            query = query.Where(ds => ds.TeamID == teamId.Value);
        }

        if (from.HasValue)
        {
            query = query.Where(ds => ds.RecordedAt >= from.Value);
        }

        if (to.HasValue)
        {
            query = query.Where(ds => ds.RecordedAt <= to.Value);
        }

        query = query.OrderByDescending(ds => ds.RecordedAt);

        if (limit.HasValue && limit.Value > 0)
        {
            query = query.Take(limit.Value);
        }

        var statistics = await query.ToListAsync(ct);

        return statistics.Select(ds => new DeviceStatisticsDto
        {
            DeviceStatisticsID = ds.DeviceStatisticsID,
            DeviceID = ds.DeviceID,
            DeviceName = ds.Device.Name,
            TeamID = ds.TeamID,
            TeamName = ds.Team.Name,
            RecordedAt = ds.RecordedAt,
            TotalScans = ds.TotalScans,
            SuccessfulScans = ds.SuccessfulScans,
            FailedScans = ds.FailedScans,
            DailyScans = ds.DailyScans,
            AverageScansPerHour = ds.AverageScansPerHour,
            SuccessRate = ds.SuccessRate,
            DeviceEfficiency = ds.DeviceEfficiency,
            PeakHour = ds.PeakHour,
            ActivityTrend = ds.ActivityTrend,
            UptimeMs = ds.UptimeMs
        }).ToList();
    }

    public async Task<DeviceStatisticsDto?> GetLatestDeviceStatisticsAsync(
        int deviceId,
        CancellationToken ct = default)
    {
        var latest = await _dbContext.DeviceStatistics
            .AsNoTracking()
            .Include(ds => ds.Device)
            .Include(ds => ds.Team)
            .Where(ds => ds.DeviceID == deviceId)
            .OrderByDescending(ds => ds.RecordedAt)
            .FirstOrDefaultAsync(ct);

        if (latest == null)
        {
            return null;
        }

        return new DeviceStatisticsDto
        {
            DeviceStatisticsID = latest.DeviceStatisticsID,
            DeviceID = latest.DeviceID,
            DeviceName = latest.Device.Name,
            TeamID = latest.TeamID,
            TeamName = latest.Team.Name,
            RecordedAt = latest.RecordedAt,
            TotalScans = latest.TotalScans,
            SuccessfulScans = latest.SuccessfulScans,
            FailedScans = latest.FailedScans,
            DailyScans = latest.DailyScans,
            AverageScansPerHour = latest.AverageScansPerHour,
            SuccessRate = latest.SuccessRate,
            DeviceEfficiency = latest.DeviceEfficiency,
            PeakHour = latest.PeakHour,
            ActivityTrend = latest.ActivityTrend,
            UptimeMs = latest.UptimeMs
        };
    }

    public async Task UpdateDeviceStatisticsAsync(
        int deviceStatisticsId,
        UpdateDeviceStatisticsRequest request,
        CancellationToken ct = default)
    {
        var stats = await _dbContext.DeviceStatistics
            .FirstOrDefaultAsync(ds => ds.DeviceStatisticsID == deviceStatisticsId, ct)
            ?? throw new InvalidOperationException("Device statistics not found");

        if (request.TotalScans.HasValue)
            stats.TotalScans = request.TotalScans.Value;

        if (request.SuccessfulScans.HasValue)
            stats.SuccessfulScans = request.SuccessfulScans.Value;

        if (request.FailedScans.HasValue)
            stats.FailedScans = request.FailedScans.Value;

        if (request.DailyScans.HasValue)
            stats.DailyScans = request.DailyScans.Value;

        if (request.AverageScansPerHour.HasValue)
            stats.AverageScansPerHour = request.AverageScansPerHour.Value;

        if (request.SuccessRate.HasValue)
            stats.SuccessRate = request.SuccessRate.Value;

        if (request.DeviceEfficiency.HasValue)
            stats.DeviceEfficiency = request.DeviceEfficiency.Value;

        if (request.PeakHour.HasValue)
            stats.PeakHour = request.PeakHour.Value;

        if (request.ActivityTrend.HasValue)
            stats.ActivityTrend = request.ActivityTrend.Value;

        if (request.UptimeMs.HasValue)
            stats.UptimeMs = request.UptimeMs.Value;

        stats.RecordedAt = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(ct);
    }
}
