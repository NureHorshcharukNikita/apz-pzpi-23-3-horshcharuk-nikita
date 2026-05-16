#pragma once

#include <Arduino.h>
#include "types.h"

struct LevelProgressResult {
    int progress;
    int pointsToNext;
    bool isMaxLevel; 
    String nextLevelName;
};

class MathUtils {
public:
    static int calculateLevelProgress(int currentPoints, int currentLevel) {
        if (currentLevel <= 0) return 0;
        
        int basePointsForLevel = currentLevel * 100;
        int nextLevelPoints = (currentLevel + 1) * 100;
        int pointsInCurrentLevel = currentPoints - basePointsForLevel;
        int pointsNeededForNext = nextLevelPoints - basePointsForLevel;
        
        if (pointsNeededForNext <= 0) return 100;
        
        int progress = (pointsInCurrentLevel * 100) / pointsNeededForNext;
        if (progress < 0) return 0;
        if (progress > 100) return 100;
        return progress;
    }
    
    static LevelProgressResult calculateLevelProgressFromDB(
        int currentPoints,
        const String& currentLevelName,
        const TeamLevel* levels,
        int levelsCount) {
        
        LevelProgressResult result;
        result.progress = 0;
        result.pointsToNext = -1;
        result.isMaxLevel = false;
        result.nextLevelName = "";
        
        if (levelsCount <= 0 || currentLevelName.length() == 0) {
            result.progress = -1;
            return result;
        }
        

        int currentLevelIndex = -1;
        for (int i = 0; i < levelsCount; i++) {
            if (levels[i].name == currentLevelName) {
                currentLevelIndex = i;
                break;
            }
        }
        
        if (currentLevelIndex < 0) {
            for (int i = levelsCount - 1; i >= 0; i--) {
                if (currentPoints >= levels[i].requiredPoints) {
                    currentLevelIndex = i;
                    break;
                }
            }
        }
        
        if (currentLevelIndex < 0) {
            result.progress = -1;
            return result;
        }
        
        if (currentLevelIndex >= levelsCount - 1) {
            result.progress = 100;
            result.pointsToNext = -1;
            result.isMaxLevel = true;
            result.nextLevelName = "";
            return result;
        }
        
        int currentLevelPoints = levels[currentLevelIndex].requiredPoints;
        int nextLevelPoints = levels[currentLevelIndex + 1].requiredPoints;
        int pointsInCurrentLevel = currentPoints - currentLevelPoints;
        int pointsNeededForNext = nextLevelPoints - currentLevelPoints;
        
        if (pointsNeededForNext <= 0) {
            result.progress = 100;
            result.pointsToNext = 0;
            result.isMaxLevel = false;
            result.nextLevelName = levels[currentLevelIndex + 1].name;
            return result;
        }
        
        int progress = (pointsInCurrentLevel * 100) / pointsNeededForNext;
        if (progress < 0) progress = 0;
        if (progress > 100) progress = 100;
        
        result.progress = progress;
        result.pointsToNext = nextLevelPoints - currentPoints;
        result.isMaxLevel = false;
        result.nextLevelName = levels[currentLevelIndex + 1].name;
        
        return result;
    }
    
    static int calculatePointsToNextLevel(int currentPoints, int currentLevel) {
        int nextLevelPoints = (currentLevel + 1) * 100;
        int pointsNeeded = nextLevelPoints - currentPoints;
        return (pointsNeeded > 0) ? pointsNeeded : 0;
    }
    
    static int calculatePointsToNextLevelFromDB(
        int currentPoints,
        const String& currentLevelName,
        const TeamLevel* levels,
        int levelsCount) {
        
        LevelProgressResult result = calculateLevelProgressFromDB(
            currentPoints, currentLevelName, levels, levelsCount);
        
        return result.pointsToNext;
    }
    
    static float calculateAverage(int* values, int count) {
        if (count <= 0) return 0.0;
        
        long sum = 0;
        for (int i = 0; i < count; i++) {
            sum += values[i];
        }
        return (float)sum / count;
    }
    
    static float calculateSuccessRate(int successful, int total) {
        if (total <= 0) return 0.0;
        return (float)successful * 100.0 / total;
    }
    
    static int calculateTrend(int* values, int count) {
        if (count < 2) return 0;
        
        int first = values[0];
        int last = values[count - 1];
        return last - first;
    }
    
    static float calculateChangeRate(int pointsChange, unsigned long timeMs) {
        if (timeMs <= 0) return 0.0;
        
        float hours = timeMs / 3600000.0;
        if (hours <= 0) return 0.0;
        
        return pointsChange / hours;
    }
    
    static unsigned long predictTimeToGoal(int currentPoints, int goalPoints, float pointsPerHour) {
        if (pointsPerHour <= 0) return 0;
        
        int pointsNeeded = goalPoints - currentPoints;
        if (pointsNeeded <= 0) return 0;
        
        float hoursNeeded = pointsNeeded / pointsPerHour;
        unsigned long result = (unsigned long)(hoursNeeded * 3600000.0);
        return result;
    }
    
    static int calculateLocalRank(const LeaderboardEntry* entries, int count, int userId) {
        for (int i = 0; i < count; i++) {
            if (entries[i].userId == userId) {
                return entries[i].rank > 0 ? entries[i].rank : (i + 1);
            }
        }
        return -1;
    }
    
    static int calculatePointsFromLeader(const LeaderboardEntry* entries, int count, int userPoints) {
        if (count <= 0) return 0;
        
        int leaderPoints = entries[0].teamPoints;
        int diff = leaderPoints - userPoints;
        return (diff > 0) ? diff : 0;
    }
    
    static float calculateScanEfficiency(int successful, int failed, unsigned long periodMs) {
        int total = successful + failed;
        if (total <= 0) return 0.0;
        
        float successRate = calculateSuccessRate(successful, total);
        float hours = periodMs / 3600000.0;
        if (hours <= 0) return successRate;
        
        return successRate / hours;
    }
};

