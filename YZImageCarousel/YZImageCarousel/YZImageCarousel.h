//
//  YZImageCarousel.h
//  YZImageCarousel
//
//  Created by 戈宇泽 on 2017/11/19.
//  Copyright © 2017年 戈宇泽. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

@interface YZImageCarousel : UIView
@property (nonatomic, copy, readonly) NSArray<UIImage *> *imageDatas;
@property (nonatomic, copy, readonly) NSArray<NSString *> *imageDataURLs;

+ (instancetype)imageCarouselWithDatas:(NSArray<UIImage *> *)imageDatas frame:(CGRect)frame clickBlock:(void(^)(NSUInteger index))clickBlock;
+ (instancetype)imageCarouselWithDataURLs:(NSArray<NSString *> *)imageDataURLs frame:(CGRect)frame clickBlock:(void(^)(NSUInteger index))clickBlock;

- (void)refreshWithImageDatas:(NSArray<UIImage *> *)imageDatas;
- (void)refreshWithImageDataURLs:(NSArray<NSString *> *)imageDataURLs;
@end
