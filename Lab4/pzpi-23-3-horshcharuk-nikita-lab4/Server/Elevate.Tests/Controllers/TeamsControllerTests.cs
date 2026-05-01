using Elevate.Dtos.Teams;
using Elevate.Entities;
using Elevate.Tests.Controllers;
using Elevate.Tests.TestUtilities;
using System.Net;
using System.Collections.Generic;
using Microsoft.Extensions.DependencyInjection;
using System.Net.Http.Json;

namespace Elevate.Tests.Controllers;

public class TeamsControllerTests : ControllerTestBase
{
    public TeamsControllerTests(CustomWebApplicationFactory factory) : base(factory)
    {
    }

    [Fact]
    public async Task GetTeams_WithAuthentication_ReturnsOk()
    {

        var uniqueId = Guid.NewGuid().ToString("N")[..8];
        var (_, client) = await CreateAuthenticatedUserAndClientAsync($"testuser_{uniqueId}");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team1 = new Team { Name = $"Backend_{uniqueId}" };
        var team2 = new Team { Name = $"Frontend_{uniqueId}" };
        context.AddRange(team1, team2);
        await context.SaveChangesAsync();

        var response = await client.GetAsync("/api/teams");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<System.Collections.Generic.List<TeamDto>>();
        result.Should().NotBeNull();

        var ourTeams = result!.Where(t => t.Id == team1.TeamID || t.Id == team2.TeamID).ToList();
        ourTeams.Should().HaveCount(2);
    }

    [Fact]
    public async Task GetTeams_WithoutAuthentication_ReturnsUnauthorized()
    {

        var response = await Client.GetAsync("/api/teams");

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetTeam_WithValidId_ReturnsOk()
    {

        var uniqueId = Guid.NewGuid().ToString("N")[..8];
        var (_, client) = await CreateAuthenticatedUserAndClientAsync($"testuser_{uniqueId}");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = $"Backend_{uniqueId}", Description = "Backend team" };
        context.Add(team);
        await context.SaveChangesAsync();

        var response = await client.GetAsync($"/api/teams/{team.TeamID}");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<TeamDetailDto>();
        result.Should().NotBeNull();
        result!.Id.Should().Be(team.TeamID);
        result.Name.Should().Be($"Backend_{uniqueId}");
    }

    [Fact]
    public async Task GetTeam_WithInvalidId_ReturnsNotFound()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync();

        var response = await client.GetAsync("/api/teams/99999");

        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task GetMembers_WithValidTeamId_ReturnsOk()
    {

        var uniqueId = Guid.NewGuid().ToString("N")[..8];
        var (user1, client) = await CreateAuthenticatedUserAndClientAsync($"user1_{uniqueId}");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var user2 = new User
        {
            Login = $"user2_{uniqueId}",
            Email = $"user2_{uniqueId}@test.com",
            FirstName = "User",
            LastName = "Two",
            PasswordHash = "hash",
            Role = "User"
        };

        var team = new Team { Name = $"Backend_{uniqueId}" };
        var level = new TeamLevel
        {
            Team = team,
            Name = "Pro",
            RequiredPoints = 0,
            OrderIndex = 1
        };

        var existingUser1 = await context.Users.FindAsync(user1.UserID);
        var member1 = new TeamMember
        {
            Team = team,
            User = existingUser1!,
            TeamPoints = 100,
            TeamLevel = level
        };
        var member2 = new TeamMember
        {
            Team = team,
            User = user2,
            TeamPoints = 150,
            TeamLevel = level
        };

        context.AddRange(user2, team, level, member1, member2);
        await context.SaveChangesAsync();

    var response = await client.GetAsync($"/api/teams/{team.TeamID}/members");

    response.StatusCode.Should().Be(HttpStatusCode.OK);
    var result = await response.Content.ReadFromJsonAsync<List<TeamMemberDto>>();
    result.Should().NotBeNull();
    result!.Should().NotBeEmpty();

    var ourTeamMembers = result.Where(m => m.UserId == user1.UserID || m.UserId == user2.UserID).ToList();

    ourTeamMembers.Should().HaveCount(2);
    ourTeamMembers.Should().Contain(m => m.UserId == user1.UserID);
    ourTeamMembers.Should().Contain(m => m.UserId == user2.UserID);

    var member1Dto = ourTeamMembers.First(m => m.UserId == user1.UserID);
    var member2Dto = ourTeamMembers.First(m => m.UserId == user2.UserID);
    member1Dto.TeamPoints.Should().Be(100);
    member2Dto.TeamPoints.Should().Be(150);
    }

    [Fact]
    public async Task GetMembers_WithInvalidTeamId_ReturnsEmptyList()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync();

        var response = await client.GetAsync("/api/teams/99999/members");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<TeamMemberDto>>();
        result.Should().NotBeNull();
        result!.Should().BeEmpty();
    }

    [Fact]
    public async Task GetLeaderboard_WithValidTeamId_ReturnsOk()
    {

        var uniqueId = Guid.NewGuid().ToString("N")[..8];
        var (user1, client) = await CreateAuthenticatedUserAndClientAsync($"user1_{uniqueId}");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var user2 = new User
        {
            Login = $"user2_{uniqueId}",
            Email = $"user2_{uniqueId}@test.com",
            FirstName = "User",
            LastName = "Two",
            PasswordHash = "hash",
            Role = "User"
        };

        var team = new Team { Name = $"Backend_{uniqueId}" };
        var level = new TeamLevel
        {
            Team = team,
            Name = "Pro",
            RequiredPoints = 0,
            OrderIndex = 1
        };

        var existingUser1 = await context.Users.FindAsync(user1.UserID);
        var member1 = new TeamMember
        {
            Team = team,
            User = existingUser1!,
            TeamPoints = 200,
            TeamLevel = level
        };
        var member2 = new TeamMember
        {
            Team = team,
            User = user2,
            TeamPoints = 150,
            TeamLevel = level
        };

        context.AddRange(user2, team, level, member1, member2);
        await context.SaveChangesAsync();

        var response = await client.GetAsync($"/api/teams/{team.TeamID}/leaderboard");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<LeaderboardEntryDto>>();
        result.Should().NotBeNull();

        var ourMembers = result!.Where(m => m.UserId == user1.UserID || m.UserId == user2.UserID).ToList();
        ourMembers.Should().HaveCount(2);

        var firstMember = ourMembers.First();
        firstMember.Rank.Should().Be(1);
        firstMember.UserId.Should().Be(user1.UserID);
        firstMember.TeamPoints.Should().Be(200);
    }

    [Fact]
    public async Task GetLeaderboard_WithInvalidTeamId_ReturnsEmptyList()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync();

        var response = await client.GetAsync("/api/teams/99999/leaderboard");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<List<LeaderboardEntryDto>>();
        result.Should().NotBeNull();
        result!.Should().BeEmpty();
    }
}
