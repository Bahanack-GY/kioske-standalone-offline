/// Activity model for tracking system activities/audit log
class Activity {
  final String id;
  final String userId;
  final String? userName;
  final String
  action; // 'login' | 'logout' | 'sale' | 'refund' | 'stock_update' | etc.
  final String
  entityType; // 'order' | 'product' | 'customer' | 'employee' | etc.
  final String? entityId;
  final String? description;
  final String? metadata; // JSON string for additional data
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.userId,
    this.userName,
    required this.action,
    required this.entityType,
    this.entityId,
    this.description,
    this.metadata,
    required this.createdAt,
  });

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String?,
      action: map['action'] as String,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String?,
      description: map['description'] as String?,
      metadata: map['metadata'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
