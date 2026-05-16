#pragma once

#include <Arduino.h>
#include "constants.h"

class MenuButton {
private:
    static int getButtonIndex(int pin) {
        if (pin == Hardware::BUTTON_SCAN) return 0;
        if (pin == Hardware::BUTTON_LEADERBOARD) return 1;
        if (pin == Hardware::BUTTON_STATS) return 2;
        if (pin == Hardware::BUTTON_SETTINGS) return 3;
        if (pin == Hardware::BUTTON_BACK) return 4;
        return -1;
    }
    
public:
    static bool isPressed(int pin) {
        int buttonIndex = getButtonIndex(pin);
        if (buttonIndex < 0) return false;
        
        static unsigned long lastPressTime[5] = {0};
        static bool wasPressed[5] = {false};
        static bool buttonState[5] = {false};
        
        unsigned long now = millis();
        bool currentState = (digitalRead(pin) == LOW);
        
        if (currentState != buttonState[buttonIndex]) {
            buttonState[buttonIndex] = currentState;
            
            if (currentState && !wasPressed[buttonIndex]) {
                if (now - lastPressTime[buttonIndex] >= Timing::BUTTON_DEBOUNCE_MS) {
                    lastPressTime[buttonIndex] = now;
                    wasPressed[buttonIndex] = true;
                    return true;
                }
            }
        }
        
        if (!currentState) {
            wasPressed[buttonIndex] = false;
        }
        
        return false;
    }
    
    static void initialize() {
        pinMode(Hardware::BUTTON_SCAN, INPUT_PULLUP);
        pinMode(Hardware::BUTTON_LEADERBOARD, INPUT_PULLUP);
        pinMode(Hardware::BUTTON_STATS, INPUT_PULLUP);
        pinMode(Hardware::BUTTON_SETTINGS, INPUT_PULLUP);
        pinMode(Hardware::BUTTON_BACK, INPUT_PULLUP);
    }
};

