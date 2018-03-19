//
//  SEEBluetooth.h
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/28.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

static NSUInteger serveiceCount = 0;

//蓝牙状态
static NSString * const kBLUETOOTH_UNKNOW =       @"蓝牙状态未知";
static NSString * const kBLUETOOTH_RESET =        @"蓝牙重置";
static NSString * const kBLUETOOTH_UNSPPORTED =   @"该设备不支持蓝牙";
static NSString * const kBLUETOOTH_UNAUTHORIZED = @"未授权蓝牙权限";
static NSString * const kBLUETOOTH_OFF =          @"蓝牙已关闭";
static NSString * const kBLUETOOTH_ON =           @"蓝牙已开启";
static NSString * const kBLUETOOTH_ERROR =        @"未知错误";

typedef void(^completeBlock)(CBUUID * _Nullable uuid, NSError * _Nullable error);

@interface SEEBluetooth : NSObject

//蓝牙状态
@property (nonatomic, copy) NSString * bluetoothState;

+ (instancetype)shareManager;

//回调缓存
@property (nonatomic, strong) NSMutableDictionary <NSString *, completeBlock> * complete;

- (void)dealBluetoothState:(CBManagerState)state;

@end

NS_ASSUME_NONNULL_END
