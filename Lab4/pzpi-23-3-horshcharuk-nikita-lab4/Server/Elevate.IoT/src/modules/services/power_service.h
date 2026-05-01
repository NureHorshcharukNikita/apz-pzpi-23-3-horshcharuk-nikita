#pragma once

#include "constants.h"
#include "display.h"
#include "modules/hardware/power_button.h"
#include "modules/network/wifi_manager.h"

class PowerService {
public:
    static void handlePowerOff() {
        WiFiManager::disconnect();
        PowerButton::setDeviceState(false);
        
        display.fillScreen(ILI9341_BLACK);
        display.setTextColor(ILI9341_CYAN);
        display.setTextSize(2);
        display.setCursor(10, 10);
        display.println("Press Power to start");
    }

};

