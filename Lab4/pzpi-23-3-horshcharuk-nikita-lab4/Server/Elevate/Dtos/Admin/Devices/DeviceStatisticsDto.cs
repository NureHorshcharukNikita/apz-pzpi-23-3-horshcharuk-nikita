namespace Elevate.Dtos.Admin.Devices;

public class DeviceStatisticsDto
{
    public int DeviceStatisticsID { get; set; }
    public int DeviceID { get; set; }
    public string DeviceName { get; set; } = null!;
    public int TeamID { get; set; }
    public string TeamName { get; set; } = null!;
    public DateTime RecordedAt { get; set; }

    public int TotalScans { get; set; }
    public int SuccessfulScans { get; set; }
    public int FailedScans { get; set; }
    public int DailyScans { get; set; }

    public float AverageScansPerHour { get; set; }
    public float SuccessRate { get; set; }
    public float DeviceEfficiency { get; set; }

    public int PeakHour { get; set; }
    public int ActivityTrend { get; set; }
    public long UptimeMs { get; set; }

    public TimeSpan Uptime => TimeSpan.FromMilliseconds(UptimeMs);
    public string ActivityTrendDescription => ActivityTrend > 0 ? "Growing" : ActivityTrend < 0 ? "Declining" : "Stable";
}
