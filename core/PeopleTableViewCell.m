//
//  PeopleTableViewCell.m
//  core
//
//  Created by 姚东 on 2019/2/18.
//  Copyright © 2019 姚东. All rights reserved.
//

#import "PeopleTableViewCell.h"

@implementation PeopleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
