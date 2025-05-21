import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;

// Call this function to test Firestore alarm fetching
Future<void> testFirestoreAlarms(String userId) async {
  try {
    developer.log('Starting Firestore test with user ID: $userId', name: 'FirestoreTest');
    
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // Query for alarms where user is the owner
    developer.log('Querying for owner alarms', name: 'FirestoreTest');
    final ownerQuery = await firestore.collection('sharedAlarms')
        .where('isEnabled', isEqualTo: true)
        .where('ownerId', isEqualTo: userId)
        .get();
    
    developer.log('Found ${ownerQuery.docs.length} owner alarms', name: 'FirestoreTest');

    // Query for alarms shared with this user
    developer.log('Querying for shared alarms', name: 'FirestoreTest');
    final sharedQuery = await firestore.collection('sharedAlarms')
        .where('isEnabled', isEqualTo: true)
        .where('sharedUserIds', arrayContains: userId)
        .get();
    
    developer.log('Found ${sharedQuery.docs.length} shared alarms', name: 'FirestoreTest');

    // Process owner alarms
    for (final doc in ownerQuery.docs) {
      developer.log('Owner alarm ID: ${doc.id}', name: 'FirestoreTest');
      developer.log('Owner alarm time: ${doc.data()['alarmTime']}', name: 'FirestoreTest');
    }
    
    // Process shared alarms
    for (final doc in sharedQuery.docs) {
      developer.log('Shared alarm ID: ${doc.id}', name: 'FirestoreTest');
      developer.log('Shared alarm time: ${doc.data()['alarmTime']}', name: 'FirestoreTest');
      
      // Verify the user ID is in sharedUserIds
      final sharedUserIds = doc.data()['sharedUserIds'] as List<dynamic>?;
      if (sharedUserIds != null) {
        developer.log('User ID in sharedUserIds: ${sharedUserIds.contains(userId)}', name: 'FirestoreTest');
      } else {
        developer.log('sharedUserIds is null or not a list', name: 'FirestoreTest');
      }
    }

    developer.log('Firestore test completed successfully', name: 'FirestoreTest');
  } catch (e) {
    developer.log('Error in Firestore test: $e', name: 'FirestoreTest');
  }
}

// Call this function to create a test alarm
Future<void> createTestAlarm(String userId) async {
  try {
    developer.log('Creating test alarm for user ID: $userId', name: 'FirestoreTest');
    
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // Get current date and calculate time 2 minutes from now
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year, 
      now.month, 
      now.day, 
      now.hour, 
      now.minute + 2
    );
    
    // Format time as HH:MM
    final formattedTime = "${alarmTime.hour.toString().padLeft(2, '0')}:${alarmTime.minute.toString().padLeft(2, '0')}";
    
    // Create test alarm
    await firestore.collection('sharedAlarms').add({
      'ownerId': userId,
      'isEnabled': true,
      'minutesSinceMidnight': alarmTime.hour * 60 + alarmTime.minute,
      'alarmTime': formattedTime,
      'days': [true, true, true, true, true, true, true], // Every day
      'isOneTime': false,
      'activityMonitor': false,
      'isWeatherEnabled': false,
      'weatherTypes': "[]",
      'isLocationEnabled': false,
      'location': "",
      'alarmDate': "${alarmTime.year}-${alarmTime.month.toString().padLeft(2, '0')}-${alarmTime.day.toString().padLeft(2, '0')}",
      'alarmID': "test_${now.millisecondsSinceEpoch}",
      'ringOn': false,
      'sharedUserIds': [userId]
    });
    
    developer.log('Test alarm created successfully for time: $formattedTime', name: 'FirestoreTest');
  } catch (e) {
    developer.log('Error creating test alarm: $e', name: 'FirestoreTest');
  }
} 