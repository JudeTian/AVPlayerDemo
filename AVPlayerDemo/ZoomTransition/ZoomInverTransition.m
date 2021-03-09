//
//  ZoomInverTransition.m
//  AVPlayerDemo
//
//  Created by tl on 2018/5/14.
//  Copyright © 2018年 tl. All rights reserved.
//

#import "ZoomInverTransition.h"
#import "RootViewController.h"
#import "AVPlayerViewController.h"

@interface ZoomInverTransition()

@property(nonatomic,strong)id<UIViewControllerContextTransitioning>transitionContext;

@end
@implementation ZoomInverTransition
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    
    self.transitionContext = transitionContext;
    
    AVPlayerViewController *fromVC = (AVPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    RootViewController *toVC   = (RootViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    UIButton *button = toVC.button;
    
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];
    
    
    UIBezierPath *finalPath = [UIBezierPath bezierPathWithRect:button.frame];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;  // 获取屏幕的宽度
    CGFloat height = [UIScreen mainScreen].bounds.size.height;  // 获取屏幕的高度
    UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = finalPath.CGPath;
    fromVC.view.layer.mask = maskLayer;
    
    
    CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    zoomAnimation.fromValue = (__bridge id)(startPath.CGPath);
    zoomAnimation.toValue   = (__bridge id)(finalPath.CGPath);
    zoomAnimation.duration = [self transitionDuration:transitionContext];
    zoomAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    zoomAnimation.delegate = self;
    
    [maskLayer addAnimation:zoomAnimation forKey:@"ZoomInvert"];
    
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
    
}
@end
