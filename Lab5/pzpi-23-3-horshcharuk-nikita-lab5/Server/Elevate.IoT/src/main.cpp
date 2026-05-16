#include <SPI.h>
#include <WiFi.h>
#include "constants.h"
#include "display.h"
#include "modules/core/config_manager.h"
#include "modules/network/wifi_manager.h"
#include "modules/network/api_client.h"
#include "modules/hardware/power_button.h"
#include "modules/hardware/led_display.h"
#include "modules/hardware/id_input.h"
#include "modules/core/menu_manager.h"
#include "modules/hardware/menu_button.h"
#include "modules/services/power_service.h"
#include "modules/controllers/menu_controller.h"
#include "modules/initialization/device_initializer.h"

Adafruit_ILI9341 display(Hardware::TFT_CS, Hardware::TFT_DC, Hardware::TFT_RST);

const char* ConfigManager::WIFI_SSID = Config::WIFI_SSID;
const char* ConfigManager::WIFI_PASSWORD = Config::WIFI_PASSWORD;
const char* ConfigManager::API_BASE_URL = Config::API_BASE_URL;
String ConfigManager::deviceKey = "";
ConfigManager::Mode ConfigManager::currentMode = ConfigManager::SCAN_MODE;
unsigned long ConfigManager::dashboardUpdateInterval = Timing::DASHBOARD_UPDATE_INTERVAL_MS;

unsigned long WiFiManager::lastConnectionAttempt = 0;
bool WiFiManager::connectionStatus = false;


bool PowerButton::isInitialized = false;
unsigned long PowerButton::lastButtonPressTime = 0;
bool PowerButton::wasPressed = false;
bool PowerButton::devicePowerState = false;

bool LedDisplay::isDisplayInitialized = false;
unsigned long LedDisplay::startTime = 0;
int LedDisplay::successfulScans = 0;
int LedDisplay::failedScans = 0;

MenuManager::MenuState MenuController::lastProcessedState = MenuManager::SCAN_MODE;

unsigned long SyncService::lastSyncAttempt = 0;
unsigned long SyncService::lastStatsSync = 0;

HTTPClient ApiClient::http;

Preferences LocalStorage::preferences;
const char* LocalStorage::NAMESPACE = "elevate";
const char* LocalStorage::KEY_LAST_SCAN_USER_ID = "last_scan_user";
const char* LocalStorage::KEY_LAST_SCAN_TIME = "last_scan_time";
const char* LocalStorage::KEY_PENDING_SCANS_COUNT = "pending_count";
const char* LocalStorage::KEY_CACHED_LEADERBOARD = "cached_lb";
const char* LocalStorage::KEY_CACHED_USER_PROFILE = "cached_prof";
const char* LocalStorage::KEY_TOTAL_SCANS = "total_scans";
const char* LocalStorage::KEY_SUCCESSFUL_SCANS = "success_scans";
const char* LocalStorage::KEY_FAILED_SCANS = "failed_scans";
const char* LocalStorage::KEY_LAST_SYNC_TIME = "last_sync";
const char* LocalStorage::KEY_LAST_STATS_SYNC_DATE = "last_stats_date";
const char* LocalStorage::KEY_LOCAL_TOTAL_DELTA = "loc_tot_d";
const char* LocalStorage::KEY_LOCAL_SUCCESS_DELTA = "loc_suc_d";
const char* LocalStorage::KEY_LOCAL_FAILED_DELTA = "loc_fail_d";
const char* LocalStorage::KEY_DEVICE_KEY = "device_key";

PendingScan OfflineQueue::pendingScans[OfflineQueue::MAX_PENDING_SCANS];
int OfflineQueue::queueHead = 0;
int OfflineQueue::queueTail = 0;
int OfflineQueue::queueSize = 0;

int LocalAnalytics::scanHistory[LocalAnalytics::HISTORY_SIZE];
unsigned long LocalAnalytics::historyTimestamps[LocalAnalytics::HISTORY_SIZE];
int LocalAnalytics::historyIndex = 0;
int LocalAnalytics::hourlyScans[24];
int LocalAnalytics::dailyScans = 0;
unsigned long LocalAnalytics::startTime = 0;
unsigned long LocalAnalytics::lastHourReset = 0;
unsigned long LocalAnalytics::lastDayReset = 0;

MenuManager::MenuState MenuManager::currentState = MenuManager::MAIN_MENU;
MenuManager::MenuState MenuManager::previousState = MenuManager::SCAN_MODE;
bool MenuManager::scanModeActive = false;
bool MenuManager::settingsModeActive = false;

int IdInput::inputUserId = 0;
bool IdInput::inputMode = false;
unsigned long IdInput::lastSerialCheck = 0;
String IdInput::serialBuffer = "";

void setup() {
    Serial.begin(115200);
    delay(100);
    
    PowerButton::initialize();
    
    SPI.begin();
    display.begin();
    display.setRotation(1);
    LedDisplay::setDisplayInitialized(true);
    
    LedDisplay::showMessage("Press Power to start", ILI9341_CYAN);
}

static bool isDeviceInitialized = false;

static void initializeDevice() {
    if (isDeviceInitialized) return;
    
    DeviceInitializer::initialize();
    isDeviceInitialized = true;
}

static void updateInputBasedOnState() {
    if (MenuManager::currentState == MenuManager::SETTINGS_MODE) {
        IdInput::update(true);
    } else if (MenuManager::currentState == MenuManager::SCAN_MODE) {
        IdInput::update(false);
    }
}

static void ensureNetworkConnection() {
    WiFiManager::connectUntilSuccess();
    WiFiManager::setConnectionStatus(true);
}

void loop() {
    if (!PowerButton::isDeviceOn()) {
        static bool powerMessageShown = false;
        if (PowerButton::isPressed()) {
            powerMessageShown = false;
            isDeviceInitialized = false;
            MenuManager::initialize();
            initializeDevice();
            PowerButton::setDeviceState(true);
        } else {
            if (!powerMessageShown) {
                LedDisplay::showMessage("Press Power to start", ILI9341_CYAN);
                powerMessageShown = true;
            }
        }
        delay(Timing::LOOP_DELAY_MS);
        return;
    }
    
    if (PowerButton::isPressed()) {
        if (PowerButton::isDeviceOn()) {
            PowerService::handlePowerOff();
            isDeviceInitialized = false;
            return;
        }
    }
    
    if (!isDeviceInitialized) {
        initializeDevice();
    }
    
    if (PowerButton::isDeviceOn()) {
        MenuManager::update();
        updateInputBasedOnState();
        
        if (WiFiManager::isConnected()) {
            MenuController::update();
        } else {
            ensureNetworkConnection();
        }
    }
    
    delay(Timing::LOOP_DELAY_MS);
}
