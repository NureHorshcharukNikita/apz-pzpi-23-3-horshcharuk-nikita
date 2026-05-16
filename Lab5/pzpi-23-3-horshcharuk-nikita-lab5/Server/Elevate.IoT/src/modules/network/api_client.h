#pragma once

#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "constants.h"
#include "types.h"
#include "modules/core/config_manager.h"
#include "modules/network/wifi_manager.h"
#include "modules/analytics/local_analytics.h"

class ApiClient {
private:
    static HTTPClient http;
    
    static String buildScanUrl() {
        return String(ConfigManager::API_BASE_URL) + "/api/iot/scan";
    }
    
    static String buildLeaderboardUrl() {
        return String(ConfigManager::API_BASE_URL) + "/api/iot/leaderboard?deviceKey=" + 
               String(ConfigManager::getDeviceKey());
    }
    
    static String buildStatsUrl() {
        return String(ConfigManager::API_BASE_URL) + "/api/iot/stats";
    }
    
    static String buildGetStatsUrl() {
        return String(ConfigManager::API_BASE_URL) + "/api/iot/stats?deviceKey=" + 
               String(ConfigManager::getDeviceKey());
    }
    
    static String buildTeamLevelsUrl() {
        return String(ConfigManager::API_BASE_URL) + "/api/iot/levels?deviceKey=" + 
               String(ConfigManager::getDeviceKey());
    }
    
    static String buildTeamLevelsByTeamUrl(int teamId) {
        return String(ConfigManager::API_BASE_URL) + "/api/iot/levels?teamId=" + 
               String(teamId);
    }
    
    static bool handleRedirect(int& httpCode, const String& requestBody = "") {
        if (httpCode != 307 && httpCode != 301) return false;
        
        String location = http.header("Location");
        if (location.length() == 0) {
            location = http.header("location");
        }
        
        http.end();
        
        if (location.length() == 0) return false;
        
        http.begin(location);
        http.setTimeout(Timing::HTTP_TIMEOUT_MS);
        if (requestBody.length() > 0) {
            http.addHeader("Content-Type", "application/json");
            httpCode = http.POST(requestBody);
        } else {
            httpCode = http.GET();
        }
        
        return (httpCode != 307 && httpCode != 301);
    }
    
    static void parseErrorResponse(int httpCode, String& errorMessage) {
        String response = http.getString();
        
        if (response.length() == 0) {
            if (httpCode == HTTP_CODE_BAD_REQUEST) {
                errorMessage = "Bad request (400)";
            } else if (httpCode == HTTP_CODE_UNAUTHORIZED) {
                errorMessage = "Unauthorized (401)";
            } else {
                errorMessage = "Server error: " + String(httpCode);
            }
            return;
        }
        
        JsonDocument errorDoc;
        if (deserializeJson(errorDoc, response) == DeserializationError::Ok) {
            if (errorDoc["message"].is<String>()) {
                errorMessage = errorDoc["message"].as<String>();
            } else if (errorDoc["error"].is<String>()) {
                errorMessage = errorDoc["error"].as<String>();
            } else if (errorDoc["title"].is<String>()) {
                errorMessage = errorDoc["title"].as<String>();
            } else {
                errorMessage = "Server error: " + String(httpCode);
            }
        } else {
            errorMessage = response.substring(0, min(50, (int)response.length()));
        }
    }
    
    static void parseConnectionError(int httpCode, String& errorMessage) {
        if (httpCode == HTTPC_ERROR_CONNECTION_REFUSED) {
            errorMessage = "Connection refused";
        } else if (httpCode == HTTPC_ERROR_CONNECTION_LOST) {
            errorMessage = "Connection lost";
        } else if (httpCode == HTTPC_ERROR_READ_TIMEOUT) {
            errorMessage = "Connection timeout";
        } else {
            errorMessage = "Server unavailable (error: " + String(httpCode) + ")";
        }
    }
    
public:
    static ScanResult scanUser(int userId) {
        ScanResult result;
        
        if (!WiFiManager::ensureConnection()) {
            result.errorMessage = "No network";
            return result;
        }
        
        String url = buildScanUrl();
        JsonDocument doc;
        doc["deviceKey"] = ConfigManager::getDeviceKey();
        doc["userId"] = userId;
        
        String requestBody;
        serializeJson(doc, requestBody);
        
        http.begin(url);
        http.setTimeout(Timing::HTTP_TIMEOUT_MS);
        http.addHeader("Content-Type", "application/json");
        
        int httpCode = http.POST(requestBody);
        
        if (httpCode == 307 || httpCode == 301) {
            if (!handleRedirect(httpCode, requestBody)) {
                result.errorMessage = "Redirect error";
                http.end();
                return result;
            }
        }
        
        if (httpCode == HTTP_CODE_OK) {
            String response = http.getString();
            JsonDocument responseDoc;
            
            if (deserializeJson(responseDoc, response) == DeserializationError::Ok) {
                result.success = true;
                result.userId = responseDoc["userId"] | 0;
                result.teamId = responseDoc["teamId"] | 0;
                result.fullName = responseDoc["fullName"].as<String>();
                result.teamPoints = responseDoc["teamPoints"] | 0;
                result.teamLevelName = responseDoc["teamLevelName"].as<String>();
                
                JsonArray badges = responseDoc["recentBadges"].as<JsonArray>();
                result.badgeCount = min((int)badges.size(), Display::MAX_RECENT_BADGES);
                for (int i = 0; i < result.badgeCount; i++) {
                    result.recentBadges[i] = badges[i].as<String>();
                }
            } else {
                result.errorMessage = "Response parsing error";
            }
        } else if (httpCode >= 400) {
            parseErrorResponse(httpCode, result.errorMessage);
        } else if (httpCode < 0) {
            parseConnectionError(httpCode, result.errorMessage);
        } else {
            result.errorMessage = "Server error: " + String(httpCode);
        }
        
        http.end();
        return result;
    }
    
    static bool getLeaderboard(LeaderboardEntry* entries, int maxEntries) {
        if (!WiFiManager::ensureConnection()) {
            return false;
        }
        
        String url = buildLeaderboardUrl();
        http.begin(url);
        http.setTimeout(Timing::HTTP_TIMEOUT_MS);
        
        int httpCode = http.GET();
        
        if (httpCode == 307 || httpCode == 301) {
            if (!handleRedirect(httpCode)) {
                http.end();
                return false;
            }
        }
        
        if (httpCode == HTTP_CODE_OK) {
            String response = http.getString();
            JsonDocument doc;
            
            if (deserializeJson(doc, response) == DeserializationError::Ok) {
                JsonArray leaderboard = doc.as<JsonArray>();
                int count = min((int)leaderboard.size(), maxEntries);
                
                for (int i = 0; i < count; i++) {
                    JsonObject entry = leaderboard[i];
                    entries[i].rank = entry["rank"] | (i + 1);
                    entries[i].userId = entry["userId"] | 0;
                    entries[i].fullName = entry["fullName"].as<String>();
                    entries[i].teamPoints = entry["teamPoints"] | 0;
                    entries[i].teamLevel = entry["teamLevel"].as<String>();
                }
                
                http.end();
                return true;
            }
        }
        
        http.end();
        return false;
    }
    
    static bool sendDeviceStats(const LocalAnalytics::DeviceStats& stats) {
        if (!WiFiManager::ensureConnection()) {
            return false;
        }
        
        String url = buildStatsUrl();
        JsonDocument doc;
        doc["deviceKey"] = ConfigManager::getDeviceKey();
        doc["totalScans"] = stats.totalScans;
        doc["successfulScans"] = stats.successfulScans;
        doc["failedScans"] = stats.failedScans;
        doc["dailyScans"] = stats.dailyScans;
        doc["averageScansPerHour"] = stats.averageScansPerHour;
        doc["successRate"] = stats.successRate;
        doc["deviceEfficiency"] = stats.deviceEfficiency;
        doc["peakHour"] = stats.peakHour;
        doc["activityTrend"] = stats.activityTrend;
        doc["uptimeMs"] = stats.uptimeMs;
        
        String requestBody;
        serializeJson(doc, requestBody);
        
        http.begin(url);
        http.setTimeout(Timing::HTTP_TIMEOUT_MS);
        http.addHeader("Content-Type", "application/json");
        
        int httpCode = http.POST(requestBody);
        
        if (httpCode == 307 || httpCode == 301) {
            if (!handleRedirect(httpCode, requestBody)) {
                http.end();
                return false;
            }
        }
        
        bool success = (httpCode == HTTP_CODE_OK);
        http.end();
        return success;
    }
    
    static bool getDeviceStats(LocalAnalytics::DeviceStats& stats) {
        if (!WiFiManager::ensureConnection()) {
            return false;
        }
        
        String url = buildGetStatsUrl();
        http.begin(url);
        http.setTimeout(Timing::HTTP_TIMEOUT_MS);
        
        int httpCode = http.GET();
        
        if (httpCode == 307 || httpCode == 301) {
            if (!handleRedirect(httpCode)) {
                http.end();
                return false;
            }
        }
        
        if (httpCode == HTTP_CODE_NOT_FOUND) {
            http.end();
            stats.totalScans = 0;
            stats.successfulScans = 0;
            stats.failedScans = 0;
            stats.dailyScans = 0;
            stats.averageScansPerHour = 0.0f;
            stats.successRate = 0.0f;
            stats.deviceEfficiency = 0.0f;
            stats.peakHour = -1;
            stats.activityTrend = 0;
            stats.uptimeMs = 0L;
            return true;
        }
        
        if (httpCode != HTTP_CODE_OK) {
            http.end();
            return false;
        }
        
        String response = http.getString();
        http.end();
        
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, response);
        
        if (error) {
            return false;
        }
        
        stats.totalScans = doc["totalScans"] | 0;
        stats.successfulScans = doc["successfulScans"] | 0;
        stats.failedScans = doc["failedScans"] | 0;
        stats.dailyScans = doc["dailyScans"] | 0;
        stats.averageScansPerHour = doc["averageScansPerHour"] | 0.0f;
        stats.successRate = doc["successRate"] | 0.0f;
        stats.deviceEfficiency = doc["deviceEfficiency"] | 0.0f;
        stats.peakHour = doc["peakHour"] | -1;
        stats.activityTrend = doc["activityTrend"] | 0;
        stats.uptimeMs = doc["uptimeMs"] | 0L;
        
        return true;
    }
    
    static int getTeamLevels(TeamLevel* levels, int maxLevels, int teamId = 0) {
        if (!WiFiManager::ensureConnection()) {
            return 0;
        }
        
        String url;
        if (teamId > 0) {
            url = buildTeamLevelsByTeamUrl(teamId);
        } else {
            url = buildTeamLevelsUrl();
        }
        
        http.begin(url);
        http.setTimeout(Timing::HTTP_TIMEOUT_MS);
        
        int httpCode = http.GET();
        
        if (httpCode == 307 || httpCode == 301) {
            if (!handleRedirect(httpCode)) {
                http.end();
                return 0;
            }
        }
        
        if (httpCode == HTTP_CODE_OK) {
            String response = http.getString();
            JsonDocument doc;
            
            if (deserializeJson(doc, response) == DeserializationError::Ok) {
                JsonArray levelsArray = doc.as<JsonArray>();
                int count = min((int)levelsArray.size(), maxLevels);
                
                for (int i = 0; i < maxLevels; i++) {
                    levels[i].id = 0;
                    levels[i].name = "";
                    levels[i].requiredPoints = 0;
                    levels[i].orderIndex = 0;
                }
                
                for (int i = 0; i < count; i++) {
                    JsonObject level = levelsArray[i];
                    levels[i].id = level["id"] | 0;
                    levels[i].name = level["name"].as<String>();
                    levels[i].requiredPoints = level["requiredPoints"] | 0;
                    levels[i].orderIndex = level["orderIndex"] | 0;
                }
                
                http.end();
                return count;
            }
        }
        
        http.end();
        return 0;
    }
};

