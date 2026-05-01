namespace Elevate.Dtos.Admin.Devices;

public class UpdateDeviceStatisticsRequest
{
    public int? TotalScans { get; set; }
    public int? SuccessfulScans { get; set; }
    public int? FailedScans { get; set; }
    public int? DailyScans { get; set; }
    public float? AverageScansPerHour { get; set; }
    public float? SuccessRate { get; set; }
    public float? DeviceEfficiency { get; set; }
    public int? PeakHour { get; set; }
    public int? ActivityTrend { get; set; }
    public long? UptimeMs { get; set; }
}
