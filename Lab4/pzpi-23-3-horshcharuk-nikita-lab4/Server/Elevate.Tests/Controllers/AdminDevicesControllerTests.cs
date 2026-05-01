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

public class AdminDevicesControllerTests : ControllerTestBase
{
    public AdminDevicesControllerTests(CustomWebApplicationFactory factory) : base(factory)
    {
    }

    [Fact]
    public async Task CreateDevice_AsAdmin_CreatesDevice()
    {

        var client = await CreateAuthenticatedClientAsync(role: "Admin");
        await using var scope = Factory.Services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<ElevateDbContext>();

        var team = new Team { Name = "Test Team" };
        context.Teams.Add(team);
        await context.SaveChangesAsync();

        var request = new
        {
            Name = "New Device",
            TeamId = team.TeamID,
            Location = "Office"
        };

        var response = await client.PostAsJsonAsync("/api/admin/devices", request);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<object>();
        result.Should().NotBeNull();
    }

    [Fact]
    public async Task DeactivateDevice_AsAdmin_DeactivatesDevice()
    {

        var client = await CreateAuthenticatedClientAsync(role: "Admin");
        await using var setupScope = Factory.Services.CreateAsyncScope();
        var setupContext = setupScope.ServiceProvider.GetRequiredService<ElevateDbContext>();

        var team = new Team { Name = "Test Team" };
        var device = new Device
        {
            Name = "Device",
            Team = team,
            DeviceKey = "key",
            IsActive = true
        };

        setupContext.Teams.Add(team);
        setupContext.Devices.Add(device);
        await setupContext.SaveChangesAsync();

        var response = await client.PostAsync($"/api/admin/devices/{device.DeviceID}/deactivate", null);

        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

    }

    [Fact]
    public async Task UpdateDevice_AsAdmin_ReturnsNoContent()
    {
        var client = await CreateAuthenticatedClientAsync(role: "Admin");
        await using var setupScope = Factory.Services.CreateAsyncScope();
        var setupContext = setupScope.ServiceProvider.GetRequiredService<ElevateDbContext>();

        var team = new Team { Name = "T1" };
        var team2 = new Team { Name = "T2" };
        var device = new Device { Name = "D", Team = team, DeviceKey = "k-upd", IsActive = true };
        setupContext.Teams.AddRange(team, team2);
        setupContext.Devices.Add(device);
        await setupContext.SaveChangesAsync();

        var body = new { Name = "Updated", TeamId = team2.TeamID, Location = "Lab" };
        var response = await client.PutAsJsonAsync($"/api/admin/devices/{device.DeviceID}", body);

        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
    }

    [Fact]
    public async Task DeleteDevice_AsAdmin_ReturnsNoContent()
    {
        var client = await CreateAuthenticatedClientAsync(role: "Admin");
        await using var setupScope = Factory.Services.CreateAsyncScope();
        var setupContext = setupScope.ServiceProvider.GetRequiredService<ElevateDbContext>();

        var team = new Team { Name = "T" };
        var device = new Device { Name = "D", Team = team, DeviceKey = "k-del", IsActive = true };
        setupContext.Teams.Add(team);
        setupContext.Devices.Add(device);
        await setupContext.SaveChangesAsync();
        var id = device.DeviceID;

        var response = await client.DeleteAsync($"/api/admin/devices/{id}");

        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
    }
}
