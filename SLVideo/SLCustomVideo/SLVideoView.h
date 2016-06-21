//
//  SLVideoView.h
//  SLVideo
//
//  Created by 孙磊 on 16/6/20.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVideoView : UIView

//初始化方法  传入url  传入frame
- (instancetype)initWithFrame:(CGRect)frame url:(NSString *)url;

@end
