#pragma once

#include <Arduino.h>
#include "constants.h"

class PowerButton {
private:
    static bool isInitialized;
    static unsigned long lastButtonPressTime;
    static bool wasPressed;
    static bool devicePowerState;
    
public:
    static void initialize() {
        if (isInitialized) return;
        
        pinMode(Hardware::BUTTON_POWER, INPUT_PULLUP);
        lastButtonPressTime = 0;
        wasPressed = false;
        devicePowerState = false;
        isInitialized = true;
    }
    
    static bool isPressed() {
        if (!isInitialized) initialize();
        
        unsigned long now = millis();
        if (now - lastButtonPressTime < Timing::BUTTON_DEBOUNCE_MS) {
            return false;
        }
        
        if (digitalRead(Hardware::BUTTON_POWER) == LOW) {
            if (!wasPressed) {
                lastButtonPressTime = now;
                wasPressed = true;
                
                while (digitalRead(Hardware::BUTTON_POWER) == LOW) {
                    delay(10);
                }
                
                devicePowerState = !devicePowerState;
                return true;
            }
        } else {
            wasPressed = false;
        }
        
        return false;
    }
    
    static bool isDeviceOn() {
        return devicePowerState;
    }
    
    static void setDeviceState(bool state) {
        devicePowerState = state;
    }
};

