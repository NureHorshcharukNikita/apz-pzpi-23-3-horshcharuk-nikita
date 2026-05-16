#pragma once

#include <WiFi.h>
#include "constants.h"
#include "modules/core/config_manager.h"

class WiFiManager {
private:
    static unsigned long lastConnectionAttempt;
    static bool connectionStatus;
    
public:
    static bool connect() {
        if (WiFi.status() == WL_CONNECTED) {
            connectionStatus = true;
            return true;
        }
        
        unsigned long now = millis();
        if (now - lastConnectionAttempt < Timing::WIFI_RETRY_INTERVAL_MS) {
            return false;
        }
        
        lastConnectionAttempt = now;
        WiFi.begin(ConfigManager::WIFI_SSID, ConfigManager::WIFI_PASSWORD);
        
        int attempts = 0;
        while (WiFi.status() != WL_CONNECTED && attempts < Timing::WIFI_MAX_ATTEMPTS) {
            delay(Timing::WIFI_CONNECT_DELAY_MS);
            attempts++;
        }
        
        connectionStatus = (WiFi.status() == WL_CONNECTED);
        return connectionStatus;
    }
    
    static bool connectUntilSuccess() {
        while (WiFi.status() != WL_CONNECTED) {
            WiFi.disconnect();
            delay(100);
            WiFi.mode(WIFI_STA);
            WiFi.begin(ConfigManager::WIFI_SSID, ConfigManager::WIFI_PASSWORD);
            
            int attempts = 0;
            while (WiFi.status() != WL_CONNECTED && attempts < Timing::WIFI_MAX_ATTEMPTS) {
                delay(Timing::WIFI_CONNECT_DELAY_MS);
                attempts++;
            }
            
            if (WiFi.status() != WL_CONNECTED) {
                delay(1000);
            }
        }
        
        connectionStatus = true;
        return true;
    }
    
    static bool ensureConnection() {
        if (WiFi.status() == WL_CONNECTED) {
            connectionStatus = true;
            return true;
        }
        WiFi.disconnect();
        delay(100);
        return connect();
    }
    
    static bool isConnected() {
        return WiFi.status() == WL_CONNECTED;
    }
    
    static bool getConnectionStatus() { return connectionStatus; }
    static void setConnectionStatus(bool status) { connectionStatus = status; }
    
    static void disconnect() {
        WiFi.disconnect();
        WiFi.mode(WIFI_OFF);
        connectionStatus = false;
    }
};

