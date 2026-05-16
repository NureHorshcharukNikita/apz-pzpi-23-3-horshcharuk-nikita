namespace Elevate.Dtos.Actions;

public class UpdateActionTypeDto
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public int DefaultPoints { get; set; }
    public string? Category { get; set; }
    public bool IsActive { get; set; } = true;
}
