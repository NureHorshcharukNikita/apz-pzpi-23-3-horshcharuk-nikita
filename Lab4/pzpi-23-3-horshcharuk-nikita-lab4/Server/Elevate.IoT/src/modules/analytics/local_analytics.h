#pragma once

#include <Arduino.h>
#include "constants.h"
#include "modules/analytics/math_utils.h"
#include "modules/storage/local_storage.h"

class LocalAnalytics {
private:
    static const int HISTORY_SIZE = 24;
    static int scanHistory[HISTORY_SIZE];
    static unsigned long historyTimestamps[HISTORY_SIZE];
    static int historyIndex;
    
    static int hourlyScans[24];
    static int dailyScans;
    static unsigned long startTime;
    static unsigned long lastHourReset;
    static unsigned long lastDayReset;
    
public:
    static void initialize() {
        historyIndex = 0;
        dailyScans = 0;
        startTime = millis();
        lastHourReset = millis();
        lastDayReset = millis();
        
        for (int i = 0; i < HISTORY_SIZE; i++) {
            scanHistory[i] = 0;
            historyTimestamps[i] = 0;
            hourlyScans[i] = 0;
        }
    }
    
    static void recordScan(int userId, bool success) {
        unsigned long now = millis();
        
        scanHistory[historyIndex] = success ? 1 : 0;
        historyTimestamps[historyIndex] = now;
        historyIndex = (historyIndex + 1) % HISTORY_SIZE;
        
        unsigned long timeSinceStart = now - startTime;
        int currentHour = (int)((timeSinceStart / 3600000UL) % 24);
        hourlyScans[currentHour]++;
        dailyScans++;
        
        if ((now - lastHourReset) >= 3600000) {
            unsigned long oldTimeSinceStart = lastHourReset - startTime;
            int oldHour = (int)((oldTimeSinceStart / 3600000UL) % 24);
            hourlyScans[oldHour] = 0;
            lastHourReset = now;
        }
        
        if ((now - lastDayReset) >= 86400000) {
            dailyScans = 0;
            lastDayReset = now;
        }
    }
    static float getAverageScansPerHour() {
        unsigned long now = millis();
        int activeHours = 0;
        int totalScans = 0;
        
        for (int i = 0; i < 24; i++) {
            if (hourlyScans[i] > 0) {
                activeHours++;
                totalScans += hourlyScans[i];
            }
        }
        
        if (activeHours <= 0) return 0.0;
        return (float)totalScans / activeHours;
    }
    
    static float getSuccessRateLastHours(int hours) {
        if (hours <= 0 || hours > HISTORY_SIZE) return 0.0;
        
        int successful = 0;
        int total = 0;
        unsigned long now = millis();
        unsigned long cutoffTime = now - (hours * 3600000UL);
        
        for (int i = 0; i < HISTORY_SIZE; i++) {
            if (historyTimestamps[i] > cutoffTime && historyTimestamps[i] > 0) {
                total++;
                if (scanHistory[i] > 0) {
                    successful++;
                }
            }
        }
        
        if (total <= 0) return 0.0;
        return (float)successful * 100.0 / total;
    }
    
    static int getPeakHour() {
        int maxScans = 0;
        int peakHour = -1;
        
        for (int i = 0; i < 24; i++) {
            if (hourlyScans[i] > maxScans) {
                maxScans = hourlyScans[i];
                peakHour = i;
            }
        }
        
        return peakHour;
    }
    
    static int getActivityTrend() {
        if (HISTORY_SIZE < 2) return 0;
        
        int recent = 0;
        int older = 0;
        unsigned long now = millis();
        unsigned long midpoint = now - (HISTORY_SIZE / 2 * 3600000UL);
        
        for (int i = 0; i < HISTORY_SIZE; i++) {
            if (historyTimestamps[i] > 0) {
                if (historyTimestamps[i] > midpoint) {
                    recent += scanHistory[i];
                } else {
                    older += scanHistory[i];
                }
            }
        }
        
        return recent - older;
    }
    static void getOverallStats(int& totalScans, int& successfulScans, int& failedScans) {
        totalScans = LocalStorage::getTotalScans();
        successfulScans = LocalStorage::getSuccessfulScans();
        failedScans = LocalStorage::getFailedScans();
    }
    
    static float getDeviceEfficiency() {
        int total = LocalStorage::getTotalScans();
        int successful = LocalStorage::getSuccessfulScans();
        
        if (total <= 0) return 0.0;
        
        float successRate = MathUtils::calculateSuccessRate(successful, total);
        float avgScansPerHour = getAverageScansPerHour();
        float activityFactor = min(avgScansPerHour / 100.0, 1.0);
        
        return successRate * activityFactor;
    }
    
    static int getDailyScans() {
        return dailyScans;
    }
    
    static void reset() {
        initialize();
        LocalStorage::clearAll();
    }
    struct DeviceStats {
        int totalScans;
        int successfulScans;
        int failedScans;
        int dailyScans;
        float averageScansPerHour;
        float successRate;
        float deviceEfficiency;
        int peakHour;
        int activityTrend;
        unsigned long uptimeMs;
    };
    
    static void getStatsForSync(DeviceStats& stats) {
        unsigned long now = millis();
        
        stats.totalScans = LocalStorage::getTotalScans();
        stats.successfulScans = LocalStorage::getSuccessfulScans();
        stats.failedScans = LocalStorage::getFailedScans();
        stats.dailyScans = dailyScans;
        stats.averageScansPerHour = getAverageScansPerHour();
        stats.successRate = (stats.totalScans > 0) ? 
            MathUtils::calculateSuccessRate(stats.successfulScans, stats.totalScans) : 0.0;
        stats.deviceEfficiency = getDeviceEfficiency();
        stats.peakHour = getPeakHour();
        stats.activityTrend = getActivityTrend();
        stats.uptimeMs = now - startTime;
    }
};

