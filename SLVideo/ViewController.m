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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 200, 50, 30)];
    [btn setTitle:@"视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
   
    [self.view addSubview:btn];
}

-(void)btnClick:(UIButton *)button{
    
//    SLVideoView *video = [[SLVideoView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width) url:@"http://7xrpiy.com1.z0.glb.clouddn.com/video%2F1.mp4"];
//    video.center = self.view.center;
//    
//    [UIView animateWithDuration:0.3f animations:^{
//        video.transform = CGAffineTransformMakeRotation(M_PI/2);
//        
//    }];
//    [self.view addSubview:video];
    
    SLVideoViewController *sl = [[SLVideoViewController alloc]init];
    
    [self presentViewController:sl animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
