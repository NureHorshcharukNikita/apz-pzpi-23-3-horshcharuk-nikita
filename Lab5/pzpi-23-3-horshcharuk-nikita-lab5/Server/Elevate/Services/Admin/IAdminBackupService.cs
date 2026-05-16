using Elevate.Dtos.Admin.Backup;

namespace Elevate.Services.Admin;

public interface IAdminBackupService
{
    Task<SystemBackupDto> ExportAsync(CancellationToken cancellationToken = default);

    Task<ImportBackupResultDto> ImportAsync(ImportBackupRequestDto request, CancellationToken cancellationToken = default);
}
