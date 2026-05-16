using Elevate.Data;
using Elevate.Dtos.Admin.Backup;
using Elevate.Entities;
using Elevate.Exceptions;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Services.Admin;

public class AdminBackupService : IAdminBackupService
{
    private const string ImportDefaultPassword = "Password123!";

    private readonly ElevateDbContext _db;
    private readonly IPasswordHasher<User> _passwordHasher;

    public AdminBackupService(ElevateDbContext db, IPasswordHasher<User> passwordHasher)
    {
        _db = db;
        _passwordHasher = passwordHasher;
    }

    public async Task<SystemBackupDto> ExportAsync(CancellationToken cancellationToken = default)
    {
        var users = await _db.Users.AsNoTracking()
            .Select(u => new BackupUserDto
            {
                UserID = u.UserID,
                Login = u.Login,
                Email = u.Email,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Role = u.Role,
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt,
                LastLoginAt = u.LastLoginAt,
                PasswordPlain = u.PasswordPlain,
            })
            .ToListAsync(cancellationToken);

        var teams = await _db.Teams.AsNoTracking()
            .Select(t => new BackupTeamDto
            {
                TeamID = t.TeamID,
                Name = t.Name,
                Description = t.Description,
                CreatedAt = t.CreatedAt,
                CreatedByUserID = t.CreatedByUserID,
                LevelPointsMode = t.LevelPointsMode.ToString(),
                MaxMembers = t.MaxMembers
            })
            .ToListAsync(cancellationToken);

        var teamLevels = await _db.TeamLevels.AsNoTracking()
            .Select(l => new BackupTeamLevelDto
            {
                TeamLevelID = l.TeamLevelID,
                TeamID = l.TeamID,
                Name = l.Name,
                RequiredPoints = l.RequiredPoints,
                OrderIndex = l.OrderIndex
            })
            .ToListAsync(cancellationToken);

        var teamMembers = await _db.TeamMembers.AsNoTracking()
            .Select(m => new BackupTeamMemberDto
            {
                TeamMemberID = m.TeamMemberID,
                TeamID = m.TeamID,
                UserID = m.UserID,
                TeamRole = m.TeamRole,
                TeamLevelID = m.TeamLevelID,
                TeamPoints = m.TeamPoints,
                JoinedAt = m.JoinedAt
            })
            .ToListAsync(cancellationToken);

        var actionTypes = await _db.ActionTypes.AsNoTracking()
            .Select(a => new BackupActionTypeDto
            {
                ActionTypeID = a.ActionTypeID,
                TeamID = a.TeamID,
                Code = a.Code,
                Name = a.Name,
                Description = a.Description,
                DefaultPoints = a.DefaultPoints,
                Category = a.Category,
                IsActive = a.IsActive
            })
            .ToListAsync(cancellationToken);

        var badges = await _db.TeamBadges.AsNoTracking()
            .Select(b => new BackupTeamBadgeDto
            {
                TeamBadgeID = b.TeamBadgeID,
                TeamID = b.TeamID,
                Code = b.Code,
                Name = b.Name,
                Description = b.Description,
                IconCode = b.IconCode,
                ConditionType = b.ConditionType,
                ConditionValue = b.ConditionValue
            })
            .ToListAsync(cancellationToken);

        var userBadges = await _db.UserTeamBadges.AsNoTracking()
            .Select(ub => new BackupUserTeamBadgeDto
            {
                UserTeamBadgeID = ub.UserTeamBadgeID,
                UserID = ub.UserID,
                TeamBadgeID = ub.TeamBadgeID,
                TeamID = ub.TeamID,
                AwardedAt = ub.AwardedAt
            })
            .ToListAsync(cancellationToken);

        var devices = await _db.Devices.AsNoTracking()
            .Select(d => new BackupDeviceDto
            {
                DeviceID = d.DeviceID,
                Name = d.Name,
                TeamID = d.TeamID,
                DeviceKey = d.DeviceKey,
                Location = d.Location,
                IsActive = d.IsActive,
                LastSeenAt = d.LastSeenAt
            })
            .ToListAsync(cancellationToken);

        return new SystemBackupDto
        {
            Version = 1,
            ExportedAtUtc = DateTime.UtcNow,
            Users = users,
            Teams = teams,
            TeamLevels = teamLevels,
            TeamMembers = teamMembers,
            ActionTypes = actionTypes,
            TeamBadges = badges,
            UserTeamBadges = userBadges,
            Devices = devices
        };
    }

    public async Task<ImportBackupResultDto> ImportAsync(
        ImportBackupRequestDto request,
        CancellationToken cancellationToken = default)
    {
        var snapshot = request.Snapshot ?? throw new ArgumentNullException(nameof(request.Snapshot));
        var mode = (request.Mode ?? "merge").Trim().ToLowerInvariant();

        if (mode == "merge")
        {
            return await MergeConfigurationAsync(snapshot, cancellationToken, upsertMissing: false, resultMode: "merge");
        }

        if (mode == "merge-upsert")
        {
            return await MergeConfigurationAsync(snapshot, cancellationToken, upsertMissing: true, resultMode: "merge-upsert");
        }

        if (mode == "replace-catalog")
        {
            return await ReplaceCatalogFromSnapshotAsync(snapshot, cancellationToken);
        }

        if (mode != "full")
        {
            throw new ClientErrorException("admin.backupErrorUnknownMode");
        }

        if (await _db.Users.AnyAsync(cancellationToken))
        {
            throw new ClientErrorException("admin.backupErrorFullNotEmptyDb");
        }

        return await FullImportAsync(snapshot, cancellationToken);
    }

    private async Task<ImportBackupResultDto> MergeConfigurationAsync(
        SystemBackupDto s,
        CancellationToken ct,
        bool upsertMissing,
        string resultMode)
    {
        var teamsUpdated = 0;
        var usersUpdated = 0;
        var levelsAdded = 0;
        var levelsUpdated = 0;
        var membersAdded = 0;
        var membersUpdated = 0;
        var actionAdded = 0;
        var actionUpdated = 0;
        var badgeAdded = 0;
        var badgeUpdated = 0;
        var userBadgesAdded = 0;
        var userBadgesUpdated = 0;
        var devicesAdded = 0;
        var devicesUpdated = 0;
        var teamsInserted = 0;
        var usersInserted = 0;

        if (upsertMissing)
        {
            (teamsInserted, usersInserted) = await InsertMissingTeamsAndUsersAsync(s, ct);
        }

        foreach (var t in s.Teams)
        {
            var team = await _db.Teams.FirstOrDefaultAsync(x => x.TeamID == t.TeamID, ct);
            if (team == null)
            {
                continue;
            }

            team.Name = t.Name;
            team.Description = t.Description;
            team.CreatedAt = t.CreatedAt;
            if (t.CreatedByUserID.HasValue &&
                await _db.Users.AnyAsync(u => u.UserID == t.CreatedByUserID.Value, ct))
            {
                team.CreatedByUserID = t.CreatedByUserID;
            }

            team.LevelPointsMode = ParseLevelPointsMode(t.LevelPointsMode);
            team.MaxMembers = t.MaxMembers;
            teamsUpdated++;
        }

        foreach (var u in s.Users)
        {
            var user = await _db.Users.FirstOrDefaultAsync(x => x.UserID == u.UserID, ct);
            if (user == null)
            {
                continue;
            }

            var newLogin = (u.Login ?? string.Empty).Trim();
            if (!string.IsNullOrEmpty(newLogin))
            {
                var loginNorm = newLogin.ToLowerInvariant();
                var takenByOther = await _db.Users.AnyAsync(
                    x => x.UserID != user.UserID && x.Login.ToLower() == loginNorm,
                    ct);
                if (!takenByOther)
                {
                    user.Login = newLogin;
                }
            }

            user.Email = u.Email;
            user.FirstName = u.FirstName;
            user.LastName = u.LastName;
            if (u.Role is "User" or "Manager" or "Admin" or "SystemAdministrator")
            {
                user.Role = u.Role;
            }

            user.IsActive = u.IsActive;
            user.LastLoginAt = u.LastLoginAt;
            user.CreatedAt = u.CreatedAt;
            var plain = u.PasswordPlain?.Trim();
            if (!string.IsNullOrEmpty(plain))
            {
                user.PasswordPlain = plain;
                user.PasswordHash = _passwordHasher.HashPassword(user, plain);
            }

            usersUpdated++;
        }

        foreach (var l in s.TeamLevels.OrderBy(x => x.OrderIndex).ThenBy(x => x.TeamLevelID))
        {
            var teamOk = await _db.Teams.AnyAsync(t => t.TeamID == l.TeamID, ct);
            if (!teamOk)
            {
                continue;
            }

            var level = await _db.TeamLevels.FirstOrDefaultAsync(x => x.TeamLevelID == l.TeamLevelID, ct);
            if (level != null)
            {
                level.Name = l.Name;
                level.RequiredPoints = l.RequiredPoints;
                level.OrderIndex = l.OrderIndex;
                levelsUpdated++;
            }
            else
            {
                _db.TeamLevels.Add(new TeamLevel
                {
                    TeamID = l.TeamID,
                    Name = l.Name,
                    RequiredPoints = l.RequiredPoints,
                    OrderIndex = l.OrderIndex
                });
                levelsAdded++;
            }
        }

        foreach (var m in s.TeamMembers)
        {
            var teamOk = await _db.Teams.AnyAsync(t => t.TeamID == m.TeamID, ct);
            var userOk = await _db.Users.AnyAsync(u => u.UserID == m.UserID, ct);
            if (!teamOk || !userOk)
            {
                continue;
            }

            int? levelId = m.TeamLevelID;
            if (levelId.HasValue &&
                !await _db.TeamLevels.AnyAsync(x => x.TeamLevelID == levelId.Value, ct))
            {
                levelId = null;
            }

            var mem = await _db.TeamMembers.FirstOrDefaultAsync(x => x.TeamMemberID == m.TeamMemberID, ct);
            if (mem != null)
            {
                mem.TeamRole = string.IsNullOrWhiteSpace(m.TeamRole) ? "Member" : m.TeamRole.Trim();
                mem.TeamLevelID = levelId;
                mem.TeamPoints = m.TeamPoints;
                mem.JoinedAt = m.JoinedAt;
                membersUpdated++;
            }
            else
            {
                var dup = await _db.TeamMembers.AnyAsync(
                    x => x.TeamID == m.TeamID && x.UserID == m.UserID,
                    ct);
                if (dup)
                {
                    continue;
                }

                _db.TeamMembers.Add(new TeamMember
                {
                    TeamID = m.TeamID,
                    UserID = m.UserID,
                    TeamRole = string.IsNullOrWhiteSpace(m.TeamRole) ? "Member" : m.TeamRole.Trim(),
                    TeamLevelID = levelId,
                    TeamPoints = m.TeamPoints,
                    JoinedAt = m.JoinedAt
                });
                membersAdded++;
            }
        }

        foreach (var at in s.ActionTypes)
        {
            if (!await _db.Teams.AnyAsync(t => t.TeamID == at.TeamID, ct))
            {
                continue;
            }

            var existing = await _db.ActionTypes
                .FirstOrDefaultAsync(x => x.TeamID == at.TeamID && x.Code == at.Code, ct);
            if (existing != null)
            {
                existing.Name = at.Name;
                existing.Description = at.Description;
                existing.DefaultPoints = at.DefaultPoints;
                existing.Category = at.Category;
                existing.IsActive = at.IsActive;
                actionUpdated++;
            }
            else
            {
                _db.ActionTypes.Add(new ActionType
                {
                    TeamID = at.TeamID,
                    Code = at.Code,
                    Name = at.Name,
                    Description = at.Description,
                    DefaultPoints = at.DefaultPoints,
                    Category = at.Category,
                    IsActive = at.IsActive
                });
                actionAdded++;
            }
        }

        foreach (var b in s.TeamBadges)
        {
            if (!await _db.Teams.AnyAsync(t => t.TeamID == b.TeamID, ct))
            {
                continue;
            }

            var existing = await _db.TeamBadges
                .FirstOrDefaultAsync(x => x.TeamID == b.TeamID && x.Code == b.Code, ct);
            if (existing != null)
            {
                existing.Name = b.Name;
                existing.Description = b.Description;
                existing.IconCode = b.IconCode;
                existing.ConditionType = b.ConditionType;
                existing.ConditionValue = b.ConditionValue;
                badgeUpdated++;
            }
            else
            {
                _db.TeamBadges.Add(new TeamBadge
                {
                    TeamID = b.TeamID,
                    Code = b.Code,
                    Name = b.Name,
                    Description = b.Description,
                    IconCode = b.IconCode,
                    ConditionType = b.ConditionType,
                    ConditionValue = b.ConditionValue
                });
                badgeAdded++;
            }
        }

        foreach (var ub in s.UserTeamBadges)
        {
            var row = await _db.UserTeamBadges.FirstOrDefaultAsync(x => x.UserTeamBadgeID == ub.UserTeamBadgeID, ct);
            if (row != null)
            {
                row.AwardedAt = ub.AwardedAt;
                userBadgesUpdated++;
                continue;
            }

            var userOk = await _db.Users.AnyAsync(u => u.UserID == ub.UserID, ct);
            var teamOk = await _db.Teams.AnyAsync(t => t.TeamID == ub.TeamID, ct);
            var badgeOk = await _db.TeamBadges.AnyAsync(b => b.TeamBadgeID == ub.TeamBadgeID, ct);
            if (!userOk || !teamOk || !badgeOk)
            {
                continue;
            }

            var dup = await _db.UserTeamBadges.AnyAsync(
                x => x.UserID == ub.UserID && x.TeamBadgeID == ub.TeamBadgeID && x.TeamID == ub.TeamID,
                ct);
            if (dup)
            {
                continue;
            }

            _db.UserTeamBadges.Add(new UserTeamBadge
            {
                UserID = ub.UserID,
                TeamBadgeID = ub.TeamBadgeID,
                TeamID = ub.TeamID,
                AwardedAt = ub.AwardedAt
            });
            userBadgesAdded++;
        }

        foreach (var d in s.Devices)
        {
            if (!await _db.Teams.AnyAsync(t => t.TeamID == d.TeamID, ct))
            {
                continue;
            }

            var dev = await _db.Devices.FirstOrDefaultAsync(x => x.DeviceID == d.DeviceID, ct);
            if (dev != null)
            {
                dev.Name = d.Name;
                dev.Location = d.Location;
                dev.IsActive = d.IsActive;
                dev.LastSeenAt = d.LastSeenAt;
                dev.TeamID = d.TeamID;
                devicesUpdated++;
            }
            else
            {
                var key = d.DeviceKey;
                if (await _db.Devices.AnyAsync(x => x.DeviceKey == key, ct))
                {
                    key = Guid.NewGuid().ToString("N");
                }

                _db.Devices.Add(new Device
                {
                    Name = d.Name,
                    TeamID = d.TeamID,
                    DeviceKey = key,
                    Location = d.Location,
                    IsActive = d.IsActive,
                    LastSeenAt = d.LastSeenAt
                });
                devicesAdded++;
            }
        }

        await _db.SaveChangesAsync(ct);

        string? messageKey = null;
        if (usersInserted > 0)
        {
            messageKey = "admin.backupResultNewUsersTempPassword";
        }

        return new ImportBackupResultDto
        {
            Mode = resultMode,
            TeamsCreated = teamsInserted,
            UsersCreated = usersInserted,
            TeamsUpdated = teamsUpdated,
            UsersUpdated = usersUpdated,
            MessageKey = messageKey,
            MessageParams = null,
            TeamLevelsAdded = levelsAdded,
            TeamLevelsUpdated = levelsUpdated,
            TeamMembersAdded = membersAdded,
            TeamMembersUpdated = membersUpdated,
            ActionTypesAdded = actionAdded,
            ActionTypesUpdated = actionUpdated,
            BadgesAdded = badgeAdded,
            BadgesUpdated = badgeUpdated,
            UserTeamBadgesAdded = userBadgesAdded,
            UserTeamBadgesUpdated = userBadgesUpdated,
            DevicesAdded = devicesAdded,
            DevicesUpdated = devicesUpdated
        };
    }

    private async Task<ImportBackupResultDto> FullImportAsync(SystemBackupDto s, CancellationToken ct)
    {
        await using var tx = await _db.Database.BeginTransactionAsync(ct);

        var userIdMap = new Dictionary<int, int>();
        foreach (var u in s.Users.OrderBy(x => x.UserID))
        {
            var user = new User
            {
                Login = u.Login,
                Email = u.Email,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Role = u.Role is "User" or "Manager" or "Admin" or "SystemAdministrator" ? u.Role : "User",
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt,
                LastLoginAt = u.LastLoginAt,
                PasswordHash = string.Empty,
            };
            ApplyImportedUserPassword(user, u.PasswordPlain);
            _db.Users.Add(user);
            await _db.SaveChangesAsync(ct);
            userIdMap[u.UserID] = user.UserID;
        }

        var teamIdMap = new Dictionary<int, int>();
        foreach (var t in s.Teams.OrderBy(x => x.TeamID))
        {
            int? createdBy = t.CreatedByUserID.HasValue && userIdMap.TryGetValue(t.CreatedByUserID.Value, out var cb)
                ? cb
                : null;

            var team = new Team
            {
                Name = t.Name,
                Description = t.Description,
                CreatedAt = t.CreatedAt,
                CreatedByUserID = createdBy,
                LevelPointsMode = ParseLevelPointsMode(t.LevelPointsMode),
                MaxMembers = t.MaxMembers
            };
            _db.Teams.Add(team);
            await _db.SaveChangesAsync(ct);
            teamIdMap[t.TeamID] = team.TeamID;
        }

        var levelIdMap = new Dictionary<int, int>();
        foreach (var l in s.TeamLevels.OrderBy(x => x.OrderIndex).ThenBy(x => x.TeamLevelID))
        {
            if (!teamIdMap.TryGetValue(l.TeamID, out var newTeamId))
            {
                continue;
            }

            var level = new TeamLevel
            {
                TeamID = newTeamId,
                Name = l.Name,
                RequiredPoints = l.RequiredPoints,
                OrderIndex = l.OrderIndex
            };
            _db.TeamLevels.Add(level);
            await _db.SaveChangesAsync(ct);
            levelIdMap[l.TeamLevelID] = level.TeamLevelID;
        }

        foreach (var m in s.TeamMembers.OrderBy(x => x.TeamMemberID))
        {
            if (!teamIdMap.TryGetValue(m.TeamID, out var newTeamId)
                || !userIdMap.TryGetValue(m.UserID, out var newUserId))
            {
                continue;
            }

            int? newLevelId = null;
            if (m.TeamLevelID.HasValue && levelIdMap.TryGetValue(m.TeamLevelID.Value, out var nl))
            {
                newLevelId = nl;
            }

            _db.TeamMembers.Add(new TeamMember
            {
                TeamID = newTeamId,
                UserID = newUserId,
                TeamRole = string.IsNullOrWhiteSpace(m.TeamRole) ? "Member" : m.TeamRole,
                TeamLevelID = newLevelId,
                TeamPoints = m.TeamPoints,
                JoinedAt = m.JoinedAt
            });
        }

        await _db.SaveChangesAsync(ct);

        foreach (var at in s.ActionTypes)
        {
            if (!teamIdMap.TryGetValue(at.TeamID, out var newTeamId))
            {
                continue;
            }

            _db.ActionTypes.Add(new ActionType
            {
                TeamID = newTeamId,
                Code = at.Code,
                Name = at.Name,
                Description = at.Description,
                DefaultPoints = at.DefaultPoints,
                Category = at.Category,
                IsActive = at.IsActive
            });
        }

        await _db.SaveChangesAsync(ct);

        var badgeIdMap = new Dictionary<int, int>();
        foreach (var b in s.TeamBadges.OrderBy(x => x.TeamBadgeID))
        {
            if (!teamIdMap.TryGetValue(b.TeamID, out var newTeamId))
            {
                continue;
            }

            var entity = new TeamBadge
            {
                TeamID = newTeamId,
                Code = b.Code,
                Name = b.Name,
                Description = b.Description,
                IconCode = b.IconCode,
                ConditionType = b.ConditionType,
                ConditionValue = b.ConditionValue
            };
            _db.TeamBadges.Add(entity);
            await _db.SaveChangesAsync(ct);
            badgeIdMap[b.TeamBadgeID] = entity.TeamBadgeID;
        }

        foreach (var ub in s.UserTeamBadges)
        {
            if (!userIdMap.TryGetValue(ub.UserID, out var nu)
                || !teamIdMap.TryGetValue(ub.TeamID, out var nt)
                || !badgeIdMap.TryGetValue(ub.TeamBadgeID, out var nb))
            {
                continue;
            }

            _db.UserTeamBadges.Add(new UserTeamBadge
            {
                UserID = nu,
                TeamBadgeID = nb,
                TeamID = nt,
                AwardedAt = ub.AwardedAt
            });
        }

        await _db.SaveChangesAsync(ct);

        foreach (var d in s.Devices)
        {
            if (!teamIdMap.TryGetValue(d.TeamID, out var newTeamId))
            {
                continue;
            }

            var key = d.DeviceKey;
            if (await _db.Devices.AnyAsync(x => x.DeviceKey == key, ct))
            {
                key = Guid.NewGuid().ToString("N");
            }

            _db.Devices.Add(new Device
            {
                Name = d.Name,
                TeamID = newTeamId,
                DeviceKey = key,
                Location = d.Location,
                IsActive = d.IsActive,
                LastSeenAt = d.LastSeenAt
            });
        }

        await _db.SaveChangesAsync(ct);
        await tx.CommitAsync(ct);

        return new ImportBackupResultDto
        {
            Mode = "full",
            UsersCreated = userIdMap.Count,
            TeamsCreated = teamIdMap.Count,
            MessageKey = "admin.backupResultAllUsersTempPassword",
            MessageParams = null,
        };
    }

    private async Task<(int teamsInserted, int usersInserted)> InsertMissingTeamsAndUsersAsync(
        SystemBackupDto s,
        CancellationToken ct)
    {
        var teamsInserted = 0;
        var usersInserted = 0;

        var newTeams = new List<Team>();
        foreach (var t in s.Teams.OrderBy(x => x.TeamID))
        {
            if (await _db.Teams.AnyAsync(x => x.TeamID == t.TeamID, ct))
            {
                continue;
            }

            int? createdBy = t.CreatedByUserID;
            if (createdBy.HasValue && !await _db.Users.AnyAsync(u => u.UserID == createdBy.Value, ct))
            {
                createdBy = null;
            }

            newTeams.Add(new Team
            {
                TeamID = t.TeamID,
                Name = t.Name,
                Description = t.Description,
                CreatedAt = t.CreatedAt,
                CreatedByUserID = createdBy,
                LevelPointsMode = ParseLevelPointsMode(t.LevelPointsMode),
                MaxMembers = t.MaxMembers,
            });
        }

        if (newTeams.Count > 0)
        {
            await WithIdentityInsertAsync<Team>(
                async () =>
                {
                    await _db.Teams.AddRangeAsync(newTeams, ct);
                    await _db.SaveChangesAsync(ct);
                },
                ct);
            teamsInserted = newTeams.Count;
        }

        var newUsers = new List<User>();
        foreach (var u in s.Users.OrderBy(x => x.UserID))
        {
            if (await _db.Users.AnyAsync(x => x.UserID == u.UserID, ct))
            {
                continue;
            }

            var user = new User
            {
                UserID = u.UserID,
                Login = (u.Login ?? string.Empty).Trim(),
                Email = (u.Email ?? string.Empty).Trim(),
                FirstName = u.FirstName,
                LastName = u.LastName,
                Role = u.Role is "User" or "Manager" or "Admin" or "SystemAdministrator" ? u.Role : "User",
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt,
                LastLoginAt = u.LastLoginAt,
                PasswordHash = string.Empty,
            };
            ApplyImportedUserPassword(user, u.PasswordPlain);
            newUsers.Add(user);
        }

        if (newUsers.Count > 0)
        {
            await WithIdentityInsertAsync<User>(
                async () =>
                {
                    await _db.Users.AddRangeAsync(newUsers, ct);
                    await _db.SaveChangesAsync(ct);
                },
                ct);
            usersInserted = newUsers.Count;
        }

        return (teamsInserted, usersInserted);
    }

    private async Task<ImportBackupResultDto> ReplaceCatalogFromSnapshotAsync(SystemBackupDto s, CancellationToken ct)
    {
        await using var tx = await _db.Database.BeginTransactionAsync(ct);
        await ClearBackupScopedTablesAsync(ct);
        await ImportSnapshotWithOriginalIdsAsync(s, ct);
        await tx.CommitAsync(ct);

        return new ImportBackupResultDto
        {
            Mode = "replace-catalog",
            UsersCreated = s.Users.Count,
            TeamsCreated = s.Teams.Count,
            MessageKey = "admin.backupResultCatalogReplacedWithPassword",
            MessageParams = null,
        };
    }

    private async Task ClearBackupScopedTablesAsync(CancellationToken ct)
    {
        await _db.DeviceStatistics.ExecuteDeleteAsync(ct);
        await _db.DeviceScans.ExecuteDeleteAsync(ct);
        await _db.ActionEvents.ExecuteDeleteAsync(ct);
        await _db.TeamJoinRequests.ExecuteDeleteAsync(ct);
        await _db.UserTeamBadges.ExecuteDeleteAsync(ct);
        await _db.TeamMembers.ExecuteDeleteAsync(ct);
        await _db.ActionTypes.ExecuteDeleteAsync(ct);
        await _db.TeamBadges.ExecuteDeleteAsync(ct);
        await _db.Devices.ExecuteDeleteAsync(ct);
        await _db.TeamLevels.ExecuteDeleteAsync(ct);
        await _db.Teams.ExecuteUpdateAsync(_ => _.SetProperty(t => t.CreatedByUserID, (int?)null), ct);
        await _db.Users.ExecuteDeleteAsync(ct);
        await _db.Teams.ExecuteDeleteAsync(ct);
    }

    private async Task ImportSnapshotWithOriginalIdsAsync(SystemBackupDto s, CancellationToken ct)
    {
        await WithIdentityInsertAsync<User>(
            async () =>
            {
                foreach (var u in s.Users.OrderBy(x => x.UserID))
                {
                    var user = new User
                    {
                        UserID = u.UserID,
                        Login = (u.Login ?? string.Empty).Trim(),
                        Email = (u.Email ?? string.Empty).Trim(),
                        FirstName = u.FirstName,
                        LastName = u.LastName,
                        Role = u.Role is "User" or "Manager" or "Admin" or "SystemAdministrator" ? u.Role : "User",
                        IsActive = u.IsActive,
                        CreatedAt = u.CreatedAt,
                        LastLoginAt = u.LastLoginAt,
                        PasswordHash = string.Empty,
                    };
                    ApplyImportedUserPassword(user, u.PasswordPlain);
                    _db.Users.Add(user);
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);

        await WithIdentityInsertAsync<Team>(
            async () =>
            {
                foreach (var t in s.Teams.OrderBy(x => x.TeamID))
                {
                    int? createdBy = t.CreatedByUserID;
                    if (createdBy.HasValue && !await _db.Users.AnyAsync(u => u.UserID == createdBy.Value, ct))
                    {
                        createdBy = null;
                    }

                    _db.Teams.Add(new Team
                    {
                        TeamID = t.TeamID,
                        Name = t.Name,
                        Description = t.Description,
                        CreatedAt = t.CreatedAt,
                        CreatedByUserID = createdBy,
                        LevelPointsMode = ParseLevelPointsMode(t.LevelPointsMode),
                        MaxMembers = t.MaxMembers,
                    });
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);

        await WithIdentityInsertAsync<TeamLevel>(
            async () =>
            {
                foreach (var l in s.TeamLevels.OrderBy(x => x.OrderIndex).ThenBy(x => x.TeamLevelID))
                {
                    if (!await _db.Teams.AnyAsync(t => t.TeamID == l.TeamID, ct))
                    {
                        continue;
                    }

                    _db.TeamLevels.Add(new TeamLevel
                    {
                        TeamLevelID = l.TeamLevelID,
                        TeamID = l.TeamID,
                        Name = l.Name,
                        RequiredPoints = l.RequiredPoints,
                        OrderIndex = l.OrderIndex,
                    });
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);

        await WithIdentityInsertAsync<TeamMember>(
            async () =>
            {
                foreach (var m in s.TeamMembers.OrderBy(x => x.TeamMemberID))
                {
                    if (!await _db.Teams.AnyAsync(t => t.TeamID == m.TeamID, ct) ||
                        !await _db.Users.AnyAsync(u => u.UserID == m.UserID, ct))
                    {
                        continue;
                    }

                    int? levelId = m.TeamLevelID;
                    if (levelId.HasValue &&
                        !await _db.TeamLevels.AnyAsync(x => x.TeamLevelID == levelId.Value, ct))
                    {
                        levelId = null;
                    }

                    _db.TeamMembers.Add(new TeamMember
                    {
                        TeamMemberID = m.TeamMemberID,
                        TeamID = m.TeamID,
                        UserID = m.UserID,
                        TeamRole = string.IsNullOrWhiteSpace(m.TeamRole) ? "Member" : m.TeamRole.Trim(),
                        TeamLevelID = levelId,
                        TeamPoints = m.TeamPoints,
                        JoinedAt = m.JoinedAt,
                    });
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);

        await WithIdentityInsertAsync<ActionType>(
            async () =>
            {
                foreach (var at in s.ActionTypes.OrderBy(x => x.ActionTypeID))
                {
                    if (!await _db.Teams.AnyAsync(t => t.TeamID == at.TeamID, ct))
                    {
                        continue;
                    }

                    _db.ActionTypes.Add(new ActionType
                    {
                        ActionTypeID = at.ActionTypeID,
                        TeamID = at.TeamID,
                        Code = at.Code,
                        Name = at.Name,
                        Description = at.Description,
                        DefaultPoints = at.DefaultPoints,
                        Category = at.Category,
                        IsActive = at.IsActive,
                    });
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);

        await WithIdentityInsertAsync<TeamBadge>(
            async () =>
            {
                foreach (var b in s.TeamBadges.OrderBy(x => x.TeamBadgeID))
                {
                    if (!await _db.Teams.AnyAsync(t => t.TeamID == b.TeamID, ct))
                    {
                        continue;
                    }

                    _db.TeamBadges.Add(new TeamBadge
                    {
                        TeamBadgeID = b.TeamBadgeID,
                        TeamID = b.TeamID,
                        Code = b.Code,
                        Name = b.Name,
                        Description = b.Description,
                        IconCode = b.IconCode,
                        ConditionType = b.ConditionType,
                        ConditionValue = b.ConditionValue,
                    });
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);

        await WithIdentityInsertAsync<UserTeamBadge>(
            async () =>
            {
                foreach (var ub in s.UserTeamBadges.OrderBy(x => x.UserTeamBadgeID))
                {
                    if (!await _db.Users.AnyAsync(u => u.UserID == ub.UserID, ct) ||
                        !await _db.Teams.AnyAsync(t => t.TeamID == ub.TeamID, ct) ||
                        !await _db.TeamBadges.AnyAsync(b => b.TeamBadgeID == ub.TeamBadgeID, ct))
                    {
                        continue;
                    }

                    _db.UserTeamBadges.Add(new UserTeamBadge
                    {
                        UserTeamBadgeID = ub.UserTeamBadgeID,
                        UserID = ub.UserID,
                        TeamBadgeID = ub.TeamBadgeID,
                        TeamID = ub.TeamID,
                        AwardedAt = ub.AwardedAt,
                    });
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);

        await WithIdentityInsertAsync<Device>(
            async () =>
            {
                foreach (var d in s.Devices.OrderBy(x => x.DeviceID))
                {
                    if (!await _db.Teams.AnyAsync(t => t.TeamID == d.TeamID, ct))
                    {
                        continue;
                    }

                    _db.Devices.Add(new Device
                    {
                        DeviceID = d.DeviceID,
                        Name = d.Name,
                        TeamID = d.TeamID,
                        DeviceKey = d.DeviceKey,
                        Location = d.Location,
                        IsActive = d.IsActive,
                        LastSeenAt = d.LastSeenAt,
                    });
                }

                await _db.SaveChangesAsync(ct);
            },
            ct);
    }

    private bool UseSqlServerIdentityInsert() =>
        _db.Database.ProviderName?.Contains("SqlServer", StringComparison.OrdinalIgnoreCase) == true;

    private string GetBracketedTableName<TEntity>()
        where TEntity : class
    {
        var entityType = _db.Model.FindEntityType(typeof(TEntity))
                         ?? throw new InvalidOperationException($"No EF entity mapped for {typeof(TEntity).Name}.");
        var table = entityType.GetTableName()
                    ?? throw new InvalidOperationException($"No table for {typeof(TEntity).Name}.");
        var schema = entityType.GetSchema();
        return schema == null ? $"[{table}]" : $"[{schema}].[{table}]";
    }

    private async Task WithIdentityInsertAsync<TEntity>(Func<Task> save, CancellationToken ct)
        where TEntity : class
    {
        if (UseSqlServerIdentityInsert())
        {
            var qn = GetBracketedTableName<TEntity>();
#pragma warning disable EF1002
            await _db.Database.ExecuteSqlRawAsync($"SET IDENTITY_INSERT {qn} ON", ct);
            try
            {
                await save();
            }
            finally
            {
                await _db.Database.ExecuteSqlRawAsync($"SET IDENTITY_INSERT {qn} OFF", ct);
            }
#pragma warning restore EF1002
        }
        else
        {
            await save();
        }
    }

    private static TeamLevelPointsMode ParseLevelPointsMode(string? value)
    {
        if (Enum.TryParse<TeamLevelPointsMode>(value, true, out var m))
        {
            return m;
        }

        return TeamLevelPointsMode.AbsoluteTotals;
    }

    private void ApplyImportedUserPassword(User user, string? passwordPlainFromBackup)
    {
        var plain = passwordPlainFromBackup?.Trim();
        if (!string.IsNullOrEmpty(plain))
        {
            user.PasswordPlain = plain;
            user.PasswordHash = _passwordHasher.HashPassword(user, plain);
        }
        else
        {
            user.PasswordPlain = null;
            user.PasswordHash = _passwordHasher.HashPassword(user, ImportDefaultPassword);
        }
    }
}
