#pragma once

#include <Arduino.h>
#include "constants.h"
#include "modules/hardware/menu_button.h"

class MenuManager {
public:
    enum MenuState {
        MAIN_MENU,
        SCAN_MODE,
        LEADERBOARD_VIEW,
        STATS_VIEW,
        SETTINGS_MODE
    };
    
    static MenuState currentState;
    static MenuState previousState;
    static bool scanModeActive;
    static bool settingsModeActive;
    
    static void initialize() {
        currentState = MAIN_MENU;
        previousState = SCAN_MODE;
        scanModeActive = false;
        settingsModeActive = false;
    }
    
    static void update() {
        if (currentState == MAIN_MENU) {
            if (MenuButton::isPressed(Hardware::BUTTON_SCAN)) {
                previousState = currentState;
                currentState = SCAN_MODE;
                scanModeActive = true;
                return;
            }
            
            if (MenuButton::isPressed(Hardware::BUTTON_LEADERBOARD)) {
                previousState = currentState;
                currentState = LEADERBOARD_VIEW;
                return;
            }
            
            if (MenuButton::isPressed(Hardware::BUTTON_BACK)) {
                return;
            }
            
            if (MenuButton::isPressed(Hardware::BUTTON_STATS)) {
                previousState = currentState;
                currentState = STATS_VIEW;
                return;
            }
            
            if (MenuButton::isPressed(Hardware::BUTTON_SETTINGS)) {
                previousState = currentState;
                currentState = SETTINGS_MODE;
                settingsModeActive = true;
                return;
            }
        }
        
        if (currentState != MAIN_MENU) {
            if (MenuButton::isPressed(Hardware::BUTTON_BACK)) {
                returnToMainMenu();
                return;
            }
        }
    }
    
    static void returnToMainMenu() {
        previousState = currentState;
        currentState = MAIN_MENU;
        scanModeActive = false;
        settingsModeActive = false;
    }
};

