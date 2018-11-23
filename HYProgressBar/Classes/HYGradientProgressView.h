//
//  HYGraditentProgressView.h
//  HYProgressBar
//
//  Created by 邱弘宇 on 2018/11/23.
//  Copyright © 2018 https://github.com/YHQiu. All rights reserved.

#import <UIKit/UIKit.h>
#import "HYProgressBar.h"

@interface HYGradientProgressView : UIView<HYProgreessViewDelegate>

@property (nonatomic, strong) UIColor *progressColor;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
