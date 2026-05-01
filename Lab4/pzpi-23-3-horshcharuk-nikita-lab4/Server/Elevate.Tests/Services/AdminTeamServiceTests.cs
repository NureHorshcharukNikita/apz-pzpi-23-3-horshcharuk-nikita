using Elevate.Data;
using Elevate.Entities;
using Elevate.Services.Admin;
using Elevate.Tests.TestUtilities;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Tests.Services;

public class AdminTeamServiceTests
{
    [Fact]
    public async Task CreateTeamAsync_CreatesTeam()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminTeamService(context);

        var team = await service.CreateTeamAsync("New Team", "Description", null, null, CancellationToken.None);

        team.Should().NotBeNull();
        team.Name.Should().Be("New Team");
        team.Description.Should().Be("Description");

        var teamInDb = await context.Teams.FindAsync(team.TeamID);
        teamInDb.Should().NotBeNull();
    }

    [Fact]
    public async Task CreateTeamAsync_WithManager_CreatesTeamMember()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminTeamService(context);

        var manager = new User
        {
            Login = "manager",
            Email = "manager@test.com",
            FirstName = "Manager",
            LastName = "User",
            PasswordHash = "hash",
            Role = "User"
        };

        context.Users.Add(manager);
        await context.SaveChangesAsync();

        var team = await service.CreateTeamAsync("New Team", "Description", manager.UserID, null, CancellationToken.None);

        var member = await context.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == team.TeamID && tm.UserID == manager.UserID);
        member.Should().NotBeNull();
        member!.TeamRole.Should().Be("Lead");

        var updatedManager = await context.Users.FindAsync(manager.UserID);
        updatedManager!.Role.Should().Be("Manager");
    }

    [Fact]
    public async Task UpdateTeamAsync_UpdatesTeam()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminTeamService(context);

        var team = new Team { Name = "Old Name", Description = "Old Desc" };
        context.Teams.Add(team);
        await context.SaveChangesAsync();

        await service.UpdateTeamAsync(team.TeamID, "New Name", "New Desc", null, CancellationToken.None);

        var updatedTeam = await context.Teams.FindAsync(team.TeamID);
        updatedTeam!.Name.Should().Be("New Name");
        updatedTeam.Description.Should().Be("New Desc");
    }

    [Fact]
    public async Task DeleteTeamAsync_DeletesTeam()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminTeamService(context);

        var team = new Team { Name = "Team to Delete" };
        context.Teams.Add(team);
        await context.SaveChangesAsync();

        await service.DeleteTeamAsync(team.TeamID, CancellationToken.None);

        var deletedTeam = await context.Teams.FindAsync(team.TeamID);
        deletedTeam.Should().BeNull();
    }

    [Fact]
    public async Task AddMemberAsync_AddsMemberToTeam()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminTeamService(context);

        var team = new Team { Name = "Team" };
        var user = new User
        {
            Login = "user",
            Email = "user@test.com",
            FirstName = "User",
            LastName = "Name",
            PasswordHash = "hash"
        };

        context.Teams.Add(team);
        context.Users.Add(user);
        await context.SaveChangesAsync();

        await service.AddMemberAsync(team.TeamID, user.UserID, "Member", CancellationToken.None);

        var member = await context.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == team.TeamID && tm.UserID == user.UserID);
        member.Should().NotBeNull();
        member!.TeamRole.Should().Be("Member");
    }

    [Fact]
    public async Task RemoveMemberAsync_RemovesMemberFromTeam()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminTeamService(context);

        var team = new Team { Name = "Team" };
        var user = new User
        {
            Login = "user",
            Email = "user@test.com",
            FirstName = "User",
            LastName = "Name",
            PasswordHash = "hash"
        };

        var member = new TeamMember
        {
            Team = team,
            User = user,
            TeamRole = "Member"
        };

        context.Teams.Add(team);
        context.Users.Add(user);
        context.TeamMembers.Add(member);
        await context.SaveChangesAsync();

        await service.RemoveMemberAsync(team.TeamID, user.UserID, CancellationToken.None);

        var removedMember = await context.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == team.TeamID && tm.UserID == user.UserID);
        removedMember.Should().BeNull();
    }

    [Fact]
    public async Task ChangeMemberRoleAsync_UpdatesMemberRole()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminTeamService(context);

        var team = new Team { Name = "Team" };
        var user = new User
        {
            Login = "user",
            Email = "user@test.com",
            FirstName = "User",
            LastName = "Name",
            PasswordHash = "hash"
        };

        var member = new TeamMember
        {
            Team = team,
            User = user,
            TeamRole = "Member"
        };

        context.Teams.Add(team);
        context.Users.Add(user);
        context.TeamMembers.Add(member);
        await context.SaveChangesAsync();

        await service.ChangeMemberRoleAsync(team.TeamID, user.UserID, "Lead", CancellationToken.None);

        var updatedMember = await context.TeamMembers
            .FirstOrDefaultAsync(tm => tm.TeamID == team.TeamID && tm.UserID == user.UserID);
        updatedMember!.TeamRole.Should().Be("Lead");
    }
}
