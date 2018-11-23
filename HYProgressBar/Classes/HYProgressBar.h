//
//  HYProgressBar.h
//  HYProgressBar_Tests
//
//  Created by 邱弘宇 on 2018/11/22.
//  Copyright © 2018 https://github.com/YHQiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HYProgreessViewDelegate <NSObject>

@required
/**-------------------
 If you cutom your progress view,you could not ignored that is confirm this protocol,and impletation the two methods.
 ---------------------*/

/**
 Change pregress value for your progress view;
 */
- (void)hy_setProgress:(CGFloat)progress animated:(BOOL)animated;

/**
 The current progress value by your progress view;
 */
- (CGFloat)hy_progress;

@optional
/**
 A progress value when startting;
 */
- (CGFloat)startProgress;

/**
 If the html page not immediately responded,delayTime=10s and progress to 1;
 */
- (CGFloat)delayTime;

@end

@interface HYProgressBar : NSObject

/**
 This is a placeholder progress View,and extends for UIProgressView.So you can use [progressView valueForKey:@""] with UIPorgressView properts customming it;
 */
@property (nonatomic, strong) UIView<HYProgreessViewDelegate> *progressView;

/**
 Use a custom progress view init;
 */
- (instancetype)initWithProgressView:(UIView<HYProgreessViewDelegate> *)progressView;

/**
 You can use a WKWebView as a onListened;
 The UIWebView have some issue,so I will add support for it by later.
 */
- (void)setProgressListen:(id)onListened;

@end
