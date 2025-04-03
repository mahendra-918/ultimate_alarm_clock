# Enhanced Snooze Functionality - Implementation Details

## Overview

The enhanced snooze functionality enhances the alarm experience by providing users with greater control over the snooze behavior. This implementation offers three primary features:

1. **Basic Snooze Duration Setting** - Allows users to set a custom duration for the snooze period (1-60 minutes).
2. **Maximum Snooze Count** - Limits the number of times an alarm can be snoozed.
3. **Smart Snooze** - Gradually decreases the snooze duration to help users wake up progressively.

## Data Model Changes

The enhanced snooze functionality required extending the `AlarmModel` class with the following properties:

```dart
// Maximum number of times the alarm can be snoozed (0 = unlimited)
late int maxSnoozeCount;

// Tracks how many times the current alarm has been snoozed
late int currentSnoozeCount;

// Whether Smart Snooze feature is enabled
late bool smartSnoozeEnabled;

// Amount by which to decrease snooze duration each time (in minutes)
late int smartSnoozeDecrement;

// Minimum duration that Smart Snooze can reach
late int minSmartSnoozeDuration;

// History of snooze events for analytics
@ignore
List<Map<String, dynamic>> snoozeHistory = [];
```

## UI Implementation

### Unified Snooze Settings Interface

A merged snooze settings interface was created to consolidate all snooze-related settings into a single, comprehensive screen:

1. **Access Point**: A dedicated "Snooze Settings" tile in the alarm creation/editing flow.
2. **Full-Screen Layout**: Settings open in a full-screen view for better usability.
3. **Visual Indicators**: The main tile displays icons and labels indicating enabled features.

### Main Components

1. **Snooze Duration Picker**
   - Number picker for selecting the snooze duration (0-60 minutes)
   - Setting to 0 disables the snooze functionality

2. **Maximum Snooze Count Control**
   - Number picker for selecting the maximum count (0-10)
   - 0 represents unlimited snoozes
   - Visual indicator showing "∞" for unlimited

3. **Smart Snooze Toggle and Settings**
   - Toggle switch to enable/disable Smart Snooze
   - When enabled, additional settings appear:
     - Decrement amount (1-5 minutes)
     - Minimum snooze duration (1+ minutes)

4. **Information Section**
   - Explanatory text about Smart Snooze functionality

## Logic Implementation

### Alarm Ring Controller

The `AlarmRingController` was enhanced with the following logic:

1. **Snooze Count Tracking**
   ```dart
   final RxInt currentSnoozeCount = 0.obs;
   ```
   - Initialized with the alarm's current count
   - Incremented each time snooze is activated
   - Persisted between app sessions via database

2. **Smart Snooze Calculation**
   ```dart
   int calculateNextSnoozeDuration() {
     if (!currentlyRingingAlarm.value.smartSnoozeEnabled) {
       return currentlyRingingAlarm.value.snoozeDuration;
     }
     
     int decrementedDuration = currentlyRingingAlarm.value.snoozeDuration - 
         (currentSnoozeCount.value * currentlyRingingAlarm.value.smartSnoozeDecrement);
     
     return math.max(decrementedDuration, currentlyRingingAlarm.value.minSmartSnoozeDuration);
   }
   ```
   - Calculates the next snooze duration based on:
     - Base duration
     - Current snooze count
     - Decrement amount
     - Minimum duration threshold

3. **Snooze Limit Enforcement**
   ```dart
   if (currentlyRingingAlarm.value.maxSnoozeCount > 0 && 
       currentSnoozeCount.value >= currentlyRingingAlarm.value.maxSnoozeCount) {
     snoozeDisabled.value = true;
   } else {
     snoozeDisabled.value = false;
   }
   ```
   - Disables the snooze button when limit is reached
   - Shows an explanatory snackbar when limit is hit

4. **Snooze History Tracking**
   ```dart
   var snoozeEvent = {
     'timestamp': DateTime.now().toIso8601String(),
     'duration': minutes.value,
   };
   currentlyRingingAlarm.value.snoozeHistory.add(snoozeEvent);
   ```
   - Records each snooze event with timestamp and duration
   - Allows for future analytics and insights

## User Interface Flow

1. **Alarm Creation/Edit Screen**
   - User sees the "Snooze Settings" tile
   - Tile shows indicators for active features (Smart Snooze icon, max count)
   - Subtitle shows duration and additional information

2. **Snooze Settings Screen**
   - Accessed by tapping the Snooze Settings tile
   - Full-screen interface with sections for each setting
   - Interactive controls with immediate feedback
   - Done button to save changes

3. **Alarm Ring Screen**
   - Displays countdown timer when snoozing
   - Shows remaining time until next ring
   - Snooze button is disabled when maximum count is reached
   - For Smart Snooze, displays the calculated next duration

## Database Integration

The enhanced snooze properties are fully integrated with the app's persistence layer:

1. **Local Storage (Isar)**
   - All snooze properties stored in local database
   - Updates when alarm settings change or snooze occurs

2. **Cloud Storage (Firestore)**
   - For shared alarms, snooze state synchronized across devices
   - Fields added to the document structure

## Benefits for Users

1. **Better Wake-Up Experience**
   - Gradual transition from sleep to wakefulness with Smart Snooze
   - More control over snooze behavior

2. **Avoiding Oversleeping**
   - Maximum snooze count prevents excessive delaying
   - Visual indicators show remaining snoozes

3. **Personalization**
   - Different users can set custom snooze behaviors based on preferences
   - All settings accessible from a single, intuitive interface

## Technical Implementation Notes

1. **Reactive Programming**
   - All snooze properties are reactive (using GetX's Rx types)
   - UI updates immediately when values change

2. **Persistence**
   - Snooze state persists between app sessions
   - Current snooze count resets for recurring alarms on new days

3. **UI Components**
   - Custom Tile component for alarm list with visual indicators
   - Full-screen settings page with standardized style
   - Number pickers for intuitive value selection

4. **Validation**
   - Smart Snooze settings enforce logical constraints
   - Minimum duration cannot exceed initial duration
   - Decrement value limited to reasonable range (1-5 minutes)

## Future Enhancements

1. **Snooze Analytics**
   - Leverage snooze history to provide insights
   - Statistics on snooze patterns

2. **More Customization Options**
   - Different snooze behaviors for weekdays vs. weekends
   - Custom snooze sound options

3. **Integration with Other Features**
   - Smart snooze that adapts based on weather or sleep data
   - Integration with health metrics

## Conclusion

The enhanced snooze functionality transforms a basic alarm feature into a sophisticated wake-up system. By providing users with greater control and smarter defaults, the alarm experience becomes more personalized and effective. The implementation is designed to be intuitive while offering powerful customization options that cater to various user preferences and needs. 