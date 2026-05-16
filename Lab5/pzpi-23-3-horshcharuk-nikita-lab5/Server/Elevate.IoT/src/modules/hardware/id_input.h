#pragma once

#include <Arduino.h>
#include "constants.h"

class IdInput {
private:
    static int inputUserId;
    static bool inputMode;
    static unsigned long lastSerialCheck;
    static String serialBuffer;
    
    
    static void processSerialInput(bool settingsMode) {
        if (Serial.available() > 0) {
            while (Serial.available() > 0) {
                char c = Serial.read();
                
                if (c == '\n' || c == '\r') {
                    if (serialBuffer.length() > 0) {
                        if (settingsMode) {
                            serialBuffer.trim();
                            serialBuffer.toLowerCase();
                            if (serialBuffer == "exit") {
                                inputMode = true;
                                serialBuffer = "EXIT";
                                Serial.println("Exiting settings...");
                            } else if (serialBuffer.startsWith("key:")) {
                                String newKey = serialBuffer.substring(4);
                                newKey.trim();
                                if (newKey.length() > 0) {
                                    inputMode = true;
                                    serialBuffer = newKey;
                                    Serial.print("Device Key set: ");
                                    Serial.println(newKey);
                                } else {
                                    Serial.println("Error: Key cannot be empty");
                                    serialBuffer = "";
                                }
                            } else {
                                Serial.print("Invalid format. You entered: ");
                                Serial.println(serialBuffer);
                                Serial.println("Expected format: key:<value> or 'exit'");
                                serialBuffer = "";
                            }
                        } else {
                            inputUserId = serialBuffer.toInt();
                            serialBuffer = "";
                            inputMode = true;
                            Serial.print("User ID set: ");
                            Serial.println(inputUserId);
                        }
                    }
                } else {
                    serialBuffer += c;
                }
            }
        }
    }
    
    
public:
    static void initialize() {
        inputUserId = 0;
        inputMode = false;
        lastSerialCheck = 0;
        serialBuffer = "";
    }
    
    static void update(bool settingsMode = false) {
        processSerialInput(settingsMode);
    }
    
    static String getDeviceKeyInput() {
        return serialBuffer;
    }
    
    static bool hasInputUserId() {
        return inputMode;
    }
    
    static int getInputUserId() {
        return inputUserId;
    }
    
    static void clearInput() {
        inputUserId = 0;
        inputMode = false;
        serialBuffer = "";
    }
};

