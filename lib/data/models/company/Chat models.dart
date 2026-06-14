import 'package:flutter/material.dart';

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
    final entityId    = json['entityId']?.toString()    ?? '';
    final isApplicant = applicantId == myId;

    // السيرفر مش بيبعت صورة في الـ rooms response
    // هنستخدم الـ initials فقط في الوقت الحالي
    const String logo = '';

    // ✅ FIX: normalize UTC timestamp
    String normalizeTime(String? raw) {
      if (raw == null || raw.isEmpty) return '';
      return raw.endsWith('Z') ? raw : '${raw}Z';
    }

    return ChatRoom(
      id: json['id'] ?? json['roomId'] ?? 0,

      participantName: isApplicant
          ? (json['entityName']?.toString() ?? 'Unknown')
          : (json['applicantName']?.toString() ?? 'Unknown'),

      participantLogo: logo,

      lastMessage: json['lastMessage']?.toString() ??
          json['lastMessageContent']?.toString() ??
          '',

      // ✅ FIX: normalize الوقت
      lastMessageTime: normalizeTime(
        json['lastMessageAt']?.toString() ??
            json['lastMessageTime']?.toString() ??
            json['updatedAt']?.toString(),
      ),

      unreadCount: json['unreadCount'] ?? json['unreadMessages'] ?? 0,

      participantId: isApplicant ? entityId : applicantId,
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

    // ✅ FIX: normalize UTC timestamp
    String normalizeTime(String? raw) {
      if (raw == null || raw.isEmpty) return '';
      return raw.endsWith('Z') ? raw : '${raw}Z';
    }

    return ChatMessage(
      id:         json['id']     ?? 0,
      roomId:     json['roomId'] ?? 0,
      content:    json['content'] ?? json['message'] ?? '',
      senderId:   senderId,
      senderName: json['senderName'] ?? json['userName'] ?? '',

      // ✅ FIX: normalize الوقت
      sentAt: normalizeTime(
        json['sentAt']?.toString() ??
            json['createdAt']?.toString() ??
            json['timestamp']?.toString(),
      ),

      isRead: json['isRead'] ?? false,
      isMine: senderId == myId,
    );
  }
}