//
//  YDCoreDataManager.m
//  core
//
//  Created by 姚东 on 2019/2/13.
//  Copyright © 2019 姚东. All rights reserved.
//

#import "YDCoreDataManager.h"

@interface YDCoreDataManager()
///模型对象
@property(strong,nonatomic)NSManagedObjectModel *managerModel;

///存储调度器
@property(strong,nonatomic)NSPersistentStoreCoordinator *managerDinator;

@end

@implementation YDCoreDataManager
///单例的实现
+(YDCoreDataManager*)shareInstance
{
    static YDCoreDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDCoreDataManager alloc]init];
    });
    return instance;
}
#pragma mark - 增/删/改/查
// 增加
- (void)save:(void (^)(BOOL, NSString * _Nonnull))success
{
    // 保存插入的数据
    NSError *error = nil;
    BOOL isSuccess = [self.managerContenxt save:&error];
    if (isSuccess) {
        success(isSuccess,@"增加成功");
    }else{
        success(isSuccess,[NSString stringWithFormat:@"增加失败-%@",error.localizedDescription]);
    }
    
}
// 删除
- (void)deleteById:(NSString *)Id tableName:(NSString *)tableName succes:(nonnull void (^)(BOOL, NSString * _Nonnull))success{
    [self deleteByIds:@[Id] tableName:tableName  succes:^(BOOL allSuccess, NSString * _Nonnull info) {
        success(allSuccess,info);
    }];
}
// 更新
- (void)updateDataById:(NSString *)Id keyValues:(NSDictionary *)keyValues tableName:(NSString *)tableName  succes:(nonnull void (^)(BOOL, NSString * _Nonnull))success{
    
    [self updateDataByIds:@[Id] keyValues:keyValues tableName:tableName succes:^(BOOL allSuccess, NSString * _Nonnull info) {
        success(allSuccess,info);
    }];
    
}
// 查询
- (NSArray<NSObject *>*)queryByConditions:(NSDictionary *)conditions sorts:(nonnull NSDictionary *)sorts pageNumber:(NSInteger)pageNumber pageCount:(NSInteger)pageCount tableName:(nonnull NSString *)tableName{
    // 1.创建一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:tableName];
    // 从第几页开始显示 通过这个属性实现分页
    request.fetchOffset = pageNumber;
    // 每页显示多少条数据
    request.fetchLimit = pageCount;
    if (conditions.count != 0) {
    //2.创建查询谓词（查询条件）
        NSMutableString * preStr = [NSMutableString string];
        for (int index = 0; index < conditions.allKeys.count; index ++) {
            NSString * key = conditions.allKeys[index];
            QueryCondition * condition = conditions[key];
            NSString * operate = [self conditionOperator:condition.query];
            //@"%@ %@ '%@'" key 运算符 值
            if (condition.value == nil) {
                continue;
            }
            if (condition.query == QUERYLIKE) {
              [preStr appendString:[NSString stringWithFormat:@"%@ %@ '*%@*'",key,operate,condition.value]];
            }
            else{
              [preStr appendString:[NSString stringWithFormat:@"%@ %@ '%@'",key,operate,condition.value]];
            }
           
            //如果不是最后一个条件,补充范围关系
            if (index != conditions.count-1) {
                [preStr appendString:condition.isOr?@" or ":@" and "];
            }
        }
        //存在再查
        if (preStr.length !=0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:preStr];
            //3.给查询请求设置谓词
            request.predicate = predicate;
        }
    }
    //3.创建排序
    NSMutableArray * sortDescriptors = [NSMutableArray array];
    if (sorts.count != 0) {
        for (NSString * key in sorts.allKeys) {
            NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:[[sorts valueForKey:key]boolValue]];
            [sortDescriptors addObject:sort];
        }
    }
    request.sortDescriptors = sortDescriptors.copy;
    //4.查询数据
    NSArray<NSObject*> *arr = [self.managerContenxt executeFetchRequest:request error:nil];
    return arr;
}
// 批量删除
- (void)deleteByIds:(NSArray<NSString *> *)ids tableName:(NSString *)tableName succes:(nonnull void (^)(BOOL, NSString * _Nonnull))success{
    
    //创建删除请求
    NSFetchRequest *deleRequest = [NSFetchRequest fetchRequestWithEntityName:tableName];
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"self.id in %@", ids];
    
    deleRequest.predicate = pre;
    //返回需要删除的对象数组
    NSArray *deleArray = [self.managerContenxt executeFetchRequest:deleRequest error:nil];
    if (deleArray.count == 0) {
        success(NO,@"信息错误-未找到对应id数据");
    }
    
    //从数据库中删除
    for (NSManagedObject * obj in deleArray) {
        [self.managerContenxt deleteObject:obj];
    }
    NSError *error = nil;
    BOOL isSuccess = [self.managerContenxt save:&error];
    //保存--记住保存
    if (isSuccess) {
        success(isSuccess,@"删除成功");
    }else{
        success(isSuccess,[NSString stringWithFormat:@"删除失败-%@",error.localizedDescription]);
    }
}
// 批量更新
- (void)updateDataByIds:(NSArray<NSString *> *)ids keyValues:(NSDictionary *)keyValues tableName:(NSString *)tableName succes:(void (^)(BOOL, NSString * _Nonnull))success{
    //创建查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:tableName];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"self.id in %@", ids];
    request.predicate = pre;
    
    //发送请求
    NSArray *resArray = [self.managerContenxt executeFetchRequest:request error:nil];
    if (resArray.count == 0) {
        success(NO,@"信息错误-未找到对应id数据");
        return;
    }
    //修改
    for (NSString * key in keyValues.allKeys) {
        for (NSObject * updateObj in resArray) {
            NSString * value = [keyValues valueForKey:key];
            [updateObj setValue:value forKey:key];
        }
    }
    //保存
    NSError *error = nil;
    BOOL isSuccess = [self.managerContenxt save:&error];
    if (isSuccess) {
        success(isSuccess,@"修改成功");
    }else{
        success(isSuccess,[NSString stringWithFormat:@"修改失败-%@",error.localizedDescription]);
    }
}
/*排序
    //创建排序请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    //实例化排序对象
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age"ascending:YES];
    NSSortDescriptor *numberSort = [NSSortDescriptor sortDescriptorWithKey:@"number"ascending:YES];
    request.sortDescriptors = @[ageSort,numberSort];
    //发送请求
    NSError *error = nil;
    //    NSArray *resArray = [self.managerContenxt executeFetchRequest:request error:&error];
    if (error == nil) {
        NSLog(@"排序成功");
    }else{
        NSLog(@"排序失败, %@", error);
    }
}
     谓词的条件指令
     1.比较运算符 > 、< 、== 、>= 、<= 、!=
     例：@"number >= 99"
     
     2.范围运算符：IN 、BETWEEN
     例：@"number BETWEEN {1,5}"
     @"address IN {'shanghai','nanjing'}"
     
     3.字符串本身:SELF
     例：@"SELF == 'APPLE'"
     
     4.字符串相关：BEGINSWITH、ENDSWITH、CONTAINS
     例：  @"name CONTAIN[cd] 'ang'"  //包含某个字符串
     @"name BEGINSWITH[c] 'sh'"    //以某个字符串开头
     @"name ENDSWITH[d] 'ang'"    //以某个字符串结束
     
     5.通配符：LIKE
     例：@"name LIKE[cd] '*er*'"   //代表通配符,Like也接受[cd].
     @"name LIKE[cd] '???er*'"
     
     *注*: 星号 "*" : 代表0个或多个字符
     问号 "?" : 代表一个字符
     
     6.正则表达式：MATCHES
     例：NSString *regex = @"^A.+e$"; //以A开头，e结尾
     @"name MATCHES %@",regex
     
     注:[c]*不区分大小写 , [d]不区分发音符号即没有重音符号, [cd]既不区分大小写，也不区分发音符号。
     
     7. 合计操作
     ANY，SOME：指定下列表达式中的任意元素。比如，ANY children.age < 18。
     ALL：指定下列表达式中的所有元素。比如，ALL children.age < 18。
     NONE：指定下列表达式中没有的元素。比如，NONE children.age < 18。它在逻辑上等于NOT (ANY ...)。
     IN：等于SQL的IN操作，左边的表达必须出现在右边指定的集合中。比如，name IN { 'Ben', 'Melissa', 'Nick' }。
     
     提示:
     1. 谓词中的匹配指令关键字通常使用大写字母
     2. 谓词中可以使用格式字符串
     3. 如果通过对象的key
     path指定匹配条件，需要使用%K
     
     */
- (NSString *)conditionOperator:(QUERY)query{
    NSString * operator = @"==";
    switch (query) {
        case QUERYLESS:
            operator = @"<";
            break;
        case QUERYLESSEQUAL:
            operator = @"<=";
            break;
        case QUERYEQUAL:
            operator = @"==";
            break;
        case QUERYGREATER:
            operator = @">";
            break;
        case QUERYGREATEREQUAL:
            operator = @">=";
            break;
        case QUERYLIKE:
            operator = @"like";
            break;
        case QUERYNOTEQUAL:
            operator = @"!=";
            break;
        default:
            break;
    }
    return operator;
}
#pragma mark - Getter
// 管理数据（管理对象，上下文，持久性存储模型对象，处理数据与应用的交互）
-(NSManagedObjectContext *)managerContenxt
{
    if (!_managerContenxt)  {
        _managerContenxt = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
        ///设置存储调度器
        [_managerContenxt setPersistentStoreCoordinator:self.managerDinator];
    }
    return _managerContenxt;
}
// 数据模型（被管理的数据模型，数据结构）
-(NSManagedObjectModel *)managerModel
{
    if (!_managerModel) {
        _managerModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managerModel;
}
// 数据库 (添加数据库，设置数据存储的名字，位置，存储方式)
/**
* type:一般使用数据库存储方式NSSQLiteStoreType 默认
* configuration:配置信息 一般无需配置
* URL:要保存的文件路径
* options:参数信息 一般无需设置
*/
-(NSPersistentStoreCoordinator *)managerDinator
{
    if (!_managerDinator) {
        _managerDinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.managerModel];
       
        //文件存储路径
        NSURL * localUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        //文件路径
        NSURL *url = [localUrl URLByAppendingPathComponent:@"sqlit.db" isDirectory:YES];
        //添加存储器
        [_managerDinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:nil];
    }
    return _managerDinator;
}
@end
#pragma mark - 查询条件
@implementation QueryCondition

- (instancetype)init {
    self = [super init];
    if (self) {
        ///初始化时 默认返回值
        self.value = nil;
        self.isOr = NO;
        self.query = QUERYEQUAL;
    }
    return self;
}
@end
