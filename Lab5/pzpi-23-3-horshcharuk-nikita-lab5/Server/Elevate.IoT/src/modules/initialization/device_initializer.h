#pragma once

#include "constants.h"
#include "modules/core/config_manager.h"
#include "modules/storage/local_storage.h"
#include "modules/services/sync_service.h"
#include "modules/hardware/led_display.h"
#include "modules/hardware/id_input.h"
#include "modules/core/menu_manager.h"
#include "modules/hardware/menu_button.h"
#include "modules/network/wifi_manager.h"
#include "modules/controllers/menu_controller.h"

class DeviceInitializer {
private:
    static const unsigned long LOADING_STEP_DELAY_MS = 200;
    static const unsigned long SYSTEM_STATUS_DISPLAY_MS = 2000;

public:
    static void initialize() {
        initializeDisplay();
        initializeStorageAndConfig();
        initializeHardware();
        connectToNetwork();
        loadStatistics();
        showReadyState();
    }

private:
    static void initializeDisplay() {
        LedDisplay::initializeStats();
        LedDisplay::showLoadingStep("Initializing...", 10);
        delay(LOADING_STEP_DELAY_MS);
    }

    static void initializeStorageAndConfig() {
        LedDisplay::showLoadingStep("Configuring...", 20);
        LocalStorage::initialize();
        ConfigManager::initialize();
        SyncService::initialize();
        delay(LOADING_STEP_DELAY_MS);
    }

    static void initializeHardware() {
        LedDisplay::showLoadingStep("Buttons...", 50);
        IdInput::initialize();
        MenuManager::initialize();
        MenuButton::initialize();
        MenuController::initialize();
        delay(LOADING_STEP_DELAY_MS);
    }

    static void connectToNetwork() {
        LedDisplay::showLoadingStep("Wi-Fi...", 80);
        WiFiManager::connectUntilSuccess();
        WiFiManager::setConnectionStatus(true);
    }

    static void loadStatistics() {
        LedDisplay::showLoadingStep("Loading stats...", 90);
        SyncService::loadStatsFromServer();
    }

    static void showReadyState() {
        LedDisplay::showLoadingStep("Ready!", 100);
        delay(500);
        
        LedDisplay::showSystemStatus();
        delay(SYSTEM_STATUS_DISPLAY_MS);
        
        LedDisplay::showMainMenu();
    }
};

