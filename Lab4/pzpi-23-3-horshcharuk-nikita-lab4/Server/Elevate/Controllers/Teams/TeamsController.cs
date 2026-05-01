using Elevate.Dtos.Actions;
using Elevate.Dtos.Teams;
using Elevate.Services.Teams;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Authorize]
[Route("api/teams")]
public class TeamsController : ApiControllerBase
{
    private readonly ITeamService _teamService;

    public TeamsController(ITeamService teamService)
    {
        _teamService = teamService;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyCollection<TeamDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetTeams(CancellationToken cancellationToken)
    {
        var teams = await _teamService.GetTeamsAsync(cancellationToken);
        return Ok(teams);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(TeamDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetTeam(int id, CancellationToken cancellationToken)
    {
        var team = await _teamService.GetTeamAsync(id, cancellationToken);
        return team == null ? NotFound() : Ok(team);
    }

    [HttpPost]
    [ProducesResponseType(typeof(TeamDetailDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateTeam(
        [FromBody] CreateMyTeamRequestDto request,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            return BadRequest(new { message = "Name is required." });
        }

        if (request.MaxMembers is < 1)
        {
            return BadRequest(new { message = "MaxMembers must be at least 1, or omit for unlimited." });
        }

        try
        {
            var team = await _teamService.CreateMyTeamAsync(
                request.Name,
                request.Description,
                request.MaxMembers,
                userId.Value,
                cancellationToken);
            return CreatedAtAction(nameof(GetTeam), new { id = team.Id }, team);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(TeamDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> UpdateTeam(
        int id,
        [FromBody] UpdateTeamDto request,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var team = await _teamService.UpdateTeamAsync(id, request, userId.Value, cancellationToken);
            return Ok(team);
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

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> DeleteTeam(int id, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.DeleteTeamAsync(id, userId.Value, cancellationToken);
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

    [HttpGet("{id:int}/members")]
    [ProducesResponseType(typeof(IReadOnlyCollection<TeamMemberDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMembers(int id, CancellationToken cancellationToken)
    {
        var members = await _teamService.GetMembersAsync(id, cancellationToken);
        return Ok(members);
    }

    [HttpPut("{id:int}/members/{userId:int}/points")]
    [ProducesResponseType(typeof(TeamMemberDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> SetMemberTeamPoints(
        int id,
        int userId,
        [FromBody] SetMemberTeamPointsRequestDto request,
        CancellationToken cancellationToken)
    {
        var actingUserId = GetCurrentUserId();
        if (actingUserId is null)
        {
            return Unauthorized();
        }

        try
        {
            var updated = await _teamService.SetMemberTeamPointsAsync(
                id,
                userId,
                request.TeamPoints,
                actingUserId.Value,
                cancellationToken);
            return Ok(updated);
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

    [HttpGet("{id:int}/members/{userId:int}/badge-awards")]
    [ProducesResponseType(typeof(IReadOnlyList<MemberBadgeAwardDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetMemberBadgeAwards(
        int id,
        int userId,
        CancellationToken cancellationToken)
    {
        var actingUserId = GetCurrentUserId();
        if (actingUserId is null)
        {
            return Unauthorized();
        }

        try
        {
            var list = await _teamService.GetMemberBadgeAwardsAsync(
                id,
                userId,
                actingUserId.Value,
                cancellationToken);
            return Ok(list);
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

    [HttpPost("{id:int}/members/{userId:int}/badges/{badgeId:int}")]
    [ProducesResponseType(typeof(MemberBadgeAwardDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GrantMemberBadge(
        int id,
        int userId,
        int badgeId,
        CancellationToken cancellationToken)
    {
        var actingUserId = GetCurrentUserId();
        if (actingUserId is null)
        {
            return Unauthorized();
        }

        try
        {
            var created = await _teamService.GrantMemberBadgeAsync(
                id,
                userId,
                badgeId,
                actingUserId.Value,
                cancellationToken);
            return Ok(created);
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

    [HttpDelete("{id:int}/members/{userId:int}/badge-awards/{userTeamBadgeId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> RevokeMemberBadgeAward(
        int id,
        int userId,
        int userTeamBadgeId,
        CancellationToken cancellationToken)
    {
        var actingUserId = GetCurrentUserId();
        if (actingUserId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.RevokeMemberBadgeAwardAsync(
                id,
                userId,
                userTeamBadgeId,
                actingUserId.Value,
                cancellationToken);
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

    [HttpGet("{id:int}/leaderboard")]
    [ProducesResponseType(typeof(IReadOnlyCollection<LeaderboardEntryDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetLeaderboard(int id, CancellationToken cancellationToken)
    {
        var leaderboard = await _teamService.GetLeaderboardAsync(id, cancellationToken);
        return Ok(leaderboard);
    }

    [HttpGet("{id:int}/action-types")]
    [ProducesResponseType(typeof(IReadOnlyCollection<ActionTypeDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetTeamActionTypes(int id, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var types = await _teamService.GetActionTypesForMemberAsync(id, userId.Value, cancellationToken);
        return Ok(types);
    }

    [HttpPost("{id:int}/join-request")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RequestJoinTeam(int id, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.RequestJoinTeamAsync(id, userId.Value, cancellationToken);
            return Ok();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("{id:int}/join-requests")]
    [ProducesResponseType(typeof(IReadOnlyList<TeamJoinRequestDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetJoinRequests(int id, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            var list = await _teamService.GetPendingJoinRequestsAsync(id, userId.Value, cancellationToken);
            return Ok(list);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message });
        }
    }

    [HttpPost("{id:int}/join-requests/{requestId:int}/approve")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ApproveJoinRequest(
        int id,
        int requestId,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.ApproveJoinRequestAsync(id, requestId, userId.Value, cancellationToken);
            return Ok();
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

    [HttpPost("{id:int}/join-requests/{requestId:int}/reject")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RejectJoinRequest(
        int id,
        int requestId,
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.RejectJoinRequestAsync(id, requestId, userId.Value, cancellationToken);
            return Ok();
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

    [HttpDelete("{id:int}/members/{userId:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> RemoveMember(
        int id,
        int userId,
        CancellationToken cancellationToken)
    {
        var actingUserId = GetCurrentUserId();
        if (actingUserId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.RemoveTeamMemberAsync(id, userId, actingUserId.Value, cancellationToken);
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

    [HttpDelete("{id:int}/members/me")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> LeaveTeam(int id, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.LeaveTeamAsync(id, userId.Value, cancellationToken);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
