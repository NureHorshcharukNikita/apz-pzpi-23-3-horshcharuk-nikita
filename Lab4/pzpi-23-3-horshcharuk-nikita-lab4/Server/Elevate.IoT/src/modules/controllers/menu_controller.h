#pragma once

#include "constants.h"
#include "types.h"
#include "modules/core/config_manager.h"
#include "modules/core/menu_manager.h"
#include "modules/hardware/led_display.h"
#include "modules/hardware/id_input.h"
#include "modules/network/api_client.h"
#include "modules/network/wifi_manager.h"
#include "modules/services/scan_service.h"
#include "modules/services/sync_service.h"
#include "modules/core/business_logic.h"
#include "modules/storage/offline_queue.h"
#include "modules/storage/local_storage.h"

class MenuController {
public:
    static MenuManager::MenuState lastProcessedState;

private:

public:
    static void initialize() {
        lastProcessedState = MenuManager::SCAN_MODE;
    }

    static void update() {
        bool stateChanged = (lastProcessedState != MenuManager::currentState);
        
        switch (MenuManager::currentState) {
            case MenuManager::MAIN_MENU:
                handleMainMenu(stateChanged);
                break;
            case MenuManager::SCAN_MODE:
                handleScanMode(stateChanged);
                break;
            case MenuManager::LEADERBOARD_VIEW:
                handleLeaderboardView(stateChanged);
                break;
            case MenuManager::STATS_VIEW:
                handleStatsView(stateChanged);
                break;
            case MenuManager::SETTINGS_MODE:
                handleSettingsMode(stateChanged);
                break;
            default:
                handleMainMenu(stateChanged);
                break;
        }
    }

private:
    static void handleMainMenu(bool stateChanged) {
        if (stateChanged) {
            LedDisplay::showMainMenu();
            lastProcessedState = MenuManager::MAIN_MENU;
        }
    }

    static void handleScanMode(bool stateChanged) {
        if (stateChanged) {
            LedDisplay::showScanMode();
            lastProcessedState = MenuManager::SCAN_MODE;
        }

        if (IdInput::hasInputUserId()) {
            processScanInput();
        } else {
            processBackgroundTasks();
        }
    }

    static void processScanInput() {
        int inputUserId = IdInput::getInputUserId();
        ScanService::processUserIdScan(inputUserId);
        IdInput::clearInput();
        
        if (WiFiManager::isConnected()) {
            SyncService::syncDeviceStats(true);
        }
        
        delay(Timing::SCAN_RESULT_DISPLAY_MS);
        returnToMainMenu();
    }

    static void processBackgroundTasks() {
        SyncService::syncOfflineQueueIfNeeded();
        SyncService::syncDeviceStats();
    }

    static void handleLeaderboardView(bool stateChanged) {
        if (stateChanged) {
            showLeaderboard();
            lastProcessedState = MenuManager::LEADERBOARD_VIEW;
        }
        
        checkAutoReturn(2000);
    }

    static void showLeaderboard() {
        LeaderboardEntry entries[5];
        bool success = ApiClient::getLeaderboard(entries, 5);
        
        if (success) {
            LocalStorage::setLastSyncTime(millis());
            LedDisplay::showLeaderboard(entries, 5);
        } else {
            LedDisplay::showOfflineInfo();
        }
    }

    static void handleStatsView(bool stateChanged) {
        if (stateChanged) {
            showStats();
            lastProcessedState = MenuManager::STATS_VIEW;
        }
        
        checkAutoReturn(5000);
    }

    static void showStats() {
        if (WiFiManager::isConnected()) {
            SyncService::syncDeviceStats(true);
        }
        LedDisplay::showDeviceStats();
    }

    static void handleSettingsMode(bool stateChanged) {
        if (stateChanged) {
            showSettings();
            lastProcessedState = MenuManager::SETTINGS_MODE;
        }

        if (IdInput::hasInputUserId()) {
            processSettingsInput();
        }
    }

    static void showSettings() {
        String currentKey = ConfigManager::getDeviceKey();
        LedDisplay::showSettingsMode(currentKey);
    }

    static void processSettingsInput() {
        String input = IdInput::getDeviceKeyInput();
        
        if (input.length() == 0) {
            return;
        }

        if (input == "EXIT") {
            handleSettingsExit();
        } else {
            handleDeviceKeyUpdate(input);
        }
    }

    static void handleSettingsExit() {
        Serial.println("Returning to main menu...");
        IdInput::clearInput();
        returnToMainMenu();
    }

    static void handleDeviceKeyUpdate(const String& input) {
        ConfigManager::setDeviceKey(input);
        Serial.print("Device Key updated: ");
        Serial.println(input);
        
        LedDisplay::showMessage("Device Key updated!", ILI9341_GREEN);
        delay(2000);
        
        IdInput::clearInput();
        returnToMainMenu();
    }

    static void checkAutoReturn(unsigned long displayDuration) {
        static unsigned long displayStartTime = 0;
        static bool isDisplayed = false;
        static MenuManager::MenuState displayedState = MenuManager::MAIN_MENU;

        if (MenuManager::currentState != displayedState) {
            displayStartTime = millis();
            isDisplayed = true;
            displayedState = MenuManager::currentState;
        }

        if (isDisplayed) {
            unsigned long now = millis();
            if ((now - displayStartTime) >= displayDuration) {
                isDisplayed = false;
                returnToMainMenu();
            }
        }
    }

    static void returnToMainMenu() {
        MenuManager::returnToMainMenu();
        LedDisplay::showMainMenu();
    }
};

