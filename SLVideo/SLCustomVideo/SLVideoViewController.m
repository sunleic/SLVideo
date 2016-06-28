//
//  SLVideoViewController.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/27.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "SLVideoViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import "SLVideoView.h"

@interface SLVideoViewController ()<SLVideoViewDelegate>

@end

@implementation SLVideoViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //开启外放音效
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //关闭外放音效
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];

    
    SLVideoView *video = [[SLVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width) url:@"http://7xrpiy.com1.z0.glb.clouddn.com/video%2F1.mp4"];

    video.delegate = self;
    [self.view addSubview:video];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//重写该方法可以隐藏或显示状态栏
//-(BOOL)prefersStatusBarHidden{
//
//    return NO;
//}

//动画效果
//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
//
//    return UIStatusBarAnimationFade;
//}

//- (BOOL)shouldAutorotate{
//
//    return  YES;
//}

//该方法可以是当前VC横屏，横屏之后默认隐藏状态栏，可以重写上面的方法来显示状态栏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark -SLVideoViewDelegate

-(void)backBtn{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
