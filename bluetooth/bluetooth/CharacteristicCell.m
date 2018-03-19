//
//  ServiceCell.m
//  bluetooth
//
//  Created by 三只鸟 on 2018/3/1.
//  Copyright © 2018年 景彦铭. All rights reserved.
//

#import "CharacteristicCell.h"

@interface CharacteristicCell()

@property (nonatomic, weak) UILabel * uuidLabel;

@property (nonatomic, weak) UILabel * descriptorLabel;

@end

@implementation CharacteristicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self see_loadUI];
    }
    return self;
}

- (void)see_loadUI {
    UILabel * uuidLabel = [[UILabel alloc]init];
    uuidLabel.textColor = [UIColor blackColor];
    uuidLabel.font = [UIFont systemFontOfSize:14 weight:0.5];
    uuidLabel.textAlignment = NSTextAlignmentLeft;
    UILabel * descriptorLabel = [[UILabel alloc]init];
    descriptorLabel.textColor = [UIColor grayColor];
    descriptorLabel.font = [UIFont systemFontOfSize:12];
    descriptorLabel.textAlignment = NSTextAlignmentLeft;
    self.uuidLabel = uuidLabel;
    self.descriptorLabel = descriptorLabel;
    [self.contentView addSubview:uuidLabel];
//    [self.contentView addSubview:descriptorLabel];
}

- (void)configureWithUUID:(NSString *)uuid descriptor:(NSString *)descriptor {
    self.uuidLabel.text = uuid;
    self.descriptorLabel.text = descriptor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize uuids = [self.uuidLabel sizeThatFits:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX)];
    self.uuidLabel.frame = CGRectMake(20, 10, uuids.width, uuids.height);
    CGSize descriptors = [self.descriptorLabel sizeThatFits:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX)];
    self.descriptorLabel.frame = CGRectMake(20, self.uuidLabel.frame.size.height + 8 + self.uuidLabel.frame.origin.y, descriptors.width, descriptors.height);
}

@end
