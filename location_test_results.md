# Location-Based Alarm Condition Test Results

**Test Date:** ___________  
**Device:** ___________  
**Target Location:** ___________  
**Position A (Within 500m):** ___________  
**Position B (Beyond 500m):** ___________  

---

## Test Results

### Test 1: OFF Condition (Index 0)
- **Expected:** Alarm rings regardless of location
- **Result:** ✅ PASS / ❌ FAIL
- **Notes:** 
- **Logcat:** 

---

### Test 2A: RING WHEN AT - Within Range (Index 1)
- **Position:** Within 500m of target
- **Expected:** Alarm RINGS
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

### Test 2B: RING WHEN AT - Beyond Range (Index 1)
- **Position:** Beyond 500m of target
- **Expected:** Alarm DOES NOT ring
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

---

### Test 3A: CANCEL WHEN AT - Within Range (Index 2)
- **Position:** Within 500m of target
- **Expected:** Alarm DOES NOT ring
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

### Test 3B: CANCEL WHEN AT - Beyond Range (Index 2)
- **Position:** Beyond 500m of target
- **Expected:** Alarm RINGS
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

---

### Test 4A: RING WHEN AWAY - Within Range (Index 3)
- **Position:** Within 500m of target
- **Expected:** Alarm DOES NOT ring
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

### Test 4B: RING WHEN AWAY - Beyond Range (Index 3)
- **Position:** Beyond 500m of target
- **Expected:** Alarm RINGS
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

---

### Test 5A: CANCEL WHEN AWAY - Within Range (Index 4)
- **Position:** Within 500m of target
- **Expected:** Alarm RINGS
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

### Test 5B: CANCEL WHEN AWAY - Beyond Range (Index 4)
- **Position:** Beyond 500m of target
- **Expected:** Alarm DOES NOT ring
- **Result:** ✅ PASS / ❌ FAIL
- **Distance:** _____ meters
- **Notes:** 
- **Logcat:** 

---

## Summary

**Total Tests:** 9  
**Passed:** _____ / 9  
**Failed:** _____ / 9  

### Issues Found:
- [ ] Issue 1: ___________
- [ ] Issue 2: ___________
- [ ] Issue 3: ___________

### Notes:
___________ 