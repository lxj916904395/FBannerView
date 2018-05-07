//
//  BannerView.m
//  JIEAPP
//
//  Created by lxj on 2018/5/7.
//  Copyright © 2018年 jie. All rights reserved.
//

#import "FBannerView.h"

#define kScreenWWidth  [[UIScreen mainScreen] bounds].size.width

@interface FBannerView()<UICollectionViewDataSource,UICollectionViewDelegate>
@end
@implementation FBannerView{
    
    int currentIndex;
    UICollectionView *collectionView;
    NSTimer *timer;
    void (^clickItem)(NSInteger index);
    NSInteger count;
    UIPageControl *pageControl;
    NSInteger _time;
}

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images time:(NSInteger)time click:(void(^)(NSInteger index))block{
    if (self = [super initWithFrame:frame]) {
        currentIndex = 0;
        clickItem = block;
        _time = time;
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
    layout.itemSize = CGSizeMake(kScreenWWidth, self.frame.size.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, kScreenWWidth, self.frame.size.height) collectionViewLayout:layout];
    collectionView.bounces = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.pagingEnabled = YES;
    
    [self addSubview:collectionView];
    
    if (_images.count <= 1) return;
    [self _createPageControl];
    collectionView.contentOffset = CGPointMake(kScreenWWidth, 0);
    [self _startTimer];
}

- (void)_createPageControl{
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.frame.size.width-100)/2, self.frame.size.height-30, 100, 20)];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    pageControl.numberOfPages = count;
    pageControl.currentPage = 0;
    [self addSubview:pageControl];
}

- (void)_stopTimer{
    if (timer) {
        [timer invalidate];
    }
    timer = nil;
}

- (void)_startTimer{
    [self _stopTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:_time target:self selector:@selector(nextPage) userInfo:nil repeats:YES] ;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)nextPage{
    CGPoint offset = collectionView.contentOffset;
    offset.x += kScreenWWidth;
    [collectionView setContentOffset:offset animated:YES];
}

- (void)resetOffset{
    NSInteger page = collectionView.contentOffset.x/kScreenWWidth;
    if (page == 0) {//滚动到左边
        collectionView.contentOffset = CGPointMake(kScreenWWidth * (_images.count - 2), 0);
    }else if (page == _images.count - 1){//滚动到右边
        collectionView.contentOffset = CGPointMake(kScreenWWidth, 0);
    }
    
    currentIndex = (int) collectionView.contentOffset.x/kScreenWWidth;
    NSLog(@"第几张 %zd",currentIndex);
    pageControl.currentPage = currentIndex-1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.image = [UIImage imageNamed:_images[indexPath.row]];
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

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}

@end
