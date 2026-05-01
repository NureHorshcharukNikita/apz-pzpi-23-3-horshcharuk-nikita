#pragma once

#include <Arduino.h>
#include "constants.h"
#include "types.h"

struct PendingScan {
    int userId;
    unsigned long timestamp;
    bool processed;
};

class OfflineQueue {
private:
    static const int MAX_PENDING_SCANS = 10;
    static PendingScan pendingScans[MAX_PENDING_SCANS];
    static int queueHead;
    static int queueTail;
    static int queueSize;
    
public:
    static void initialize() {
        queueHead = 0;
        queueTail = 0;
        queueSize = 0;
        
        for (int i = 0; i < MAX_PENDING_SCANS; i++) {
            pendingScans[i].userId = 0;
            pendingScans[i].timestamp = 0;
            pendingScans[i].processed = false;
        }
    }
    
    static bool enqueue(int userId) {
        if (queueSize >= MAX_PENDING_SCANS) {
            return false;
        }
        
        pendingScans[queueTail].userId = userId;
        pendingScans[queueTail].timestamp = millis();
        pendingScans[queueTail].processed = false;
        
        queueTail = (queueTail + 1) % MAX_PENDING_SCANS;
        queueSize++;
        
        return true;
    }
    
    static bool dequeue(int& userId, unsigned long& timestamp) {
        if (queueSize <= 0) {
            return false;
        }
        
        userId = pendingScans[queueHead].userId;
        timestamp = pendingScans[queueHead].timestamp;
        pendingScans[queueHead].processed = true;
        
        queueHead = (queueHead + 1) % MAX_PENDING_SCANS;
        queueSize--;
        
        return true;
    }
    
    static bool hasPending() {
        return queueSize > 0;
    }
    
    static int getPendingCount() {
        return queueSize;
    }
    
    static void clear() {
        queueHead = 0;
        queueTail = 0;
        queueSize = 0;
        
        for (int i = 0; i < MAX_PENDING_SCANS; i++) {
            pendingScans[i].userId = 0;
            pendingScans[i].timestamp = 0;
            pendingScans[i].processed = false;
        }
    }
    
    static bool peek(int& userId, unsigned long& timestamp) {
        if (queueSize <= 0) {
            return false;
        }
        
        userId = pendingScans[queueHead].userId;
        timestamp = pendingScans[queueHead].timestamp;
        return true;
    }
};

