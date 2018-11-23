//
//  HYProgressBar.m
//  RJSCore
//
//  Created by 邱弘宇 on 2018/3/22.
//  Copyright © 2018年 https://github.com/YHQiu. All rights reserved.
//

#import <objc/runtime.h>
#import "HYProgressBar.h"
#import <WebKit/WebKit.h>

@interface HYProgressView : UIProgressView<HYProgreessViewDelegate>

@end

@implementation HYProgressView

- (instancetype)init{
    if (self = [super init]) {
        self.progressTintColor = [UIColor orangeColor];
        self.trackImage = nil;
        self.trackTintColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - HYProgressDelegate Required
- (void)hy_setProgress:(CGFloat)progress animated:(BOOL)animated{
    [self setProgress:progress animated:animated];
}
- (CGFloat)hy_progress{
    return self.progress;
}

#pragma mark - HYProgressDelegate Opitional
- (CGFloat)startProgress{
    return 0;
}
- (CGFloat)delayTime{
    return 10;
}

@end

@interface HYProgressBar()

@end

@implementation HYProgressBar

- (instancetype)initWithProgressView:(UIView<HYProgreessViewDelegate> *)progressView{
    if (self = [super init]) {
        self.progressView = progressView;
        [self configUI];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        
        [self configUI];
        
    }
    return self;
}

- (void)configUI{
    
    if (self.progressView == nil) {
        self.progressView = [[HYProgressView alloc]init];
    }
    
    self.progressView.backgroundColor = [UIColor clearColor];
    
    self.progressView.frame = CGRectMake(0, 0, 0, 2);
    self.progressView.layer.cornerRadius = 0.5f;
    self.progressView.layer.masksToBounds = YES;
}

- (void)setProgressListen:(id)onListened{
    //此处用策略模式实现
    if ([onListened respondsToSelector:@selector(prepareListenSelf:)]) {
        [onListened performSelector:@selector(prepareListenSelf:) withObject:self.progressView afterDelay:0];
    }
}

@end

@protocol HYProgressBarKVOHelperDelegate<NSObject>

- (void)kvohelper_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;

@end

@interface HYProgressBarKVOHelper : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *observeKeyPathArr;

@property (nonatomic, unsafe_unretained) id<HYProgressBarKVOHelperDelegate> delegate;

@property (nonatomic, unsafe_unretained) id target;

@end

@implementation HYProgressBarKVOHelper

- (instancetype)init{
    if (self = [super init]) {
        self.observeKeyPathArr = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc{
    for (NSString *observeKeyPath in self.observeKeyPathArr) {
        if (self.target) {
            [self.target removeObserver:self forKeyPath:observeKeyPath];
        }
    }
}

- (void)kvohelper_observerAddTarget:(NSObject *)target forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context{
    self.target = target;
    if (keyPath) {
        BOOL isHave = NO;
        for (NSString *_keyPath in self.observeKeyPathArr) {
            if ([_keyPath isEqualToString:keyPath]) {
                isHave = YES;
                break;
            }
        }
        if (!isHave) {
            [self.observeKeyPathArr addObject:keyPath];
            [target addObserver:self forKeyPath:keyPath options:options context:context];
            
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (self.delegate && [self.delegate respondsToSelector:@selector(kvohelper_observeValueForKeyPath:ofObject:change:context:)]) {
        [self.delegate kvohelper_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 进行检索获取Key
- (BOOL)observerKeyPath:(NSString *)key
{
    id info = self.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array) {
        id Properties = [objc valueForKeyPath:@"_property"];
        NSString *keyPath = [Properties valueForKeyPath:@"_keyPath"];
        if ([key isEqualToString:keyPath]) {
            return YES;
        }
    }
    return NO;
}

@end

@interface UIWebView(ListerSelf)<HYProgressBarKVOHelperDelegate>

- (void)prepareListenSelf:(UIView<HYProgreessViewDelegate> *)progressView;

@property (nonatomic, weak) UIView<HYProgreessViewDelegate> *weakProgressView;

@property (nonatomic, strong) HYProgressBarKVOHelper *target;

@end

static char *rjs_weakProgressViewKeyForUIWeb;
static char *rjs_weakKVOHelperKeyForUIWeb;
@implementation UIWebView(ListerSelf)
@dynamic weakProgressView,target;

- (void)setWeakProgressView:(UIView<HYProgreessViewDelegate> *)weakProgressView{
    objc_setAssociatedObject(self, &rjs_weakProgressViewKeyForUIWeb, weakProgressView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView<HYProgreessViewDelegate> *)weakProgressView{
    return objc_getAssociatedObject(self, &rjs_weakProgressViewKeyForUIWeb);
}

- (void)setTarget:(HYProgressBarKVOHelper *)target{
    objc_setAssociatedObject(self, &rjs_weakKVOHelperKeyForUIWeb, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HYProgressBarKVOHelper *)target{
    return objc_getAssociatedObject(self, &rjs_weakKVOHelperKeyForUIWeb);
}

- (void)prepareListenSelf:(UIView<HYProgreessViewDelegate> *)progressView{
    
    //Test
//    unsigned int count = 0;
//    objc_property_t *propertys = class_copyPropertyList([self class], &count);
//    for (int i = 0; i < count; i++) {
//        objc_property_t property = propertys[i];
//        NSString *propertyName = @(property_getName(property));
//        NSLog(@"\nUIWebViewPropertyName:%@",propertyName);
//    }
    
    if (!self.weakProgressView) {
        if (self.target == nil) {
            self.target = [HYProgressBarKVOHelper new];
            self.target.delegate = self;
            [self.target kvohelper_observerAddTarget:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
        }
        self.weakProgressView = progressView;
    }
    
    if (self.weakProgressView) {
        [self.weakProgressView removeFromSuperview];
        [self addSubview:self.weakProgressView];
        self.weakProgressView.frame = CGRectMake(0, 0, self.bounds.size.width, progressView.frame.size.height);
    }
    
    [self.weakProgressView hy_setProgress:0.25f animated:YES];
    
}

- (void)kvohelper_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"loading"] && self.weakProgressView) {
        BOOL isLoading = [[object valueForKey:@"loading"] boolValue];
        if (isLoading) {
            [self.weakProgressView hy_setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.weakProgressView.hidden = YES;
            });
        }
        else{
            [self.weakProgressView hy_setProgress:0.0 animated:NO];
            self.weakProgressView.hidden = NO;
        }
    }
}

@end

@interface WKWebView(ListerSelf)

- (void)prepareListenSelf:(UIView<HYProgreessViewDelegate> *)progressView;

@property (nonatomic, weak) UIView<HYProgreessViewDelegate> *weakProgressView;

@property (nonatomic, strong) HYProgressBarKVOHelper *target;

@property (nonatomic, weak) NSTimer *delayHideTimer;

@end

static char *rjs_weakProgressViewKeyForWKWeb;
static char *rjs_weakKVOHelperKeyForWKWeb;
static char *rjs_weakDelayHiderTimerForWKWeb;
@implementation WKWebView(ListerSelf)

@dynamic weakProgressView,target,delayHideTimer;
- (void)setWeakProgressView:(UIView<HYProgreessViewDelegate> *)weakProgressView{
    objc_setAssociatedObject(self, &rjs_weakProgressViewKeyForWKWeb, weakProgressView, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView<HYProgreessViewDelegate> *)weakProgressView{
    return objc_getAssociatedObject(self, &rjs_weakProgressViewKeyForWKWeb);
}

- (void)setTarget:(HYProgressBarKVOHelper *)target{
    objc_setAssociatedObject(self, &rjs_weakKVOHelperKeyForWKWeb, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HYProgressBarKVOHelper *)target{
    return objc_getAssociatedObject(self, &rjs_weakKVOHelperKeyForWKWeb);
}

- (void)setDelayHideTimer:(NSTimer *)delayHideTimer{
    objc_setAssociatedObject(self, &rjs_weakDelayHiderTimerForWKWeb, delayHideTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)delayHideTimer{
    return objc_getAssociatedObject(self, &rjs_weakDelayHiderTimerForWKWeb);
}

- (void)prepareListenSelf:(UIView<HYProgreessViewDelegate> *)progressView{
    
    if (self.weakProgressView == nil) {
        if (self.target == nil) {
            self.target = [HYProgressBarKVOHelper new];
            __weak typeof(self) weakSelf = self;
            self.target.delegate = weakSelf;
            [self.target kvohelper_observerAddTarget:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            [self.target kvohelper_observerAddTarget:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        }
        self.weakProgressView = progressView;
    }
    
    if (self.weakProgressView) {
        [self.weakProgressView removeFromSuperview];
        [self addSubview:self.weakProgressView];
        self.weakProgressView.frame = CGRectMake(0, 0, self.bounds.size.width, progressView.frame.size.height);
    }
    CGFloat startProgress = 0.15;
    if ([progressView respondsToSelector:@selector(startProgress)]) {
        startProgress = [progressView startProgress];
    }
    [progressView hy_setProgress:startProgress animated:YES];
    
}

- (void)kvohelper_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]&&self.weakProgressView) {
        CGFloat estimatedProgress = [[object valueForKey:@"estimatedProgress"] floatValue];
        if (estimatedProgress < [self.weakProgressView hy_progress]) {
            self.weakProgressView.hidden = YES;
            [self.weakProgressView hy_setProgress:estimatedProgress animated:NO];
            self.weakProgressView.hidden = NO;
        }
        else{
            [self.weakProgressView hy_setProgress:estimatedProgress animated:YES];
        }

        if (estimatedProgress == 1) {
            [self invalidateDelayHideTimer];
            [self delayHideProgressView];
        }
        else{
            self.weakProgressView.hidden = NO;
        }
        
    }
    else if ([keyPath isEqualToString:@"loading"]&&self.weakProgressView){
        BOOL loading = [[object valueForKey:@"loading"] boolValue];
        if (loading == NO) {
            [self delayHideProgressView];
        }
        else{
            self.weakProgressView.hidden = NO;
            [self startHideProgressViewTimer];
        }
    }
    
}

- (void)invalidateDelayHideTimer{
    if (self.delayHideTimer) {
        [self.delayHideTimer invalidate];
    }
}

- (void)delayHideProgressView{
    [self.weakProgressView hy_setProgress:1 animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.weakProgressView.hidden = YES;
        CGFloat startProgress = 0.15;
        if ([self.weakProgressView respondsToSelector:@selector(startProgress)]) {
            startProgress = [self.weakProgressView startProgress];
        }
        [self.weakProgressView hy_setProgress:startProgress animated:NO];
    });
}

- (void)startHideProgressViewTimer{
    
    [self invalidateDelayHideTimer];
    CGFloat delayTime = 10;
    if ([self.weakProgressView respondsToSelector:@selector(delayTime)]) {
        delayTime = [self.weakProgressView delayTime];
    }
    self.delayHideTimer = [NSTimer scheduledTimerWithTimeInterval:delayTime target:self selector:@selector(delayHideProgressView) userInfo:nil repeats:NO];
    
}

@end
