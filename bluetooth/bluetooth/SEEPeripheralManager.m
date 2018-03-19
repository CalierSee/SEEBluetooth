//
//  SEEPeripheralManager.m
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/28.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "SEEPeripheralManager.h"
#import "UUIDS.h"
@interface SEEPeripheralManager () <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager * manager;

@property (nonatomic, strong) NSMutableArray <CBMutableService *> * serviceList;

@property (nonatomic, assign) BOOL delayAdvertising;

@property (nonatomic, copy) NSString * localName;

@property (nonatomic, copy) void (^advertisingComplete)(CBPeripheralManager * manager, NSError * _Nullable error) ;

@end

@implementation SEEPeripheralManager

+ (instancetype)shareManager {
    static SEEPeripheralManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        instance.complete = [NSMutableDictionary dictionary];
        instance.bluetoothState = kBLUETOOTH_UNKNOW;
        instance.manager = [[CBPeripheralManager alloc]initWithDelegate:instance queue:nil];
        instance.serviceList = [NSMutableArray array];
    });
    return instance;
}

- (void)addServiceWithUUID:(CBUUID *)uuid characters:(NSArray<CBCharacteristic *> *)characters complete:(completeBlock)complete {
    if (complete) {
        [self.complete setObject:complete forKey:uuid.UUIDString];
    }
    CBMutableService * server = [[CBMutableService alloc]initWithType:uuid primary:YES];
    [server setCharacteristics:characters];
    [self.serviceList addObject:server];
}

+ (CBMutableCharacteristic *)characterWithUUID:(CBUUID *)uuid properties:(CBCharacteristicProperties)properties value:(NSData *)value permissions:(CBAttributePermissions)permissions descriptor:(NSString *)descriptor {
    CBMutableCharacteristic * character = [[CBMutableCharacteristic alloc]initWithType:uuid properties:properties value:value permissions:permissions];
    if (descriptor) {
        CBMutableDescriptor * descriptors = [[CBMutableDescriptor alloc]initWithType:[CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString] value:descriptor];
        [character setDescriptors:@[descriptors]];
    }
    return character;
}

/**
 开始广播
 */
- (void)startAdvertisingWithLocalName:(NSString *)localName complete:(nullable void (^)(CBPeripheralManager * manager, NSError * _Nullable error))complete {
    self.localName = localName;
    self.advertisingComplete = complete;
    //如果当前蓝牙状态正常则开始广播，如果不正常则等待状态更新
    if (self.bluetoothState == kBLUETOOTH_ON) {
        serveiceCount = self.serviceList.count;
        [self.serviceList enumerateObjectsUsingBlock:^(CBMutableService *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //添加服务
            [self.manager addService:obj];
        }];
    }
    else {
        //标识位 如果为YES 则蓝牙状态正常后开始广播
        self.delayAdvertising = YES;
    }
}

- (void)stopAdvertising {
    [self.serviceList enumerateObjectsUsingBlock:^(CBMutableService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.manager removeService:obj];
    }];
    [self.serviceList removeAllObjects];
    [self.complete removeAllObjects];
    [self.manager stopAdvertising];
}

#pragma mark CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    [self dealBluetoothState:peripheral.state];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    NSString * key = service.UUID.UUIDString;
    completeBlock complete = [self.complete objectForKey:key];
    if (complete) {
        complete(service.UUID, error);
        [self.complete removeObjectForKey:key];
    }
    @synchronized(self) {
        //所有服务添加完成开始广播
        serveiceCount -= 1;
        if (serveiceCount == 0) {
            NSMutableArray * uuids = [NSMutableArray array];
            [self.serviceList enumerateObjectsUsingBlock:^(CBMutableService *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [uuids addObject:obj.UUID];
            }];
            if (self.localName.length) {
                [self.manager startAdvertising:@{CBAdvertisementDataLocalNameKey: self.localName, CBAdvertisementDataServiceUUIDsKey:uuids}];
            }
            else {
                [self.manager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:uuids}];
            }
        }
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if (self.advertisingComplete) {
        self.advertisingComplete(peripheral, error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if (self.subscribe && characteristic.properties == CBCharacteristicPropertyNotify) {
        self.subscribe(YES,(CBMutableCharacteristic *)characteristic, central,peripheral);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    if (self.subscribe && characteristic.properties == CBCharacteristicPropertyNotify) {
        self.subscribe(NO, (CBMutableCharacteristic *)characteristic, central,peripheral);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
        CBATTRequest * request = requests.firstObject;
        //如果有写权限则写入
        if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
            NSData * value = request.value;
            [((CBMutableCharacteristic *)request.characteristic) setValue:value];
            //做出相应
            [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
            if (self.write) {
                self.write(peripheral, request);
            }
        }
        else {
            [peripheral respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
            if (self.write) {
                self.write(peripheral, request);
            }
        }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        [request setValue:request.characteristic.value];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
    else {
        [peripheral respondToRequest:request withResult:CBATTErrorReadNotPermitted];
    }
}

#pragma mark getter & setter
- (void)setBluetoothState:(NSString *)bluetoothState {
    [super setBluetoothState:bluetoothState];
    if (bluetoothState == kBLUETOOTH_ON) {
        if (self.delayAdvertising) {
            [self startAdvertisingWithLocalName:self.localName complete:self.advertisingComplete];
            self.delayAdvertising = NO;
        }
    }
}

@end
