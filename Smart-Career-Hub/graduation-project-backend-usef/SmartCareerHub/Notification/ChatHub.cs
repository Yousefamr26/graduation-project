using DataAccess.Contexts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

[Authorize]
public class ChatHub : Hub
{
    private readonly ApplicationDbContext _db;

    public ChatHub(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task JoinRoom(int roomId)
    {
        var userId = Context.UserIdentifier;

        var room = await _db.ChatRooms
            .FirstOrDefaultAsync(r => r.Id == roomId &&
                (r.ApplicantId == userId || r.EntityId == userId));

        if (room == null)
            throw new HubException("مش مسموح ليك تدخل المحادثة دي");

        await Groups.AddToGroupAsync(Context.ConnectionId, roomId.ToString());

        // تحديد الرسائل كمقروءة
        var unreadMessages = await _db.Messages
            .Where(m => m.ChatRoomId == roomId &&
                        m.SenderId != userId &&
                        m.IsRead == false)
            .ToListAsync();

        unreadMessages.ForEach(m => m.IsRead = true);
        await _db.SaveChangesAsync();
    }

    public async Task SendMessage(int roomId, string content)
    {
        var userId = Context.UserIdentifier;

        var room = await _db.ChatRooms
            .FirstOrDefaultAsync(r => r.Id == roomId &&
                (r.ApplicantId == userId || r.EntityId == userId));

        if (room == null)
            throw new HubException("مش مسموح ليك تبعت في المحادثة دي");

        // ✅ جيب اسم الـ Sender الصح
        var sender = await _db.Users.FindAsync(userId);

        var message = new Message
        {
            Content = content,
            SenderId = userId,
            ChatRoomId = roomId,
            SentAt = DateTime.UtcNow,
            IsRead = false
        };

        _db.Messages.Add(message);
        await _db.SaveChangesAsync();

        var messageData = new
        {
            message.Id,
            message.Content,
            message.SentAt,
            message.IsRead,
            SenderId = userId,
            SenderName = $"{sender.FirstName} {sender.LastName}" // ✅ مصلح
        };

        // ابعت للـ room
        await Clients.Group(roomId.ToString()).SendAsync("ReceiveMessage", messageData);

        // ✅ إشعار للطرف التاني لو مش في الـ room
        var otherUserId = room.ApplicantId == userId ? room.EntityId : room.ApplicantId;
        await Clients.User(otherUserId).SendAsync("NewMessageNotification", new
        {
            roomId,
            message.Content,
            SenderName = $"{sender.FirstName} {sender.LastName}"
        });
    }

    public async Task LeaveRoom(int roomId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, roomId.ToString());
    }

    public override async Task OnDisconnectedAsync(Exception exception)
    {
        if (exception != null)
            Console.WriteLine($"ChatHub Disconnected: {exception.Message}");

        await base.OnDisconnectedAsync(exception);
    }
}