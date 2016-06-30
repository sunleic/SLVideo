//
//  ViewController.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/20.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "ViewController.h"
#import "SLVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import "SLVideoViewController.h"
#import "SLAlertVideo.h"
#import "VideoTableViewCell.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, SLAlertVideoDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) VideoTableViewCell *selecteCell; //当前被选中cell

@property (nonatomic, strong) SLAlertVideo *alertVideo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"模仿开眼demo";
    
    [self createTableView];
}

-(void)createTableView{

    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.rowHeight = 235;
        
        [self.view addSubview:_tableView];
    }else{
        [_tableView reloadData];
    }
}

#pragma mark = tableview相关
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[VideoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.picsImgView.image = [UIImage imageNamed:@"sunlei.jpg"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
    _selecteCell = [tableView cellForRowAtIndexPath:indexPath];
    
    CGRect sourceRect = [_selecteCell convertRect:_selecteCell.picsImgView.frame toView:self.view];
    
    _alertVideo = [[SLAlertVideo alloc]initWithFrame:sourceRect];
    _alertVideo.delegate = self;
    [_alertVideo showOnView:self.view];
    _alertVideo.videoImage.image = _selecteCell.picsImgView.image;
    
    
    [UIView animateWithDuration:0.3f animations:^{
        
        _alertVideo.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        
    } completion:nil];
}


#pragma mark = SLAlertVideoDelegate

-(void)hideAlertVideo{
    
    CGRect sourceRect = [_selecteCell convertRect:_selecteCell.picsImgView.frame toView:self.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _alertVideo.frame = sourceRect;
        
    } completion:^(BOOL finished) {
        
        [_alertVideo removeFromSuperview];
    }];
}

-(void)playVideo{

    
    //    SLVideoView *video = [[SLVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width) url:@"http://7xrpiy.com1.z0.glb.clouddn.com/video%2F1.mp4"];
    //    video.center = self.view.center;
    //
    //    [UIView animateWithDuration:0.3f animations:^{
    //        video.transform = CGAffineTransformMakeRotation(M_PI/2);
    //
    //    }];
    //    [self.view addSubview:video];
    
    SLVideoViewController *sl = [[SLVideoViewController alloc]init];
    
    sl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:sl animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
