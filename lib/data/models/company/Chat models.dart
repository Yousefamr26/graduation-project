class ChatRoom {
  final int id;
  final String participantName;
  final String participantLogo;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final String participantId;

  ChatRoom({
    required this.id,
    required this.participantName,
    required this.participantLogo,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.participantId,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json, String myId) {
    final applicantId = json['applicantId']?.toString() ?? '';
    final isApplicant = applicantId == myId;

    // ✅ DEBUG: اطبع الـ JSON عشان نشوف أسماء الـ fields الصح
    // يمكنك تشيل السطر ده بعد ما تتأكد إن الصورة شغالة
    // debugPrint('🖼️ [ROOM JSON] $json');

    // ✅ FIX: الصورة بتاعة الطرف الثاني — نفس منطق participantName
    String logo = '';
    if (isApplicant) {
      // أنا الـ applicant → الطرف الثاني هو الـ entity (company/university)
      logo = json['entityLogo']?.toString() ??
          json['entityImage']?.toString() ??
          json['entityProfileImage']?.toString() ??
          json['companyLogo']?.toString() ??
          json['universityLogo']?.toString() ??
          json['logoUrl']?.toString() ??
          json['participantLogo']?.toString() ??
          json['otherPartyLogo']?.toString() ??
          '';
    } else {
      // أنا الـ entity → الطرف الثاني هو الـ applicant (user/student)
      logo = json['applicantImage']?.toString() ??
          json['applicantLogo']?.toString() ??
          json['applicantProfileImage']?.toString() ??
          json['profileImage']?.toString() ??
          json['profilePicture']?.toString() ??
          json['userImage']?.toString() ??
          json['studentImage']?.toString() ??
          json['participantLogo']?.toString() ??
          json['otherPartyLogo']?.toString() ??
          '';
    }

    return ChatRoom(
      id: json['id'] ?? json['roomId'] ?? 0,

      // ✅ لو أنا الـ applicant → الطرف الثاني هو الـ entity والعكس
      participantName: isApplicant
          ? (json['entityName']?.toString() ?? 'Unknown')
          : (json['applicantName']?.toString() ?? 'Unknown'),

      participantLogo: logo,

      lastMessage: json['lastMessage']?.toString() ??
          json['lastMessageContent']?.toString() ??
          '',

      lastMessageTime: json['lastMessageAt']?.toString() ??
          json['lastMessageTime']?.toString() ??
          json['updatedAt']?.toString() ??
          '',

      unreadCount: json['unreadCount'] ?? json['unreadMessages'] ?? 0,

      // ✅ الـ participantId هو الطرف الثاني
      participantId: isApplicant
          ? (json['entityId']?.toString() ?? '')
          : applicantId,
    );
  }
}

class ChatMessage {
  final int id;
  final int roomId;
  final String content;
  final String senderId;
  final String senderName;
  final String sentAt;
  final bool isRead;
  bool isMine;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.sentAt,
    required this.isRead,
    required this.isMine,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myId) {
    final senderId =
        json['senderId']?.toString() ?? json['userId']?.toString() ?? '';
    return ChatMessage(
      id:         json['id']      ?? 0,
      roomId:     json['roomId']  ?? 0,
      content:    json['content'] ?? json['message'] ?? '',
      senderId:   senderId,
      senderName: json['senderName'] ?? json['userName'] ?? '',
      sentAt:     json['sentAt']     ??
          json['createdAt']          ??
          json['timestamp']          ??
          '',
      isRead: json['isRead'] ?? false,
      isMine: senderId == myId,
    );
  }
}