//
//  HYGraditentProgressView.m
//  HYProgressBar
//
//  Created by 邱弘宇 on 2018/11/23.
//  Copyright © 2018 https://github.com/YHQiu. All rights reserved.

#import "HYGradientProgressView.h"

@interface HYGradientProgressView()

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) BOOL animated;

@property (nonatomic, strong) CAGradientLayer *progressLayer;

@end

@implementation HYGradientProgressView

- (instancetype)init{
    if (self = [super init]) {
        [self initLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initLayer];
    }
    return self;
}

- (void)initLayer{
    //[self.layer addSublayer:self.progressLayer];
}

- (void)drawRect:(CGRect)rect{
    if (self.progressLayer.superlayer == nil) {
       [self.layer addSublayer:self.progressLayer];
    }
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    self.progress = MAX(progress,1);
    self.animated = animated;
    /* 不断改变layer颜色的起始位置 */
    self.progressLayer.locations = @[@(0),@(progress)];
    /* 不断改变layer的frame */
    self.progressLayer.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width * progress, 2);
}

#pragma mark - HYProgreessViewDelegate
- (CGFloat)startProgress{
    return 0;
}
- (CGFloat)hy_progress{
    return self.progress;
}

- (void)hy_setProgress:(CGFloat)progress animated:(BOOL)animated{
    [self setProgress:progress animated:animated];
}

#pragma mark - getter
- (UIColor *)progressColor{
    if (_progressColor) {
        return _progressColor;
    }
    _progressColor = [UIColor orangeColor];
    return _progressColor;
}
- (CAGradientLayer *)progressLayer{
    if (_progressLayer) {
        return _progressLayer;
    }
    _progressLayer = [CAGradientLayer layer];
    _progressLayer.cornerRadius = 1;
    CGFloat RGB[3];
    [self getRGBComponents:RGB forColor:self.progressColor];
    _progressLayer.colors = @[(__bridge id)[UIColor colorWithRed:RGB[0] green:RGB[1] blue:RGB[2] alpha:0.3].CGColor, (__bridge id)_progressColor.CGColor];
    _progressLayer.startPoint = CGPointMake(0, 1);
    _progressLayer.endPoint = CGPointMake(1, 1);
    _progressLayer.frame = CGRectMake(0, 0, 0, 2);
    _progressLayer.locations = @[@(0),@(0)];
    
    return _progressLayer;
}

/* 获取颜色的RGB值 */
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    if (!color) {
        components[0] = 1;
        components[1] = 1;
        components[2] = 1;
        return;
    }
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

@end
