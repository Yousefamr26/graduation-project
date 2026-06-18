using Business_Logic.IService;
using Microsoft.AspNetCore.SignalR;

namespace Business_Logic.Service
{
    public class RealTimeNotificationService : IRealTimeNotificationService
    {
        private readonly IHubContext<NotificationHub> _hubContext;

        public RealTimeNotificationService(
            IHubContext<NotificationHub> hubContext)
        {
            _hubContext = hubContext;
        }

        // 🔹 إرسال لمستخدم واحد
        public async Task SendToUserAsync(
            string userId,
            string title,
            string message)
        {
            await _hubContext.Clients
                .Group(userId)
                .SendAsync("ReceiveNotification", new
                {
                    title,
                    message,
                    time = DateTime.UtcNow
                });
        }

        // 🔹 إرسال لمجموعة Users
        public async Task SendToUsersAsync(
            List<string> userIds,
            string title,
            string message)
        {
            await _hubContext.Clients
                .Groups(userIds)
                .SendAsync("ReceiveNotification", new
                {
                    title,
                    message,
                    time = DateTime.UtcNow
                });
        }

        // 🔹 Broadcast لكل الناس
        public async Task BroadcastAsync(
            string title,
            string message)
        {
            await _hubContext.Clients
                .All
                .SendAsync("ReceiveNotification", new
                {
                    title,
                    message,
                    time = DateTime.UtcNow
                });
        }
    }
}