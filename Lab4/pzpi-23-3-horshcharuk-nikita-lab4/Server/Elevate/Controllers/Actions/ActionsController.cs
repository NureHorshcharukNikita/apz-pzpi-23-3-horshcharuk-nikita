using Elevate.Dtos.Actions;
using Elevate.Entities;
using Elevate.Services.Actions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Authorize]
[Route("api/actions")]
public class ActionsController : ApiControllerBase
{
    private readonly IActionEventService _actionEventService;

    public ActionsController(IActionEventService actionEventService)
    {
        _actionEventService = actionEventService;
    }

    [HttpPost]
    [ProducesResponseType(typeof(ActionEventDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreateActionEvent([FromBody] CreateActionEventDto dto, CancellationToken cancellationToken)
    {
        var created = await _actionEventService.CreateActionEventAsync(dto, GetCurrentUserId(), cancellationToken);
        return CreatedAtAction(nameof(GetActionEventById), new { id = created.Id }, created);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ActionEvent), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetActionEventById(int id, CancellationToken cancellationToken)
    {
        var actionEvent = await _actionEventService.GetActionEventByIdAsync(id, cancellationToken);
        return actionEvent == null ? NotFound() : Ok(actionEvent);
    }

    [HttpGet]
    [ProducesResponseType(typeof(IReadOnlyCollection<ActionEventDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetActionEvents([FromQuery] int? userId, [FromQuery] int? teamId, CancellationToken cancellationToken)
    {
        var events = await _actionEventService.GetActionEventsAsync(userId, teamId, cancellationToken);
        return Ok(events);
    }
}
