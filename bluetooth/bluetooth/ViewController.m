//
//  ViewController.m
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/27.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "ViewController.h"
#import "SEECentralManager.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *central;
@property (weak, nonatomic) IBOutlet UIButton *peripheral;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.manager = [SEEBluetoothManager sharePeripheral];
//
//        [self.manager serverWithUUID:@"FFF0" localNameKey:@"test" characters:@[
//                                                                               character(@"4561", CBCharacteristicPropertyNotify, CBAttributePermissionsReadable, @[@"这是一个测试通知特征"]),
//                                                                               character(@"4562", CBCharacteristicPropertyWrite, CBAttributePermissionsWriteable, @[@"这是一个测试写特征"])]];
//        [self.manager startAdvertising:^(NSArray<CBMutableService *> * _Nonnull errorServices, void (^ _Nonnull completeHanlder)(void)) {
//            if (errorServices.count == 0) {
//                completeHanlder();
//            }
//        }];
//
//    [self.manager setSubscribe:^(CBPeripheralManager * _Nonnull peripheral, CBCentral * _Nonnull central, CBCharacteristic * _Nonnull characteristic) {
//        [self send:peripheral centeral:central characteristic:characteristic];
//    }];
    
//    self.centralManager = [SEECentralManager shareManager];
//    [self.centralManager scanForPeripheralsUUIDList:@[[CBUUID UUIDWithString:@"FFF0"]] option:nil result:^(NSArray<NSDictionary *> *peripheralList) {
//        [self.centralManager connectPeripheral:peripheralList.firstObject[kScanResultPeripheralKey] options:nil failure:nil];
//        [self.centralManager stopScan];
//    }];
//    [self.centralManager addObserver:self forKeyPath:@"prepareComplete" options:NSKeyValueObservingOptionNew context:nil];
//
//    [self.centralManager setOnReceive:^(CBCharacteristic * _Nonnull characteristic, NSError * _Nonnull error) {
//        if (error == nil) {
//            if ([characteristic.UUID.UUIDString isEqualToString:@"4561"]) {
//                NSString * string = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//                NSLog(@"%@",string);
//            }
//        }
//    }];
    // Do any additional setup after loading the view, typically from a nib.
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    NSLog(@"%@",self.centralManager.connectState);
//    [self.centralManager subscribeCharacteristicUUID:[CBUUID UUIDWithString:@"4561"] withServiceUUID:[CBUUID UUIDWithString:@"FFF0"] failure:nil];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.centralManager unsubscribeCharacteristicUUID:[CBUUID UUIDWithString:@"4561"] withServiceUUID:[CBUUID UUIDWithString:@"FFF0"] failure:nil];
//    });
//}
//
//- (void)send:(CBPeripheralManager *)peripheral centeral:(CBCentral *)centeral characteristic:(CBCharacteristic *)character {
//    [peripheral updateValue:[@"123" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:character onSubscribedCentrals:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self send:peripheral centeral:centeral characteristic:character];
//    });
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
