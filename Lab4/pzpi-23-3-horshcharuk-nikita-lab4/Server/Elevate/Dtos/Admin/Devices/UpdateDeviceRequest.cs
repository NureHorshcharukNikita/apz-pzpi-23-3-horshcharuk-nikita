namespace Elevate.Dtos.Admin.Devices;

public record UpdateDeviceRequest(string Name, int TeamId, string? Location);
