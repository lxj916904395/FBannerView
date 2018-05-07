//
//  BannerView.h
//  JIEAPP
//
//  Created by lxj on 2018/5/7.
//  Copyright © 2018年 jie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBannerView : UIView

@property(strong ,nonatomic) NSMutableArray * images;
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images time:(NSInteger)time click:(void(^)(NSInteger index))block;


@end


@interface ImageCell : UICollectionViewCell

@property(strong ,nonatomic) UIImageView * imageView;
@property(strong ,nonatomic) UIImage * image;
@end
