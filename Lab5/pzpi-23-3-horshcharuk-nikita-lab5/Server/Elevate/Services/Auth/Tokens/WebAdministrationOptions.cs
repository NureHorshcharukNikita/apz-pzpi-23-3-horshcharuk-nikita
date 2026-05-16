namespace Elevate.Services.Auth.Tokens;

public sealed class WebAdministrationOptions
{
    public const string SectionName = "WebAdministration";

    public string Login { get; set; } = "sysadmin";
}
