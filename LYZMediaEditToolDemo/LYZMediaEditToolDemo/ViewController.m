//
//  ViewController.m
//  LYZMediaEditToolDemo
//
//  Created by artios on 2017/9/25.
//  Copyright © 2017年 artios. All rights reserved.
//

#import "ViewController.h"
#import "LYZEditAudioViewController.h"
#import "LYZEditVideoViewController.h"
#import "LYZCutVideoViewController.h"
#import "LYZCutAudioViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray     *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self lyz_config];
}

- (void)lyz_config {
    
    self.dataArray = @[@"合并音频与音频",@"合并音频与视频",@"剪辑音频",@"剪辑视频",];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            LYZEditAudioViewController *editAudioVC = [[LYZEditAudioViewController alloc] init];
            [self.navigationController pushViewController:editAudioVC animated:YES];
        }
            break;
        case 1:
        {
            LYZEditVideoViewController *editVideoVC = [[LYZEditVideoViewController alloc] init];
            [self.navigationController pushViewController:editVideoVC animated:YES];
        }
            break;
        case 2:
        {
            LYZCutAudioViewController *cutAudioVC = [[LYZCutAudioViewController alloc] init];
            [self.navigationController pushViewController:cutAudioVC animated:YES];
        }
            break;
        case 3:
        {
            LYZCutVideoViewController *cutVideoVC = [[LYZCutVideoViewController alloc] init];
            [self.navigationController pushViewController:cutVideoVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
