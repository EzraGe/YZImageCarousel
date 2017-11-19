//
//  ViewController.m
//  YZImageCarousel
//
//  Created by 戈宇泽 on 2017/11/19.
//  Copyright © 2017年 戈宇泽. All rights reserved.
//

#import "ViewController.h"
#import "YZImageCarousel.h"
#import <Masonry/Masonry.h>

@interface ViewController ()
@property (nonatomic, strong) YZImageCarousel *imageCarousel;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSArray<NSString *> *imageUrls = @[@"http://p3.music.126.net/s25q2x5QyqsAzilCurD-2w==/7973658325212564.jpg",
									   @"http://p4.music.126.net/V9-MXz6b2MNhEKjutoDWIg==/7937374441542745.jpg",
									   @"http://p4.music.126.net/CTU5B9R9y3XyYBZXJUXzTg==/2897213141428023.jpg",
									   @"http://p4.music.126.net/tGPljf-IMOCyPvumoWLOTg==/7987951976374270.jpg",
									   @"http://p4.music.126.net/mp2Y2n4ueZzIj6JSnUOdtw==/7875801790676538.jpg",
									   @"http://p3.music.126.net/e0gGadEhjur2UuUpDF9hPg==/7788940372125389.jpg"];
	
	self.imageCarousel = [YZImageCarousel imageCarouselWithDataURLs:imageUrls
															  frame:CGRectZero
														 clickBlock:^(NSUInteger index) {
															 NSLog(@"You clicked picture %@", @(index));
														 }];
	[self.view addSubview:self.imageCarousel];
	[self.imageCarousel mas_remakeConstraints:^(MASConstraintMaker *make) {
		make.left.right.equalTo(self.view);
		make.top.equalTo(self.view).offset(120.0f);
		make.height.equalTo(@138.0f);
	}];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
