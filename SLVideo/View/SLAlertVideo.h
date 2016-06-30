//
//  SLAlertVideo.h
//  SLVideo
//
//  Created by 孙磊 on 16/6/29.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  SLAlertVideoDelegate <NSObject>

-(void)hideAlertVideo;

@end

@interface SLAlertVideo : UIView

@property (nonatomic, assign) id <SLAlertVideoDelegate> delegate;


//将本视图展示到view上
-(void)showOnView:(UIView *)view;

@end
