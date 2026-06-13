namespace DataAccess.Entities
{
    public class PasswordResetOtp
    {
        public int Id { get; set; }
        public string UserId { get; set; }         // string لأن Identity بيستخدم string ID
        public string OtpCode { get; set; }
        public DateTime ExpiresAt { get; set; }
        public bool IsUsed { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public ApplicationUser User { get; set; }
    }
}