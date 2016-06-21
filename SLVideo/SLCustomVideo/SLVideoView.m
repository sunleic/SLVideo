//
//  SLVideoView.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/20.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "SLVideoView.h"
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger, VideoDirection){

    VideoDirectionLandScape,
    VideoDirectionPortrait
};

@interface SLVideoView ()

//用于播放视频
@property (nonatomic, strong) AVPlayer *player;

//小视频时视频的大小
@property (nonatomic, assign) CGRect originaFrame;

//用于高级自定义，视频管理者
@property (nonatomic, strong) AVPlayerItem *playerItem;

//顶部视图，包括返回按钮，标题，收藏，分享等
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *videoTitleLbl;

@property (nonatomic, strong) UIButton *shareBtn;

//添加一个播放展厅按钮
@property (nonatomic, strong) UIButton *playBtn;

//当前播放时间
@property (nonatomic, copy) NSString *currentTime;

//视频总时间
@property (nonatomic ,copy) NSString *totalTime;

//下面三个视图的载体
@property (nonatomic, strong) UIView *sliderView;

//当前时间label
@property (nonatomic, strong) UILabel *currentTimeLbl;

//视频播放的进度条
@property (nonatomic, strong) UISlider *slider;

//总时间label
@property (nonatomic, strong) UILabel *totalTimeLbl;

//缓冲进度条
@property (nonatomic, strong) UIProgressView *videoProgress;

@end

@implementation SLVideoView

//初始化方法实现
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor purpleColor];
        
        self.originaFrame = frame;
        
        //初始化播放组件
        NSURL *_url = [NSURL URLWithString:url];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_url options:nil];
        [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"duration"] completionHandler:^{
            
            _playerItem = [AVPlayerItem playerItemWithAsset:asset];
            _player = [AVPlayer playerWithPlayerItem:_playerItem];

            //_player视图加载到layer上
            [(AVPlayerLayer *)[self layer] setPlayer:_player];
            
            //监听播放的进度 status播放状态
            [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            // 监听loadedTimeRanges缓冲属性
            [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            // 添加视频播放结束通知
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
            
        }];
        
        //创建滑动条等控件
        [self createSliderWithPlayerItem:self.playerItem];
        
    }
    return self;
}

//监听播放的进度 status播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            
            NSLog(@"AVPlayerStatusReadyToPlay");
            
            _playBtn.enabled = YES;
            [_playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];

            // 获取视频总长度  转换成秒
            CMTime duration = self.playerItem.duration;
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;
            _totalTime = [self formatTime:totalSecond];// 格式化成播放时间
            NSLog(@"总时间:%f",CMTimeGetSeconds(duration));
            
            self.slider.maximumValue = CMTimeGetSeconds(playerItem.duration);
            self.totalTimeLbl.text = _totalTime;
            
            // 监听当前时间
            [self currentTimeUpdate:self.playerItem];
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            
            NSLog(@"AVPlayerStatusFailed");
            _playBtn.enabled = NO;
            [_playBtn setImage:[UIImage imageNamed:@"cant-play"] forState:UIControlStateNormal];
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

- (void)currentTimeUpdate:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    //每秒监听一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        // 计算当前在第几秒
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;
//        NSLog(@"当前是+++++%lf",currentSecond);
        
        //给slider赋值
        [weakSelf.slider setValue:currentSecond animated:YES];
        
        //给当前时间和总共时间label赋值
        NSString *currentTimeString = [weakSelf formatTime:currentSecond];

        weakSelf.currentTimeLbl.text = currentTimeString;
        weakSelf.totalTimeLbl.text = weakSelf.totalTime;
    }];
}

//格式化时间
- (NSString *)formatTime:(CGFloat)second{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    if (second/3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [dateFormatter stringFromDate:date];
    return showtimeNew;
}


// 计算缓冲总进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

//创建控制面板
- (void)createSliderWithPlayerItem:(AVPlayerItem *)playerItem{
    
    //顶部横条，包括返回，标题，高清，收藏，分享
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    _topView.backgroundColor = [UIColor clearColor];
    [self addSubview:_topView];
    
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, _topView.frame.size.height - 10, _topView.frame.size.height - 10)];
//    _backBtn.backgroundColor = [UIColor redColor];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateNormal];
    
    [_topView addSubview:_backBtn];
    
    _videoTitleLbl = [[UILabel alloc]initWithFrame:CGRectMake(_backBtn.frame.origin.x + _backBtn.frame.size.width, _backBtn.frame.origin.y, 200, _backBtn.frame.size.height)];
//    _videoTitleLbl.backgroundColor = [UIColor purpleColor];
    _videoTitleLbl.textColor = [UIColor whiteColor];
    _videoTitleLbl.text = @"测试test";
    
    [_topView addSubview:_videoTitleLbl];
    
    
    //添加一个播放展厅按钮
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [_playBtn setBounds:CGRectMake(0, 0, 65, 65)];
    [_playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    
    _sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
    
    [self addSubview:_sliderView];
    
    //缓冲进度条
    _videoProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(62, (_sliderView.frame.size.height - 2)/2.0f, self.frame.size.width - 120 - 4, 2)];
    _videoProgress.backgroundColor = [UIColor purpleColor];
    [_sliderView addSubview:_videoProgress];
    
    //当前时间
    _currentTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, self.frame.size.height/8.0f)];
    _currentTimeLbl.textAlignment = NSTextAlignmentCenter;
    _currentTimeLbl.adjustsFontSizeToFitWidth = YES;
    _currentTimeLbl.textColor = [UIColor whiteColor];
    self.currentTimeLbl.text = @"00:00";
    [_sliderView addSubview:self.currentTimeLbl];
    
    //滑动条
    _slider = [[UISlider alloc]initWithFrame:CGRectMake(60, 0, self.frame.size.width - 120, 30)];
    _slider.backgroundColor = [UIColor clearColor];
    _slider.tintColor = [UIColor whiteColor];
    
    //设置thumb的图片大小可以改变滑块的大小
    [_slider setThumbImage:[self originalImage:[UIImage imageNamed:@"progress_controller"] scaleToSize:CGSizeMake(25, 25)] forState:UIControlStateNormal];
    
    [_slider addTarget:self action:@selector(sliderUpdate:) forControlEvents:UIControlEventValueChanged];
    
    [_sliderView addSubview:self.slider];
    
    //总共时间
    _totalTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 60, 0, 60, self.frame.size.height/8.0f)];
    _totalTimeLbl.textAlignment = NSTextAlignmentCenter;
    _totalTimeLbl.adjustsFontSizeToFitWidth = YES;
    _totalTimeLbl.textColor = [UIColor whiteColor];
    _totalTimeLbl.text = @"00:00";
    [_sliderView addSubview:_totalTimeLbl];
    
}

-(void)sliderUpdate:(UISlider *)slider{
    NSLog(@"滑块拖动了");
    NSLog(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    
    __weak typeof(self) weakSelf = self;
    [_player seekToTime:changedTime completionHandler:^(BOOL finished) {

//        [weakSelf.playBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }];

}

//改变图片的大小
-(UIImage *)originalImage:(UIImage *)image scaleToSize:(CGSize)size{

    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.slider setValue:currentSecond animated:YES];
}

//视频播放结束的响应方法
- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.slider setValue:0.0 animated:YES];
        [weakSelf.playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    }];
}

- (void)click:(UIButton *)bt
{
    if (_player.rate == 1) {
        //暂停播放
        [_player pause];
        [bt setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];

        [UIView animateWithDuration:0.3f animations:^{
            self.transform = CGAffineTransformIdentity;
            self.frame = self.originaFrame;
        }];
        
    }else{
        //播放
        [_player play];
        [bt setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];

//        //按顺序显示，不然导航条和状态栏会重合的啊
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//
//        //状态栏转向
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
//        
//        [UIView animateWithDuration:0.3f animations:^{
//            self.transform = CGAffineTransformMakeRotation(M_PI/2);
//            self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.2, 1.2), M_PI/2);
//            self.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f);
//
//        }];
    }
}

//刷新控件的位置
-(void)refreshControllersWithVideoDirection:(VideoDirection)direction{
    
    //小屏
    if (direction == VideoDirectionPortrait) {
        
    }else{ //全屏
    
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        _sliderView.frame = CGRectMake(0, 0, self.frame.size.height/8.0f, self.frame.size.height);
        //当前时间
        self.currentTimeLbl.frame = CGRectMake(0, 0, 60, self.frame.size.height/8.0f);
        //滑动条
        self.slider.frame = CGRectMake(60, 0, self.frame.size.width - 120, self.frame.size.height/8.0f);
        //总共时间
        self.totalTimeLbl.frame = CGRectMake(self.frame.size.width - 60, 0, 60, self.frame.size.height/8.0f);
    }

}


//重载一个获取layer的方法(必须实现)
//默认的layer属性是CALayer类型的，在此改成AVPlayerLayer类型
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

@end

