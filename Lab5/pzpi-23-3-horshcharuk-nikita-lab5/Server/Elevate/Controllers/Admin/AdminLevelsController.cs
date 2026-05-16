using Elevate.Dtos.Admin.Gamification.Levels;
using Elevate.Dtos.Admin.Teams;
using Elevate.Entities;
using Elevate.Exceptions;
using Elevate.Services.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Route("api/admin/levels")]
[Authorize(Roles = "Admin,SystemAdministrator")]
public class AdminLevelsController : ControllerBase
{
    private readonly ITeamLevelsAdminService _service;
    private readonly IAdminTeamService _teamAdmin;

    public AdminLevelsController(ITeamLevelsAdminService service, IAdminTeamService teamAdmin)
    {
        _service = service;
        _teamAdmin = teamAdmin;
    }

    [HttpGet("teams/{teamId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetLevels(int teamId, CancellationToken ct)
    {
        try
        {
            var data = await _service.GetTeamLevelsForAdminAsync(teamId, ct);
            return Ok(new { levels = data.Levels, levelPointsMode = data.LevelPointsMode });
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpPut("teams/{teamId:int}/level-points-mode")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SetTeamLevelPointsMode(
        int teamId,
        [FromBody] UpdateTeamLevelPointsModeRequest request,
        CancellationToken ct)
    {
        try
        {
            await _teamAdmin.SetLevelPointsModeAsync(teamId, (TeamLevelPointsMode)request.LevelPointsMode, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpPost("teams/{teamId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateLevel(int teamId, [FromBody] CreateLevelRequest request, CancellationToken ct)
    {
        try
        {
            var level = await _service.CreateTeamLevelAsync(teamId, request.Name, request.RequiredPoints, request.OrderIndex, ct);
            return Ok(level);
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

    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateLevel(int id, [FromBody] UpdateLevelRequest request, CancellationToken ct)
    {
        try
        {
            await _service.UpdateTeamLevelAsync(id, request.Name, request.RequiredPoints, request.OrderIndex, ct);
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
    public async Task<IActionResult> DeleteLevel(int id, CancellationToken ct)
    {
        try
        {
            await _service.DeleteTeamLevelAsync(id, ct);
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
