//
//  SLAlertVideo.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/29.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "SLAlertVideo.h"

@interface SLAlertVideo ()

@property (nonatomic, strong) UIButton *videoPlayBtn;

@property (nonatomic, strong) UILabel *videoNameLbl;


@property (nonatomic, assign) NSInteger countTouches;

@end

@implementation SLAlertVideo


-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:173/225.0f green:173/225.0f blue:173/225.0f alpha:1.0f];
        self.frame = frame;
        self.clipsToBounds = YES;
        
        //添加单击手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
        
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
    _videoImage.userInteractionEnabled = YES;
    [self addSubview:_videoImage];
    
    //播放按钮
    _videoPlayBtn = [[UIButton alloc]initWithFrame:CGRectMake((_videoImage.frame.size.width - 53)/2, (_videoImage.frame.size.height - 53)/2, 53, 53)];
    [_videoPlayBtn setImage:[UIImage imageNamed:@"videoPlayBtn"] forState:UIControlStateNormal];
    [_videoPlayBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
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

-(void)pan:(UIPanGestureRecognizer *)gesture{
    
    //每秒移动的点
    CGPoint point = [gesture velocityInView:self];
    
    CGFloat pointX = fabs(point.x);
    CGFloat pointY = fabs(point.y);
    
    //    NSLog(@"拖动了。。。X:%f------Y:%f",pointX,pointY);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //NSLog(@"开始拖动。。。。");
            _countTouches = 0;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //NSLog(@"拖动中。。。。");
            if (pointX < pointY) { //竖直滑动

                _countTouches += 1;
                if (_countTouches > 15) {
                    
                    [_videoPlayBtn removeFromSuperview];
                    if ([self.delegate respondsToSelector:@selector(hideAlertVideo)]) {
                        
                        [self.delegate hideAlertVideo];
                    }
                }
                
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //NSLog(@"开始拖动。。。。");
            [_videoPlayBtn removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(hideAlertVideo)]) {
                
                [self.delegate hideAlertVideo];
            }
        }
            break;

            
        default:
            break;
    }
    
}

-(void)playVideo{
    NSLog(@"**adkfladfjaldfjalsdf***");
    [self.delegate playVideo];
}


@end
