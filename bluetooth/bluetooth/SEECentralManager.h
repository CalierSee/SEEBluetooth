//
//  SEECenteralManager.h
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/27.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "SEEBluetooth.h"

NS_ASSUME_NONNULL_BEGIN

//外设连接状态
static NSString * const kCONNECT_UNKNOW =       @"未知";
static NSString * const kCONNECT_RECONNECT =    @"断线重连";
static NSString * const kCONNECT_DISCONNECT =   @"连接断开";
static NSString * const kCONNECT_FAIL =         @"连接失败";
static NSString * const kCONNECT_CONNECT =      @"连接";


//从机key
static NSString * const kScanResultPeripheralKey = @"kScanResultPeripheralKey";
//从机广播datakey
static NSString * const kScanResultAdvertisementDataKey = @"kScanResultAdvertisementDataKey";
//从机RRSIkey
static NSString * const kScanResultRSSIKey = @"kScanResultRSSIKey";

@interface SEECentralManager : SEEBluetooth

+ (instancetype)shareManager;

//当前连接的外设
@property (nonatomic, strong) CBPeripheral * connectPeripheral;

//设备连接状态
@property (nonatomic, copy) NSString * connectState;
//是否完成连接工作并且已经发现所有的服务与特征 完成后才可以对外围设备进行操作
@property (nonatomic, assign) BOOL prepareComplete;
//已经发现所有特征的描述 此时 prepareComplete 为YES
@property (nonatomic, assign) BOOL  descriptorsComplete;


//接收到数据回调
@property (nonatomic, copy)  void(^ _Nullable onReceive)(CBCharacteristic * characteristic,NSError * error);


//扫描设备
- (void)scanForPeripheralsUUIDList:(nullable NSArray <CBUUID *> *)serviceList option:(nullable NSDictionary *)option result:(void(^)(NSArray <NSDictionary *> * _Nullable peripheralList))result;
- (void)stopScan;

//连接设备
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary *)options complete:(nullable void(^)(CBPeripheral * peripheral,NSError * _Nullable error))complete;
- (void)disconnect;

//订阅/取消订阅特征
- (void)subscribeCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(nullable CBUUID *)sUUID complete:(nullable completeBlock)complete;
- (void)unsubscribeCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(nullable CBUUID *)sUUID complete:(nullable completeBlock)complete;

- (void)readCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(nullable CBUUID *)sUUID;

- (void)writeCharacteristicUUID:(CBUUID *)cUUID withServiceUUID:(nullable CBUUID *)sUUID value:(NSData *)value complete:(completeBlock)complete;

@end

NS_ASSUME_NONNULL_END
