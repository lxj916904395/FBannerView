//
//  BannerView.h
//  JIEAPP
//
//  Created by lxj on 2018/5/7.
//  Copyright © 2018年 jie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBannerConfig : NSObject

@property(strong ,nonatomic) UIColor * pageIndicatorTintColor;//底部图默认颜色

@property(strong ,nonatomic) UIColor * currentPageIndicatorTintColor;//底部图选中颜色
@end

@protocol FBannerViewDelegate;
@interface FBannerView : UIView

@property(strong ,nonatomic) NSMutableArray * images;
- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images duration:(NSTimeInterval)duration placeholderImage:(UIImage *)placeholderImg config:(FBannerConfig *)config;
@property(weak ,nonatomic) id<FBannerViewDelegate> delegate;

@end

@protocol FBannerViewDelegate <NSObject>
- (void)bannerView:(FBannerView *)bannerView didSelectIndex:(NSInteger)index;
@end

@interface ImageCell : UICollectionViewCell

@property(strong ,nonatomic) UIImageView * imageView;
@property(strong ,nonatomic) NSString * url;
@property(strong ,nonatomic) UIImage * placeholderImage;

@end
