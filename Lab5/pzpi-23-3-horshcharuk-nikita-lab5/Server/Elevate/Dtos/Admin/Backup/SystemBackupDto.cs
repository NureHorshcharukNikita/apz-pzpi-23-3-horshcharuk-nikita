namespace Elevate.Dtos.Admin.Backup;

public class SystemBackupDto
{
    public int Version { get; set; } = 1;
    public DateTime ExportedAtUtc { get; set; }
    public List<BackupUserDto> Users { get; set; } = new();
    public List<BackupTeamDto> Teams { get; set; } = new();
    public List<BackupTeamLevelDto> TeamLevels { get; set; } = new();
    public List<BackupTeamMemberDto> TeamMembers { get; set; } = new();
    public List<BackupActionTypeDto> ActionTypes { get; set; } = new();
    public List<BackupTeamBadgeDto> TeamBadges { get; set; } = new();
    public List<BackupUserTeamBadgeDto> UserTeamBadges { get; set; } = new();
    public List<BackupDeviceDto> Devices { get; set; } = new();
}

public class BackupUserDto
{
    public int UserID { get; set; }
    public string Login { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Role { get; set; } = null!;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }

    public string? PasswordPlain { get; set; }
}

public class BackupTeamDto
{
    public int TeamID { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }
    public int? CreatedByUserID { get; set; }
    public string LevelPointsMode { get; set; } = null!;
    public int? MaxMembers { get; set; }
}

public class BackupTeamLevelDto
{
    public int TeamLevelID { get; set; }
    public int TeamID { get; set; }
    public string Name { get; set; } = null!;
    public int RequiredPoints { get; set; }
    public int OrderIndex { get; set; }
}

public class BackupTeamMemberDto
{
    public int TeamMemberID { get; set; }
    public int TeamID { get; set; }
    public int UserID { get; set; }
    public string TeamRole { get; set; } = null!;
    public int? TeamLevelID { get; set; }
    public int TeamPoints { get; set; }
    public DateTime JoinedAt { get; set; }
}

public class BackupActionTypeDto
{
    public int ActionTypeID { get; set; }
    public int TeamID { get; set; }
    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public int DefaultPoints { get; set; }
    public string? Category { get; set; }
    public bool IsActive { get; set; }
}

public class BackupTeamBadgeDto
{
    public int TeamBadgeID { get; set; }
    public int TeamID { get; set; }
    public string Code { get; set; } = null!;
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public string? IconCode { get; set; }
    public string? ConditionType { get; set; }
    public int? ConditionValue { get; set; }
}

public class BackupUserTeamBadgeDto
{
    public int UserTeamBadgeID { get; set; }
    public int UserID { get; set; }
    public int TeamBadgeID { get; set; }
    public int TeamID { get; set; }
    public DateTime AwardedAt { get; set; }
}

public class BackupDeviceDto
{
    public int DeviceID { get; set; }
    public string Name { get; set; } = null!;
    public int TeamID { get; set; }
    public string DeviceKey { get; set; } = null!;
    public string? Location { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastSeenAt { get; set; }
}

public class ImportBackupRequestDto
{

    public string Mode { get; set; } = "merge";

    public SystemBackupDto Snapshot { get; set; } = null!;
}

public class ImportBackupResultDto
{
    public string Mode { get; set; } = null!;
    public int UsersCreated { get; set; }
    public int TeamsCreated { get; set; }
    public int UsersUpdated { get; set; }
    public int TeamsUpdated { get; set; }
    public int TeamLevelsAdded { get; set; }
    public int TeamLevelsUpdated { get; set; }
    public int TeamMembersAdded { get; set; }
    public int TeamMembersUpdated { get; set; }
    public int ActionTypesAdded { get; set; }
    public int ActionTypesUpdated { get; set; }
    public int BadgesAdded { get; set; }
    public int BadgesUpdated { get; set; }
    public int UserTeamBadgesAdded { get; set; }
    public int UserTeamBadgesUpdated { get; set; }
    public int DevicesAdded { get; set; }
    public int DevicesUpdated { get; set; }

    public string? Message { get; set; }

    public string? MessageKey { get; set; }

    public Dictionary<string, string>? MessageParams { get; set; }
}
