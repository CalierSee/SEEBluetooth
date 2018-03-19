//
//  SEECenteralManager.m
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/27.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "SEECentralManager.h"

static NSUInteger characteristicCount = 0;

@interface SEECentralManager() <CBPeripheralDelegate,CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager * manager;

//连接option
@property (nonatomic, strong) NSDictionary * peripheralOption;


/**
 扫描结果回调
 */
@property (nonatomic, copy) void (^scanResult)(NSArray<NSDictionary *> *);
//扫描到的设备列表
@property (nonatomic, strong) NSMutableArray <NSDictionary *> * scanPeripheralList;
//延迟扫描标志
@property (nonatomic, assign) BOOL delayScan;

//自动重连
@property (nonatomic, strong) NSArray * scanServiceList;
@property (nonatomic, strong) NSDictionary * scanOption;

//是否为用户手动关闭连接
@property (nonatomic, assign) BOOL userDisconnect;


//连接外设失败异常回调
@property (nonatomic, copy)void(^connectComplete)(CBPeripheral * peripheral,NSError * error);

@end

@implementation SEECentralManager

+ (instancetype)shareManager {
    static SEECentralManager * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        instance.complete = [NSMutableDictionary dictionary];
        instance.bluetoothState = kBLUETOOTH_UNKNOW;
        instance.connectState = kCONNECT_UNKNOW;
        instance.scanPeripheralList = [NSMutableArray array];
        instance.manager = [[CBCentralManager alloc]initWithDelegate:instance queue:nil];
    });
    return instance;
}

#pragma mark public method
- (void)scanForPeripheralsUUIDList:(NSArray<CBUUID *> *)serviceList option:(NSDictionary *)option result:(void (^)(NSArray<NSDictionary *> *))result {
    self.scanServiceList = serviceList;
    self.scanOption = option;
    self.scanResult = result;
    if (self.bluetoothState == kBLUETOOTH_ON) {
        [self.manager scanForPeripheralsWithServices:serviceList options:option];
    }
    else {
        self.delayScan = YES;
    }
}

- (void)stopScan {
    [self.manager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary *)options complete:(void(^)(CBPeripheral * peripheral,NSError * error))complete{
    self.userDisconnect = NO;
    self.connectPeripheral = peripheral;
    self.peripheralOption = options;
    self.connectComplete = complete;
    [self.manager connectPeripheral:peripheral options:options];
}

- (void)disconnect {
    self.userDisconnect = YES;
    if (self.connectPeripheral) {
        [self.manager cancelPeripheralConnection:self.connectPeripheral];
        [self.complete removeAllObjects];
        self.scanResult = nil;
        self.onReceive = nil;
        self.prepareComplete = NO;
        self.descriptorsComplete = NO;
    }
}

- (void)subscribeCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(CBUUID *)sUUID complete:(completeBlock)complete{
    if (complete) {
        [self.complete setObject:complete forKey:cUUID.UUIDString];
    }
    CBCharacteristic * characteristic = [self see_characteristicUUID:cUUID withServiceUUID:sUUID];
    if (characteristic && characteristic.properties & CBCharacteristicPropertyNotify) {
        [self.connectPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)unsubscribeCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(CBUUID *)sUUID complete:(completeBlock)complete{
    if (complete) {
        [self.complete setObject:complete forKey:cUUID.UUIDString];
    }
    CBCharacteristic * characteristic = [self see_characteristicUUID:cUUID withServiceUUID:sUUID];
    if (characteristic && characteristic.properties & CBCharacteristicPropertyNotify) {
        [self.connectPeripheral setNotifyValue:NO forCharacteristic:characteristic];
    }
}

- (void)readCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(CBUUID *)sUUID {
    CBCharacteristic * characteristic = [self see_characteristicUUID:cUUID withServiceUUID:sUUID];
    if (characteristic && characteristic.properties & CBCharacteristicPropertyRead) {
        [self.connectPeripheral readValueForCharacteristic:characteristic];
    }
}

- (void)writeCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(CBUUID *)sUUID value:(nonnull NSData *)value complete:(nonnull completeBlock)complete {
    if (complete) {
        [self.complete setObject:complete forKey:cUUID.UUIDString];
    }
    CBCharacteristic * characteristic = [self see_characteristicUUID:cUUID withServiceUUID:sUUID];
    if (characteristic && characteristic.properties & CBCharacteristicPropertyWrite) {
        [self.connectPeripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark private method
- (CBCharacteristic *)see_characteristicUUID:(CBUUID *)cUUID withServiceUUID:(CBUUID *)sUUID {
    __block CBCharacteristic * character;
    [self.connectPeripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sUUID) {
            if ([service.UUID.UUIDString isEqualToString:sUUID.UUIDString]) {
                * stop = YES;
                [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull characteristic, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([characteristic.UUID.UUIDString isEqualToString:cUUID.UUIDString]) {
                        *stop = YES;
                        character = characteristic;
                    }
                }];
            }
        }
        else {
            [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull characteristic, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([characteristic.UUID.UUIDString isEqualToString:cUUID.UUIDString]) {
                    *stop = YES;
                    character = characteristic;
                }
            }];
            *stop = character;
        }
    }];
    return character;
}


#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self dealBluetoothState:central.state];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral == nil) {
        return;
    }
    __block BOOL hadPeripheral = NO;
    [self.scanPeripheralList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            hadPeripheral = [((CBPeripheral *)obj[kScanResultPeripheralKey]) isEqual:peripheral];
            *stop = hadPeripheral;
    }];
    if (!hadPeripheral) {
        [self.scanPeripheralList addObject:@{kScanResultRSSIKey: RSSI,kScanResultPeripheralKey: peripheral,kScanResultAdvertisementDataKey:advertisementData}];
    }
    self.scanResult(self.scanPeripheralList);
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.connectState = kCONNECT_CONNECT;
    peripheral.delegate = self;
    if (self.connectComplete) {
        self.connectComplete(peripheral,nil);
    }
    //发现服务
    [peripheral discoverServices:nil];
}
//连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.connectState = kCONNECT_FAIL;
    self.connectComplete(peripheral,error);
}

//断开连接以及断线重连
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.userDisconnect) {
        self.connectState = kCONNECT_DISCONNECT;
    }
    else {
        self.connectState = kCONNECT_RECONNECT;
        [self connectPeripheral:self.connectPeripheral options:self.peripheralOption complete:self.connectComplete];
    }
}

#pragma mark CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    serveiceCount = peripheral.services.count;
    [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [peripheral discoverCharacteristics:nil forService:obj];
    }];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    characteristicCount = service.characteristics.count;
    [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [peripheral discoverDescriptorsForCharacteristic:obj];
    }];
    @synchronized(self) {
        serveiceCount -= 1;
        if (serveiceCount == 0) {
            self.prepareComplete = YES;
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    @synchronized(self) {
        characteristicCount -= 1;
        if (characteristicCount == 0) {
            self.descriptorsComplete = YES;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString * key = characteristic.UUID.UUIDString;
    completeBlock complete = [self.complete objectForKey:key];
    //订阅/取消失败返回错误
    if (complete) {
        complete(characteristic.UUID, error);
        [self.complete removeObjectForKey:key];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString * key = characteristic.UUID.UUIDString;
    completeBlock complete = [self.complete objectForKey:key];
    if (complete) {
        complete(characteristic.UUID,error);
        [self.complete removeObjectForKey:key];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //接收到数据
    self.onReceive(characteristic,error);
}

#pragma mark setter & getter
- (void)setBluetoothState:(NSString *)bluetoothState {
    [super setBluetoothState:bluetoothState];
    if (bluetoothState == kBLUETOOTH_ON) {
        if (self.delayScan) {
            [self.manager scanForPeripheralsWithServices:self.scanServiceList options:self.scanOption];
            self.delayScan = NO;
        }        
    }
}

@end
