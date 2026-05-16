using Elevate.Dtos.Actions;
using Elevate.Dtos.Teams;
using Elevate.Entities;
using Elevate.Tests.Controllers;
using Elevate.Tests.TestUtilities;
using System.Net;
using System.Collections.Generic;
using Microsoft.Extensions.DependencyInjection;
using System.Net.Http.Json;

namespace Elevate.Tests.Controllers;

public class TeamGamificationControllerTests : ControllerTestBase
{
    public TeamGamificationControllerTests(CustomWebApplicationFactory factory) : base(factory)
    {
    }

    [Fact]
    public async Task CreateLevel_WithValidData_ReturnsCreated()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "Manager");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateTeamLevelDto
        {
            Name = "Legend",
            RequiredPoints = 500,
            OrderIndex = 3
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/levels", dto);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var result = await response.Content.ReadFromJsonAsync<TeamLevelDto>();
        result.Should().NotBeNull();
        result!.Name.Should().Be("Legend");
        result.RequiredPoints.Should().Be(500);
    }

    [Fact]
    public async Task CreateLevel_WithoutManagerRole_ReturnsForbidden()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "User");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateTeamLevelDto
        {
            Name = "Legend",
            RequiredPoints = 500,
            OrderIndex = 3
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/levels", dto);

        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task CreateBadge_WithValidData_ReturnsCreated()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "Manager");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateTeamBadgeDto
        {
            Code = "SPRINT_HERO",
            Name = "Sprint Hero",
            Description = "Complete a sprint",
            ConditionType = "PointsReached",
            ConditionValue = 100
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/badges", dto);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var result = await response.Content.ReadFromJsonAsync<TeamBadgeDto>();
        result.Should().NotBeNull();
        result!.Code.Should().Be("SPRINT_HERO");
        result.Name.Should().Be("Sprint Hero");
    }

    [Fact]
    public async Task CreateBadge_WithoutCondition_ReturnsBadRequest()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "Manager");
        await using var scope = Factory.Services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateTeamBadgeDto
        {
            Code = "NO_RULE",
            Name = "Broken",
            Description = null,
            ConditionType = null,
            ConditionValue = null
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/badges", dto);

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task CreateBadge_WithoutManagerRole_ReturnsForbidden()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "User");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateTeamBadgeDto
        {
            Code = "SPRINT_HERO",
            Name = "Sprint Hero",
            ConditionType = "PointsReached",
            ConditionValue = 100
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/badges", dto);

        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task CreateActionType_WithValidData_ReturnsCreated()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "Manager");
        await using var scope = Factory.Services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateActionTypeDto
        {
            Code = "CODE_REVIEW",
            Name = "Code Review",
            Description = "Review code",
            DefaultPoints = 5,
            Category = "Development",
            IsActive = true
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/action-types", dto);

        response.StatusCode.Should().Be(HttpStatusCode.Created);

        var result = await response.Content.ReadFromJsonAsync<ActionTypeDto>();
        result.Should().NotBeNull();
        result!.Code.Should().Be("CODE_REVIEW");
        result.Name.Should().Be("Code Review");
    }

    [Fact]
    public async Task CreateActionType_WithoutManagerRole_ReturnsForbidden()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "User");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateActionTypeDto
        {
            Code = "CODE_REVIEW",
            Name = "Code Review",
            DefaultPoints = 5
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/action-types", dto);

        response.StatusCode.Should().Be(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task CreateLevel_WithAdminRole_ReturnsCreated()
    {

        var (_, client) = await CreateAuthenticatedUserAndClientAsync(role: "Admin");
        await using var scope = Factory.Services.CreateAsyncScope(); var context = scope.ServiceProvider.GetRequiredService<Elevate.Data.ElevateDbContext>();

        var team = new Team { Name = "Backend" };
        context.Add(team);
        await context.SaveChangesAsync();

        var dto = new CreateTeamLevelDto
        {
            Name = "Master",
            RequiredPoints = 1000,
            OrderIndex = 4
        };

        var response = await client.PostAsJsonAsync($"/api/teams/{team.TeamID}/gamification/levels", dto);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
    }
}
