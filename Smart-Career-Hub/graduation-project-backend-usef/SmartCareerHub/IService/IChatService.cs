public interface IChatService
{
    // إنشاء أو جلب room موجود بين يوزرين
    Task<ChatRoomDto> GetOrCreateRoomAsync(string applicantId, string entityId);

    // جلب كل المحادثات بتاعت يوزر معين
    Task<IEnumerable<ChatRoomDto>> GetUserRoomsAsync(string userId);

    // جلب رسائل room معين
    Task<IEnumerable<MessageDto>> GetRoomMessagesAsync(int roomId, string userId);

    // بعت رسالة
    Task<MessageDto> SendMessageAsync(string senderId, SendMessageDto dto);

    // تحديد الرسائل كمقروءة
    Task MarkAsReadAsync(int roomId, string userId);
    Task<MessageDto> SendMessageRestAsync(string senderId, SendMessageDto dto);
}