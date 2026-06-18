using DataAccess.Contexts;
using Microsoft.EntityFrameworkCore;

public class ChatService : IChatService
{
    private readonly ApplicationDbContext _db;

    public ChatService(ApplicationDbContext db)
    {
        _db = db;
    }

    // إنشاء أو جلب room موجود
    public async Task<ChatRoomDto> GetOrCreateRoomAsync(string applicantId, string entityId)
    {
        // هل في room موجود بين الاتنين؟
        var room = await _db.ChatRooms
            .Include(r => r.Applicant)
            .Include(r => r.Entity)
            .Include(r => r.Messages)
            .FirstOrDefaultAsync(r =>
                r.ApplicantId == applicantId &&
                r.EntityId == entityId);

        // لو مفيش room نعمل واحد جديد
        if (room == null)
        {
            room = new ChatRoom
            {
                ApplicantId = applicantId,
                EntityId = entityId,
                CreatedAt = DateTime.UtcNow
            };
            _db.ChatRooms.Add(room);
            await _db.SaveChangesAsync();

            // جيب الـ room تاني مع الـ includes
            room = await _db.ChatRooms
                .Include(r => r.Applicant)
                .Include(r => r.Entity)
                .Include(r => r.Messages)
                .FirstAsync(r => r.Id == room.Id);
        }

        return MapToRoomDto(room, applicantId);
    }

    // جلب كل المحادثات بتاعت يوزر
    public async Task<IEnumerable<ChatRoomDto>> GetUserRoomsAsync(string userId)
    {
        var rooms = await _db.ChatRooms
            .Include(r => r.Applicant)
            .Include(r => r.Entity)
            .Include(r => r.Messages)
            .Where(r => r.ApplicantId == userId || r.EntityId == userId)
            .OrderByDescending(r => r.Messages
                .Max(m => (DateTime?)m.SentAt) ?? r.CreatedAt)
            .ToListAsync();

        return rooms.Select(r => MapToRoomDto(r, userId));
    }

    // جلب رسائل room معين
    public async Task<IEnumerable<MessageDto>> GetRoomMessagesAsync(int roomId, string userId)
    {
        // تأكد إن اليوزر من ضمن المحادثة
        var room = await _db.ChatRooms
            .FirstOrDefaultAsync(r => r.Id == roomId &&
                (r.ApplicantId == userId || r.EntityId == userId));

        if (room == null)
            throw new UnauthorizedAccessException("مش مسموح ليك تشوف المحادثة دي");

        var messages = await _db.Messages
            .Include(m => m.Sender)
            .Where(m => m.ChatRoomId == roomId)
            .OrderBy(m => m.SentAt)
            .ToListAsync();

        return messages.Select(m => new MessageDto(
            m.Id,
            m.Content,
            m.SentAt,
            m.IsRead,
            m.SenderId,
            $"{m.Sender.FirstName} {m.Sender.LastName}"
        ));
    }

    // بعت رسالة
    public async Task<MessageDto> SendMessageAsync(string senderId, SendMessageDto dto)
    {
        // تأكد إن السيندر من ضمن المحادثة
        var room = await _db.ChatRooms
            .FirstOrDefaultAsync(r => r.Id == dto.RoomId &&
                (r.ApplicantId == senderId || r.EntityId == senderId));

        if (room == null)
            throw new UnauthorizedAccessException("مش مسموح ليك تبعت في المحادثة دي");

        var message = new Message
        {
            Content = dto.Content,
            SenderId = senderId,
            ChatRoomId = dto.RoomId,
            SentAt = DateTime.UtcNow,
            IsRead = false
        };

        _db.Messages.Add(message);
        await _db.SaveChangesAsync();

        var sender = await _db.Users.FindAsync(senderId);

        return new MessageDto(
            message.Id,
            message.Content,
            message.SentAt,
            message.IsRead,
            message.SenderId,
            $"{sender.FirstName} {sender.LastName}"
        );
    }

    // تحديد الرسائل كمقروءة
    public async Task MarkAsReadAsync(int roomId, string userId)
    {
        var messages = await _db.Messages
            .Where(m => m.ChatRoomId == roomId &&
                        m.SenderId != userId &&
                        m.IsRead == false)
            .ToListAsync();

        messages.ForEach(m => m.IsRead = true);
        await _db.SaveChangesAsync();
    }
    public async Task<MessageDto> SendMessageRestAsync(string senderId, SendMessageDto dto)
    {
        var room = await _db.ChatRooms
            .FirstOrDefaultAsync(r => r.Id == dto.RoomId &&
                (r.ApplicantId == senderId || r.EntityId == senderId));

        if (room == null)
            throw new UnauthorizedAccessException("مش مسموح");

        var message = new Message
        {
            Content = dto.Content,
            SenderId = senderId,
            ChatRoomId = dto.RoomId,
            SentAt = DateTime.UtcNow,
            IsRead = false
        };

        _db.Messages.Add(message);
        await _db.SaveChangesAsync();

        var sender = await _db.Users.FindAsync(senderId);

        return new MessageDto(
            message.Id,
            message.Content,
            message.SentAt,
            message.IsRead,
            message.SenderId,
            $"{sender.FirstName} {sender.LastName}"
        );
    }


    // Helper Method
    private ChatRoomDto MapToRoomDto(ChatRoom room, string userId)
    {
        var lastMessage = room.Messages
            .OrderByDescending(m => m.SentAt)
            .FirstOrDefault();

        var unreadCount = room.Messages
            .Count(m => m.SenderId != userId && !m.IsRead);

        return new ChatRoomDto(
            room.Id,
            room.ApplicantId,
            $"{room.Applicant.FirstName} {room.Applicant.LastName}",
            room.EntityId,
            $"{room.Entity.FirstName} {room.Entity.LastName}",
            room.CreatedAt,
            lastMessage?.Content,
            lastMessage?.SentAt,
            unreadCount
        );
    }
}