//
//  YZImageCarousel.m
//  YZImageCarousel
//
//  Created by 戈宇泽 on 2017/11/19.
//  Copyright © 2017年 戈宇泽. All rights reserved.
//

#import "YZImageCarousel.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <KVOController/KVOController.h>
#import <YYCategories/YYCategories.h>

#define MAXSCROLLABLEPOINT CGPointMake(self.scrollview.contentSize.width,0)

@interface YZImageCarousel()<UIScrollViewDelegate>
@property (nonatomic, copy) NSArray<UIImage *> *imageDatas;
@property (nonatomic, copy) NSArray<NSString *> *imageDataURLs;
@property (nonatomic, copy) void(^clickBlock)(NSUInteger index);

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageviews;
@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation YZImageCarousel
+ (instancetype)imageCarouselWithDatas:(NSArray<UIImage *> *)imageDatas
								 frame:(CGRect)frame
							clickBlock:(void (^)(NSUInteger))clickBlock {
	if (imageDatas.count > 0) {
		return [[self alloc] initWithImageDatas:imageDatas frame:frame clickBlock:clickBlock];
	} else {
		return [[YZImageCarousel alloc] initWithFrame:frame];
	}
}

+ (instancetype)imageCarouselWithDataURLs:(NSArray<NSString *> *)imageDataURLs frame:(CGRect)frame clickBlock:(void (^)(NSUInteger))clickBlock {
	if (imageDataURLs.count > 0) {
		return [[self alloc] initWithImageDataURLs:imageDataURLs frame:frame clickBlock:clickBlock];
	} else {
		return [[YZImageCarousel alloc] initWithFrame:frame];
	}
}

- (instancetype)initWithImageDatas:(NSArray<UIImage *> *)imageDatas
							 frame:(CGRect)frame
						clickBlock:(void (^)(NSUInteger))clickBlock {
	if (self = [super initWithFrame:frame]) {
		self.clickBlock = clickBlock;
		[self refreshWithImageDatas:imageDatas];
	}
	return self;
}

- (instancetype)initWithImageDataURLs:(NSArray<NSString *> *)imageDataURLs
								frame:(CGRect)frame
						   clickBlock:(void (^)(NSUInteger))clickBlock {
	if (self = [super initWithFrame:frame]) {
		self.clickBlock = clickBlock;
		[self refreshWithImageDataURLs:imageDataURLs];
	}
	return self;
}

- (void)refreshWithImageDatas:(NSArray<UIImage *> *)imageDatas {
	self.imageDatas = imageDatas;
	for (UIView *subview in self.scrollview.subviews) {
		[subview removeFromSuperview];
	}
	[self resetContentWithImages:imageDatas];
	[self setupPageControlWithCount:imageDatas.count];
}

- (void)refreshWithImageDataURLs:(NSArray<NSString *> *)imageDataURLs {
	self.imageDataURLs = imageDataURLs;
	for (UIView *subview in self.scrollview.subviews) {
		[subview removeFromSuperview];
	}
	[self resetContentWithImages:imageDataURLs];
	[self setupPageControlWithCount:imageDataURLs.count];
}

#pragma mark - access method

- (UIScrollView *)scrollview {
	if (!_scrollview) {
		_scrollview = [UIScrollView new];
		_scrollview.contentSize = CGSizeZero;
		_scrollview.contentOffset = CGPointZero;
		_scrollview.showsHorizontalScrollIndicator = NO;
		_scrollview.pagingEnabled = YES;
		_scrollview.bounces = NO;
		_scrollview.delegate = self;
		[self addSubview:_scrollview];
		[_scrollview mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self);
		}];
	}
	return _scrollview;
}

- (UIPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [UIPageControl new];
		[self addSubview:_pageControl];
		[_pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.left.right.equalTo(self);
			make.top.equalTo(self.mas_bottom).offset(-30.0f);
			make.height.equalTo(@20.0f);
		}];
	}
	return _pageControl;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self stopAutoDisplaying];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGPoint contentOffset = self.scrollview.contentOffset;
	if (contentOffset.x == MAXSCROLLABLEPOINT.x-SCREEN_WIDTH) {
		[self.scrollview setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
	} else if(contentOffset.x == 0) {
		[self.scrollview setContentOffset:CGPointMake(self.scrollview.contentSize.width-2*SCREEN_WIDTH, 0)];
	}
	[self startAutoDisplaying];
}

#pragma mark - private

- (void)startAutoDisplaying {
	self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(moveToNext) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopAutoDisplaying {
	[self.timer invalidate];
	self.timer = nil;
}

- (void)moveToNext {
	CGPoint contentOffset = self.scrollview.contentOffset;
	[UIView animateKeyframesWithDuration:0.5f delay:0.0f options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
		if(contentOffset.x <= MAXSCROLLABLEPOINT.x - SCREEN_WIDTH) {
			[self.scrollview setContentOffset:CGPointMake(contentOffset.x+SCREEN_WIDTH, contentOffset.y)];
		}
	} completion:^(BOOL finished) {
		if (contentOffset.x == MAXSCROLLABLEPOINT.x-2*SCREEN_WIDTH) {
			[self.scrollview setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
		}
	}];
}

- (void)setupPageControlWithCount:(NSUInteger)count {
	self.pageControl.numberOfPages = count;
	self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
	self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
	
	__weak typeof(self) weakSelf = self;
	[self.pageControl.KVOController observe:self.scrollview keyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
		__strong typeof(weakSelf) self = weakSelf;
		if (self.scrollview.contentSize.width >= 2*SCREEN_WIDTH) {
			CGPoint contentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
			if (contentOffset.x >= 0 && contentOffset.x <0.5*SCREEN_WIDTH) {
				self.pageControl.currentPage = count-1;
			} else if (contentOffset.x >= 0.5*SCREEN_WIDTH &&
					   contentOffset.x < MAXSCROLLABLEPOINT.x - 2*SCREEN_WIDTH) {
				self.pageControl.currentPage = floorf((contentOffset.x+0.5*SCREEN_WIDTH)/SCREEN_WIDTH)-1;
			} else if (contentOffset.x >= MAXSCROLLABLEPOINT.x-2*SCREEN_WIDTH &&
					   contentOffset.x <  MAXSCROLLABLEPOINT.x-SCREEN_WIDTH*1.5) {
				self.pageControl.currentPage = count-1;
			} else {
				self.pageControl.currentPage = 0;
			}
		}
	}];
}

- (void)resetContentWithImages:(NSArray *)images {
	[self stopAutoDisplaying];
	NSUInteger count = images.count;
	
	self.scrollview.contentSize = CGSizeMake(SCREEN_WIDTH * (count + 2), 0);
	self.scrollview.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
	
	CGFloat x = 0;
	for (NSUInteger i=0; i<count+2; i++) {
		NSUInteger index;
		if (0 == i) {
			index = count - 1;
		} else if (count+1 == i) {
			index = 0;
		} else {
			index = i - 1;
		}
		id imageData = [images objectAtIndex:index];
		UIImageView *imageview = nil;
		
		if ([imageData isKindOfClass:[UIImage class]]) {
			imageview = [[UIImageView alloc] initWithImage:imageData];
		} else if([imageData isKindOfClass:[NSString class]]) {
			NSString *url = (NSString *)imageData;
			imageview = [UIImageView new];
			[imageview sd_setImageWithURL:[NSURL URLWithString:url]];
		} else {
			imageview = [UIImageView new];
		}
		
		imageview.userInteractionEnabled = YES;
		__weak typeof(self) weakSelf = self;
		[imageview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
			__strong typeof(weakSelf) self = weakSelf;
			if (self.clickBlock) {
				self.clickBlock(index);
			}
		}]];
		[self.scrollview addSubview:imageview];
		[imageview mas_remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.scrollview).offset(x);
			make.width.equalTo(self.scrollview);
			make.top.equalTo(self.scrollview);
			make.height.equalTo(self.scrollview);
		}];
		x += SCREEN_WIDTH;
	}
	
	[self startAutoDisplaying];
}

@end
