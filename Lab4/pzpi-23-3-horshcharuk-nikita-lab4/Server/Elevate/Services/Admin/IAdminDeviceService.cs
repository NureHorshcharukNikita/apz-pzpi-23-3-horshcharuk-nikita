using Elevate.Dtos.Admin.Devices;
using Elevate.Entities;

namespace Elevate.Services.Admin;

public interface IAdminDeviceService
{
    Task<Device> CreateDeviceAsync(string name, int teamId, string? location, CancellationToken ct = default);
    Task UpdateDeviceAsync(int deviceId, string name, int teamId, string? location, CancellationToken ct = default);
    Task DeleteDeviceAsync(int deviceId, CancellationToken ct = default);
    Task SetDeviceActiveAsync(int deviceId, bool isActive, CancellationToken ct = default);
    Task<IReadOnlyList<Device>> GetAllDevicesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<DeviceStatisticsDto>> GetDeviceStatisticsAsync(
        int? deviceId,
        int? teamId,
        DateTime? from,
        DateTime? to,
        int? limit,
        CancellationToken ct = default);

    Task<DeviceStatisticsDto?> GetLatestDeviceStatisticsAsync(
        int deviceId,
        CancellationToken ct = default);

    Task UpdateDeviceStatisticsAsync(
        int deviceStatisticsId,
        UpdateDeviceStatisticsRequest request,
        CancellationToken ct = default);
}
