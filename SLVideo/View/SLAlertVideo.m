//
//  SLAlertVideo.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/29.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "SLAlertVideo.h"

@interface SLAlertVideo ()

@property (nonatomic, strong) UIImageView *videoImage;

@property (nonatomic, strong) UIButton *videoPlayBtn;

@property (nonatomic, strong) UILabel *videoNameLbl;


@end

@implementation SLAlertVideo


-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:173/225.0f green:173/225.0f blue:173/225.0f alpha:1.0f];
        self.frame = frame;
        self.clipsToBounds = YES;
        
        //添加单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
        
        [self setupUI];
    }
    
    return self;
}


#pragma mark - 显示本视图到view上
-(void)showOnView:(UIView *)view{
    
    [view addSubview:self];
}


//创建UI
-(void)setupUI{
    
    //视频播放图片展示
    _videoImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 375)];
    _videoImage.backgroundColor = [UIColor clearColor];
    [self addSubview:_videoImage];
    
    //播放按钮
    _videoPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake((_videoImage.frame.size.width - 53)/2, (_videoImage.frame.size.height - 53)/2, 53, 53)];
    [_videoPlayBtn setImage:[UIImage imageNamed:@"videoPlayBtn"] forState:UIControlStateNormal];
    [_videoImage addSubview:_videoPlayBtn];
    
    //下面的功能面板
    UIView *funcView = [[UIView alloc]initWithFrame:CGRectMake(0, _videoImage.frame.origin.y + _videoImage.frame.size.height, self.frame.size.width, 292)];
    funcView.backgroundColor = [UIColor colorWithRed:136/225.0f green:136/225.0f blue:136/225.0f alpha:1.0f];
    [self addSubview:funcView];
    
    _videoNameLbl = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 200, 40)];
    self.videoNameLbl.text = @"空手道";
    self.videoNameLbl.font = [UIFont systemFontOfSize:17];
    self.videoNameLbl.textColor = [UIColor whiteColor];
    
    [funcView addSubview:self.videoNameLbl];
    
    UILabel *breakLineLbl = [[UILabel alloc]initWithFrame:CGRectMake(15, _videoNameLbl.frame.origin.y + _videoNameLbl.frame.size.height + 1, self.frame.size.width/2, 1)];
    breakLineLbl.backgroundColor = [UIColor colorWithRed:173/225.0f green:173/225.0f blue:173/225.0f alpha:1.0f];
    [funcView addSubview:breakLineLbl];

}

-(void)tap:(UITapGestureRecognizer *)tap{
    [_videoPlayBtn removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(hideAlertVideo)]) {
        
        [self.delegate hideAlertVideo];
    }
    
    
}


@end
