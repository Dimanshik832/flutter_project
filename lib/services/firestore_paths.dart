class FirestoreCollections {
  static const String users = 'users';
  static const String reports = 'reports';
  static const String firms = 'firms';
  static const String categories = 'categories';
  static const String firmApplications = 'firmApplications';
  static const String firmHistory = 'firmHistory';
  static const String announcements = 'announcements';
  static const String whitelistApplications = 'whitelistApplications';
  static const String debugPushQueue = 'debugPushQueue';
}

class FirestoreUserFields {
  static const String role = 'role';
  static const String isBanned = 'isBanned';
  static const String fcmToken = 'fcmToken';
  static const String notificationSettings = 'notificationSettings';
  static const String applicationStatus = 'applicationStatus';
  static const String updatedAt = 'updatedAt';
  static const String name = 'name';
  static const String avatarUrl = 'avatarUrl';
  static const String email = 'email';
  static const String fullName = 'fullName';
  static const String album = 'album';
  static const String createdAt = 'createdAt';
}


class FirestoreReportFields {
  static const String title = 'title';
  static const String description = 'description';
  static const String status = 'status';
  static const String room = 'room';
  static const String roomNumber = 'roomNumber';
  static const String category = 'category';
  static const String images = 'images';
  static const String createdAt = 'createdAt';
  static const String userId = 'userId';
  static const String userEmail = 'userEmail';
  static const String sentToFirms = 'sentToFirms';
  static const String sentAt = 'sentAt';
  static const String selectedApplicationId = 'selectedApplicationId';
  static const String assignedFirmId = 'assignedFirmId';
  static const String assignedWorkerIds = 'assignedWorkerIds';
  static const String deadline = 'deadline';
}

class FirestoreCategoryFields {
  static const String name = 'name';
  static const String icon = 'icon';
}

class FirestoreFirmFields {
  static const String name = 'name';
  static const String ownerId = 'ownerId';
  static const String categories = 'categories';
  static const String workerIds = 'workerIds';
  static const String createdAt = 'createdAt';
  static const String logoUrl = 'logoUrl';
  static const String description = 'description';
  static const String email = 'email';
  static const String phone = 'phone';
}

class FirestoreFirmApplicationFields {
  static const String firmId = 'firmId';
  static const String reportId = 'reportId';
  static const String price = 'price';
  static const String workersCount = 'workersCount';
  static const String deadline = 'deadline';
  static const String comment = 'comment';
  static const String createdAt = 'createdAt';
}

class FirestoreAnnouncementFields {
  static const String title = 'title';
  static const String text = 'text';
  static const String type = 'type';
  static const String createdAt = 'createdAt';
  static const String authorEmail = 'authorEmail';
  static const String authorId = 'authorId';
  static const String images = 'images';
}

class FirestoreFirmHistoryFields {
  static const String firmId = 'firmId';
  static const String reportId = 'reportId';
  static const String type = 'type';
  static const String timestamp = 'timestamp';
  static const String title = 'title';
  static const String category = 'category';
}

class FirestoreWhitelistApplicationFields {
  static const String uid = 'uid';
  static const String status = 'status';
  static const String createdAt = 'createdAt';
  static const String userId = 'userId';
}

class FirestoreDebugPushFields {
  static const String userId = 'userId';
  static const String title = 'title';
  static const String body = 'body';
  static const String createdAt = 'createdAt';
}
