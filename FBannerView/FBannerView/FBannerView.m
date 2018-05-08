//
//  BannerView.m
//  JIEAPP
//
//  Created by lxj on 2018/5/7.
//  Copyright © 2018年 jie. All rights reserved.
//

#import "FBannerView.h"

#define viewWidth self.frame.size.width
#define viewHeight self.frame.size.height

@interface FBannerView()<UICollectionViewDataSource,UICollectionViewDelegate>
@end
@implementation FBannerView{
    
    long currentIndex;
    UICollectionView *collectionView;
    NSTimer *timer;
    void (^clickItem)(NSInteger index);
    NSInteger count;
    UIPageControl *pageControl;
    NSInteger _time;
    UIImage *placeholderImage;
}

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images duration:(NSTimeInterval)duration placeholderImage:(UIImage *)placeholderImg click:(void(^)(NSInteger index))block{
    if (self = [super initWithFrame:frame]) {
        currentIndex = 0;
        clickItem = block;
        _time = duration;
        placeholderImage = placeholderImg;
        
        count = images.count;
        _images = [NSMutableArray arrayWithArray:images];
        
        if (images.count >1) {
            [_images addObject:images[0]];
            [_images insertObject:[images lastObject] atIndex:0];
        }
        [self _createUI];

    }
    return self;
}

- (void)_createUI{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(viewWidth, viewHeight);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, viewWidth, viewHeight) collectionViewLayout:layout];
    collectionView.bounces = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.pagingEnabled = YES;
    
    [self addSubview:collectionView];
    
    if (_images.count <= 1) return;
    [self _createPageControl];
    collectionView.contentOffset = CGPointMake(viewWidth, 0);
    [self _startTimer];
}

- (void)_createPageControl{
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((viewWidth-100)/2, viewHeight-30, 100, 20)];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    pageControl.numberOfPages = count;
    pageControl.currentPage = 0;
    [self addSubview:pageControl];
}


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
    timer = [NSTimer scheduledTimerWithTimeInterval:_time target:self selector:@selector(nextPage) userInfo:nil repeats:YES] ;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

//下一页
- (void)nextPage{
    CGPoint offset = collectionView.contentOffset;
    offset.x += viewWidth;
    [collectionView setContentOffset:offset animated:YES];
}

// 重置偏移量
- (void)resetOffset{
    NSInteger page = collectionView.contentOffset.x/viewWidth;
    if (page == 0) {//滚动到左边
        collectionView.contentOffset = CGPointMake(viewWidth * (_images.count - 2), 0);
    }else if (page == _images.count - 1){//滚动到右边
        collectionView.contentOffset = CGPointMake(viewWidth, 0);
    }
    
    currentIndex = collectionView.contentOffset.x/viewWidth;
    pageControl.currentPage = currentIndex-1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.placeholderImage = placeholderImage;
    cell.url = _images[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (clickItem) {
        
        NSInteger row = indexPath.row;
    
        //第一张
        if (row == 1 || row == _images.count-1) {
            clickItem(1);
        }else if(row == 0 || row == _images.count-2){
            //最后一张
            clickItem(count);
        }else{
            clickItem(row);
        }
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
