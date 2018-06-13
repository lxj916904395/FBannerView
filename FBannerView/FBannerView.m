//
//  BannerView.m
//  JIEAPP
//
//  Created by lxj on 2018/5/7.
//  Copyright © 2018年 jie. All rights reserved.
//

#import "FBannerView.h"

#import "UIImageView+WebCache.h"
#import <SDWebImage/SDWebImageDownloader.h>

#define viewWidth self.frame.size.width
#define viewHeight self.frame.size.height

@interface FBannerView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(strong ,nonatomic) FBannerConfig * config;
@property(strong ,nonatomic) NSMutableArray * images;
@property(strong ,nonatomic) UICollectionView *collectionView;
@property(strong ,nonatomic) UIPageControl *pageControl;
@end
@implementation FBannerView{
    
    long _currentPage;
    
    NSTimer *timer;
    NSInteger _imageCount;

}

- (instancetype)initWithFrame:(CGRect)frame config:(FBannerConfig *)config{
    if (self = [super initWithFrame:frame]) {
        self.config = config;
        
        _currentPage = 0;
    
        [self _createUI];

    }
    return self;
}

- (UICollectionView *)collectionView{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(viewWidth, viewHeight);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, viewWidth, viewHeight) collectionViewLayout:layout];
        _collectionView.bounces = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (void)_createUI{
    
    _imageCount = _config.imageUrls.count;
    _images = [NSMutableArray arrayWithArray:_config.imageUrls];
    
    if (_images.count >1) {
        [_images addObject:_config.imageUrls[0]];
        [_images insertObject:[_config.imageUrls lastObject] atIndex:0];
    }
    
    if (!self.collectionView.superview) {
        [self addSubview:self.collectionView];
    }

    if (_images.count <= 1) return;
    if (!self.pageControl.superview) {
        [self addSubview:self.pageControl];
    }
    _pageControl.numberOfPages = _imageCount;
    _pageControl.currentPage = 0;

    _collectionView.contentOffset = CGPointMake(viewWidth, 0);
    [self _startTimer];
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((viewWidth-100)/2, viewHeight-30, 100, 20)];
        _pageControl.pageIndicatorTintColor = _config.pageIndicatorTintColor?_config.pageIndicatorTintColor:[UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = _config.currentPageIndicatorTintColor?_config.currentPageIndicatorTintColor:[UIColor orangeColor];
    }
    return _pageControl;
}

- (void)setImageUrls:(NSArray *)imageUrls{
    _imageUrls = imageUrls;
    if (!self.config) {
        self.config = [FBannerConfig new];
    }
    self.config.imageUrls = _imageUrls;
    [self _stopTimer];
    [self _createUI];
}

#pragma mark - 定时器

/**
 停止定时器
 */
- (void)_stopTimer{
    if (timer) {
        [timer invalidate];
    }
    timer = nil;
}

//开始定时器
- (void)_startTimer{
    [self _stopTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:self.config.duration>0?self.config.duration:2.f target:self selector:@selector(nextPage) userInfo:nil repeats:YES] ;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 图片切换
//下一页
- (void)nextPage{
    CGPoint offset = _collectionView.contentOffset;
    offset.x += viewWidth;
    [_collectionView setContentOffset:offset animated:YES];
}

// 重置偏移量
- (void)resetOffset{
    NSInteger page = _collectionView.contentOffset.x/viewWidth;
    if (page == 0) {//滚动到左边
        _collectionView.contentOffset = CGPointMake(viewWidth * (_images.count - 2), 0);
    }else if (page == _images.count - 1){//滚动到右边
        _collectionView.contentOffset = CGPointMake(viewWidth, 0);
    }
    
    _currentPage = _collectionView.contentOffset.x/viewWidth;
    _pageControl.currentPage = _currentPage-1;
}


#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.placeholderImage = self.config.placeholderImg;
    cell.url = _images[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_delegate && [_delegate respondsToSelector:@selector(bannerView:didSelectIndex:)]) {
        
        NSInteger row = indexPath.row;
        NSInteger current = 0;
    
        //第一张
        if (row == 1 || row == _images.count-1) {
            current = 1;
        }else if(row == 0 || row == _images.count-2){
            //最后一张
            current = _imageCount;
        }else{
            current = row;
        }
        
        [_delegate bannerView:self didSelectIndex:current];
    }
}

// 手动滚动 减速完毕会调用(停止滚动),开启定时器
// 只要设置了scrollView的分页显示，当手动(使用手指)滚动结束后，该代理方法会被调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self resetOffset];
    [self _startTimer];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self _stopTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self resetOffset];
}

@end


@implementation ImageCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        _imageView = imageView;
        
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)setUrl:(NSString *)url{
    
    NSString *userAgent = @"";
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
    
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        [[SDWebImageDownloader sharedDownloader] setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }

    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:self.placeholderImage];
}
@end

@implementation FBannerConfig
@end
