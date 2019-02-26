//
//  YDCoreDataManager.h
//  core
//
//  Created by 姚东 on 2019/2/13.
//  Copyright © 2019 姚东. All rights reserved.
//
/*
 CoreData调试:
 打开Product，选择Edit Scheme.
 选择Arguments，在下面的ArgumentsPassed On Launch中添加下面两个选项，如图：
 (1)-com.apple.CoreData.SQLDebug
 (2)1
 */
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "People+CoreDataClass.h"
#define YDCoreManagerInstance [YDCoreDataManager shareInstance]
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QUERY) {
    /// 小于 <
    QUERYLESS,
    /// 小于等于 <=
    QUERYLESSEQUAL,
    /// 等于 =
    QUERYEQUAL,
    /// 大于 >
    QUERYGREATER,
    /// 大于等于 >=
    QUERYGREATEREQUAL,
    /// 类似于  like
    QUERYLIKE,
    /// 不等于  !=
    QUERYNOTEQUAL
};

@interface QueryCondition : NSObject

/// 值
@property (copy, nonatomic,nullable)   id value;
/// 查询条件
@property (assign, nonatomic) QUERY query;
/// 条件||或 && 默认为no（必要条件and）
@property (assign, nonatomic) BOOL isOr;

@end

@interface YDCoreDataManager : NSObject
///管理对象上下文
@property(strong,nonatomic)NSManagedObjectContext *managerContenxt;

///单例
+(YDCoreDataManager*)shareInstance;

/**
  增加
  使用 [NSEntityDescription  insertNewObjectForEntityForName:@"People" inManagedObjectContext:YDCoreManagerInstance.managerContenxt]; 获取对应实体
 @param success 成功回调
 */
- (void)save:(void(^)(BOOL success,NSString * info))success;

/**
 删除

 @param Id 删除数据id
 @param tableName 表名称
 @param success 成功回调
 */
- (void)deleteById:(NSString*)Id tableName:(NSString*)tableName succes:(void(^)(BOOL success,NSString * info))success;

/**
 更新
 
 @param Id 数据id
 @param keyValues 更新的键和值 例:{@"name":@"1",@"phone":@"13258273839"} 将name更新为1,phone更新为13258273839
 @param tableName 表名称
 @param success 成功回调
 */
- (void)updateDataById:(NSString*)Id keyValues:(NSDictionary*)keyValues tableName:(nonnull NSString *)tableName succes:(void(^)(BOOL success,NSString * info))success;

/**
 查询

 @param conditions 条件 {@"key1":QueryCondition,@"key2":QueryCondition}   例:{@"name":{@"query":@QUERYLIKE,@"value":@"22",@"isOr":@NO}}
 @param sorts  排序 {@"key1":@YES,@"key2":@NO}  例：{@"name":@(yes)} name升序排列
 @param pageNumber 第几页
 @param pageCount  每页数量
 @param tableName 表名称
 @return 对象结果数组
 */
- (NSArray<NSObject *>*)queryByConditions:(NSDictionary*)conditions sorts:(NSDictionary *)sorts pageNumber:(NSInteger)pageNumber pageCount:(NSInteger )pageCount tableName:(NSString*)tableName;

/**
 批量删除

 @param ids 删除id数据
 @param tableName 表名称
 @param success 成功回调
 */
- (void)deleteByIds:(NSArray<NSString*> *)ids tableName:(NSString*)tableName  succes:(void(^)(BOOL success,NSString * info))success;

/**
 批量更新
 注意：适用于统一更新，如p1,p2,p3的name都更改为@"12"
 @param ids 更新id数据
 @param keyValues 更新的键和值 例:{@"name":@"1",@"phone":@"13258273839"} 将name更新为1,phone更新为13258273839
 @param tableName 表名称
 @param success 成功回调
 */
- (void)updateDataByIds:(NSArray<NSString *> *)ids keyValues:(NSDictionary*)keyValues tableName:(nonnull NSString *)tableName succes:(void(^)(BOOL success,NSString * info))success;
@end

NS_ASSUME_NONNULL_END
