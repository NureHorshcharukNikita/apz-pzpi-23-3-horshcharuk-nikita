using Elevate.Dtos.Admin.Devices;
using Elevate.Exceptions;
using Elevate.Services.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Route("api/admin/devices")]
[Authorize(Roles = "Admin,SystemAdministrator")]
public class AdminDevicesController : ControllerBase
{
    private readonly IAdminDeviceService _service;

    public AdminDevicesController(IAdminDeviceService service)
    {
        _service = service;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAllDevices(CancellationToken ct)
    {
        var devices = await _service.GetAllDevicesAsync(ct);
        return Ok(devices.Select(d => new
        {
            d.DeviceID,
            d.Name,
            d.TeamID,
            d.Location,
            d.DeviceKey,
            d.IsActive,
            d.LastSeenAt
        }));
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> CreateDevice([FromBody] CreateDeviceRequest request, CancellationToken ct)
    {
        var device = await _service.CreateDeviceAsync(request.Name, request.TeamId, request.Location, ct);
        return Ok(new { device.DeviceID, device.DeviceKey });
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateDevice(int id, [FromBody] UpdateDeviceRequest request, CancellationToken ct)
    {
        try
        {
            await _service.UpdateDeviceAsync(id, request.Name, request.TeamId, request.Location, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
        catch (InvalidOperationException ex) when (ex.Message == "Device not found")
        {
            return NotFound();
        }
        catch (InvalidOperationException ex) when (ex.Message == "Team not found")
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteDevice(int id, CancellationToken ct)
    {
        try
        {
            await _service.DeleteDeviceAsync(id, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
        catch (InvalidOperationException ex) when (ex.Message == "Device not found")
        {
            return NotFound();
        }
    }

    [HttpPost("{id:int}/activate")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ActivateDevice(int id, CancellationToken ct)
    {
        try
        {
            await _service.SetDeviceActiveAsync(id, true, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpPost("{id:int}/deactivate")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> DeactivateDevice(int id, CancellationToken ct)
    {
        try
        {
            await _service.SetDeviceActiveAsync(id, false, ct);
            return NoContent();
        }
        catch (ClientErrorException ex)
        {
            return BadRequest(new { messageKey = ex.MessageKey, messageParams = ex.MessageParams });
        }
    }

    [HttpGet("statistics")]
    [ProducesResponseType(typeof(IReadOnlyCollection<Dtos.Admin.Devices.DeviceStatisticsDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDeviceStatistics(
        [FromQuery] int? deviceId,
        [FromQuery] int? teamId,
        [FromQuery] DateTime? from,
        [FromQuery] DateTime? to,
        [FromQuery] int? limit,
        CancellationToken ct)
    {
        var statistics = await _service.GetDeviceStatisticsAsync(deviceId, teamId, from, to, limit, ct);
        return Ok(statistics);
    }

    [HttpGet("{id:int}/statistics/latest")]
    [ProducesResponseType(typeof(Dtos.Admin.Devices.DeviceStatisticsDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetLatestDeviceStatistics(int id, CancellationToken ct)
    {
        var statistics = await _service.GetLatestDeviceStatisticsAsync(id, ct);
        return statistics == null ? NotFound() : Ok(statistics);
    }

    [HttpPut("statistics/{statisticsId:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateDeviceStatistics(
        int statisticsId,
        [FromBody] UpdateDeviceStatisticsRequest request,
        CancellationToken ct)
    {
        try
        {
            await _service.UpdateDeviceStatisticsAsync(statisticsId, request, ct);
            return Ok(new { message = "Statistics updated successfully" });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(ex.Message);
        }
    }
}
