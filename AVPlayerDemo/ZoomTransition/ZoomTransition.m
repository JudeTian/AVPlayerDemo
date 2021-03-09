//
//  ZoomTransition.m
//  AVPlayer
//
//  Created by tl on 2018/5/14.
//  Copyright © 2018年 cmjstudio. All rights reserved.
//

#import "ZoomTransition.h"
#import "RootViewController.h"
#import "AVPlayerViewController.h"

@interface ZoomTransition ()
@property (nonatomic,strong)id<UIViewControllerContextTransitioning> transitionContext;

@end
@implementation ZoomTransition


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return  0.4f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    self.transitionContext = transitionContext;
    
    RootViewController * fromVC = (RootViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    AVPlayerViewController *toVC = (AVPlayerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *contView = [transitionContext containerView];
    
    UIButton *button = fromVC.button;
    
    UIBezierPath *maskStartBP =  [UIBezierPath bezierPathWithRect:button.frame];
    
    [contView addSubview:fromVC.view];
    [contView addSubview:toVC.view];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;  // 获取屏幕的宽度
    CGFloat height = [UIScreen mainScreen].bounds.size.height;  // 获取屏幕的高度

    
    UIBezierPath *maskEndBP = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
    //线条拐角
    maskEndBP.lineCapStyle = kCGLineCapRound;
    //终点处理
    maskEndBP.lineJoinStyle = kCGLineJoinRound;
    [maskEndBP stroke];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path =  maskEndBP.CGPath;
    toVC.view.layer.mask = maskLayer;
    
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(maskStartBP.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((maskEndBP.CGPath));
    maskLayerAnimation.duration = [self transitionDuration:transitionContext];
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    maskLayerAnimation.delegate = self;
    
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    
}


- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished{
    [self.transitionContext completeTransition:![self. transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
}
#pragma mark - CABasicAnimation的Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.transitionContext completeTransition:![self. transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
    
}


@end
