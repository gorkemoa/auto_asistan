/// Chat mesaj modeli
class ChatMessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final DiagnosisModel? diagnosis;

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.diagnosis,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      content: json['content'],
      isUser: json['is_user'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['image_url'],
      diagnosis: json['diagnosis'] != null ? DiagnosisModel.fromJson(json['diagnosis']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
      'image_url': imageUrl,
      'diagnosis': diagnosis?.toJson(),
    };
  }
}

/// Arıza teşhis modeli
class DiagnosisModel {
  final String possibleIssue;
  final String severity; // low, medium, high, critical
  final String description;
  final bool canDrive;
  final List<String> recommendations;

  const DiagnosisModel({
    required this.possibleIssue,
    required this.severity,
    required this.description,
    required this.canDrive,
    required this.recommendations,
  });

  factory DiagnosisModel.fromResponse(Map<String, dynamic> json) {
    return DiagnosisModel(
      possibleIssue: json['possible_issue'] ?? 'Bilinmeyen sorun',
      severity: json['severity'] ?? 'medium',
      description: json['description'] ?? '',
      canDrive: json['can_drive'] ?? true,
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      possibleIssue: json['possible_issue'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      canDrive: json['can_drive'] ?? true,
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'possible_issue': possibleIssue,
      'severity': severity,
      'description': description,
      'can_drive': canDrive,
      'recommendations': recommendations,
    };
  }

  String get severityText {
    switch (severity) {
      case 'low': return 'Düşük';
      case 'medium': return 'Orta';
      case 'high': return 'Yüksek';
      case 'critical': return 'Kritik';
      default: return 'Bilinmiyor';
    }
  }
}

/// Sohbet Oturumu Modeli
class ChatSessionModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ChatMessageModel> messages;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    List<ChatMessageModel>? messages,
  }) : messages = messages ?? [];

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      messages: (json['messages'] as List?)
              ?.map((e) => ChatMessageModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}
