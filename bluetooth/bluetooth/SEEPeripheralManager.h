//
//  SEEPeripheralManager.h
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/28.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "SEEBluetooth.h"

NS_ASSUME_NONNULL_BEGIN

@interface SEEPeripheralManager : SEEBluetooth

+ (instancetype)shareManager;

- (void)addServiceWithUUID:(CBUUID *)uuid characters:(NSArray<CBCharacteristic *> *)characters complete:(nullable completeBlock)complete;

- (void)startAdvertisingWithLocalName:(nullable NSString *)localName complete:(nullable void (^)(CBPeripheralManager * manager, NSError * _Nullable error))complete;
- (void)stopAdvertising;

+ (CBMutableCharacteristic *)characterWithUUID:(CBUUID *)uuid properties:(CBCharacteristicProperties)properties value:(NSData *)value permissions:(CBAttributePermissions)permissions descriptor:(nullable NSString *)descriptor;

@property (nonatomic, copy) void(^subscribe)(BOOL enabled,CBMutableCharacteristic * characteristic, CBCentral * central,CBPeripheralManager * peripheral);

@property (nonatomic, copy) void(^write)(CBPeripheralManager * peripheral, CBATTRequest * request);

@end

NS_ASSUME_NONNULL_END
