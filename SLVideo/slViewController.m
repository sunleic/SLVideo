//
//  slViewController.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/27.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "slViewController.h"
#import "SLVideoView.h"

@interface slViewController ()

@end

@implementation slViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
        SLVideoView *video = [[SLVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width) url:@"http://7xrpiy.com1.z0.glb.clouddn.com/video%2F1.mp4"];
//        video.center = self.view.center;
    
//        [UIView animateWithDuration:0.3f animations:^{
//            video.transform = CGAffineTransformMakeRotation(M_PI/2);
//    
//        }];
        [self.view addSubview:video];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 60, 30)];
    button.backgroundColor = [UIColor purpleColor];
    
    [button addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void)btn{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)prefersStatusBarHidden{

    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{

    return UIStatusBarAnimationFade;
}

//- (BOOL)shouldAutorotate{
//
//    return  YES;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
}


@end
