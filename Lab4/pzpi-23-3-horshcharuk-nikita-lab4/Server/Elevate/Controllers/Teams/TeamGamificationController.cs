using Elevate.Dtos.Actions;
using Elevate.Dtos.Teams;
using Elevate.Services.Teams;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Authorize]
[Route("api/teams/{teamId:int}/gamification")]
public class TeamGamificationController : ApiControllerBase
{
    private readonly ITeamService _teamService;

    public TeamGamificationController(ITeamService teamService)
    {
        _teamService = teamService;
    }

    [HttpPost("levels")]
    [ProducesResponseType(typeof(TeamLevelDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateLevel(int teamId, [FromBody] CreateTeamLevelDto dto, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var level = await _teamService.CreateLevelAsync(teamId, dto, userId.Value, cancellationToken);
            return CreatedAtAction(nameof(CreateLevel), new { teamId, levelId = level.Id }, level);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("badges")]
    [ProducesResponseType(typeof(TeamBadgeDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateBadge(int teamId, [FromBody] CreateTeamBadgeDto dto, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var badge = await _teamService.CreateBadgeAsync(teamId, dto, userId.Value, cancellationToken);
            return CreatedAtAction(nameof(CreateBadge), new { teamId, badgeId = badge.Id }, badge);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("levels/{levelId:int}")]
    [ProducesResponseType(typeof(TeamLevelDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateLevel(
        int teamId,
        int levelId,
        [FromBody] UpdateTeamLevelDto dto,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var level = await _teamService.UpdateLevelAsync(teamId, levelId, dto, userId.Value, cancellationToken);
            return Ok(level);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("badges/{badgeId:int}")]
    [ProducesResponseType(typeof(TeamBadgeDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateBadge(
        int teamId,
        int badgeId,
        [FromBody] UpdateTeamBadgeDto dto,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var badge = await _teamService.UpdateBadgeAsync(teamId, badgeId, dto, userId.Value, cancellationToken);
            return Ok(badge);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("levels/{levelId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> DeleteLevel(
        int teamId,
        int levelId,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.DeleteLevelAsync(teamId, levelId, userId.Value, cancellationToken);
            return NoContent();
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("badges/{badgeId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> DeleteBadge(
        int teamId,
        int badgeId,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.DeleteBadgeAsync(teamId, badgeId, userId.Value, cancellationToken);
            return NoContent();
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("action-types")]
    [ProducesResponseType(typeof(IReadOnlyCollection<ActionTypeDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetActionTypesForSetup(int teamId, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var types = await _teamService.GetActionTypesForGamificationSetupAsync(
                teamId,
                userId.Value,
                cancellationToken);
            return Ok(types);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPost("action-types")]
    [ProducesResponseType(typeof(ActionTypeDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateActionType(int teamId, [FromBody] CreateActionTypeDto dto, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var actionType = await _teamService.CreateActionTypeAsync(teamId, dto, userId.Value, cancellationToken);

            return CreatedAtAction(
                nameof(CreateActionType),
                new { teamId, actionTypeId = actionType.Id },
                actionType
            );
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPut("action-types/{actionTypeId:int}")]
    [ProducesResponseType(typeof(ActionTypeDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateActionType(
        int teamId,
        int actionTypeId,
        [FromBody] UpdateActionTypeDto dto,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var actionType = await _teamService.UpdateActionTypeAsync(
                teamId,
                actionTypeId,
                dto,
                userId.Value,
                cancellationToken);
            return Ok(actionType);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("action-types/{actionTypeId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> DeleteActionType(
        int teamId,
        int actionTypeId,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.DeleteActionTypeAsync(teamId, actionTypeId, userId.Value, cancellationToken);
            return NoContent();
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
