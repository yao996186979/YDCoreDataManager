//
//  ViewController.m
//  core
//
//  Created by 姚东 on 2019/2/13.
//  Copyright © 2019 姚东. All rights reserved.
//

#import "ViewController.h"
#import "YDCoreDataManager.h"
#import "PeopleTableViewCell.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/// 展示数据
@property (strong, nonatomic) NSMutableArray <People*>* dataSource;
/// 搜索框
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/// 搜索条件
@property (nonatomic ,strong) NSMutableDictionary * conditions;
/// 搜索条件key=name
@property (strong ,nonatomic) QueryCondition * nameCondition;
/// 搜索条件key=sex
@property (strong ,nonatomic) QueryCondition * sexConditon;
/// 页码
@property (assign ,nonatomic) NSInteger page;
@end

static NSString *kTableName = @"People";

@implementation ViewController

- (void)viewDidLoad {
    self.dataSource = [NSMutableArray array];
    self.searchBar.delegate = self;
    [super viewDidLoad];
    self.tableView.dataSource =self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"PeopleTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.conditions = [NSMutableDictionary dictionary];
    [self reloadData];
}
#pragma mark - 刷新/重新拉取数据库数据
- (void)reloadData{
    if (self.page == 0) {
        //下拉刷新
        [self.dataSource removeAllObjects];
    }
    NSArray * newData = [YDCoreManagerInstance queryByConditions:self.conditions sorts:@{} pageNumber:self.page pageCount:5 tableName:kTableName];
    if (newData.count < 3) {
        // 已经没有更多数据了
    }
   
    [self.dataSource addObjectsFromArray:newData];
    [self.tableView reloadData];
}
//加载更多
- (IBAction)loadMore:(id)sender {
    self.page++;
    [self reloadData];
}
//下拉舒心
- (IBAction)refresh:(id)sender {
    self.page = 0;
    [self reloadData];
}
#pragma mark - 增加/随机生成属性
- (IBAction)add:(id)sender {
    self.page =0;
    // 1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    People * student = [NSEntityDescription  insertNewObjectForEntityForName:kTableName  inManagedObjectContext:YDCoreManagerInstance.managerContenxt];
    //2.根据表Student中的键值，给NSManagedObject对象赋值
    student.name = [NSString stringWithFormat:@"Mr-%d",arc4random()%1000];
    student.phone = [NSString stringWithFormat:@"132%.6d",(arc4random() % 100000000)];
    student.sex = arc4random()%2 == 0 ?  true : false ;
    student.id = [NSUUID new].UUIDString;
    [YDCoreManagerInstance save:^(BOOL success,NSString * info) {
        if (success) {
            [self reloadData];
        }
        else{
            NSLog(@"%@", info);
        }
    }];
    
}
#pragma mark - UITableViewDelegate
/**
 *  只要实现这个方法,就拥有左滑删除功能
 *  点击左滑出现的Delete按钮 会调用这个
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"commitEditingStyle--");
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

/**
 *  修改默认Delete按钮的文字
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//实现这个方法不仅可以实现左滑功能,还可以自定义左滑的按钮,并且实现按钮点击处理的事件
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    self.tableView.editing = YES;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"更新" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self showAlert:indexPath.row];
    }];
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [YDCoreManagerInstance deleteById:self.dataSource[indexPath.row].id tableName:kTableName succes:^(BOOL success,NSString * info) {
            if (success) {
               [self reloadData];
            }else{
                NSLog(@"%@", info);
            }
        }];
    }];
    return @[action1,action];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    People * p = self.dataSource[indexPath.row];
    PeopleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.name.text = p.name;
    cell.phone.text = p.phone;
    cell.sex.text = p.sex?@"男":@"女";
    cell.udid.text = p.id;
    return cell;
}
#pragma mark - 更改确认弹窗
- (void)showAlert:(NSInteger)row{
    People * p = self.dataSource[row];
    UITextField * phoneText;
    __block typeof(UITextField *)weakPhoneText = phoneText;
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"更改%@的信息",p.name] message:@"确认更改吗？" preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入要更改的电话";
        weakPhoneText = textField;
    }];
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];

    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /// 更新
        [YDCoreManagerInstance updateDataById:p.id keyValues:@{@"phone":weakPhoneText.text} tableName:kTableName succes:^(BOOL success, NSString * _Nonnull info) {
            if (success) {
                [self reloadData];
            }
            else{
                NSLog(@"%@", info);
            }
        }];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
    
}
# pragma mark - sex切换事件
- (IBAction)sexSearch:(UISegmentedControl*)sender {
    self.page =0;
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.sexConditon.value = nil;
            break;
        case 1:
            self.sexConditon.value = @(true);
            break;
        case 2:
            self.sexConditon.value = @(false);
            break;
        default:
            break;
    }
    //更新 条件字典
    [self.conditions setValue:self.sexConditon forKey:@"sex"];
    //刷新
    [self reloadData];
    
}
#pragma mark - searchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar endEditing:YES];
    self.page =0;
    if (searchBar.text.length != 0) {
        self.nameCondition.value = self.searchBar.text;
    }
    else{
        self.nameCondition.value = nil;
    }
    //更新 条件字典
    [self.conditions setValue:self.nameCondition forKey:@"name"];
     //刷新
    [self reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    self.nameCondition.value = nil;
    [self.conditions setValue:self.nameCondition forKey:@"name"];
    [self reloadData];
}

#pragma mark - Getter
- (QueryCondition *)nameCondition {
    if (!_nameCondition) {
        _nameCondition = [[QueryCondition alloc]init];
        _nameCondition.value = nil;
        _nameCondition.query = QUERYLIKE;
        _nameCondition.isOr = NO;
    }
    return _nameCondition;
}
-(QueryCondition *)sexConditon {
    if (!_sexConditon) {
        _sexConditon = [[QueryCondition alloc]init];
        _sexConditon.value = nil;
        _sexConditon.query = QUERYEQUAL;
        _sexConditon.isOr = NO;
    }
    return _sexConditon;
}
@end
