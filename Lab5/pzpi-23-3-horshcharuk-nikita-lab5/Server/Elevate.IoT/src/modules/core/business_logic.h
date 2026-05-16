#pragma once

#include <Arduino.h>
#include "constants.h"
#include "types.h"
#include "modules/storage/local_storage.h"
#include "modules/analytics/math_utils.h"

class BusinessLogic {
public:
    static bool validateScan(int userId, unsigned long lastScanTime) {
        if (userId <= 0) {
            return false;
        }
        
        unsigned long now = millis();
        unsigned long timeSinceLastScan = now - lastScanTime;
        
        if (timeSinceLastScan < 500 && lastScanTime > 0) {
            return false;
        }
        
        static int recentScans[10];
        static unsigned long recentScanTimes[10];
        static int recentScanIndex = 0;
        static bool initialized = false;
        
        if (!initialized) {
            for (int i = 0; i < 10; i++) {
                recentScans[i] = 0;
                recentScanTimes[i] = 0;
            }
            initialized = true;
        }
        
        int scansInLastMinute = 0;
        for (int i = 0; i < 10; i++) {
            if (recentScanTimes[i] > 0 && (now - recentScanTimes[i]) < 60000) {
                scansInLastMinute++;
            }
        }
        
        if (scansInLastMinute >= 10) {
            return false;
        }
        
        recentScans[recentScanIndex] = userId;
        recentScanTimes[recentScanIndex] = now;
        recentScanIndex = (recentScanIndex + 1) % 10;
        
        return true;
    }
    
    static bool shouldShowOfflineMode(unsigned long lastSyncTime, bool isConnected) {
        if (!isConnected) {
            return true;
        }
        
        unsigned long now = millis();
        unsigned long timeSinceSync = now - lastSyncTime;
        
        if (timeSinceSync > 300000) {
            return true;
        }
        
        return false;
    }
    
    static int calculateLocalRanking(int userPoints, const LeaderboardEntry* entries, int count) {
        if (count <= 0) return -1;
        
        for (int i = 0; i < count; i++) {
            if (entries[i].teamPoints <= userPoints) {
                return i + 1;
            }
        }
        
        return count + 1;
    }
    
    static bool shouldUpdateLeaderboard(unsigned long lastUpdate, unsigned long updateInterval) {
        unsigned long now = millis();
        return (now - lastUpdate) >= updateInterval;
    }
    
    static bool needsImmediateSync(int pendingScansCount, unsigned long oldestPendingTime) {
        if (pendingScansCount >= 5) {
            return true;
        }
        
        unsigned long now = millis();
        if ((now - oldestPendingTime) > 600000) {
            return true;
        }
        
        return false;
    }
    
    enum ErrorType {
        NETWORK_ERROR,
        SERVER_ERROR,
        VALIDATION_ERROR,
        UNKNOWN_ERROR
    };
    
    static ErrorType classifyError(const String& errorMessage) {
        String lowerError = errorMessage;
        lowerError.toLowerCase();
        
        if (lowerError.indexOf("network") >= 0 || 
            lowerError.indexOf("connection") >= 0 ||
            lowerError.indexOf("timeout") >= 0 ||
            lowerError.indexOf("unavailable") >= 0) {
            return NETWORK_ERROR;
        }
        
        if (lowerError.indexOf("server") >= 0 ||
            lowerError.indexOf("500") >= 0 ||
            lowerError.indexOf("503") >= 0) {
            return SERVER_ERROR;
        }
        
        if (lowerError.indexOf("bad request") >= 0 ||
            lowerError.indexOf("400") >= 0 ||
            lowerError.indexOf("unauthorized") >= 0 ||
            lowerError.indexOf("401") >= 0) {
            return VALIDATION_ERROR;
        }
        
        return UNKNOWN_ERROR;
    }
    
    static unsigned long estimateSyncTime(int pendingScansCount) {
        return pendingScansCount * 500;
    }
    
    static bool canWorkOffline(int pendingScansCount) {
        return pendingScansCount < 10;
    }
};

