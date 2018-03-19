//
//  ServiceCell.h
//  bluetooth
//
//  Created by 三只鸟 on 2018/3/1.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharacteristicCell : UITableViewCell

- (void)configureWithUUID:(NSString *)uuid descriptor:(NSString *)descriptor;

@end
