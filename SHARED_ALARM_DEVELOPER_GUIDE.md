# 🔔 Shared Alarm System - Developer Guide

## Architecture Overview

### Core Components
```
📱 Flutter Frontend
├── Controllers (Business Logic)
├── Views (UI Components)  
├── Models (Data Structures)
└── Providers (Data Access)

☁️ Firebase Backend
├── Firestore (Database)
├── Cloud Functions (Server Logic)
├── FCM (Push Notifications)
└── Auth (User Management)

🤖 Native Layer
├── AlarmManager (Android)
├── Background Services
└── Local Storage
```

## Key Files & Directories

### Frontend (Flutter)
```
lib/app/modules/addOrUpdateAlarm/
├── controllers/add_or_update_alarm_controller.dart
├── views/shared_alarm_tile.dart
└── views/alarm_offset_tile.dart

lib/app/modules/notifications/
├── controllers/notifications_controller.dart
└── views/notifications_view.dart

lib/app/modules/home/
└── controllers/home_controller.dart

lib/app/data/
├── models/alarm_model.dart
├── providers/firestore_provider.dart
└── providers/isar_provider.dart
```

### Backend (Firebase)
```
functions/
├── rescheduleAlarm.js
└── index.js

firestore.rules
```

### Native (Android)
```
android/app/src/main/kotlin/.../
├── AlarmReceiver.kt
├── AlarmUtils.kt
├── MainActivity.kt
└── GetLatestAlarm.kt
```

## Data Models

### AlarmModel Structure
```dart
class AlarmModel {
  // Core Properties
  String alarmTime;              // Main alarm time
  String alarmID;                // Unique identifier
  bool isSharedAlarmEnabled;     // Enable sharing
  
  // Sharing Properties  
  String? firestoreId;           // Firestore document ID
  List<String>? sharedUserIds;   // Invited users
  String ownerId;                // Creator's user ID
  String ownerName;              // Creator's display name
  String lastEditedUserId;       // Last editor
  bool mutexLock;                // Edit lock
  
  // Offset System
  String? mainAlarmTime;         // Original time set by owner
  List<Map>? offsetDetails;      // User-specific time offsets
  
  // ... other alarm properties
}
```

### Offset Details Structure
```dart
Map<String, dynamic> offsetDetails = {
  'userId1': {
    'offsetDuration': 15,        // Minutes offset
    'isOffsetBefore': true,      // Before/after main time
    'offsettedTime': '06:45'     // Calculated result
  },
  'userId2': {
    'offsetDuration': 0,         // No offset
    'isOffsetBefore': true,      
    'offsettedTime': '07:00'     // Same as main time
  }
};
```

## Core Functionality

### 1. Creating Shared Alarms

```dart
// Enable sharing
controller.isSharedAlarmEnabled.value = true;

// Initialize settings
await controller.initializeSharedAlarmSettings();

// Save to Firestore
if (alarmRecord.isSharedAlarmEnabled) {
  await FirestoreDb.addAlarm(user, alarmRecord);
}
```

### 2. Sharing Process

```dart
// Share with multiple users
await FirestoreDb.shareAlarm(emails, alarm);

// Create notification item
Map sharedItem = {
  'type': 'alarm',
  'AlarmName': alarm.firestoreId,
  'owner': ownerName,
  'alarmTime': alarm.alarmTime
};

// Send to recipients
for (String email in emails) {
  await addItemToUserByEmail(email, sharedItem);
}
```

### 3. Real-time Synchronization

```dart
// Setup Firestore listener
void setupSharedAlarmListener() {
  FirestoreDb.getSharedAlarms(userModel.value).listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        // Handle alarm updates
        processSharedAlarmUpdate(change.doc);
      }
    }
  });
}
```

### 4. Offset Calculation

```dart
// Calculate offset time
DateTime calculateOffsetAlarmTime(
  DateTime mainTime,
  bool isOffsetBefore,
  int offsetDuration,
) {
  if (isOffsetBefore) {
    return mainTime.subtract(Duration(minutes: offsetDuration));
  } else {
    return mainTime.add(Duration(minutes: offsetDuration));
  }
}
```

## Database Schema

### Firestore Collections

#### sharedAlarms/{alarmId}
```json
{
  "alarmTime": "07:00",
  "alarmID": "uuid-string",
  "ownerId": "user-uid",
  "ownerName": "John Doe", 
  "sharedUserIds": ["uid1", "uid2"],
  "isEnabled": true,
  "isSharedAlarmEnabled": true,
  "offsetDetails": {
    "user-uid": {
      "offsetDuration": 0,
      "isOffsetBefore": true,
      "offsettedTime": "07:00"
    }
  },
  "lastEditedUserId": "user-uid",
  "mutexLock": false,
  "days": [true, true, true, true, true, false, false],
  "minutesSinceMidnight": 420,
  // ... other alarm properties
}
```

#### users/{userId}
```json
{
  "email": "user@example.com",
  "fullName": "John Doe",
  "fcmToken": "fcm-token-string",
  "receivedItems": [
    {
      "type": "alarm",
      "AlarmName": "alarm-firestore-id",
      "owner": "Jane Doe",
      "alarmTime": "07:00"
    }
  ]
}
```

## API Methods

### FirestoreProvider Methods

```dart
// Core CRUD operations
static addAlarm(UserModel? user, AlarmModel alarmRecord)
static updateAlarm(String? userId, AlarmModel alarmRecord) 
static deleteAlarm(UserModel? user, String id)
static getLatestAlarm(UserModel? user, AlarmModel alarmRecord, bool wantNextAlarm)

// Sharing operations
static shareAlarm(List emails, AlarmModel alarm)
static acceptSharedAlarm(String alarmOwnerId, AlarmModel alarm)
static removeUserFromAlarmSharedUsers(UserModel? userModel, String alarmID)

// Dismissal tracking
static markSharedAlarmDismissedByUser(String firestoreId, String userId)

// Real-time streams
static Stream<QuerySnapshot> getSharedAlarms(UserModel? user)
static Stream<DocumentSnapshot> getNotifications()
```

### Controller Methods

```dart
// AddOrUpdateAlarmController
Future<void> initializeSharedAlarmSettings()
Future<void> createAlarm(AlarmModel alarmRecord)
Future<void> updateAlarm(AlarmModel alarmRecord)

// HomeController  
Future<void> refreshUpcomingAlarms()
Future<void> scheduleAlarmIfNeeded(AlarmModel alarm, bool isShared)
void setupSharedAlarmListener()
Future<void> updateSharedAlarmCache(AlarmModel alarm, int intervalToAlarm)

// NotificationsController
Future acceptSharedAlarm(String alarmOwnerId, String alarmId)
Future<void> scheduleAcceptedSharedAlarm(AlarmModel alarm)
```

## Security Rules

### Firestore Security
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Shared alarms access control
    match /sharedAlarms/{alarmId} {
      allow read, write: if request.auth != null && (
        resource.data.ownerId == request.auth.uid ||
        request.auth.uid in resource.data.sharedUserIds ||
        // Allow creation if user is owner
        (request.method == "create" && 
         request.auth.uid == request.resource.data.ownerId) ||
        // Allow users to accept shared alarms
        (request.method == "update" && 
         request.auth.uid in request.resource.data.sharedUserIds &&
         !(request.auth.uid in resource.data.sharedUserIds))
      );
    }
    
    // User notifications
    match /userNotifications/{userId}/notifications/{notificationId} {
      allow read, write: if request.auth != null && 
                          request.auth.uid == userId;
    }
  }
}
```

## Native Implementation

### Android AlarmReceiver
```kotlin
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val isSharedAlarm = intent.getBooleanExtra("isSharedAlarm", false)
        
        if (isSharedAlarm) {
            // Handle shared alarm ringing
            handleSharedAlarmRing(context, intent)
        } else {
            // Handle local alarm ringing  
            handleLocalAlarmRing(context, intent)
        }
    }
}
```

### Shared Preferences Caching
```kotlin
// Cache shared alarm data
val editor = sharedPreferences.edit()
editor.putBoolean("flutter.has_active_shared_alarm", true)
editor.putString("flutter.shared_alarm_id", alarmID)
editor.putString("flutter.shared_alarm_time", alarmTime)
editor.apply()
```

## Testing Strategies

### Unit Tests
```dart
// Test offset calculations
testWidgets('should calculate correct offset times', (tester) async {
  final mainTime = DateTime(2024, 1, 1, 7, 0); // 7:00 AM
  final offsetTime = Utils.calculateOffsetAlarmTime(mainTime, true, 15);
  expect(offsetTime.hour, 6);
  expect(offsetTime.minute, 45);
});

// Test sharing logic
test('should create shared item correctly', () {
  final alarm = createTestAlarm();
  final sharedItem = createSharedItem(alarm);
  expect(sharedItem['type'], 'alarm');
  expect(sharedItem['alarmTime'], alarm.alarmTime);
});
```

### Integration Tests
```dart
// Test end-to-end sharing flow
testWidgets('complete sharing flow', (tester) async {
  // 1. Create shared alarm
  await createSharedAlarm(tester);
  
  // 2. Share with user
  await shareAlarmWithUser(tester, 'test@example.com');
  
  // 3. Verify notification sent
  verify(mockFirestore.collection('users').doc(any).update(any));
  
  // 4. Accept shared alarm
  await acceptSharedAlarm(tester);
  
  // 5. Verify alarm scheduled
  verify(mockAlarmManager.setExact(any, any, any));
});
```

## Performance Considerations

### Optimization Strategies
1. **Efficient Queries**: Use compound indexes for Firestore queries
2. **Caching**: Cache shared alarm data locally
3. **Debouncing**: Debounce real-time updates to prevent excessive calls
4. **Pagination**: Implement pagination for large alarm lists
5. **Background Sync**: Minimize foreground processing

### Firestore Indexes
```json
{
  "indexes": [
    {
      "collectionGroup": "sharedAlarms",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "isEnabled", "order": "ASCENDING"},
        {"fieldPath": "ownerId", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "sharedAlarms", 
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "isEnabled", "order": "ASCENDING"},
        {"fieldPath": "sharedUserIds", "arrayConfig": "CONTAINS"}
      ]
    }
  ]
}
```

## Debugging & Monitoring

### Debug Information
```dart
// Enable debug logging
debugPrint('🔔 Shared alarm operation: $operation');
debugPrint('   - User: ${userModel.value?.email}');
debugPrint('   - Alarm ID: ${alarm.firestoreId}');
debugPrint('   - Sync status: $syncStatus');
```

### Error Handling
```dart
try {
  await FirestoreDb.shareAlarm(emails, alarm);
} catch (e) {
  debugPrint('❌ Error sharing alarm: $e');
  
  // Show user-friendly error
  Get.snackbar(
    'Sharing Failed',
    'Could not share alarm. Please try again.',
    backgroundColor: Colors.red.withOpacity(0.1),
  );
  
  // Log for analytics
  analytics.trackError('shared_alarm_share_failed', e.toString());
}
```

## Deployment Checklist

### Pre-deployment
- [ ] Run all tests (unit, integration, e2e)
- [ ] Verify Firestore security rules
- [ ] Test offline functionality
- [ ] Validate real-time sync
- [ ] Check notification delivery
- [ ] Test cross-platform compatibility

### Post-deployment  
- [ ] Monitor error rates
- [ ] Check Firestore usage
- [ ] Verify notification delivery rates
- [ ] Monitor user adoption
- [ ] Collect user feedback

## Contributing Guidelines

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable names
- Add comprehensive comments
- Include error handling
- Write unit tests for new features

### Pull Request Process
1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Submit PR with detailed description
5. Address review feedback
6. Merge after approval

---

*Developer Guide v2.1 | Last Updated: December 2024* 