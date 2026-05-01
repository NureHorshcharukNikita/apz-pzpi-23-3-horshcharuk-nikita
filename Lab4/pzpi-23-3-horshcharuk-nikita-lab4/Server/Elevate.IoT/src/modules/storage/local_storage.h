#pragma once

#include <Arduino.h>
#include <Preferences.h>
#include "constants.h"
#include "types.h"

class LocalStorage {
private:
    static Preferences preferences;
    static const char* NAMESPACE;
    
    static const char* KEY_LAST_SCAN_USER_ID;
    static const char* KEY_LAST_SCAN_TIME;
    static const char* KEY_PENDING_SCANS_COUNT;
    static const char* KEY_CACHED_LEADERBOARD;
    static const char* KEY_CACHED_USER_PROFILE;
    static const char* KEY_TOTAL_SCANS;
    static const char* KEY_SUCCESSFUL_SCANS;
    static const char* KEY_FAILED_SCANS;
    static const char* KEY_LAST_SYNC_TIME;
    static const char* KEY_LAST_STATS_SYNC_DATE;
    static const char* KEY_LOCAL_TOTAL_DELTA;
    static const char* KEY_LOCAL_SUCCESS_DELTA;
    static const char* KEY_LOCAL_FAILED_DELTA;
    static const char* KEY_DEVICE_KEY;
    
public:
    static bool initialize() {
        return preferences.begin(NAMESPACE, false);
    }
    
    static void close() {
        preferences.end();
    }
    
    static void saveLastScan(int userId, unsigned long timestamp) {
        preferences.putInt(KEY_LAST_SCAN_USER_ID, userId);
        preferences.putULong(KEY_LAST_SCAN_TIME, timestamp);
    }
    
    static int getLastScanUserId() {
        return preferences.getInt(KEY_LAST_SCAN_USER_ID, 0);
    }
    
    static unsigned long getLastScanTime() {
        return preferences.getULong(KEY_LAST_SCAN_TIME, 0);
    }
    
    static void setPendingScansCount(int count) {
        preferences.putInt(KEY_PENDING_SCANS_COUNT, count);
    }
    
    static int getPendingScansCount() {
        return preferences.getInt(KEY_PENDING_SCANS_COUNT, 0);
    }
    
    static void incrementTotalScans() {
        int total = preferences.getInt(KEY_TOTAL_SCANS, 0);
        preferences.putInt(KEY_TOTAL_SCANS, total + 1);
    }
    
    static void incrementSuccessfulScans() {
        int success = preferences.getInt(KEY_SUCCESSFUL_SCANS, 0);
        preferences.putInt(KEY_SUCCESSFUL_SCANS, success + 1);
    }
    
    static void incrementFailedScans() {
        int failed = preferences.getInt(KEY_FAILED_SCANS, 0);
        preferences.putInt(KEY_FAILED_SCANS, failed + 1);
    }
    
    static int getTotalScans() {
        return preferences.getInt(KEY_TOTAL_SCANS, 0);
    }
    
    static int getSuccessfulScans() {
        return preferences.getInt(KEY_SUCCESSFUL_SCANS, 0);
    }
    
    static int getFailedScans() {
        return preferences.getInt(KEY_FAILED_SCANS, 0);
    }
    
    static void setTotalScans(int value) {
        preferences.putInt(KEY_TOTAL_SCANS, value);
    }
    
    static void setSuccessfulScans(int value) {
        preferences.putInt(KEY_SUCCESSFUL_SCANS, value);
    }
    
    static void setFailedScans(int value) {
        preferences.putInt(KEY_FAILED_SCANS, value);
    }
    
    static void incrementLocalTotalDelta() {
        int delta = preferences.getInt(KEY_LOCAL_TOTAL_DELTA, 0);
        preferences.putInt(KEY_LOCAL_TOTAL_DELTA, delta + 1);
    }
    
    static void incrementLocalSuccessDelta() {
        int delta = preferences.getInt(KEY_LOCAL_SUCCESS_DELTA, 0);
        preferences.putInt(KEY_LOCAL_SUCCESS_DELTA, delta + 1);
    }
    
    static void incrementLocalFailedDelta() {
        int delta = preferences.getInt(KEY_LOCAL_FAILED_DELTA, 0);
        preferences.putInt(KEY_LOCAL_FAILED_DELTA, delta + 1);
    }
    
    static int getLocalTotalDelta() {
        return preferences.getInt(KEY_LOCAL_TOTAL_DELTA, 0);
    }
    
    static int getLocalSuccessDelta() {
        return preferences.getInt(KEY_LOCAL_SUCCESS_DELTA, 0);
    }
    
    static int getLocalFailedDelta() {
        return preferences.getInt(KEY_LOCAL_FAILED_DELTA, 0);
    }
    
    static void resetLocalDeltas() {
        preferences.putInt(KEY_LOCAL_TOTAL_DELTA, 0);
        preferences.putInt(KEY_LOCAL_SUCCESS_DELTA, 0);
        preferences.putInt(KEY_LOCAL_FAILED_DELTA, 0);
    }
    
    static void setLastSyncTime(unsigned long timestamp) {
        preferences.putULong(KEY_LAST_SYNC_TIME, timestamp);
    }
    
    static unsigned long getLastSyncTime() {
        return preferences.getULong(KEY_LAST_SYNC_TIME, 0);
    }
    
    static void setLastStatsSyncDate(unsigned long date) {
        preferences.putULong(KEY_LAST_STATS_SYNC_DATE, date);
    }
    
    static unsigned long getLastStatsSyncDate() {
        return preferences.getULong(KEY_LAST_STATS_SYNC_DATE, 0);
    }
    
    static void clearAll() {
        preferences.clear();
    }
    
    static void setDeviceKey(const String& deviceKey) {
        preferences.putString(KEY_DEVICE_KEY, deviceKey);
    }
    
    static String getDeviceKey() {
        if (!preferences.isKey(KEY_DEVICE_KEY)) {
            String defaultKey = String(Config::DEVICE_KEY);
            setDeviceKey(defaultKey);
            return defaultKey;
        }
        return preferences.getString(KEY_DEVICE_KEY, String(Config::DEVICE_KEY));
    }
};
