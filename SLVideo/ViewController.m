//
//  ViewController.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/20.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "ViewController.h"
#import "SLVideoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    SLVideoView *video = [[SLVideoView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 220) url:@"http://localhost/video.mp4"];
    [self.view addSubview:video];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
