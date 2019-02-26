//
//  PeopleTableViewCell.h
//  core
//
//  Created by 姚东 on 2019/2/18.
//  Copyright © 2019 姚东. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PeopleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *sex;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *udid;

@end

NS_ASSUME_NONNULL_END
