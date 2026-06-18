namespace Business_Logic.IService
{
    public interface IRealTimeNotificationService
    {
        Task SendToUserAsync(string userId, string title, string message);

        Task SendToUsersAsync(List<string> userIds, string title, string message);

        Task BroadcastAsync(string title, string message);
    }
}