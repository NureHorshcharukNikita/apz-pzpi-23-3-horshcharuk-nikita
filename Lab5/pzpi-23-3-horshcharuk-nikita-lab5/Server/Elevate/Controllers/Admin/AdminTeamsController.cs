using Elevate.Dtos.Admin.Teams;
using Elevate.Entities;
using Elevate.Exceptions;
using Elevate.Services.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Route("api/admin/teams")]
[Authorize(Roles = "Admin,SystemAdministrator")]
public class AdminTeamsController : ControllerBase
{
    private readonly IAdminTeamService _service;

    public AdminTeamsController(IAdminTeamService service)
    {
        _service = service;
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> Create([FromBody] CreateTeamRequest request, CancellationToken ct)
    {
        try
        {
            var team = await _service.CreateTeamAsync(
                request.Name,
                request.Description,
                request.ManagerUserId,
                request.MaxMembers,
                ct);
            return Ok(new { team.TeamID, team.Name, team.Description });
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

    [HttpPut("{id:int}/level-points-mode")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SetLevelPointsMode(
        int id,
        [FromBody] UpdateTeamLevelPointsModeRequest request,
        CancellationToken ct)
    {
        try
        {
            await _service.SetLevelPointsModeAsync(id, (TeamLevelPointsMode)request.LevelPointsMode, ct);
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
    public async Task<IActionResult> Update(int id, [FromBody] UpdateTeamRequest request, CancellationToken ct)
    {
        try
        {
            await _service.UpdateTeamAsync(id, request.Name, request.Description, request.MaxMembers, ct);
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
    public async Task<IActionResult> Delete(int id, CancellationToken ct)
    {
        await _service.DeleteTeamAsync(id, ct);
        return NoContent();
    }

    [HttpPost("{id:int}/members")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> AddMember(int id, [FromBody] AddMemberRequest request, CancellationToken ct)
    {
        try
        {
            await _service.AddMemberAsync(id, request.UserId, request.TeamRole, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpDelete("{id:int}/members/{userId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RemoveMember(int id, int userId, CancellationToken ct)
    {
        try
        {
            await _service.RemoveMemberAsync(id, userId, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpPost("{id:int}/members/{userId:int}/role")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ChangeMemberRole(int id, int userId, [FromBody] ChangeMemberRoleRequest request, CancellationToken ct)
    {
        try
        {
            await _service.ChangeMemberRoleAsync(id, userId, request.TeamRole, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }
}
