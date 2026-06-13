public class CVTemplate
{
    public int Id { get; set; }
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string FileName { get; set; } = null!;
    public string FilePath { get; set; } = null!;
    public string ContentType { get; set; } = null!;
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    public string CompanyId { get; set; } = null!;
    public ApplicationUser Company { get; set; } = null!;
}