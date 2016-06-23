//
//  SLVideoView.m
//  SLVideo
//
//  Created by 孙磊 on 16/6/20.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "SLVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


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

//顶部视图，包括返回按钮，标题，高清，收藏，分享
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *videoTitleLbl;

@property (nonatomic, strong) UIButton *HDBtn;

@property (nonatomic, strong) UIButton *collectionBtn;

@property (nonatomic, strong) UIButton *shareBtn;

//添加一个播放展厅按钮
@property (nonatomic, strong) UIButton *playBtn;

//下一个视频
@property (nonatomic, strong) UIButton *nextBtn;

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

// 计算当前在第几秒
@property (nonatomic, assign) __block CGFloat currentSecond;

//缓冲的时间
@property (nonatomic, assign) NSTimeInterval timeInterval;

//用于显示当前的快进或快退的信息
@property (nonatomic, strong) UILabel *showLbl;

@end

@implementation SLVideoView{
    
    float _touchTime;
}

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
            //当没有多余的缓冲的时候会监听
            [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        
            
            // 添加视频播放结束通知
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
            
        }];
        
        //创建滑动条等控件
        [self createSliderWithPlayerItem:self.playerItem];
//        [self controlVolume];
        
        //添加拖动手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

#pragma mark - 手势

/**
 *  多动的响应方法
 *
 *  @param gesture 拖动手势的对象
 */
-(void)panGesture:(UIPanGestureRecognizer *)gesture{
    
    //每秒移动的点
    CGPoint point = [gesture velocityInView:self];
    
    CGFloat pointX = fabs(point.x);
    CGFloat pointY = fabs(point.y);
    
//    NSLog(@"拖动了。。。X:%f------Y:%f",pointX,pointY);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"开始拖动。。。。");
            _showLbl.hidden = NO;
            
            _touchTime = _currentSecond;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"拖动中。。。。");
            if (pointX > pointY) { //水平滑动
                
                _touchTime += point.x;
                if (point.x > 0) { //快进
                    NSLog(@"快进>>>>%--f",_touchTime);
                    if (_touchTime > _playerItem.duration.value) {
                        
                        _showLbl.text = [NSString stringWithFormat:@"%@ / %@>>>",_totalTime,_totalTime];
                        _touchTime = _playerItem.duration.value;
                    }else{
                        
                        _showLbl.text = [NSString stringWithFormat:@"%@ / %@>>>",[self formatTime:_touchTime],_totalTime];
                    }
                }else{ //快退
                    NSLog(@"<<<<快退--%f",point.x);
                    
                    if (_touchTime < 0) {
                        
                        _showLbl.text = [NSString stringWithFormat:@"%@ / %@>>>",_totalTime,_totalTime];
                    }else{
                        
                        _showLbl.text = [NSString stringWithFormat:@"%@ / %@>>>",[self formatTime:_touchTime],_totalTime];
                    }
                }
                
                _touchTime = 0;

            }else{ //上下滑动
                
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"拖动结束。。。。");
            _showLbl.hidden = YES;
            
            NSLog(@"拖动中。。。。");
            if (pointX > pointY) { //水平滑动
                
                if (point.x > 0) { //快进
                    NSLog(@"快进>>>>%--f",point.x);
                    if (_touchTime > _playerItem.duration.value) {
                        break;
                    }
                }else{ //快退
                    NSLog(@"<<<<快退--%f",point.x);
                    if (_touchTime < 0) {
                        break;
                    }
                }
                
                [_player seekToTime:CMTimeMake(_touchTime, 1)];
            }else{ //上下滑动
                
                if (point.y < 0) {
                    NSLog(@"大大大大大大---%f",point.y);
                }else{
                    NSLog(@"小小小小小小---%f",point.y);
                }
                
            }
            
        }
            break;
            
        default:
            break;
    }
    
     _touchTime = 0;
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
            NSLog(@"----总时间----：%f",CMTimeGetSeconds(duration));
            
            self.slider.maximumValue = CMTimeGetSeconds(playerItem.duration);
            self.totalTimeLbl.text = _totalTime;
            
            // 监听当前时间
            [self currentTimeUpdate];
            
            [self.player play];
            [_playBtn setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            
            NSLog(@"AVPlayerStatusFailed");
            _playBtn.enabled = NO;
            [_playBtn setImage:[UIImage imageNamed:@"cant-play"] forState:UIControlStateNormal];
        
        }else{ //AVPlayerStatusUnknown
            
            NSLog(@"状态未知.....");
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        _timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",_timeInterval);
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:_timeInterval / totalDuration animated:YES];
    
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        NSLog(@"**playbackBufferEmpty***");
        
        //如果缓冲的不够，视频的播放会暂停，如下操作可以让视频在缓冲够了之后自动播放，这样不至于在缓冲的时候暂停播放还需要人为点击播放按钮了
        if (_currentSecond <= _timeInterval) {
            
            [_player play];
        }
    }
}

/**
 *  监听当前的时间
 *
 */
- (void)currentTimeUpdate{
    
    __weak typeof(self) weakSelf = self;
    //每秒监听一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {

        // 计算当前在第几秒
        weakSelf.currentSecond = time.value/time.timescale;
        
        //给slider赋值
        [weakSelf.slider setValue:weakSelf.currentSecond animated:YES];
        
        //给当前时间和总共时间label赋值
        NSString *currentTimeString = [weakSelf formatTime:weakSelf.currentSecond];

        weakSelf.currentTimeLbl.text = currentTimeString;
        weakSelf.totalTimeLbl.text = weakSelf.totalTime;
    }];
}

/**
 *  格式化时间
 *
 *  @param second 秒
 *
 *  @return 格式化后的时间
 */
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


/**
 *  计算缓冲总进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

/**
 *  创建控制面板
 *
 *  @param playerItem 当前视频控制对象
 */
- (void)createSliderWithPlayerItem:(AVPlayerItem *)playerItem{
    
    //顶部横条，包括返回，标题，高清，收藏，分享
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    _topView.backgroundColor = [UIColor clearColor];
    [self addSubview:_topView];
    
    //返回按钮
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, _topView.frame.size.height - 10, _topView.frame.size.height - 10)];
    [_backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back_normal"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [_topView addSubview:_backBtn];
    
    //视频名称
    _videoTitleLbl = [[UILabel alloc]initWithFrame:CGRectMake(_backBtn.frame.origin.x + _backBtn.frame.size.width, _backBtn.frame.origin.y, 200, _backBtn.frame.size.height)];
    _videoTitleLbl.textColor = [UIColor whiteColor];
    _videoTitleLbl.text = @"测试test";
    
    [_topView addSubview:_videoTitleLbl];
    
    //分享
    _shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 30 - 10, (_topView.frame.size.height - 23)/2.0f, 23, 23)];
    [_shareBtn setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [_topView addSubview:_shareBtn];
    
    //收藏
    _collectionBtn = [[UIButton alloc]initWithFrame:CGRectMake(_shareBtn.frame.origin.x - _shareBtn.frame.size.width - 20, _shareBtn.frame.origin.y, _shareBtn.frame.size.height, _shareBtn.frame.size.height)];
    [_collectionBtn setBackgroundImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
    [_topView addSubview:_collectionBtn];

    //高清
    _HDBtn = [[UIButton alloc]initWithFrame:CGRectMake(_collectionBtn.frame.origin.x - _collectionBtn.frame.size.width - 20, _collectionBtn.frame.origin.y, _collectionBtn.frame.size.height, _collectionBtn.frame.size.height)];
    [_HDBtn setBackgroundImage:[UIImage imageNamed:@"HD"] forState:UIControlStateNormal];
    [_topView addSubview:_HDBtn];
    
    //添加一个播放暂停按钮
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [_playBtn setBounds:CGRectMake(0, 0, 65, 65)];
    [_playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(videoPlayClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    
    //下一个视频按钮
    _nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 75, (self.frame.size.height - 65)/2.0f, 65, 65)];
    [_nextBtn setImage:[UIImage imageNamed:@"btn_next"] forState:UIControlStateNormal];
    [_topView addSubview:_nextBtn];
    
    
    //缓冲进度条、当前时间、总共时间
    _sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 30)];
    _sliderView.backgroundColor = [UIColor clearColor];
    [self addSubview:_sliderView];
    
    //缓冲进度条
    _videoProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(75, (_sliderView.frame.size.height - 2)/2.0f, self.frame.size.width - 146 - 4, 2)];
    _videoProgress.backgroundColor = [UIColor purpleColor];
    [_sliderView addSubview:_videoProgress];
    
    //当前时间
    _currentTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, _sliderView.frame.size.height)];
    _currentTimeLbl.textAlignment = NSTextAlignmentCenter;
    _currentTimeLbl.adjustsFontSizeToFitWidth = YES;
    _currentTimeLbl.textColor = [UIColor whiteColor];
    self.currentTimeLbl.text = @"00:00";
    [_sliderView addSubview:self.currentTimeLbl];
    
    //滑动条
    _slider = [[UISlider alloc]initWithFrame:CGRectMake(73, 0, self.frame.size.width - 146, 30)];
    _slider.backgroundColor = [UIColor clearColor];
    
    
//    [self setUpVideoSlider];
    _slider.tintColor = [UIColor whiteColor];
    
    
    //设置thumb的图片大小可以改变滑块的大小
    [_slider setThumbImage:[self originalImage:[UIImage imageNamed:@"progress_controller"] scaleToSize:CGSizeMake(25, 25)] forState:UIControlStateNormal];
    
    [_slider addTarget:self action:@selector(sliderUpdate:) forControlEvents:UIControlEventValueChanged];
    
    [_sliderView addSubview:self.slider];
    
    //总共时间
    _totalTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 70, 0, 60, _sliderView.frame.size.height)];
    _totalTimeLbl.textAlignment = NSTextAlignmentCenter;
    _totalTimeLbl.adjustsFontSizeToFitWidth = YES;
    _totalTimeLbl.textColor = [UIColor whiteColor];
    _totalTimeLbl.text = @"00:00";
    [_sliderView addSubview:_totalTimeLbl];
    
    //显示快进或快退
    _showLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 30)];
    _showLbl.center = CGPointMake(self.center.x, 70);
    _showLbl.textAlignment = NSTextAlignmentCenter;
    _showLbl.textColor = [UIColor whiteColor];
    _showLbl.adjustsFontSizeToFitWidth = YES;
    _showLbl.hidden = YES;
    [self addSubview:_showLbl];
    
}

- (void)setUpVideoSlider{
//    self.slider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, YES, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

-(void)backBtn:(UIButton *)button{
 
    [self.player pause];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.transform = CGAffineTransformIdentity;
    [self removeFromSuperview];
}

/**
 *  滑块的响应方法
 *
 *  @param slider 滑块对象
 */
-(void)sliderUpdate:(UISlider *)slider{
    NSLog(@"滑块拖动了");
    NSLog(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    
//    __weak typeof(self) weakSelf = self;
    [_player seekToTime:changedTime completionHandler:^(BOOL finished) {

//        [weakSelf.playBtn setTitle:@"Stop" forState:UIControlStateNormal];
    }];

}

/**
 *  控制系统音量
 */
-(void)controlVolume{

    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 70)/2.0f + 10, 50, 70)];
    volumeView.showsRouteButton = NO;
    volumeView.showsVolumeSlider = YES;
    
    [volumeView sizeToFit];
    
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    volumeView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    volumeViewSlider.tintColor = [UIColor whiteColor];
    [volumeViewSlider setThumbImage:[self originalImage:[UIImage imageNamed:@"progress_controller"] scaleToSize:CGSizeMake(0.1, 0.1)] forState:UIControlStateNormal];
    
    // retrieve system volume
//    float systemVolume = volumeViewSlider.value;
    
    // change system volume, the value is between 0.0f and 1.0f
    [volumeViewSlider setValue:0.5f animated:NO];
    
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];

    [self addSubview:volumeView];
}


- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.slider setValue:currentSecond animated:YES];
}

/**
 *  视频播放结束的响应方法
 *
 *  @param notification 通知对象
 */
- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.slider setValue:0.0 animated:YES];
        [weakSelf.playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    }];
}

- (void)videoPlayClick:(UIButton *)bt
{
    if (_player.rate == 1) {
        //暂停播放
        [_player pause];
        [bt setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];

//        [UIView animateWithDuration:0.3f animations:^{
//            self.transform = CGAffineTransformIdentity;
//            self.frame = self.originaFrame;
//        }];
        
    }else{
        //播放
        [_player play];
        [bt setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];

        //按顺序显示，不然导航条和状态栏会重合的啊
        [[UIApplication sharedApplication] setStatusBarHidden:NO];

//        //状态栏转向
//        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
//        
//        [UIView animateWithDuration:0.3f animations:^{
//            self.transform = CGAffineTransformMakeRotation(M_PI/2);
//            self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.5, 1.5), M_PI/2);
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

#pragma TODO
//重载一个获取layer的方法(必须实现)
//默认的layer属性是CALayer类型的，在此改成AVPlayerLayer类型
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

/**
 *  改变图片的大小
 *
 *  @param image 源图片
 *  @param size  要裁剪的尺寸
 *
 *  @return 返回裁剪后的尺寸
 */
-(UIImage *)originalImage:(UIImage *)image scaleToSize:(CGSize)size{
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

/**
 *  播放
 */

-(void)play{

    [self.player play];
}

/**
 *  暂停
 */
-(void)pause{
    [self.player pause];
}

@end

