using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace Elevate.Controllers;

public abstract class ApiControllerBase : ControllerBase
{
    protected int? GetCurrentUserId()
    {
        var subject =
            User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub");

        return int.TryParse(subject, out var id) ? id : null;
    }
}
