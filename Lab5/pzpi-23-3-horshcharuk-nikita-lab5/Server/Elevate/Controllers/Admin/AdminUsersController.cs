using Elevate.Dtos.Admin.Users;
using Elevate.Entities;
using Elevate.Exceptions;
using Elevate.Services.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Route("api/admin/users")]
[Authorize(Roles = "Admin,SystemAdministrator")]
public class AdminUsersController : ControllerBase
{
    private readonly IAdminUserService _service;

    public AdminUsersController(IAdminUserService service)
    {
        _service = service;
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] CreateAdminUserRequest request, CancellationToken ct)
    {
        try
        {
            var role = string.IsNullOrWhiteSpace(request.Role) ? UserRoleNames.User : request.Role.Trim();
            var user = await _service.CreateUserAsync(
                request.Login,
                request.Email,
                request.Password,
                request.FirstName,
                request.LastName,
                role,
                ct);

            return Ok(new
            {
                user.UserID,
                user.Login,
                user.Email,
                user.FirstName,
                user.LastName,
                user.Role,
                user.IsActive,
                user.CreatedAt,
                user.PasswordPlain,
            });
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var users = await _service.GetAllAsync(ct);

        var result = users.Select(u => new
        {
            u.UserID,
            u.Login,
            u.Email,
            u.FirstName,
            u.LastName,
            u.Role,
            u.IsActive,
            u.CreatedAt,
            u.LastLoginAt,
            u.PasswordPlain,
        });

        return Ok(result);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id, CancellationToken ct)
    {
        var user = await _service.GetByIdAsync(id, ct);
        if (user == null) return NotFound();

        return Ok(new
        {
            user.UserID,
            user.Login,
            user.Email,
            user.Role,
            user.IsActive,
            user.FirstName,
            user.LastName,
            user.CreatedAt,
            user.LastLoginAt,
            user.PasswordPlain,
        });
    }

    [HttpPost("{id:int}/role")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SetRole(int id, [FromBody] SetRoleRequest request, CancellationToken ct)
    {
        try
        {
            await _service.SetRoleAsync(id, request.Role, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpPost("{id:int}/block")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> BlockUser(int id, CancellationToken ct)
    {
        try
        {
            await _service.SetActiveAsync(id, false, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpPost("{id:int}/unblock")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UnblockUser(int id, CancellationToken ct)
    {
        try
        {
            await _service.SetActiveAsync(id, true, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateUser(int id, [FromBody] AdminUpdateUserRequest request, CancellationToken ct)
    {
        try
        {
            await _service.UpdateUserAsync(
                id,
                request.Login,
                request.Email,
                request.FirstName,
                request.LastName,
                request.Password,
                request.ClearPasswordPlain,
                ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> DeleteUser(int id, CancellationToken ct)
    {
        try
        {
            await _service.DeleteUserAsync(id, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
