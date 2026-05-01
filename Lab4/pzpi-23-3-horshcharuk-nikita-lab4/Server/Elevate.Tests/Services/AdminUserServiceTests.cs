using Elevate.Data;
using Elevate.Entities;
using Elevate.Services.Admin;
using Elevate.Tests.TestUtilities;
using Microsoft.EntityFrameworkCore;

namespace Elevate.Tests.Services;

public class AdminUserServiceTests
{
    [Fact]
    public async Task GetAllAsync_ReturnsAllUsers()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminUserService(context);

        var user1 = new User
        {
            Login = "user1",
            Email = "user1@test.com",
            FirstName = "John",
            LastName = "Doe",
            PasswordHash = "hash",
            Role = "User"
        };

        var user2 = new User
        {
            Login = "user2",
            Email = "user2@test.com",
            FirstName = "Anna",
            LastName = "Smith",
            PasswordHash = "hash",
            Role = "Manager"
        };

        context.Users.AddRange(user1, user2);
        await context.SaveChangesAsync();

        var users = await service.GetAllAsync(CancellationToken.None);

        users.Should().HaveCount(2);
        users.Should().Contain(u => u.Login == "user1");
        users.Should().Contain(u => u.Login == "user2");
    }

    [Fact]
    public async Task GetByIdAsync_ReturnsUser()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminUserService(context);

        var user = new User
        {
            Login = "user1",
            Email = "user1@test.com",
            FirstName = "John",
            LastName = "Doe",
            PasswordHash = "hash",
            Role = "User"
        };

        context.Users.Add(user);
        await context.SaveChangesAsync();

        var result = await service.GetByIdAsync(user.UserID, CancellationToken.None);

        result.Should().NotBeNull();
        result!.Login.Should().Be("user1");
    }

    [Fact]
    public async Task SetRoleAsync_UpdatesUserRole()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminUserService(context);

        var user = new User
        {
            Login = "user1",
            Email = "user1@test.com",
            FirstName = "John",
            LastName = "Doe",
            PasswordHash = "hash",
            Role = "User"
        };

        context.Users.Add(user);
        await context.SaveChangesAsync();

        await service.SetRoleAsync(user.UserID, "Manager", CancellationToken.None);

        var updatedUser = await context.Users.FindAsync(user.UserID);
        updatedUser!.Role.Should().Be("Manager");
    }

    [Fact]
    public async Task SetRoleAsync_WithInvalidRole_ThrowsException()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminUserService(context);

        var user = new User
        {
            Login = "user1",
            Email = "user1@test.com",
            FirstName = "John",
            LastName = "Doe",
            PasswordHash = "hash",
            Role = "User"
        };

        context.Users.Add(user);
        await context.SaveChangesAsync();

        var act = () => service.SetRoleAsync(user.UserID, "InvalidRole", CancellationToken.None);

        await act.Should().ThrowAsync<InvalidOperationException>()
            .WithMessage("*Invalid role*");
    }

    [Fact]
    public async Task SetRoleAsync_ToSystemAdministrator_UpdatesUserRole()
    {
        await using var context = TestContextFactory.CreateContext();
        var service = new AdminUserService(context);

        var user = new User
        {
            Login = "user1",
            Email = "user1@test.com",
            FirstName = "John",
            LastName = "Doe",
            PasswordHash = "hash",
            Role = "User"
        };

        context.Users.Add(user);
        await context.SaveChangesAsync();

        await service.SetRoleAsync(user.UserID, UserRoleNames.SystemAdministrator, CancellationToken.None);

        var updatedUser = await context.Users.FindAsync(user.UserID);
        updatedUser!.Role.Should().Be(UserRoleNames.SystemAdministrator);
    }

    [Fact]
    public async Task SetActiveAsync_UpdatesUserActiveStatus()
    {

        await using var context = TestContextFactory.CreateContext();
        var service = new AdminUserService(context);

        var user = new User
        {
            Login = "user1",
            Email = "user1@test.com",
            FirstName = "John",
            LastName = "Doe",
            PasswordHash = "hash",
            IsActive = true
        };

        context.Users.Add(user);
        await context.SaveChangesAsync();

        await service.SetActiveAsync(user.UserID, false, CancellationToken.None);

        var updatedUser = await context.Users.FindAsync(user.UserID);
        updatedUser!.IsActive.Should().BeFalse();
    }
}
