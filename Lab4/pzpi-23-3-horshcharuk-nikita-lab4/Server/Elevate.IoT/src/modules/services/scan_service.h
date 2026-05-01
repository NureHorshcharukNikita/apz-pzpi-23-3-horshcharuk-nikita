#pragma once

#include "constants.h"
#include "types.h"
#include "modules/core/config_manager.h"
#include "modules/network/api_client.h"
#include "modules/network/wifi_manager.h"
#include "modules/hardware/led_display.h"
#include "modules/storage/local_storage.h"
#include "modules/storage/offline_queue.h"
#include "modules/core/business_logic.h"
#include "modules/analytics/math_utils.h"
#include "modules/analytics/local_analytics.h"

class ScanService {
public:
    static void processUserIdScan(int userId) {
        if (!isValidUserId(userId)) {
            showValidationError("Invalid User ID");
            return;
        }

        if (!isScanAllowed(userId)) {
            return;
        }

        recordScanAttempt(userId);

        if (WiFiManager::isConnected()) {
            processOnlineScan(userId);
        } else {
            processOfflineScan(userId);
        }
    }

private:
    static bool isValidUserId(int userId) {
        return userId > 0;
    }

    static bool isScanAllowed(int userId) {
        unsigned long lastScanTime = LocalStorage::getLastScanTime();
        
        if (!BusinessLogic::validateScan(userId, lastScanTime)) {
            showValidationError(getValidationErrorMessage(userId, lastScanTime));
            return false;
        }
        return true;
    }

    static String getValidationErrorMessage(int userId, unsigned long lastScanTime) {
        unsigned long now = millis();
        unsigned long timeSinceLastScan = now - lastScanTime;
        
        if (userId <= 0) {
            return "Invalid user ID";
        } else if (timeSinceLastScan < 500 && lastScanTime > 0) {
            return "Too soon (debounce)";
        } else {
            return "Rate limit exceeded";
        }
    }

    static void showValidationError(const String& message) {
        LedDisplay::showError(message);
        delay(2000);
    }

    static void recordScanAttempt(int userId) {
        LocalStorage::saveLastScan(userId, millis());
        LocalStorage::incrementTotalScans();
        LocalStorage::incrementLocalTotalDelta();
    }

    static void processOnlineScan(int userId) {
        ScanResult result = ApiClient::scanUser(userId);
        
        if (result.success) {
            handleSuccessfulScan(userId, result);
        } else {
            handleFailedScan(userId, result);
        }
    }

    static void handleSuccessfulScan(int userId, const ScanResult& result) {
        LocalAnalytics::recordScan(userId, true);
        LocalStorage::incrementSuccessfulScans();
        LocalStorage::incrementLocalSuccessDelta();
        LocalStorage::setLastSyncTime(millis());
        
        LedDisplay::incrementSuccessfulScan();
        
        LevelProgressResult levelProgress = calculateLevelProgress(result);
        LedDisplay::showUserProfile(result, &levelProgress);
    }

    static LevelProgressResult calculateLevelProgress(const ScanResult& result) {
        TeamLevel teamLevels[10];
        int levelsCount = ApiClient::getTeamLevels(teamLevels, 10, result.teamId);
        
        if (levelsCount > 0) {
            return MathUtils::calculateLevelProgressFromDB(
                result.teamPoints,
                result.teamLevelName,
                teamLevels,
                levelsCount
            );
        } else {
            return calculateFallbackProgress(result);
        }
    }

    static LevelProgressResult calculateFallbackProgress(const ScanResult& result) {
        LevelProgressResult progressResult;
        int estimatedLevel = result.teamLevelName.length();
        progressResult.progress = MathUtils::calculateLevelProgress(
            result.teamPoints, estimatedLevel);
        progressResult.pointsToNext = MathUtils::calculatePointsToNextLevel(
            result.teamPoints, estimatedLevel);
        progressResult.isMaxLevel = false;
        progressResult.nextLevelName = "";
        return progressResult;
    }

    static void handleFailedScan(int userId, const ScanResult& result) {
        BusinessLogic::ErrorType errorType = BusinessLogic::classifyError(result.errorMessage);
        LocalAnalytics::recordScan(userId, false);
        LocalStorage::incrementFailedScans();
        LocalStorage::incrementLocalFailedDelta();
        
        String errorMessage = getErrorMessage(result, errorType);
        handleErrorType(errorType, userId);
        LedDisplay::showError(errorMessage);
    }

    static String getErrorMessage(const ScanResult& result, BusinessLogic::ErrorType errorType) {
        switch (errorType) {
            case BusinessLogic::VALIDATION_ERROR:
                return "Validation: " + result.errorMessage;
            default:
                return result.errorMessage;
        }
    }

    static void handleErrorType(BusinessLogic::ErrorType errorType, int userId) {
        if (errorType == BusinessLogic::NETWORK_ERROR || errorType == BusinessLogic::SERVER_ERROR) {
            if (OfflineQueue::enqueue(userId)) {
                LocalStorage::setPendingScansCount(OfflineQueue::getPendingCount());
            }
        }
    }

    static void processOfflineScan(int userId) {
        int pendingCount = OfflineQueue::getPendingCount();
        
        if (BusinessLogic::canWorkOffline(pendingCount)) {
            queueOfflineScan(userId);
        } else {
            LedDisplay::showError("Offline - no queue");
        }
    }

    static void queueOfflineScan(int userId) {
        if (OfflineQueue::enqueue(userId)) {
            LocalStorage::setPendingScansCount(OfflineQueue::getPendingCount());
            LocalAnalytics::recordScan(userId, false);
            LedDisplay::showError("Offline - queued");
        } else {
            LedDisplay::showError("Queue full");
        }
    }
};

