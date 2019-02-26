//
//  People+CoreDataProperties.h
//  core
//
//  Created by 姚东 on 2019/2/19.
//  Copyright © 2019 姚东. All rights reserved.
//
//

#import "People+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface People (CoreDataProperties)

+ (NSFetchRequest<People *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nonatomic) BOOL sex;

@end

NS_ASSUME_NONNULL_END
