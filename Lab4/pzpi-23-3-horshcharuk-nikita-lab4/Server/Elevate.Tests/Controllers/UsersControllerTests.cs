using Elevate.Dtos.Users;
using Elevate.Entities;
using Elevate.Tests.Controllers;
using Elevate.Tests.TestUtilities;
using System.Net;
using System.Collections.Generic;
using Microsoft.Extensions.DependencyInjection;
using System.Net.Http.Json;

namespace Elevate.Tests.Controllers;

public class UsersControllerTests : ControllerTestBase
{
    public UsersControllerTests(CustomWebApplicationFactory factory) : base(factory)
    {
    }

    [Fact]
    public async Task Me_WithAuthenticatedUser_ReturnsOk()
    {

        var (user, client) = await CreateAuthenticatedUserAndClientAsync();

        var response = await client.GetAsync("/api/users/me");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<UserProfileDto>();
        result.Should().NotBeNull();
        result!.Id.Should().Be(user.UserID);
        result.Login.Should().Be(user.Login);
    }

    [Fact]
    public async Task Me_WithoutAuthentication_ReturnsUnauthorized()
    {

        var response = await Client.GetAsync("/api/users/me");

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetById_WithManagerRole_ReturnsOk()
    {

        var (user, client) = await CreateAuthenticatedUserAndClientAsync(role: "Manager");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var targetUser = new User
        {
            Login = "targetuser",
            Email = "target@test.com",
            FirstName = "Target",
            LastName = "User",
            PasswordHash = "hash",
            Role = "User"
        };
        context.Users.Add(targetUser);
        await context.SaveChangesAsync();

        var response = await client.GetAsync($"/api/users/{targetUser.UserID}");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<UserProfileDto>();
        result.Should().NotBeNull();
        result!.Id.Should().Be(targetUser.UserID);
        result.Login.Should().Be("targetuser");
    }

    [Fact]
    public async Task GetById_WithAdminRole_ReturnsOk()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "Admin");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var targetUser = new User
        {
            Login = "targetuser",
            Email = "target@test.com",
            FirstName = "Target",
            LastName = "User",
            PasswordHash = "hash",
            Role = "User"
        };
        context.Users.Add(targetUser);
        await context.SaveChangesAsync();

        var response = await client.GetAsync($"/api/users/{targetUser.UserID}");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task GetById_WithoutManagerRole_ReturnsForbidden()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "User");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var targetUser = new User
        {
            Login = "targetuser",
            Email = "target@test.com",
            FirstName = "Target",
            LastName = "User",
            PasswordHash = "hash",
            Role = "User"
        };
        context.Users.Add(targetUser);
        await context.SaveChangesAsync();

        var response = await client.GetAsync($"/api/users/{targetUser.UserID}");

        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task GetById_WithInvalidId_ReturnsNotFound()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "Manager");

        var response = await client.GetAsync("/api/users/99999");

        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task GetById_WithoutAuthentication_ReturnsUnauthorized()
    {

        var response = await Client.GetAsync("/api/users/1");

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Me_WithUserInTeams_ReturnsProfileWithTeams()
    {

        var uniqueId = Guid.NewGuid().ToString("N")[..8];
        var (user, client) = await CreateAuthenticatedUserAndClientAsync($"testuser_{uniqueId}");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = $"Backend_{uniqueId}" };
        var level = new TeamLevel
        {
            Team = team,
            Name = "Pro",
            RequiredPoints = 0,
            OrderIndex = 1
        };
        var existingUser = await context.Users.FindAsync(user.UserID);
        var membership = new TeamMember
        {
            Team = team,
            User = existingUser!,
            TeamPoints = 100,
            TeamLevel = level
        };

        context.AddRange(team, level, membership);
        await context.SaveChangesAsync();

        var response = await client.GetAsync("/api/users/me");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<UserProfileDto>();
        result.Should().NotBeNull();
        result!.Teams.Should().NotBeNull();

        result.Teams.Should().Contain(t => t.TeamId == team.TeamID);

        var ourTeam = result.Teams.First(t => t.TeamId == team.TeamID);
        ourTeam.TeamPoints.Should().Be(100);
    }
}
