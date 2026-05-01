#pragma once

#include "constants.h"
#include "modules/network/api_client.h"
#include "modules/network/wifi_manager.h"
#include "modules/storage/local_storage.h"
#include "modules/storage/offline_queue.h"
#include "modules/core/business_logic.h"
#include "modules/analytics/local_analytics.h"
#include "modules/hardware/power_button.h"

class SyncService {
public:
    static unsigned long lastSyncAttempt;
    static unsigned long lastStatsSync;

private:
    static const unsigned long SYNC_COOLDOWN_MS = 5000;
    static const int MAX_SYNCS_PER_ATTEMPT = 3;

public:
    static void initialize() {
        lastSyncAttempt = 0;
        lastStatsSync = 0;
    }

    static void syncOfflineQueue() {
        if (!shouldSyncOfflineQueue()) {
            return;
        }

        lastSyncAttempt = millis();
        int synced = syncPendingScans();
        
        if (synced > 0) {
            LocalStorage::setPendingScansCount(OfflineQueue::getPendingCount());
            LocalStorage::setLastSyncTime(millis());
        }
    }

    static void syncDeviceStats(bool forceSync = false) {
        if (!shouldSyncStats(forceSync)) {
            return;
        }

        LocalAnalytics::DeviceStats stats = prepareStatsForSync();
        
        if (ApiClient::sendDeviceStats(stats)) {
            updateLocalStats(stats);
            lastStatsSync = millis();
        }
    }

    static bool loadStatsFromServer() {
        if (!WiFiManager::isConnected()) {
            return false;
        }

        LocalAnalytics::DeviceStats serverStats;
        bool hasStats = ApiClient::getDeviceStats(serverStats);

        if (hasStats) {
            LocalStorage::setTotalScans(serverStats.totalScans);
            LocalStorage::setSuccessfulScans(serverStats.successfulScans);
            LocalStorage::setFailedScans(serverStats.failedScans);
        } else {
            resetStats();
        }

        LocalStorage::resetLocalDeltas();
        return true;
    }

    static void syncOfflineQueueIfNeeded() {
        int pendingCount = OfflineQueue::getPendingCount();
        
        if (pendingCount > 0) {
            int userId;
            unsigned long timestamp;
            if (OfflineQueue::peek(userId, timestamp)) {
                if (BusinessLogic::needsImmediateSync(pendingCount, timestamp)) {
                    syncOfflineQueue();
                }
            }
        }
    }


private:
    static bool shouldSyncOfflineQueue() {
        if (!WiFiManager::isConnected()) {
            return false;
        }

        int pendingCount = OfflineQueue::getPendingCount();
        if (pendingCount <= 0) {
            return false;
        }

        unsigned long now = millis();
        if ((now - lastSyncAttempt) < SYNC_COOLDOWN_MS) {
            return false;
        }

        return true;
    }

    static int syncPendingScans() {
        int synced = 0;

        while (OfflineQueue::hasPending() && synced < MAX_SYNCS_PER_ATTEMPT) {
            int userId;
            unsigned long timestamp;
            
            if (!OfflineQueue::peek(userId, timestamp)) {
                break;
            }

            ScanResult result = ApiClient::scanUser(userId);
            
            if (result.success) {
                dequeueAndRecordSuccess(userId);
                synced++;
            } else {
                handleFailedSync(result, userId);
                break;
            }
        }

        return synced;
    }

    static void dequeueAndRecordSuccess(int userId) {
        int tempUserId;
        unsigned long tempTimestamp;
        OfflineQueue::dequeue(tempUserId, tempTimestamp);
        
        LocalAnalytics::recordScan(userId, true);
        LocalStorage::incrementSuccessfulScans();
        LocalStorage::incrementLocalSuccessDelta();
    }

    static void handleFailedSync(const ScanResult& result, int userId) {
        BusinessLogic::ErrorType errorType = BusinessLogic::classifyError(result.errorMessage);
        
        if (errorType == BusinessLogic::VALIDATION_ERROR) {
            int tempUserId;
            unsigned long tempTimestamp;
            OfflineQueue::dequeue(tempUserId, tempTimestamp);
            LocalStorage::incrementFailedScans();
            LocalStorage::incrementLocalFailedDelta();
        }
    }

    static bool shouldSyncStats(bool forceSync) {
        if (!WiFiManager::isConnected()) {
            return false;
        }

        if (!forceSync && !PowerButton::isDeviceOn()) {
            return false;
        }

        return true;
    }

    static LocalAnalytics::DeviceStats prepareStatsForSync() {
        LocalAnalytics::DeviceStats serverStats;
        bool hasServerStats = ApiClient::getDeviceStats(serverStats);
        
        LocalAnalytics::DeviceStats stats;
        LocalAnalytics::getStatsForSync(stats);
        
        int localTotalDelta = LocalStorage::getLocalTotalDelta();
        int localSuccessDelta = LocalStorage::getLocalSuccessDelta();
        int localFailedDelta = LocalStorage::getLocalFailedDelta();
        
        if (hasServerStats) {
            stats.totalScans = serverStats.totalScans + localTotalDelta;
            stats.successfulScans = serverStats.successfulScans + localSuccessDelta;
            stats.failedScans = serverStats.failedScans + localFailedDelta;
            stats.dailyScans = serverStats.dailyScans + localTotalDelta;
        } else {
            stats.totalScans = LocalStorage::getTotalScans();
            stats.successfulScans = LocalStorage::getSuccessfulScans();
            stats.failedScans = LocalStorage::getFailedScans();
            stats.dailyScans = LocalAnalytics::getDailyScans();
        }

        return stats;
    }

    static void updateLocalStats(const LocalAnalytics::DeviceStats& stats) {
        LocalStorage::setTotalScans(stats.totalScans);
        LocalStorage::setSuccessfulScans(stats.successfulScans);
        LocalStorage::setFailedScans(stats.failedScans);
        LocalStorage::resetLocalDeltas();
        
        unsigned long now = millis();
        unsigned long today = (now / 86400000UL) * 86400000UL;
        LocalStorage::setLastStatsSyncDate(today);
    }

    static void resetStats() {
        LocalStorage::setTotalScans(0);
        LocalStorage::setSuccessfulScans(0);
        LocalStorage::setFailedScans(0);
    }

};

