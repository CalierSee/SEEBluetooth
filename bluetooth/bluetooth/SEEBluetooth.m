//
//  SEEBluetooth.m
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/28.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "SEEBluetooth.h"

@implementation SEEBluetooth

- (void)dealBluetoothState:(CBManagerState)state {
    switch (state) {
        case CBManagerStateUnknown:
            self.bluetoothState = kBLUETOOTH_UNKNOW;
            break;
        case CBManagerStateResetting:
            self.bluetoothState = kBLUETOOTH_RESET;
            break;
        case CBManagerStateUnsupported:
            self.bluetoothState = kBLUETOOTH_UNSPPORTED;
            break;
        case CBManagerStateUnauthorized:
            self.bluetoothState = kBLUETOOTH_UNAUTHORIZED;
            break;
        case CBManagerStatePoweredOff:
            self.bluetoothState = kBLUETOOTH_OFF;
            break;
        case CBManagerStatePoweredOn:
            self.bluetoothState = kBLUETOOTH_ON;
            break;
        default:
            self.bluetoothState = kBLUETOOTH_ERROR;
            break;
    }
}

@end
