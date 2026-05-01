using Elevate.Data;
using Elevate.Entities;
using Elevate.Services.Admin;
using Elevate.Tests.TestUtilities;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Tests.Services;

public class AdminDeviceServiceTests
{
    [Fact]
    public async Task CreateDeviceAsync_CreatesDevice()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminDeviceService(context);

        var team = new Team { Name = "Team" };
        context.Teams.Add(team);
        await context.SaveChangesAsync();

        var device = await service.CreateDeviceAsync("Device Name", team.TeamID, "Location", CancellationToken.None);

        device.Should().NotBeNull();
        device.Name.Should().Be("Device Name");
        device.TeamID.Should().Be(team.TeamID);
        device.Location.Should().Be("Location");
        device.DeviceKey.Should().NotBeNullOrWhiteSpace();
        device.IsActive.Should().BeTrue();

        var deviceInDb = await context.Devices.FindAsync(device.DeviceID);
        deviceInDb.Should().NotBeNull();
    }

    [Fact]
    public async Task SetDeviceActiveAsync_UpdatesDeviceActiveStatus()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminDeviceService(context);

        var team = new Team { Name = "Team" };
        var device = new Device
        {
            Name = "Device",
            Team = team,
            DeviceKey = "key",
            IsActive = true
        };

        context.Teams.Add(team);
        context.Devices.Add(device);
        await context.SaveChangesAsync();

        await service.SetDeviceActiveAsync(device.DeviceID, false, CancellationToken.None);

        var updatedDevice = await context.Devices.FindAsync(device.DeviceID);
        updatedDevice!.IsActive.Should().BeFalse();
    }

    [Fact]
    public async Task GetAllDevicesAsync_ReturnsAllDevices()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminDeviceService(context);

        var team = new Team { Name = "Team" };
        var device1 = new Device
        {
            Name = "Device 1",
            Team = team,
            DeviceKey = "key1",
            IsActive = true
        };

        var device2 = new Device
        {
            Name = "Device 2",
            Team = team,
            DeviceKey = "key2",
            IsActive = false
        };

        context.Teams.Add(team);
        context.Devices.AddRange(device1, device2);
        await context.SaveChangesAsync();

        var devices = await service.GetAllDevicesAsync(CancellationToken.None);

        devices.Should().HaveCount(2);
        devices.Should().Contain(d => d.Name == "Device 1");
        devices.Should().Contain(d => d.Name == "Device 2");
    }

    [Fact]
    public async Task UpdateDeviceAsync_UpdatesNameTeamAndLocation()
    {
        await using var context = TestContextFactory.CreateContext();
        var service = new AdminDeviceService(context);

        var teamA = new Team { Name = "Team A" };
        var teamB = new Team { Name = "Team B" };
        var device = new Device
        {
            Name = "Old",
            Team = teamA,
            DeviceKey = "key-u1",
            Location = "L1",
            IsActive = true,
        };

        context.Teams.AddRange(teamA, teamB);
        context.Devices.Add(device);
        await context.SaveChangesAsync();

        await service.UpdateDeviceAsync(device.DeviceID, "New", teamB.TeamID, "L2", CancellationToken.None);

        var updated = await context.Devices.FindAsync(device.DeviceID);
        updated!.Name.Should().Be("New");
        updated.TeamID.Should().Be(teamB.TeamID);
        updated.Location.Should().Be("L2");
    }

    [Fact]
    public async Task UpdateDeviceAsync_WhenDeviceMissing_Throws()
    {
        await using var context = TestContextFactory.CreateContext();
        var service = new AdminDeviceService(context);

        var act = async () => await service.UpdateDeviceAsync(99999, "X", 1, null, CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>().WithMessage("Device not found");
    }

    [Fact]
    public async Task DeleteDeviceAsync_RemovesDevice()
    {
        await using var context = TestContextFactory.CreateContext();
        var service = new AdminDeviceService(context);

        var team = new Team { Name = "Team" };
        var device = new Device { Name = "D", Team = team, DeviceKey = "key-d1", IsActive = true };
        context.Teams.Add(team);
        context.Devices.Add(device);
        await context.SaveChangesAsync();
        var id = device.DeviceID;

        await service.DeleteDeviceAsync(id, CancellationToken.None);

        (await context.Devices.FindAsync(id)).Should().BeNull();
    }
}
