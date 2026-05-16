#pragma once

#include "constants.h"
#include "modules/storage/local_storage.h"

class ConfigManager {
private:
    static String deviceKey;
    
public:
    enum Mode { SCAN_MODE, DASHBOARD_MODE };
    
    static const char* WIFI_SSID;
    static const char* WIFI_PASSWORD;
    static const char* API_BASE_URL;
    static Mode currentMode;
    static unsigned long dashboardUpdateInterval;
    
    static void initialize() {
        currentMode = SCAN_MODE;
        dashboardUpdateInterval = Timing::DASHBOARD_UPDATE_INTERVAL_MS;
        deviceKey = LocalStorage::getDeviceKey();
        if (deviceKey.length() == 0) {
            deviceKey = String(Config::DEVICE_KEY);
            LocalStorage::setDeviceKey(deviceKey);
        }
    }
    
    static const char* getDeviceKey() {
        return deviceKey.c_str();
    }
    
    static void setDeviceKey(const String& newKey) {
        deviceKey = newKey;
        LocalStorage::setDeviceKey(newKey);
    }
};

