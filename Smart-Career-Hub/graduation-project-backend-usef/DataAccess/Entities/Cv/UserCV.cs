using Resend;

public class UserCV
{
    public int Id { get; set; }
    public string FileName { get; set; } = null!;
    public string FilePath { get; set; } = null!;
    public string ContentType { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public ApplicationUser User { get; set; } = null!;
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

    // Optional - لو عايز تعرف الطالب استخدم أنهي تمبليت
    public int? CVTemplateId { get; set; }
    public CVTemplate? CVTemplate { get; set; }
}