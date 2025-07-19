#!/bin/bash

echo "=== Weather Option 1 Test ==="
echo "This tests 'Ring when weather matches' functionality"
echo ""

# Function to wait for user input
wait_for_input() {
    read -p "Press Enter to continue..."
}

echo "TEST SETUP:"
echo "1. Check your current weather on Google"
echo "2. Set an alarm with weather condition 'Option 1' (Ring when weather matches)"
echo "3. Select the SAME weather condition that Google shows"
echo "4. Set the alarm for 2 minutes from now"
echo "5. Come back here and press Enter"
wait_for_input

echo ""
echo "EXPECTED BEHAVIOR:"
echo "- Since you selected the SAME weather as current, the alarm SHOULD ring"
echo "- Option 1 = 'Ring when weather matches' = condition type 1"
echo "- If current weather matches selected weather, shouldRing = true"
echo ""

echo "CLEARING LOGS..."
adb logcat -c

echo ""
echo "MONITORING WEATHER SERVICE..."
echo "Looking for key debug information:"
echo ""

# Monitor specific debug lines
adb logcat | grep -E "WeatherFetcherService.*Weather condition type|WeatherFetcherService.*Converted weather types|WeatherFetcherService.*Weather determination|WeatherMatch.*Current weather|WeatherMatch.*Selected weather types|WeatherMatch.*Weather matches|WeatherCondition.*RING_WHEN_MATCH|WeatherCondition.*shouldRing" --line-buffered | while read line; do
    echo "[$(date '+%H:%M:%S')] $line"
done &

LOGCAT_PID=$!

echo "WAIT FOR ALARM TO TRIGGER..."
echo "Key values to check:"
echo "1. 'Weather condition type: RING_WHEN_MATCH (Option 1)' - Should show this"
echo "2. 'Converted weather types: 'X'' - Should show your selected weather"
echo "3. 'Weather determination: ... -> X' - Should show detected weather"
echo "4. 'Current weather: 'X'' - Should match your selection"
echo "5. 'Weather matches selected types: true' - Should be true"
echo "6. 'RING_WHEN_MATCH: shouldRing = true' - Should be true"
echo ""
echo "Press Ctrl+C when done"

# Wait for Ctrl+C
trap "kill $LOGCAT_PID 2>/dev/null; echo ''; echo 'Test complete. If shouldRing was false, there is a mismatch between detected and selected weather.'; exit" INT
wait