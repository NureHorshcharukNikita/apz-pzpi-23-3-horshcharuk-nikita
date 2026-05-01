namespace Elevate.Services.Teams;

public interface ITeamService :
    ITeamCatalogService,
    ITeamLifecycleService,
    ITeamRosterService,
    ITeamMemberBadgeService,
    ITeamGamificationSetupService,
    ITeamJoinRequestService;
