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


@interface SLVideoView ()

//用于播放视频
@property (nonatomic, strong) AVPlayer *player;

//用于高级自定义，视频管理者
@property (nonatomic, strong) AVPlayerItem *playerItem;


//*********顶部视图容器***********
@property (nonatomic, strong) UIView *topView;
//返回按钮
@property (nonatomic, strong) UIButton *backBtn;
//标题
@property (nonatomic, strong) UILabel *videoTitleLbl;
//高清
@property (nonatomic, strong) UIButton *HDBtn;
//收藏
@property (nonatomic, strong) UIButton *collectionBtn;
//分享
@property (nonatomic, strong) UIButton *shareBtn;
//

//添加一个播放展厅按钮
@property (nonatomic, strong) UIButton *playBtn;

//下一个视频
@property (nonatomic, strong) UIButton *nextBtn;

//格式化后的视频总时间
@property (nonatomic ,copy) NSString *totalTime;

//*********底部视图容器***********
@property (nonatomic, strong) UIView *sliderView;
//当前时间label
@property (nonatomic, strong) UILabel *currentTimeLbl;
//视频播放的进度条
@property (nonatomic, strong) UISlider *videoSlider;
//总时间label
@property (nonatomic, strong) UILabel *totalTimeLbl;
//缓冲进度条
@property (nonatomic, strong) UIProgressView *videoProgress;
//缓冲的时间
@property (nonatomic, assign) NSTimeInterval timeInterval;


//************音量条容器************
@property (nonatomic, strong) UIImageView *volumeImgView;
//音量条
@property (nonatomic, strong) UISlider *volumeSlider;
//左边的音量显示条
@property (nonatomic, strong) UISlider *showVolueSlider;
//系统音量
@property (nonatomic, strong) MPVolumeView *volumeView;


//用于显示当前的快进或快退的信息
@property (nonatomic, strong) UILabel *showLbl;

// 计算当前在第几秒
@property (nonatomic, assign) __block CGFloat currentSecond;

@end

@implementation SLVideoView{
    
    //拖动之后的时间
    float _touchTime;
    //拖动之后的音量
    float _volumeValue;
    
    //视频控件是否隐藏，默认刚打开时不隐藏，3秒后隐藏
    BOOL isHidden;
}

//初始化方法实现
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        //默认刚打开视频时控件不隐藏，3s后再做隐藏操作
        isHidden = NO;
        
        //初始化播放组件
        [self initVideoWith:url];
        
        //创建滑动条等控件
        [self setupUIWithPlayerItem:self.playerItem];
        
        //添加拖动手势
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
        
        //添加单击手势
        UITapGestureRecognizer *tapGesutre = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tapGesutre];
        
        //获取系统音量条，并创建自定制音量条
        [self controlVolume];
        
        //视频刚打开时，让控件们停留3.0秒
        [self performSelector:@selector(displayVideoControlers) withObject:nil afterDelay:3.0f];

    }
    return self;
}


/**
 *  初始化播放组件
 *
 *  @param url 视频的URL字符串
 */
-(void)initVideoWith:(NSString *)url{

    
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
}

/**
 *  显示或隐藏视频控制面板
 */
-(void)displayVideoControlers{
    
    if (isHidden == NO) {
    
        [UIView animateWithDuration:0.5f animations:^{
            _topView.transform = CGAffineTransformMakeTranslation(_topView.frame.origin.x, -_topView.frame.size.height);
            
            _volumeImgView.hidden = YES;
            _playBtn.hidden = YES;
            
            _sliderView.transform = CGAffineTransformMakeTranslation(_sliderView.frame.origin.x, _sliderView.frame.size.height*2);
        }];
        
    }else{
        
        [UIView animateWithDuration:0.5f animations:^{
            _topView.transform = CGAffineTransformIdentity;
            
            _volumeImgView.hidden = NO;
            _playBtn.hidden = NO;
            
            _sliderView.transform = CGAffineTransformIdentity;
        }];
    
    }
    
    isHidden = !isHidden;
}

-(void)tapGesture:(UITapGestureRecognizer *)gesture{
    
    // 先取消一个3秒后的方法，保证不管点击多少次，都只有最后一次的点击生效
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayVideoControlers) object:nil];
    
    if (isHidden == YES) { //此时控件s在隐藏着
        [self displayVideoControlers];
        
        // 3秒后执行隐藏的方法
        [self performSelector:@selector(displayVideoControlers) withObject:nil afterDelay:3.0f];
    }else{//此时控件在显示着，本次tap是隐藏控件s
        [self displayVideoControlers];
    }
}

#pragma mark - 拖拽手势

/**
 *  拖动的响应方法，用来调节视频快进、快退 音量的大小
 *
 *  @param gesture 拖动手势的对象
 */
-(void)panGesture:(UIPanGestureRecognizer *)gesture{
    
    // 先取消一个3秒后的方法，保证不管点击多少次，都只有最后一次的点击生效
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayVideoControlers) object:nil];
    
    //每秒移动的点
    CGPoint point = [gesture velocityInView:self];
    
    CGFloat pointX = fabs(point.x);
    CGFloat pointY = fabs(point.y);
    
//    NSLog(@"拖动了。。。X:%f------Y:%f",pointX,pointY);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //NSLog(@"开始拖动。。。。");
            
            if (pointX > pointY) {
                _showLbl.hidden = NO;
                _touchTime = (int)(CMTimeGetSeconds(_playerItem.currentTime));
            }else{
                [_showVolueSlider setValue:_volumeValue animated:YES];
                
                if (isHidden == YES) {
                    //NSLog(@"+++++++++++");
                    _volumeImgView.hidden = NO;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //NSLog(@"拖动中。。。。");
            if (pointX > pointY) { //水平滑动
                
                if (point.x > 0) { //快进
                    _touchTime += 1;
                    //快进的描述大于总共时间
                    if (_touchTime > CMTimeGetSeconds(_playerItem.duration)) {
                        
                        //如果没有缓冲完，而你有快进到终点了，此时只能快进到最大缓冲的位置
                        _showLbl.text = [NSString stringWithFormat:@"%@ / %@>>>",_totalTime,_totalTime];
                        _touchTime = _playerItem.duration.value;
                    }else{
                        
                        _showLbl.text = [NSString stringWithFormat:@"%@ / %@>>>",[self formatTime:_touchTime],_totalTime];
                    }
                }else{ //快退
                    //NSLog(@"<<<<快退--%f",point.x);
                    _touchTime -= 1;
                    //快退的时间小于0
                    if (_touchTime < 0) {
                        
                        _showLbl.text = [NSString stringWithFormat:@"<<<%@ / %@",@"00:00",_totalTime];
                    }else{
                        
                        _showLbl.text = [NSString stringWithFormat:@"<<<%@ / %@",[self formatTime:_touchTime],_totalTime];
                    }
                }

            }else{ //上下滑动
        
                if (point.y < 0) { //增加音量
                    
                    _volumeValue  += 0.01;
                    if (_volumeValue > 1) {
                        [_volumeSlider setValue:1.0f animated:YES];
                    }else{
                        //change system volume, the value is between 0.0f and 1.0f
                        [_volumeSlider setValue:_volumeValue animated:NO];
                        
                        // send UI control event to make the change effect right now.
                        [_volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    [_showVolueSlider setValue:_volumeSlider.value animated:YES];
                    
                }else{  //减小音量
                    _volumeValue  -= 0.01;
                    if (_volumeValue < 0) {
                        [_volumeSlider setValue:0 animated:YES];
                    }else{
                        
                        //change system volume, the value is between 0.0f and 1.0f
                        [_volumeSlider setValue:_volumeValue animated:NO];
                        
                        // send UI control event to make the change effect right now.
                        [_volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
                    }
                    [_showVolueSlider setValue:_volumeSlider.value animated:YES];
                }

            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            // 3秒后执行的方法
            [self performSelector:@selector(displayVideoControlers) withObject:nil afterDelay:2.0f];
            
            NSLog(@"拖动结束。。。。");
            _showLbl.hidden = YES;
            
            NSLog(@"拖动中。。。。");
            if (pointX > pointY) { //水平滑动
                
                if (point.x > 0) { //快进
                    //NSLog(@"快进>>>>%--f",point.x);
                    if (_touchTime > CMTimeGetSeconds(_playerItem.duration)) {
                        
                        _touchTime = CMTimeGetSeconds(_playerItem.duration);
                    }
                }else{ //快退
                    //NSLog(@"<<<<快退--%f",point.x);
                    if (_touchTime < 0) {
                        _touchTime = 0;
                    }
                }
                
                [_player seekToTime:CMTimeMake(_touchTime, 1)];
                
            }else{ //上下滑动
                
                if (isHidden == YES) {
                     _volumeImgView.hidden = YES;
                }
                
            }
            
        }
            break;
            
        default:
            break;
    }
    
}

//监听播放的进度 status播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            
            NSLog(@"AVPlayerStatusReadyToPlay");
            
            _playBtn.enabled = YES;
            _videoSlider.enabled = YES;
        
            [_playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];

            // 获取视频总长度  转换成秒
            CMTime duration = self.playerItem.duration;
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;
            _totalTime = [self formatTime:totalSecond];// 格式化成播放时间
            NSLog(@"----总时间----：%f",CMTimeGetSeconds(duration));
            
            self.videoSlider.maximumValue = CMTimeGetSeconds(playerItem.duration);
            self.totalTimeLbl.text = _totalTime;
            
            // 更新显示当前时间label
            [self currentTimeUIUpdate];
            
            [self.player play];
            [_playBtn setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            
            NSLog(@"AVPlayerStatusFailed");
            _playBtn.enabled = NO;
            _videoSlider.enabled = NO;
            [_playBtn setImage:[UIImage imageNamed:@"cant-play"] forState:UIControlStateNormal];
        
        }else{ //AVPlayerStatusUnknown
            
            NSLog(@"状态未知.....");
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        _timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"视频缓冲到----:%f",_timeInterval);
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:_timeInterval / totalDuration animated:YES];
    
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        NSLog(@"**playbackBufferEmpty***");
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        [self addSubview:indicator];
        //如果缓冲的不够，视频的播放会暂停，如下操作可以让视频在缓冲够了之后自动播放，这样不至于在缓冲的时候暂停播放还需要人为点击播放按钮了
        if (_currentSecond <= _timeInterval) {
            
            [_player play];
        }
    }
}

/**
 *  监听视频播放的当前时间，并更新对应的UI
 *
 */
- (void)currentTimeUIUpdate{
    
    __weak typeof(self) weakSelf = self;
    //每秒监听一次，更新UI
    //CMTimeGetSeconds(_playerItem.currentTime)这样也可以获取当前时间，当时不能实时更新UI啊
    [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {

        // 计算当前在第几秒
        weakSelf.currentSecond = time.value/time.timescale;
        
        //给slider赋值
        [weakSelf.videoSlider setValue:weakSelf.currentSecond animated:YES];
        
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

#pragma mark -创建视频控制面板
/**
 *  创建视频控制面板
 *
 *  @param playerItem 当前视频控制对象
 */
- (void)setupUIWithPlayerItem:(AVPlayerItem *)playerItem{
    
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
    
    //下一集视频按钮
//    _nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 75, (self.frame.size.height - 65)/2.0f, 65, 65)];
//    [_nextBtn setImage:[UIImage imageNamed:@"btn_next"] forState:UIControlStateNormal];
//    [_topView addSubview:_nextBtn];
    
    
    //缓冲进度条、当前时间、总共时间
    _sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 30)];
    _sliderView.backgroundColor = [UIColor clearColor];
    [self addSubview:_sliderView];
    
    //当前时间
    _currentTimeLbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 60, _sliderView.frame.size.height)];
    _currentTimeLbl.textAlignment = NSTextAlignmentCenter;
    _currentTimeLbl.adjustsFontSizeToFitWidth = YES;
    _currentTimeLbl.textColor = [UIColor whiteColor];
    self.currentTimeLbl.text = @"00:00";
    [_sliderView addSubview:self.currentTimeLbl];
    
    //缓冲进度条
    _videoProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(73, _sliderView.frame.size.height/2, self.frame.size.width - 146, 2)];
    _videoProgress.backgroundColor = [UIColor purpleColor];
    [_sliderView addSubview:_videoProgress];
    
    //滑动条
    _videoSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width - 146 + 4, 30)];
    _videoSlider.center = _videoProgress.center;
    _videoSlider.backgroundColor = [UIColor clearColor];
    
    
    [self setUpVideoSlider];
    _videoSlider.tintColor = [UIColor greenColor];
    
    
    //设置thumb的图片大小可以改变滑块的大小
    [_videoSlider setThumbImage:[self originalImage:[UIImage imageNamed:@"progress_controller"] scaleToSize:CGSizeMake(25, 25)] forState:UIControlStateNormal];
    
    [_videoSlider addTarget:self action:@selector(sliderUpdate:) forControlEvents:UIControlEventValueChanged];
    
    [_sliderView addSubview:_videoSlider];
    
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
    
    
    //音量条
    _volumeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 140)];
    _volumeImgView.center = CGPointMake(45, self.center.y);
    _volumeImgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_volumeImgView];
    
    UIImageView *volumeBig = [[UIImageView alloc]initWithFrame:CGRectMake(2, 0, _volumeImgView.frame.size.width - 4, _volumeImgView.frame.size.width - 4)];
    [volumeBig setImage:[UIImage imageNamed:@"volume_big"]];
    [_volumeImgView addSubview:volumeBig];
    
    UIImageView *volumeSmall = [[UIImageView alloc]initWithFrame:CGRectMake(2, _volumeImgView.frame.size.height - _volumeImgView.frame.size.width + 4, _volumeImgView.frame.size.width - 4, _volumeImgView.frame.size.width - 4)];
    [volumeSmall setImage:[UIImage imageNamed:@"volume_small"]];
    [_volumeImgView addSubview:volumeSmall];
    
    _showVolueSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, _volumeImgView.frame.size.height - 2*18, 2)];
    [_showVolueSlider setThumbImage:[self originalImage:[UIImage imageNamed:@"progress_controller"] scaleToSize:CGSizeMake(0.01, 0.01)] forState:UIControlStateNormal];
    _showVolueSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _showVolueSlider.center = CGPointMake(_volumeImgView.frame.size.width/2.0f, _volumeImgView.frame.size.height/2.0f);
    
    [_volumeImgView addSubview:_showVolueSlider];

}

/**
 *  显示缓冲进度条
 */
- (void)setUpVideoSlider{

    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, YES, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    [_videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [_videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

-(void)backBtn:(UIButton *)button{
 
    [self.player pause];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    self.transform = CGAffineTransformIdentity;
//    [self removeFromSuperview];
    
    [self.delegate backBtn];
}

/**
 *  滑块的响应方法
 *
 *  @param slider 滑块对象
 */
-(void)sliderUpdate:(UISlider *)slider{
    //NSLog(@"滑块拖动了");
    //NSLog(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    
    [_player seekToTime:changedTime completionHandler:^(BOOL finished) {

    }];
}

/**
 *  控制系统音量
 */
-(void)controlVolume{
    
    _volumeView = [[MPVolumeView alloc]init];
    _volumeView.showsRouteButton = NO;

    [_volumeView sizeToFit];
    [_volumeView setFrame:CGRectMake(-1000, -1000, 10, 10)];
   
    
    [self addSubview:_volumeView];
    [_volumeView userActivity];
    for (UIView *view in [_volumeView subviews]){
        if ([[view.class description] isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider*)view;
            break;
        }
    }
    
    //设置默认打开视频时声音为0.3，如果不设置的话，获取的当前声音始终是0
    [_volumeSlider setValue:0.2];
    
    //获取最是刚打开时的音量值
    _volumeValue = _volumeSlider.value;
    
    //设置展示音量条的值
    _showVolueSlider.value = _volumeValue;
    
}

/**
 *  更新视频进度条
 *
 *  @param currentSecond 视频播放的当前时间
 */
- (void)updateVideoSlider:(CGFloat)currentSecond {
    [_videoSlider setValue:currentSecond animated:YES];
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
        [weakSelf.videoSlider setValue:0.0 animated:YES];
        [weakSelf.playBtn setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
    }];
}

/**
 *  播放或暂停视频
 *
 *  @param bt 视频播放/暂停按钮
 */
- (void)videoPlayClick:(UIButton *)bt
{
    if (_player.rate == 1) {
        //暂停播放
        [self pause];
        [bt setImage:[UIImage imageNamed:@"btn_play"] forState:UIControlStateNormal];
        
    }else{
        //播放
        [self play];
        [bt setImage:[UIImage imageNamed:@"btn_pause"] forState:UIControlStateNormal];

        //按顺序显示，不然导航条和状态栏会重合的啊
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

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

