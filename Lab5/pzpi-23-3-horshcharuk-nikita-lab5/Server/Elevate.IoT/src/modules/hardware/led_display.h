#pragma once

#include "constants.h"
#include "types.h"
#include "display.h"
#include "modules/core/config_manager.h"
#include "modules/network/wifi_manager.h"
#include "modules/analytics/math_utils.h"
#include "modules/analytics/local_analytics.h"
#include "modules/storage/local_storage.h"

class LedDisplay {
private:
    static bool isDisplayInitialized;
    static unsigned long startTime;
    static int successfulScans;
    static int failedScans;
    
    static void initDisplay() {
        if (isDisplayInitialized) return;
        display.begin();
        display.setRotation(1);
        display.fillScreen(ILI9341_BLACK);
        display.setTextColor(ILI9341_WHITE);
        isDisplayInitialized = true;
    }
    
    static String truncateString(const String& str, int maxLen) {
        return (str.length() > maxLen) ? str.substring(0, maxLen) + "..." : str;
    }
    
public:
    static void setDisplayInitialized(bool state) {
        isDisplayInitialized = state;
    }
    
    static void showUserProfile(const ScanResult& result, const LevelProgressResult* progressResult = nullptr) {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setTextSize(2);
            display.setCursor(10, 10);
            display.println("PROFILE");
            
            display.setTextSize(1);
            display.setCursor(10, 40);
            display.println(truncateString(result.fullName, Display::MAX_NAME_LENGTH));
            
            display.setCursor(10, 60);
            display.print("Points: ");
            display.println(result.teamPoints);
            
            display.setCursor(10, 80);
            display.print("Level: ");
            display.println(truncateString(result.teamLevelName, Display::MAX_LEVEL_LENGTH));
            
            if (progressResult != nullptr) {
                display.setCursor(10, 100);
                display.print("Progress: ");
                if (progressResult->isMaxLevel) {
                    display.setTextColor(ILI9341_YELLOW);
                    display.println("MAX");
                    display.setTextColor(ILI9341_WHITE);
                } else if (progressResult->progress >= 0) {
                    display.print(progressResult->progress);
                    display.println("%");
                } else {
                    display.println("N/A");
                }
                
                display.setCursor(10, 120);
                display.print("To next: ");
                if (progressResult->isMaxLevel) {
                    display.setTextColor(ILI9341_YELLOW);
                    display.println("MAX LEVEL");
                    display.setTextColor(ILI9341_WHITE);
                } else if (progressResult->pointsToNext >= 0) {
                    display.print(progressResult->pointsToNext);
                    display.print(" pts");
                    if (progressResult->nextLevelName.length() > 0) {
                        display.print(" -> ");
                        display.println(truncateString(progressResult->nextLevelName, 10));
                    } else {
                        display.println();
                    }
                } else {
                    display.println("N/A");
                }
            } else {
                int estimatedLevel = result.teamLevelName.length();
                int levelProgress = MathUtils::calculateLevelProgress(result.teamPoints, estimatedLevel);
                int pointsToNext = MathUtils::calculatePointsToNextLevel(result.teamPoints, estimatedLevel);
                
                display.setCursor(10, 100);
                display.print("Progress: ");
                display.print(levelProgress);
                display.println("%");
                
                display.setCursor(10, 120);
                display.print("To next: ");
                display.print(pointsToNext);
                display.println(" pts");
            }
            
            if (result.badgeCount > 0) {
                display.setCursor(10, 140);
                display.print("Badge: ");
                display.println(truncateString(result.recentBadges[0], Display::MAX_BADGE_LENGTH));
            }
        }
    }
    
    static void showMessage(const String& message, uint16_t color = ILI9341_WHITE) {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(color);
            display.setTextSize(2);
            display.setCursor(10, 10);
            display.println(message);
        }
    }
    
    static void showError(const String& message) {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_RED);
            display.setCursor(10, 10);
            display.setTextSize(2);
            display.println("ERROR");
            
            display.setTextColor(ILI9341_WHITE);
            display.setTextSize(1);
            
            String errorMsg = message;
            int yPos = 40;
            
            while (errorMsg.length() > 0 && yPos < 220) {
                String line = errorMsg;
                if (line.length() > Display::MAX_ERROR_LINE_LENGTH) {
                    line = line.substring(0, Display::MAX_ERROR_LINE_LENGTH);
                    errorMsg = errorMsg.substring(Display::MAX_ERROR_LINE_LENGTH);
                } else {
                    errorMsg = "";
                }
                display.setCursor(10, yPos);
                display.println(line);
                yPos += 20;
            }
        }
    }
    
    static void showLeaderboard(const LeaderboardEntry* entries, int count) {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setCursor(10, 10);
            display.setTextSize(2);
            display.println("LEADERBOARD");
            
            display.setTextSize(1);
            int yPos = 40;
            int validEntries = 0;
            
            for (int i = 0; i < count && validEntries < Display::MAX_LEADERBOARD_ENTRIES; i++) {
                if (entries[i].userId > 0 && entries[i].teamPoints > 0) {
                    display.setCursor(10, yPos);
                    display.print(entries[i].rank);
                    display.print(". ");
                    display.print(truncateString(entries[i].fullName, Display::MAX_LEADERBOARD_NAME_LENGTH));
                    display.print(" ");
                    display.print(entries[i].teamPoints);
                    display.println("pt");
                    yPos += 20;
                    validEntries++;
                }
            }
            
            while (validEntries < Display::MAX_LEADERBOARD_ENTRIES) {
                display.setCursor(10, yPos);
                display.print(validEntries + 1);
                display.print(". ");
                display.println("---");
                yPos += 20;
                validEntries++;
            }
        }
    }
    
    static void showWaitingMessage() {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setCursor(10, 80);
            display.setTextSize(2);
            display.println("Waiting");
            display.setCursor(10, 110);
            display.setTextSize(1);
            display.println("for scan...");
        }
    }
    
    static void showMainMenu() {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setTextSize(2);
            display.setCursor(10, 10);
            display.println("ELEVATE MENU");
            
            display.setTextSize(1);
            display.setCursor(10, 50);
            display.println("1. Scan (Button 1)");
            
            display.setCursor(10, 80);
            display.println("2. Leaderboard (Button 2)");
            
            display.setCursor(10, 110);
            display.println("3. Statistics (Button 3)");
            
            display.setCursor(10, 140);
            display.println("4. Settings (Button 4)");
            
            display.setTextColor(ILI9341_CYAN);
            display.setCursor(10, 180);
            display.println("Select option...");
        }
    }
    
    static void showScanMode() {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setTextSize(2);
            display.setCursor(10, 10);
            display.println("SCAN MODE");
            
            display.setTextSize(1);
            display.setCursor(10, 50);
            display.println("Enter User ID:");
            
            display.setTextColor(ILI9341_CYAN);
            display.setCursor(10, 90);
            display.println("Waiting for input...");
            
            display.setTextColor(ILI9341_WHITE);
            display.setCursor(10, 130);
            display.println("Format: <number>");
            display.setCursor(10, 150);
            display.println("Example: 123");
        }
    }
    
    static void showSettingsMode(const String& currentDeviceKey) {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setTextSize(2);
            display.setCursor(10, 10);
            display.println("SETTINGS");
            
            display.setTextSize(1);
            display.setCursor(10, 50);
            display.print("Device Key: ");
            display.println(truncateString(currentDeviceKey, 25));
            
            display.setTextColor(ILI9341_CYAN);
            display.setCursor(10, 90);
            display.println("Enter new Device Key:");
            display.setCursor(10, 110);
            display.println("Format: key:<value>");
            
            display.setTextColor(ILI9341_WHITE);
            display.setCursor(10, 150);
            display.println("Format: key:<value>");
            display.setCursor(10, 170);
            display.println("Example: key:new-device-002");
        }
    }
    
    static void showLoadingStep(const String& step, int progress = -1) {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setCursor(10, 50);
            display.setTextSize(2);
            display.println("Elevate");
            display.setCursor(10, 80);
            display.setTextSize(1);
            display.println(step);
            
            if (progress >= 0 && progress <= 100) {
                constexpr int barWidth = 200;
                constexpr int barHeight = 10;
                constexpr int barX = 20;
                constexpr int barY = 120;
                
                display.drawRect(barX, barY, barWidth, barHeight, ILI9341_WHITE);
                int fillWidth = (barWidth * progress) / 100;
                display.fillRect(barX, barY, fillWidth, barHeight, ILI9341_GREEN);
                
                display.setCursor(barX + barWidth + 10, barY - 2);
                display.print(progress);
                display.print("%");
            }
        }
    }
    
    static void showOfflineInfo() {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            
            display.setCursor(10, 10);
            display.setTextSize(1);
            display.println("SERVER UNAVAILABLE");
            
            display.setCursor(10, 30);
            display.print("Wi-Fi: ");
            if (WiFiManager::isConnected()) {
                display.println("OK");
                display.setCursor(10, 50);
                display.print("IP: ");
                IPAddress ip = WiFi.localIP();
                display.println(String(ip[0]) + "." + String(ip[1]) + "." + 
                               String(ip[2]) + "." + String(ip[3]));
            } else {
                display.println("NOT CONN.");
            }
            
            unsigned long uptime = (millis() - startTime) / 1000;
            unsigned long hours = uptime / 3600;
            unsigned long minutes = (uptime % 3600) / 60;
            unsigned long seconds = uptime % 60;
            
            display.setCursor(10, 70);
            display.print("Time: ");
            if (hours > 0) {
                display.print(hours);
                display.print("h ");
            }
            if (minutes > 0 || hours > 0) {
                display.print(minutes);
                display.print("m");
            } else {
                display.print(seconds);
                display.print("s");
            }
            
            display.setCursor(10, 90);
            display.print("Scans: ");
            display.print(successfulScans);
            display.print("/");
            display.print(successfulScans + failedScans);
            
            display.setCursor(10, 110);
            display.print("Mode: ");
            display.println((ConfigManager::currentMode == ConfigManager::SCAN_MODE) ? "SCAN" : "DASHBOARD");
        }
    }
    
    static void incrementSuccessfulScan() { successfulScans++; }
    static void incrementFailedScan() { failedScans++; }
    
    static void initializeStats() {
        startTime = millis();
        successfulScans = 0;
        failedScans = 0;
    }
    
    static void showDeviceStats() {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            display.setTextSize(2);
            display.setCursor(10, 5);
            display.println("STATISTICS");
            
            display.setTextSize(1);
            int yPos = 35;
            const int lineHeight = 18;
            
            int totalScans = LocalStorage::getTotalScans();
            int successfulScans = LocalStorage::getSuccessfulScans();
            int failedScans = LocalStorage::getFailedScans();
            int dailyScans = LocalAnalytics::getDailyScans();
            
            display.setCursor(10, yPos);
            display.print("Total: ");
            display.println(totalScans);
            yPos += lineHeight;
            
            display.setCursor(10, yPos);
            display.print("Success: ");
            display.print(successfulScans);
            display.print(" (");
            if (totalScans > 0) {
                float successRate = MathUtils::calculateSuccessRate(successfulScans, totalScans);
                display.print(successRate, 1);
            } else {
                display.print("0");
            }
            display.println("%)");
            yPos += lineHeight;
            
            display.setCursor(10, yPos);
            display.print("Failed: ");
            display.println(failedScans);
            yPos += lineHeight;
            
            display.setCursor(10, yPos);
            display.print("Today: ");
            display.println(dailyScans);
            yPos += lineHeight;
            
            float avgScansPerHour = LocalAnalytics::getAverageScansPerHour();
            display.setCursor(10, yPos);
            display.print("Avg/Hour: ");
            display.println(avgScansPerHour, 1);
            yPos += lineHeight;
            
            float efficiency = LocalAnalytics::getDeviceEfficiency();
            display.setCursor(10, yPos);
            display.print("Efficiency: ");
            display.print(efficiency, 1);
            display.println("%");
            yPos += lineHeight;
            
            int peakHour = LocalAnalytics::getPeakHour();
            if (peakHour >= 0) {
                display.setCursor(10, yPos);
                display.print("Peak Hour: ");
                display.println(peakHour);
                yPos += lineHeight;
            }
            
            unsigned long uptimeMs = millis() - startTime;
            unsigned long hours = uptimeMs / 3600000;
            unsigned long minutes = (uptimeMs % 3600000) / 60000;
            display.setCursor(10, yPos);
            display.print("Uptime: ");
            if (hours > 0) {
                display.print(hours);
                display.print("h ");
            }
            display.print(minutes);
            display.println("m");
        }
    }
    
    static bool testApiConnection() {
        if (!WiFiManager::isConnected()) {
            return false;
        }
        
        HTTPClient http;
        String testUrl = String(ConfigManager::API_BASE_URL) + "/api/iot/leaderboard?deviceKey=" + 
                        String(ConfigManager::getDeviceKey());
        http.begin(testUrl);
        http.setTimeout(3000);
        int httpCode = http.GET();
        http.end();
        
        return (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_BAD_REQUEST || httpCode == HTTP_CODE_UNAUTHORIZED);
    }
    
    static void showSystemStatus() {
        initDisplay();
        
        if (isDisplayInitialized) {
            display.fillScreen(ILI9341_BLACK);
            display.setTextColor(ILI9341_WHITE);
            
            display.setCursor(10, 5);
            display.setTextSize(1);
            display.println("=== SYSTEM STATUS ===");
            
            int yPos = 25;
            const int lineHeight = 18;
            const int maxLineWidth = 38;

            display.setTextColor(ILI9341_WHITE);
            display.setCursor(5, yPos);
            display.print("WiFi: ");
            String ssid = String(ConfigManager::WIFI_SSID);
            if (ssid.length() > maxLineWidth - 7) {
                ssid = ssid.substring(0, maxLineWidth - 10) + "...";
            }
            display.println(ssid);
            yPos += lineHeight;

            display.setCursor(5, yPos);
            display.print("WiFi Status: ");
            bool wifiConnected = WiFiManager::isConnected();
            if (wifiConnected) {
                display.setTextColor(ILI9341_GREEN);
                display.print("OK");
                display.setTextColor(ILI9341_WHITE);
                IPAddress ip = WiFi.localIP();
                display.print(" (");
                display.print(ip[0]);
                display.print(".");
                display.print(ip[1]);
                display.print(".");
                display.print(ip[2]);
                display.print(".");
                display.print(ip[3]);
                display.println(")");
            } else {
                display.setTextColor(ILI9341_RED);
                display.println("DISCONNECTED");
                display.setTextColor(ILI9341_WHITE);
            }
            yPos += lineHeight;
            
            display.setCursor(5, yPos);
            display.print("API: ");
            String apiUrl = String(ConfigManager::API_BASE_URL);
            if (apiUrl.length() > maxLineWidth - 6) {
                apiUrl = apiUrl.substring(0, maxLineWidth - 9) + "...";
            }
            display.println(apiUrl);
            yPos += lineHeight;

            display.setCursor(5, yPos);
            display.print("API Status: ");
            bool apiOk = testApiConnection();
            if (apiOk) {
                display.setTextColor(ILI9341_GREEN);
                display.println("OK");
            } else {
                display.setTextColor(ILI9341_RED);
                display.println("FAIL");
            }
            display.setTextColor(ILI9341_WHITE);
            yPos += lineHeight;

            display.setCursor(5, yPos);
            display.print("Device: ");
            String deviceKey = String(ConfigManager::getDeviceKey());
            if (deviceKey.length() > maxLineWidth - 9) {
                deviceKey = deviceKey.substring(0, maxLineWidth - 12) + "...";
            }
            display.println(deviceKey);
            yPos += lineHeight;

            display.setCursor(5, yPos);
            display.print("Mode: ");
            display.print((ConfigManager::currentMode == ConfigManager::SCAN_MODE) ? "SCAN" : "DASH");
            display.print(" | Int: ");
            display.print(ConfigManager::dashboardUpdateInterval / 1000);
            display.println("s");
        }
    }
};

