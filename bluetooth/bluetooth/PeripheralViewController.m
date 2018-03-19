//
//  PeripheralViewController.m
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/28.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "PeripheralViewController.h"
#import "SEEPeripheralManager.h"
#import "UUIDS.h"
@interface PeripheralViewController ()

@property (nonatomic, assign) BOOL stopNotify;


@end

@implementation PeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray * characters = @[[SEEPeripheralManager characterWithUUID:[CBUUID UUIDWithString:NotifyUUID1] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable descriptor:@"这是一个测试通知"],[SEEPeripheralManager characterWithUUID:[CBUUID UUIDWithString:WriteUUID1] properties:CBCharacteristicPropertyWrite value:nil  permissions:CBAttributePermissionsWriteable descriptor:@"这是一个测试写特征"],[SEEPeripheralManager characterWithUUID:[CBUUID UUIDWithString:ReadUUID1] properties:CBCharacteristicPropertyRead value:[@"readCharacteristic" dataUsingEncoding:NSUTF8StringEncoding] permissions:CBAttributePermissionsReadable descriptor:@"这是一个测试读特征"]];
    [[SEEPeripheralManager shareManager] addServiceWithUUID:[CBUUID UUIDWithString:Service1] characters:characters complete:^(CBUUID * _Nullable uuid, NSError * _Nullable error) {
        if (error) {
            NSLog(@"服务%@失败",uuid.UUIDString);
        }
        else {
            NSLog(@"服务%@成功",uuid.UUIDString);
        }
    }];
    [[SEEPeripheralManager shareManager] startAdvertisingWithLocalName:@"test" complete:^(CBPeripheralManager * _Nonnull manager, NSError * _Nullable error) {
        if (error) {
            NSLog(@"广播失败");
        }
        else {
            NSLog(@"广播成功");
        }
    }];
    __weak typeof(self) weakSelf = self;
    [[SEEPeripheralManager shareManager] setSubscribe:^(BOOL enabled, CBMutableCharacteristic * _Nonnull characteristic, CBCentral * _Nonnull central, CBPeripheralManager * _Nonnull peripheral) {
        if (enabled) {
            [weakSelf sendNotifyWithPeripheral:peripheral central:central characteristic:characteristic
             ];
        }
        else {
            weakSelf.stopNotify = YES;
        }
    }];
    
    [[SEEPeripheralManager shareManager]setWrite:^(CBPeripheralManager * _Nonnull peripheral, CBATTRequest * _Nonnull request) {
        NSLog(@"%@",[[NSString alloc]initWithData:request.characteristic.value encoding:NSUTF8StringEncoding]);
    }];
    
    // Do any additional setup after loading the view.
}

- (void)sendNotifyWithPeripheral:(CBPeripheralManager *)peripheral central:(CBCentral *)central characteristic:(CBMutableCharacteristic *)characteristic {
    if (self.stopNotify) {
        self.stopNotify = NO;
        return;
    }
    
    [peripheral updateValue:[@"123" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic onSubscribedCentrals:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendNotifyWithPeripheral:peripheral central:central characteristic:characteristic];
    });
}


- (void)dealloc {
    [[SEEPeripheralManager shareManager]stopAdvertising];
    [[SEEPeripheralManager shareManager]stopAdvertising];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
