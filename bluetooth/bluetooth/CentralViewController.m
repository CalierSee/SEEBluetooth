//
//  CentralViewController.m
//  bluetooth
//
//  Created by 三只鸟 on 2018/2/28.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "CentralViewController.h"
#import "SEECentralManager.h"
#import "CharacteristicCell.h"
#import "UUIDS.h"
@interface CentralViewController ()

@property (nonatomic, strong) NSMutableArray * lists;

@end

@implementation CentralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[CharacteristicCell class] forCellReuseIdentifier:@"characteristic"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [[SEECentralManager shareManager] scanForPeripheralsUUIDList:@[[CBUUID UUIDWithString:Service1],[CBUUID UUIDWithString:Service2]] option:nil result:^(NSArray<NSDictionary *> * _Nullable peripheralList) {
        [peripheralList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString * advName = obj[kScanResultAdvertisementDataKey][CBAdvertisementDataLocalNameKey];
            if ([advName isEqualToString:@"test"]) {
                CBPeripheral * peripheral = obj[kScanResultPeripheralKey];
                [[SEECentralManager shareManager]connectPeripheral:peripheral options:nil complete:^(CBPeripheral * _Nonnull peripheral, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"外设连接失败");
                    }
                    else {
                        NSLog(@"外设连接成功");
                    }
                }];
                *stop = YES;
            }
        }];
    }];
    [[SEECentralManager shareManager]addObserver:self forKeyPath:@"prepareComplete" options:NSKeyValueObservingOptionNew context:nil];
    [[SEECentralManager shareManager]addObserver:self forKeyPath:@"descriptorsComplete" options:NSKeyValueObservingOptionNew context:nil];
    [[SEECentralManager shareManager]setOnReceive:^(CBCharacteristic * _Nonnull characteristic, NSError * _Nonnull error) {
        if (error == nil) {
            NSLog(@"%@",[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    [[SEECentralManager shareManager]disconnect
     ];
    [[SEECentralManager shareManager]removeObserver:self forKeyPath:@"prepareComplete"];
    [[SEECentralManager shareManager]removeObserver:self forKeyPath:@"descriptorsComplete"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"descriptorsComplete"]) {
        if ([SEECentralManager shareManager].descriptorsComplete) {
            [self see_loadData];
            [self.tableView reloadData];
        }
    }
}


#pragma mark private method
- (void)see_loadData {
    self.lists = [NSMutableArray arrayWithArray:[SEECentralManager shareManager].connectPeripheral.services];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.lists[indexPath.row];
    if ([model isKindOfClass:[CBService class]]) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = ((CBService *)model).UUID.UUIDString;
        return cell;
    }
    else {
        CharacteristicCell * cell = [tableView dequeueReusableCellWithIdentifier:@"characteristic" forIndexPath:indexPath];
        CBCharacteristic * characteristic = (CBCharacteristic *)model;
        [cell configureWithUUID:characteristic.UUID.UUIDString descriptor:characteristic.descriptors.firstObject.value];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.lists[indexPath.row];
    id nextModel = indexPath.row + 1 == self.lists.count ? nil : [self.lists objectAtIndex:indexPath.row + 1];
    if ([model isKindOfClass:[CBService class]]) {
        if (nextModel) {
            if ([nextModel isKindOfClass:[CBService class]]) {
                [self.lists insertObjects:((CBService *)model).characteristics atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + 1, ((CBService *)model).characteristics.count)]];
                [tableView reloadData];
            }
            else {
                [self.lists removeObjectsInArray:((CBService *)model).characteristics];
                [tableView reloadData];
            }
        }
        else {
            [self.lists insertObjects:((CBService *)model).characteristics atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + 1, ((CBService *)model).characteristics.count)]];
            [tableView reloadData];
        }
    }
    else {
        CBCharacteristic * characteristic = (CBCharacteristic *)model;
        
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            [[SEECentralManager shareManager]subscribeCharacteristicUUID:characteristic.UUID withServiceUUID:nil complete:^(CBUUID * _Nullable uuid, NSError * _Nonnull error) {
                if (error) {
                    NSLog(@"订阅失败");
                }
                else {
                    NSLog(@"订阅成功");
                }
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[SEECentralManager shareManager]unsubscribeCharacteristicUUID:characteristic.UUID withServiceUUID:nil complete:^(CBUUID * _Nullable uuid, NSError * _Nonnull error) {
                    if (error) {
                        NSLog(@"取消失败");
                    }
                    else {
                        NSLog(@"取消成功");
                    }
                }];
            });
        }
        else if (characteristic.properties & CBCharacteristicPropertyRead) {
            [[SEECentralManager shareManager]readCharacteristicUUID:characteristic.UUID withServiceUUID:nil];
        }
        else if (characteristic.properties & CBCharacteristicPropertyWrite) {
            [[SEECentralManager shareManager]writeCharacteristicUUID:characteristic.UUID withServiceUUID:nil value:[@"jfksdal" dataUsingEncoding:NSUTF8StringEncoding] complete:^(CBUUID * _Nullable uuid, NSError * _Nonnull error) {
                if (error) {
                    NSLog(@"写入失败");
                }
                else {
                    NSLog(@"写入成功");
                }
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

@end
