//
//  VideoTableViewCell.m
//  SLVideo
//
//  Created by 孙磊 on 16/3/26.
//  Copyright © 2016年 孙磊. All rights reserved.
//

#import "VideoTableViewCell.h"

@implementation VideoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createContent];
    }
    return self;
}

-(void)createContent{
    
    CGFloat cell_h = 235;
    
    self.picsImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cell_h)];
    self.picsImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.picsImgView.clipsToBounds = YES;
    self.picsImgView.backgroundColor = [UIColor redColor];

    
    self.titleLbl = [[UILabel alloc]initWithFrame:CGRectMake((self.picsImgView.frame.size.width - 200)/2.0f, 85, 200, 16)];
    self.titleLbl.font = [UIFont systemFontOfSize:16];
    self.titleLbl.textColor = [UIColor whiteColor];
    self.titleLbl.textAlignment = NSTextAlignmentCenter;
    
    self.categoryLbl = [[UILabel alloc]initWithFrame:CGRectMake((self.picsImgView.frame.size.width -200)/2.0f, _titleLbl.frame.origin.y + _titleLbl.frame.size.height + 18, 200, 14)];
    self.categoryLbl.font = [UIFont systemFontOfSize:14];
    self.categoryLbl.textColor = [UIColor whiteColor];
    self.categoryLbl.textAlignment = NSTextAlignmentCenter;

    [self.contentView addSubview:self.picsImgView];
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.categoryLbl];
}


@end
