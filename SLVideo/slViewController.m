//
//  slViewController.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/27.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "slViewController.h"
#import "SLVideoView.h"

@interface slViewController ()<SLVideoViewDelegate>

@end

@implementation slViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    
    SLVideoView *video = [[SLVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width) url:@"http://7xrpiy.com1.z0.glb.clouddn.com/video%2F1.mp4"];

    video.delegate = self;
    [self.view addSubview:video];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//-(BOOL)prefersStatusBarHidden{
//
//    return NO;
//}

//- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
//
//    return UIStatusBarAnimationFade;
//}

//- (BOOL)shouldAutorotate{
//
//    return  YES;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark -SLVideoViewDelegate

-(void)backBtn{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
