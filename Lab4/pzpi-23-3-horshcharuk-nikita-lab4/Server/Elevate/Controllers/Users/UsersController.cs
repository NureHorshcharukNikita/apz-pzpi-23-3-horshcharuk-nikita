using Elevate.Dtos.Teams;
using Elevate.Dtos.Users;
using Elevate.Services.Teams;
using Elevate.Services.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Authorize]
[Route("api/users")]
public class UsersController : ApiControllerBase
{
    private readonly IUserService _userService;
    private readonly IMobileOverviewService _mobileOverview;
    private readonly ITeamService _teamService;

    public UsersController(
        IUserService userService,
        IMobileOverviewService mobileOverview,
        ITeamService teamService)
    {
        _userService = userService;
        _mobileOverview = mobileOverview;
        _teamService = teamService;
    }

    [HttpGet("me/dashboard")]
    [ProducesResponseType(typeof(IReadOnlyList<TeamDashboardDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyTeamDashboards(CancellationToken cancellationToken)
    {
        var list = await _mobileOverview.GetMyTeamDashboardsAsync(User, cancellationToken);
        return Ok(list);
    }

    [HttpGet("me/activity")]
    [ProducesResponseType(typeof(IReadOnlyList<UserActivityItemDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyActivity(
        [FromQuery] int? teamId,
        CancellationToken cancellationToken)
    {
        var items = await _mobileOverview.GetMyActivityAsync(User, teamId, cancellationToken);
        return Ok(items);
    }

    [HttpGet("me/badges")]
    [ProducesResponseType(typeof(IReadOnlyList<UserAchievementItemDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyBadges(CancellationToken cancellationToken)
    {
        var list = await _mobileOverview.GetMyAchievementsAsync(User, cancellationToken);
        return Ok(list);
    }

    [HttpGet("me")]
    [ProducesResponseType(typeof(UserProfileDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyProfile(CancellationToken cancellationToken)
    {
        var profile = await _userService.GetProfileAsync(User, cancellationToken);
        if (profile == null)
        {
            return NotFound();
        }

        return Ok(profile);
    }

    [HttpPost("me/teams/{teamId:int}/join-request")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> RequestJoinTeam(int teamId, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.RequestJoinTeamAsync(teamId, userId.Value, cancellationToken);
            return Ok();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("me/join-requests")]
    [ProducesResponseType(typeof(IReadOnlyList<MyPendingJoinRequestDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyJoinRequests(CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        var list = await _teamService.GetMyPendingJoinRequestsAsync(userId.Value, cancellationToken);
        return Ok(list);
    }

    [HttpDelete("me/teams/{teamId:int}/join-request")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> CancelMyJoinRequest(int teamId, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
        {
            return Unauthorized();
        }

        try
        {
            await _teamService.CancelMyJoinRequestAsync(teamId, userId.Value, cancellationToken);
            return NoContent();
        }
        catch (InvalidOperationException)
        {
            return NotFound();
        }
    }

    [HttpPut("me")]
    [ProducesResponseType(typeof(UserProfileDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateMyProfile(
        [FromBody] UpdateMyProfileRequestDto request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.FirstName)
            || string.IsNullOrWhiteSpace(request.LastName)
            || string.IsNullOrWhiteSpace(request.Email))
        {
            return BadRequest(new { message = "firstName, lastName and email are required" });
        }

        var updated = await _userService.UpdateProfileAsync(
            User,
            request.FirstName,
            request.LastName,
            request.Email,
            cancellationToken);

        return updated == null ? NotFound() : Ok(updated);
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Manager,Admin")]
    [ProducesResponseType(typeof(UserProfileDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id, CancellationToken cancellationToken)
    {
        var profile = await _userService.GetProfileAsync(id, cancellationToken);
        if (profile == null)
        {
            return NotFound();
        }

        return Ok(profile);
    }

    [HttpPost("avatar")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UploadAvatar(
    IFormFile file,
    CancellationToken ct)
    {
        if (file == null || file.Length == 0)
            return BadRequest();

        using var ms = new MemoryStream();
        await file.CopyToAsync(ms, ct);

        await _userService.UpdateAvatarAsync(User, ms.ToArray(), ct);

        return Ok(new { avatarUrl = "/api/users/avatar" });
    }

    [HttpGet("avatar")]
    public async Task<IActionResult> GetAvatar(CancellationToken ct)
    {
        var avatar = await _userService.GetAvatarAsync(User, ct);

        if (avatar == null)
            return NotFound();

        return File(avatar, "image/jpeg");
    }
}
