using Elevate.Data;
using Elevate.Entities;
using Elevate.Tests.Controllers;
using Elevate.Tests.TestUtilities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System.Net;
using System.Net.Http.Json;

namespace Elevate.Tests.Controllers;

public class AdminTeamsControllerTests : ControllerTestBase
{
    public AdminTeamsControllerTests(CustomWebApplicationFactory factory) : base(factory)
    {
    }

    [Fact]
    public async Task Create_AsAdmin_CreatesTeam()
    {

        var client = await CreateAuthenticatedClientAsync(role: "Admin");
        var request = new
        {
            Name = "New Team",
            Description = "Team Description",
            ManagerUserId = (int?)null
        };

        var response = await client.PostAsJsonAsync("/api/admin/teams", request);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<object>();
        result.Should().NotBeNull();
    }

    [Fact]
    public async Task AddMember_AsAdmin_AddsMemberToTeam()
    {

        var client = await CreateAuthenticatedClientAsync(role: "Admin");
        await using var setupScope = Factory.Services.CreateAsyncScope();
        var setupContext = setupScope.ServiceProvider.GetRequiredService<ElevateDbContext>();

        var team = new Team { Name = "Test Team" };
        var user = new User
        {
            Login = "member",
            Email = "member@test.com",
            FirstName = "Member",
            LastName = "User",
            PasswordHash = "hash"
        };

        setupContext.Teams.Add(team);
        setupContext.Users.Add(user);
        await setupContext.SaveChangesAsync();

        var request = new
        {
            UserId = user.UserID,
            TeamRole = "Member"
        };

        var response = await client.PostAsJsonAsync($"/api/admin/teams/{team.TeamID}/members", request);

        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

    }
}
