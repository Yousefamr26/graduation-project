using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using static SendGrid.BaseClient;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;

    public ChatController(IChatService chatService)
    {
        _chatService = chatService;
    }

    // ============================
    // GET: api/chat/rooms
    // جلب كل المحادثات بتاعت اليوزر
    // ============================
    [HttpGet("rooms")]
    public async Task<IActionResult> GetMyRooms()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var rooms = await _chatService.GetUserRoomsAsync(userId);
        return Ok(rooms);
    }

    // ============================
    // POST: api/chat/rooms
    // إنشاء أو فتح محادثة مع شركة
    // ============================
    [HttpPost("rooms")]
    public async Task<IActionResult> GetOrCreateRoom([FromBody] CreateRoomDto dto)
    {
        var applicantId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var room = await _chatService.GetOrCreateRoomAsync(applicantId, dto.EntityId);
        return Ok(room);
    }

    // ============================
    // GET: api/chat/rooms/{roomId}/messages
    // جلب رسائل محادثة معينة
    // ============================
    [HttpGet("rooms/{roomId}/messages")]
    public async Task<IActionResult> GetMessages(int roomId)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        var messages = await _chatService.GetRoomMessagesAsync(roomId, userId);
        return Ok(messages);
    }

    // ============================
    // PUT: api/chat/rooms/{roomId}/read
    // تحديد الرسائل كمقروءة
    // ============================
    [HttpPut("rooms/{roomId}/read")]
    public async Task<IActionResult> MarkAsRead(int roomId)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        await _chatService.MarkAsReadAsync(roomId, userId);
        return NoContent();
    }
    // POST: api/chat/rooms/{roomId}/messages
    [HttpPost("rooms/{roomId}/messages")]
    public async Task<IActionResult> SendMessage(int roomId, [FromBody] SendMessageDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

        // ← ضيف السطر ده
        dto = dto with { RoomId = roomId };

        var message = await _chatService.SendMessageRestAsync(userId, dto);
        return Ok(message);
    }
}
