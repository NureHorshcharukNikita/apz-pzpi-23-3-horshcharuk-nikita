using Elevate.Dtos.Admin.Backup;
using Elevate.Exceptions;
using Elevate.Services.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

[ApiController]
[Route("api/admin/backup")]
[Authorize(Roles = "Admin,SystemAdministrator")]
public class AdminBackupController : ControllerBase
{
    private readonly IAdminBackupService _backupService;

    public AdminBackupController(IAdminBackupService backupService)
    {
        _backupService = backupService;
    }

    [HttpGet("export")]
    [ProducesResponseType(typeof(SystemBackupDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> Export(CancellationToken ct)
    {
        var snapshot = await _backupService.ExportAsync(ct);
        return Ok(snapshot);
    }

    [HttpPost("import")]
    [ProducesResponseType(typeof(ImportBackupResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Import([FromBody] ImportBackupRequestDto request, CancellationToken ct)
    {
        try
        {
            var result = await _backupService.ImportAsync(request, ct);
            return Ok(result);
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
