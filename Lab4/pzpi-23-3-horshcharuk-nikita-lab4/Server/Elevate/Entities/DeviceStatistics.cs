namespace Elevate.Entities;

public class DeviceStatistics
{
    public int DeviceStatisticsID { get; set; }
    public int DeviceID { get; set; }
    public int TeamID { get; set; }
    public DateTime RecordedAt { get; set; } = DateTime.UtcNow;

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

    public Device Device { get; set; } = null!;
    public Team Team { get; set; } = null!;
}
