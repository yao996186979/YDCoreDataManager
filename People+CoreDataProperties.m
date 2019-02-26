//
//  People+CoreDataProperties.m
//  core
//
//  Created by 姚东 on 2019/2/19.
//  Copyright © 2019 姚东. All rights reserved.
//
//

#import "People+CoreDataProperties.h"

@implementation People (CoreDataProperties)

+ (NSFetchRequest<People *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"People"];
}

@dynamic id;
@dynamic name;
@dynamic phone;
@dynamic sex;

@end
