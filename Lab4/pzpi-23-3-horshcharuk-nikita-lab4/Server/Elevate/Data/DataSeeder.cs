using Elevate.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Data;

public class DataSeeder
{
    private static readonly Dictionary<string, string> DemoLoginKnownPasswords = new(StringComparer.OrdinalIgnoreCase)
    {
        ["sysadmin"] = "SysWeb$2026Adm",
        ["admin"] = "CorpAdm#88x",
        ["manager"] = "LeadMgr#77m",
        ["jdoe"] = "Jdoe$44work",
        ["asmith"] = "Anna$33dev",
        ["pkoval"] = "Petro$22qa",
        ["oshevchenko"] = "Olena$11sup",
        ["idev"] = "Ihor$55code",
        ["vboyko"] = "Bogdan$66ui",
        ["ntkachenko"] = "Natalia$77test",
        ["skravets"] = "Serhiy$88api",
        ["olytvyn"] = "Oleh$99ops",
    };

    private readonly ElevateDbContext _dbContext;
    private readonly IPasswordHasher<User> _passwordHasher;

    public DataSeeder(ElevateDbContext dbContext, IPasswordHasher<User> passwordHasher)
    {
        _dbContext = dbContext;
        _passwordHasher = passwordHasher;
    }

    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        await EnsureDatabaseCreatedAsync(cancellationToken);

        if (!await HasUsersAsync(cancellationToken))
        {
            var users = await SeedUsersAsync(cancellationToken);
            var teams = await SeedTeamsAsync(cancellationToken);
            var levels = await SeedTeamLevelsAsync(teams, cancellationToken);

            await SeedTeamMembersAsync(teams, users, levels, cancellationToken);
            await SeedActionTypesAsync(teams, cancellationToken);
            await SeedBadgesAsync(teams, cancellationToken);
            await SeedUserTeamBadgesAsync(teams, users, cancellationToken);
            await SeedDevicesAsync(teams, cancellationToken);
            await SeedDeviceStatisticsAsync(cancellationToken);
            await SeedDeviceScansAsync(users, cancellationToken);
            await SeedActionEventsAsync(teams, users, cancellationToken);
            await SeedTeamJoinRequestsAsync(teams, users, cancellationToken);
            return;
        }

        await EnsureDemoUserTeamBadgesIfMissingAsync(cancellationToken);
        await EnsureSysAdministratorAsync(cancellationToken);
        await BackfillDemoPasswordPlainWhereHashMatchesAsync(cancellationToken);
    }

    private async Task EnsureDatabaseCreatedAsync(CancellationToken cancellationToken)
    {
        await _dbContext.Database.EnsureCreatedAsync(cancellationToken);
        await EnsurePasswordPlainColumnAsync(cancellationToken);
    }

    private async Task EnsurePasswordPlainColumnAsync(CancellationToken cancellationToken)
    {
        try
        {
            await _dbContext.Database.ExecuteSqlRawAsync(
                """
                IF NOT EXISTS (
                    SELECT 1 FROM sys.columns c
                    INNER JOIN sys.tables t ON c.object_id = t.object_id
                    WHERE t.name = 'Users' AND c.name = 'PasswordPlain')
                ALTER TABLE [Users] ADD [PasswordPlain] nvarchar(256) NULL;
                """,
                cancellationToken);
        }
        catch
        {
        }
    }

    private Task<bool> HasUsersAsync(CancellationToken cancellationToken)
        => _dbContext.Users.AnyAsync(cancellationToken);

    private async Task<Dictionary<string, User>> SeedUsersAsync(CancellationToken cancellationToken)
    {
        User U(
            string login,
            string email,
            string firstName,
            string lastName,
            string role,
            string password)
        {
            var user = new User
            {
                Login = login,
                Email = email,
                FirstName = firstName,
                LastName = lastName,
                Role = role
            };
            user.PasswordHash = _passwordHasher.HashPassword(user, password);
            user.PasswordPlain = password;
            return user;
        }

        var data = new[]
        {
            U("sysadmin", "sysadmin@elevate.local", "Системний", "Адміністратор", "Admin", "SysWeb$2026Adm"),
            U("admin", "admin@elevate.local", "System", "Admin", "Admin", "CorpAdm#88x"),
            U("manager", "manager@elevate.local", "Marta", "Manager", "Manager", "LeadMgr#77m"),
            U("jdoe", "john.doe@elevate.local", "John", "Doe", "User", "Jdoe$44work"),
            U("asmith", "anna.smith@elevate.local", "Anna", "Smith", "User", "Anna$33dev"),
            U("pkoval", "p.koval@elevate.local", "Петро", "Коваль", "User", "Petro$22qa"),
            U("oshevchenko", "o.shevchenko@elevate.local", "Олена", "Шевченко", "User", "Olena$11sup"),
            U("idev", "i.dev@elevate.local", "Ihor", "Developer", "User", "Ihor$55code"),
            U("vboyko", "v.boyko@elevate.local", "Богдан", "Бойко", "User", "Bogdan$66ui"),
            U("ntkachenko", "n.tkachenko@elevate.local", "Наталія", "Ткаченко", "User", "Natalia$77test"),
            U("skravets", "s.kravets@elevate.local", "Сергій", "Кравець", "User", "Serhiy$88api"),
            U("olytvyn", "o.lytvyn@elevate.local", "Олег", "Литвин", "User", "Oleh$99ops")
        };

        _dbContext.Users.AddRange(data);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return data.ToDictionary(u => u.Login, u => u);
    }

    private async Task<Dictionary<string, Team>> SeedTeamsAsync(CancellationToken cancellationToken)
    {
        var backend = new Team { Name = "Backend Team", Description = "API, інтеграції, інфраструктура" };
        var mobile = new Team { Name = "Mobile Team", Description = "Flutter, iOS/Android клієнти" };
        var qa = new Team { Name = "QA & Support", Description = "Тестування, підтримка, документація" };
        var platform = new Team { Name = "Platform & DevOps", Description = "CI/CD, хмари, моніторинг" };

        _dbContext.Teams.AddRange(backend, mobile, qa, platform);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new Dictionary<string, Team>
        {
            ["backend"] = backend,
            ["mobile"] = mobile,
            ["qa"] = qa,
            ["platform"] = platform
        };
    }

    private async Task<Dictionary<string, List<TeamLevel>>> SeedTeamLevelsAsync(
        Dictionary<string, Team> teams,
        CancellationToken cancellationToken)
    {
        static List<TeamLevel> L(int teamId, params (string n, int rp, int o)[] rows)
            => rows.Select(r => new TeamLevel { TeamID = teamId, Name = r.n, RequiredPoints = r.rp, OrderIndex = r.o }).ToList();

        var backendLevels = L(teams["backend"].TeamID, ("Rookie", 0, 1), ("Pro", 200, 2), ("Legend", 500, 3), ("Mythic", 900, 4));
        var mobileLevels = L(teams["mobile"].TeamID, ("Starter", 0, 1), ("Builder", 180, 2), ("Champion", 350, 3), ("Elite", 650, 4));
        var qaLevels = L(teams["qa"].TeamID, ("Scout", 0, 1), ("Guardian", 150, 2), ("Oracle", 400, 3));
        var platformLevels = L(teams["platform"].TeamID, ("Initiate", 0, 1), ("SRE", 220, 2), ("Architect", 480, 3));

        _dbContext.TeamLevels.AddRange(backendLevels);
        _dbContext.TeamLevels.AddRange(mobileLevels);
        _dbContext.TeamLevels.AddRange(qaLevels);
        _dbContext.TeamLevels.AddRange(platformLevels);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new Dictionary<string, List<TeamLevel>>
        {
            ["backend"] = backendLevels,
            ["mobile"] = mobileLevels,
            ["qa"] = qaLevels,
            ["platform"] = platformLevels
        };
    }

    private async Task SeedTeamMembersAsync(
        Dictionary<string, Team> teams,
        Dictionary<string, User> users,
        Dictionary<string, List<TeamLevel>> levels,
        CancellationToken cancellationToken)
    {
        var b = teams["backend"];
        var m = teams["mobile"];
        var q = teams["qa"];
        var p = teams["platform"];

        b.CreatedByUserID = users["admin"].UserID;
        m.CreatedByUserID = users["manager"].UserID;
        q.CreatedByUserID = users["sysadmin"].UserID;
        p.CreatedByUserID = users["sysadmin"].UserID;
        _dbContext.Teams.UpdateRange(b, m, q, p);

        var bl = levels["backend"];
        var ml = levels["mobile"];
        var ql = levels["qa"];
        var pl = levels["platform"];

        TeamMember M(int teamId, int userId, string role, int pts, int levelIdx, string teamKey)
        {
            var lv = levels[teamKey][levelIdx];
            return new TeamMember
            {
                TeamID = teamId,
                UserID = userId,
                TeamRole = role,
                TeamPoints = pts,
                TeamLevelID = lv.TeamLevelID
            };
        }

        var members = new[]
        {
            M(b.TeamID, users["admin"].UserID, "Lead", 620, 3, "backend"),
            M(b.TeamID, users["jdoe"].UserID, "Member", 310, 1, "backend"),
            M(b.TeamID, users["asmith"].UserID, "Member", 175, 0, "backend"),
            M(b.TeamID, users["idev"].UserID, "Member", 420, 2, "backend"),
            M(b.TeamID, users["skravets"].UserID, "Member", 290, 1, "backend"),

            M(m.TeamID, users["manager"].UserID, "Lead", 510, 3, "mobile"),
            M(m.TeamID, users["asmith"].UserID, "Member", 260, 2, "mobile"),
            M(m.TeamID, users["pkoval"].UserID, "Member", 210, 1, "mobile"),
            M(m.TeamID, users["vboyko"].UserID, "Member", 340, 2, "mobile"),

            M(q.TeamID, users["oshevchenko"].UserID, "Lead", 380, 2, "qa"),
            M(q.TeamID, users["jdoe"].UserID, "Member", 110, 0, "qa"),
            M(q.TeamID, users["pkoval"].UserID, "Member", 195, 1, "qa"),
            M(q.TeamID, users["ntkachenko"].UserID, "Member", 155, 0, "qa"),

            M(p.TeamID, users["olytvyn"].UserID, "Lead", 440, 2, "platform"),
            M(p.TeamID, users["skravets"].UserID, "Member", 260, 1, "platform"),
            M(p.TeamID, users["admin"].UserID, "Member", 180, 0, "platform")
        };

        _dbContext.TeamMembers.AddRange(members);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedActionTypesAsync(Dictionary<string, Team> teams, CancellationToken cancellationToken)
    {
        void Add(int teamId, string code, string name, int pts, string? cat = null, string? desc = null)
        {
            _dbContext.ActionTypes.Add(new ActionType
            {
                TeamID = teamId,
                Code = code,
                Name = name,
                DefaultPoints = pts,
                Category = cat,
                Description = desc,
                IsActive = true
            });
        }

        var b = teams["backend"].TeamID;
        var mob = teams["mobile"].TeamID;
        var q = teams["qa"].TeamID;
        var pl = teams["platform"].TeamID;

        Add(b, "DEPLOY", "Production Deployment", 50, "Delivery", "Реліз у production");
        Add(b, "CODE_REVIEW", "Code Review Hero", 20, "Quality");
        Add(b, "INCIDENT_FIX", "Incident Resolution", 35, "Ops");
        Add(b, "DOCS", "Technical Documentation", 15, "Docs");
        Add(b, "REFACTOR", "Major Refactor", 28, "Quality");
        Add(b, "ON_CALL", "On-call shift", 25, "Ops");

        Add(mob, "HOTFIX", "Critical Hotfix", 40, "Delivery");
        Add(mob, "UI_POLISH", "UI Polish Sprint", 25, "UX");
        Add(mob, "STORE_RELEASE", "Store Release", 45, "Delivery");
        Add(mob, "WIDGET", "New Widget", 18, "Feature");
        Add(mob, "A11Y", "Accessibility pass", 22, "UX");

        Add(q, "REGRESSION_RUN", "Regression Suite", 30, "Testing");
        Add(q, "BUG_TRIAGE", "Bug Triage Session", 18, "Process");
        Add(q, "USER_HELP", "User Support Win", 22, "Support");
        Add(q, "TEST_PLAN", "Test Plan Authoring", 16, "Testing");
        Add(q, "AUTO_TEST", "Automation added", 24, "Testing");

        Add(pl, "PIPELINE_FIX", "Pipeline repair", 32, "DevOps");
        Add(pl, "K8S_ROLLOUT", "K8s rollout", 38, "DevOps");
        Add(pl, "MONITORING", "Dashboards & alerts", 20, "Observability");
        Add(pl, "INFRA_COST", "Cost optimization", 26, "FinOps");

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedBadgesAsync(Dictionary<string, Team> teams, CancellationToken cancellationToken)
    {
        void B(int teamId, string code, string name, string? cond, int? val)
        {
            _dbContext.TeamBadges.Add(new TeamBadge
            {
                TeamID = teamId,
                Code = code,
                Name = name,
                ConditionType = cond,
                ConditionValue = val,
                IconCode = code.ToLowerInvariant()
            });
        }

        var b = teams["backend"].TeamID;
        var m = teams["mobile"].TeamID;
        var q = teams["qa"].TeamID;
        var p = teams["platform"].TeamID;

        B(b, "SPRINT_HERO", "Sprint Hero", "PointsReached", 200);
        B(b, "OPS_GURU", "Ops Guru", "PointsReached", 400);
        B(b, "NIGHT_OWL", "Night Owl Deploy", "PointsReached", 120);
        B(b, "DOC_MASTER", "Documentation Master", "PointsReached", 80);

        B(m, "MOBILE_STAR", "Mobile Star", "PointsReached", 250);
        B(m, "PIXEL_PERFECT", "Pixel Perfect", "PointsReached", 180);
        B(m, "STORE_KING", "Store King", "PointsReached", 320);

        B(q, "QUALITY_GATE", "Quality Gatekeeper", "PointsReached", 150);
        B(q, "CUSTOMER_CHAMP", "Customer Champion", "PointsReached", 220);
        B(q, "BUG_HUNTER", "Bug Hunter", "PointsReached", 100);

        B(p, "UPTIME_KEEPER", "Uptime Keeper", "PointsReached", 200);
        B(p, "PIPELINE_PRO", "Pipeline Pro", "PointsReached", 280);

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedUserTeamBadgesAsync(
        Dictionary<string, Team> teams,
        Dictionary<string, User> users,
        CancellationToken cancellationToken)
    {
        async Task<int> Bid(string teamKey, string code)
        {
            var tid = teams[teamKey].TeamID;
            return (await _dbContext.TeamBadges.AsNoTracking()
                .FirstAsync(x => x.TeamID == tid && x.Code == code, cancellationToken)).TeamBadgeID;
        }

        var utc = DateTime.UtcNow;
        void Ub(int uid, string teamKey, int badgeId, int daysAgo)
        {
            _dbContext.UserTeamBadges.Add(new UserTeamBadge
            {
                UserID = uid,
                TeamID = teams[teamKey].TeamID,
                TeamBadgeID = badgeId,
                AwardedAt = utc.AddDays(-daysAgo)
            });
        }

        var bh = await Bid("backend", "SPRINT_HERO");
        var bo = await Bid("backend", "OPS_GURU");
        var ms = await Bid("mobile", "MOBILE_STAR");
        var mp = await Bid("mobile", "PIXEL_PERFECT");
        var qg = await Bid("qa", "QUALITY_GATE");
        var qb = await Bid("qa", "BUG_HUNTER");
        var uk = await Bid("platform", "UPTIME_KEEPER");
        var pp = await Bid("platform", "PIPELINE_PRO");

        Ub(users["admin"].UserID, "backend", bh, 14);
        Ub(users["admin"].UserID, "backend", bo, 5);
        Ub(users["jdoe"].UserID, "backend", bh, 9);
        Ub(users["idev"].UserID, "backend", bo, 3);
        Ub(users["manager"].UserID, "mobile", ms, 4);
        Ub(users["asmith"].UserID, "mobile", ms, 2);
        Ub(users["vboyko"].UserID, "mobile", mp, 6);
        Ub(users["oshevchenko"].UserID, "qa", qg, 7);
        Ub(users["ntkachenko"].UserID, "qa", qb, 11);
        Ub(users["olytvyn"].UserID, "platform", uk, 8);
        Ub(users["skravets"].UserID, "platform", pp, 2);

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedDevicesAsync(Dictionary<string, Team> teams, CancellationToken cancellationToken)
    {
        var devs = new[]
        {
            new Device { Name = "Backend Wall Panel", TeamID = teams["backend"].TeamID, DeviceKey = "device-backend-001", Location = "Київ, офіс A" },
            new Device { Name = "Mobile LED Strip", TeamID = teams["mobile"].TeamID, DeviceKey = "device-mobile-001", Location = "Львів" },
            new Device { Name = "QA Floor Display", TeamID = teams["qa"].TeamID, DeviceKey = "device-qa-001", Location = "Харків" },
            new Device { Name = "Lobby Totem", TeamID = teams["backend"].TeamID, DeviceKey = "device-lobby-001", Location = "Київ, рецепція" },
            new Device { Name = "DevOps NOC Screen", TeamID = teams["platform"].TeamID, DeviceKey = "device-platform-001", Location = "Remote NOC" },
            new Device { Name = "Breakroom Badge Tap", TeamID = teams["mobile"].TeamID, DeviceKey = "device-mobile-002", Location = "Київ, кухня" }
        };

        _dbContext.Devices.AddRange(devs);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedDeviceStatisticsAsync(CancellationToken cancellationToken)
    {
        var devices = await _dbContext.Devices.AsNoTracking().OrderBy(d => d.DeviceID).ToListAsync(cancellationToken);
        var rnd = new Random(42);
        var stats = new List<DeviceStatistics>();
        var now = DateTime.UtcNow;

        foreach (var d in devices)
        {
            for (var i = 0; i < 3; i++)
            {
                var total = rnd.Next(80, 400);
                var ok = (int)(total * (0.85 + rnd.NextDouble() * 0.14));
                stats.Add(new DeviceStatistics
                {
                    DeviceID = d.DeviceID,
                    TeamID = d.TeamID,
                    RecordedAt = now.AddHours(-(i * 6 + rnd.Next(0, 3))),
                    TotalScans = total,
                    SuccessfulScans = ok,
                    FailedScans = total - ok,
                    DailyScans = rnd.Next(10, 80),
                    AverageScansPerHour = (float)(total / 24.0),
                    SuccessRate = ok / (float)total * 100f,
                    DeviceEfficiency = 0.75f + (float)rnd.NextDouble() * 0.2f,
                    PeakHour = rnd.Next(9, 18),
                    ActivityTrend = rnd.Next(-5, 15),
                    UptimeMs = rnd.Next(3600_000, 86_400_000)
                });
            }
        }

        _dbContext.DeviceStatistics.AddRange(stats);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedDeviceScansAsync(Dictionary<string, User> users, CancellationToken cancellationToken)
    {
        var devices = await _dbContext.Devices.AsNoTracking().ToListAsync(cancellationToken);
        var scanUsers = new[] { users["jdoe"], users["asmith"], users["pkoval"], users["idev"], users["manager"] };
        var scans = new List<DeviceScan>();
        var t0 = DateTime.UtcNow;

        for (var i = 0; i < 24; i++)
        {
            var d = devices[i % devices.Count];
            var u = scanUsers[i % scanUsers.Length];
            scans.Add(new DeviceScan
            {
                DeviceID = d.DeviceID,
                TeamID = d.TeamID,
                UserID = u.UserID,
                ScannedAt = t0.AddMinutes(-i * 37)
            });
        }

        _dbContext.DeviceScans.AddRange(scans);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedActionEventsAsync(
        Dictionary<string, Team> teams,
        Dictionary<string, User> users,
        CancellationToken cancellationToken)
    {
        async Task<int> Atid(int teamId, string code) =>
            (await _dbContext.ActionTypes.AsNoTracking()
                .FirstAsync(a => a.TeamID == teamId && a.Code == code, cancellationToken)).ActionTypeID;

        var b = teams["backend"].TeamID;
        var m = teams["mobile"].TeamID;
        var q = teams["qa"].TeamID;
        var p = teams["platform"].TeamID;

        var now = DateTime.UtcNow;
        var events = new List<ActionEvent>
        {
            new() { UserID = users["jdoe"].UserID, TeamID = b, ActionTypeID = await Atid(b, "DEPLOY"), SourceType = "Self", PointsAwarded = 50, OccurredAt = now.AddDays(-9), Comment = "v1.3.0" },
            new() { UserID = users["idev"].UserID, TeamID = b, ActionTypeID = await Atid(b, "CODE_REVIEW"), SourceType = "Self", PointsAwarded = 20, OccurredAt = now.AddDays(-8), Comment = "PR #501" },
            new() { UserID = users["skravets"].UserID, TeamID = b, ActionTypeID = await Atid(b, "REFACTOR"), SourceType = "Self", PointsAwarded = 28, OccurredAt = now.AddDays(-7) },
            new() { UserID = users["admin"].UserID, TeamID = b, ActionTypeID = await Atid(b, "INCIDENT_FIX"), SourceType = "Self", PointsAwarded = 35, OccurredAt = now.AddDays(-5) },
            new() { UserID = users["asmith"].UserID, TeamID = b, ActionTypeID = await Atid(b, "DOCS"), SourceType = "Self", PointsAwarded = 15, OccurredAt = now.AddDays(-4) },
            new() { UserID = users["jdoe"].UserID, TeamID = b, ActionTypeID = await Atid(b, "ON_CALL"), SourceType = "Self", PointsAwarded = 25, OccurredAt = now.AddDays(-2) },

            new() { UserID = users["pkoval"].UserID, TeamID = m, ActionTypeID = await Atid(m, "HOTFIX"), SourceType = "Self", PointsAwarded = 40, OccurredAt = now.AddDays(-6) },
            new() { UserID = users["manager"].UserID, TeamID = m, ActionTypeID = await Atid(m, "STORE_RELEASE"), SourceType = "Self", PointsAwarded = 45, OccurredAt = now.AddDays(-5) },
            new() { UserID = users["vboyko"].UserID, TeamID = m, ActionTypeID = await Atid(m, "UI_POLISH"), SourceType = "Self", PointsAwarded = 25, OccurredAt = now.AddDays(-3) },
            new() { UserID = users["vboyko"].UserID, TeamID = m, ActionTypeID = await Atid(m, "A11Y"), SourceType = "Self", PointsAwarded = 22, OccurredAt = now.AddDays(-1) },

            new() { UserID = users["oshevchenko"].UserID, TeamID = q, ActionTypeID = await Atid(q, "REGRESSION_RUN"), SourceType = "Self", PointsAwarded = 30, OccurredAt = now.AddDays(-10) },
            new() { UserID = users["ntkachenko"].UserID, TeamID = q, ActionTypeID = await Atid(q, "AUTO_TEST"), SourceType = "Self", PointsAwarded = 24, OccurredAt = now.AddDays(-4) },
            new() { UserID = users["pkoval"].UserID, TeamID = q, ActionTypeID = await Atid(q, "USER_HELP"), SourceType = "Self", PointsAwarded = 22, OccurredAt = now.AddDays(-2) },
            new() { UserID = users["jdoe"].UserID, TeamID = q, ActionTypeID = await Atid(q, "BUG_TRIAGE"), SourceType = "Self", PointsAwarded = 18, OccurredAt = now.AddHours(-12) },

            new() { UserID = users["olytvyn"].UserID, TeamID = p, ActionTypeID = await Atid(p, "K8S_ROLLOUT"), SourceType = "Self", PointsAwarded = 38, OccurredAt = now.AddDays(-6) },
            new() { UserID = users["skravets"].UserID, TeamID = p, ActionTypeID = await Atid(p, "PIPELINE_FIX"), SourceType = "Self", PointsAwarded = 32, OccurredAt = now.AddDays(-3) },
            new() { UserID = users["admin"].UserID, TeamID = p, ActionTypeID = await Atid(p, "MONITORING"), SourceType = "Self", PointsAwarded = 20, OccurredAt = now.AddDays(-1) }
        };

        _dbContext.ActionEvents.AddRange(events);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task SeedTeamJoinRequestsAsync(
        Dictionary<string, Team> teams,
        Dictionary<string, User> users,
        CancellationToken cancellationToken)
    {
        var reqs = new[]
        {
            new TeamJoinRequest { TeamID = teams["backend"].TeamID, UserID = users["ntkachenko"].UserID, Status = "Pending", RequestedAt = DateTime.UtcNow.AddDays(-2) },
            new TeamJoinRequest { TeamID = teams["backend"].TeamID, UserID = users["vboyko"].UserID, Status = "Pending", RequestedAt = DateTime.UtcNow.AddDays(-1) },
            new TeamJoinRequest { TeamID = teams["backend"].TeamID, UserID = users["pkoval"].UserID, Status = "Pending", RequestedAt = DateTime.UtcNow.AddHours(-8) },
            new TeamJoinRequest { TeamID = teams["qa"].TeamID, UserID = users["idev"].UserID, Status = "Pending", RequestedAt = DateTime.UtcNow.AddDays(-3) },
            new TeamJoinRequest { TeamID = teams["platform"].TeamID, UserID = users["asmith"].UserID, Status = "Pending", RequestedAt = DateTime.UtcNow.AddDays(-4) },
            new TeamJoinRequest { TeamID = teams["platform"].TeamID, UserID = users["jdoe"].UserID, Status = "Pending", RequestedAt = DateTime.UtcNow.AddHours(-20) },
            new TeamJoinRequest { TeamID = teams["mobile"].TeamID, UserID = users["ntkachenko"].UserID, Status = "Pending", RequestedAt = DateTime.UtcNow.AddHours(-5) }
        };

        _dbContext.TeamJoinRequests.AddRange(reqs);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task BackfillDemoPasswordPlainWhereHashMatchesAsync(CancellationToken cancellationToken)
    {
        var users = await _dbContext.Users.ToListAsync(cancellationToken);
        var changed = false;
        foreach (var u in users)
        {
            if (!string.IsNullOrEmpty(u.PasswordPlain))
            {
                continue;
            }

            if (!DemoLoginKnownPasswords.TryGetValue(u.Login, out var pwd))
            {
                continue;
            }

            var vr = _passwordHasher.VerifyHashedPassword(u, u.PasswordHash, pwd);
            if (vr == PasswordVerificationResult.Failed)
            {
                continue;
            }

            u.PasswordPlain = pwd;
            changed = true;
        }

        if (changed)
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    private async Task EnsureSysAdministratorAsync(CancellationToken cancellationToken)
    {
        if (await _dbContext.Users.AnyAsync(u => u.Login == "sysadmin", cancellationToken))
            return;

        var user = new User
        {
            Login = "sysadmin",
            Email = "sysadmin@elevate.local",
            FirstName = "Системний",
            LastName = "Адміністратор",
            Role = "Admin",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
        user.PasswordHash = _passwordHasher.HashPassword(user, "SysWeb$2026Adm");
        user.PasswordPlain = "SysWeb$2026Adm";
        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private async Task EnsureDemoUserTeamBadgesIfMissingAsync(CancellationToken cancellationToken)
    {
        if (await _dbContext.UserTeamBadges.AnyAsync(cancellationToken))
            return;

        var admin = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Login == "admin", cancellationToken);
        var jdoe = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Login == "jdoe", cancellationToken);
        var manager = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Login == "manager", cancellationToken);
        var asmith = await _dbContext.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Login == "asmith", cancellationToken);
        if (admin == null || jdoe == null || manager == null || asmith == null)
            return;

        var backend = await _dbContext.Teams.AsNoTracking()
            .FirstOrDefaultAsync(t => t.Name == "Backend Team", cancellationToken);
        var mobile = await _dbContext.Teams.AsNoTracking()
            .FirstOrDefaultAsync(t => t.Name == "Mobile Team", cancellationToken);
        if (backend == null || mobile == null)
            return;

        var sprintHero = await _dbContext.TeamBadges.AsNoTracking()
            .FirstOrDefaultAsync(b => b.TeamID == backend.TeamID && b.Code == "SPRINT_HERO", cancellationToken);
        var opsGuru = await _dbContext.TeamBadges.AsNoTracking()
            .FirstOrDefaultAsync(b => b.TeamID == backend.TeamID && b.Code == "OPS_GURU", cancellationToken);
        var mobileStar = await _dbContext.TeamBadges.AsNoTracking()
            .FirstOrDefaultAsync(b => b.TeamID == mobile.TeamID && b.Code == "MOBILE_STAR", cancellationToken);
        if (sprintHero == null || opsGuru == null || mobileStar == null)
            return;

        var utc = DateTime.UtcNow;
        var awards = new[]
        {
            new UserTeamBadge { UserID = admin.UserID, TeamID = backend.TeamID, TeamBadgeID = sprintHero.TeamBadgeID, AwardedAt = utc.AddDays(-10) },
            new UserTeamBadge { UserID = admin.UserID, TeamID = backend.TeamID, TeamBadgeID = opsGuru.TeamBadgeID, AwardedAt = utc.AddDays(-3) },
            new UserTeamBadge { UserID = jdoe.UserID, TeamID = backend.TeamID, TeamBadgeID = sprintHero.TeamBadgeID, AwardedAt = utc.AddDays(-7) },
            new UserTeamBadge { UserID = manager.UserID, TeamID = mobile.TeamID, TeamBadgeID = mobileStar.TeamBadgeID, AwardedAt = utc.AddDays(-2) },
            new UserTeamBadge { UserID = asmith.UserID, TeamID = mobile.TeamID, TeamBadgeID = mobileStar.TeamBadgeID, AwardedAt = utc.AddDays(-1) }
        };

        _dbContext.UserTeamBadges.AddRange(awards);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
