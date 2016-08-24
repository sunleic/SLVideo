//
//  SLVideoView.h
//  SLVideo
//
//  Created by 孙磊 on 16/6/20.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SLVideoViewDelegate <NSObject>

//视频返回按钮
-(void)backBtn;

@end

@interface SLVideoView : UIView

@property (nonatomic, assign) id <SLVideoViewDelegate> delegate;

//标题
@property (nonatomic, strong) UILabel *videoTitleLbl;

/**
 *  视频初始化
 *
 *  @param frame 视频界面大小
 *  @param url   视频URL
 *
 *  @return 返回一个视频视图对象
 */
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url;

@end
