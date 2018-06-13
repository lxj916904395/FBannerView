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
@property(strong ,nonatomic) NSArray * imageUrls;//图片链接
@property(assign ,nonatomic) CGFloat duration;//翻页间隔
@property(strong ,nonatomic) UIImage * placeholderImg;//占位图

@end

@protocol FBannerViewDelegate;
@interface FBannerView : UIView

- (instancetype)initWithFrame:(CGRect)frame config:(FBannerConfig *)config;
@property(weak ,nonatomic) id<FBannerViewDelegate> delegate;
@property(strong ,nonatomic) NSArray * imageUrls;//图片链接

@end

@protocol FBannerViewDelegate <NSObject>
//点击第几张广告
- (void)bannerView:(FBannerView *)bannerView didSelectIndex:(NSInteger)index;
@end

@interface ImageCell : UICollectionViewCell

@property(strong ,nonatomic) UIImageView * imageView;
@property(strong ,nonatomic) NSString * url;
@property(strong ,nonatomic) UIImage * placeholderImage;

@end
