//
//  MJBubbleView.m
//  MJBubbleView
//
//  Created by 刘鹏 on 2018/4/26.
//  Copyright © 2018年 musjoy. All rights reserved.
//

#import "MJBubbleView.h"

@interface MJBubbleView ()
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation MJBubbleView
#pragma mark - Life Circle
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Private
/// 创建定时器
- (void)createTimer {
    //设置时间间隔
    NSTimeInterval period = 0.6;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, period * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //回到主线程做事情
            [self createBubble];
        });
    });
}

/// 创建泡泡
- (void)createBubble {
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_bubble"]];
    CGFloat width = [self randomFloatBetween:10 and:25];
    NSInteger x = arc4random() % (NSInteger)self.frame.size.width;
    
    CGFloat height = self.frame.size.height;
    NSInteger y = [self randomFloatBetween:height * 0.9 and:height];
    
    bubbleImageView.frame = CGRectMake(x, y, width, width);
    bubbleImageView.alpha = [self randomFloatBetween:0.2 and:0.8];
    [self addSubview:bubbleImageView];
    
    UIBezierPath *zigzagPath = [[UIBezierPath alloc] init];
    CGFloat oX = bubbleImageView.center.x;
    CGFloat oY = bubbleImageView.center.y;
    CGFloat eX = oX;
    CGFloat eY = [self randomFloatBetween:0 and:oY];
    CGFloat t = [self randomFloatBetween:10 and:30];
    
    CGPoint cp1 = CGPointMake(oX - t, ((oY + eY) / 2));
    CGPoint cp2 = CGPointMake(oX + t, cp1.y);
    
    // randomly switch up the control points so that the bubble
    // swings right or left at random
    NSInteger r = arc4random() % 2;
    if (r == 1) {
        CGPoint temp = cp1;
        cp1 = cp2;
        cp2 = temp;
    }
    
    // the moveToPoint method sets the starting point of the line
    [zigzagPath moveToPoint:CGPointMake(oX, oY)];
    // add the end point and the control points
    [zigzagPath addCurveToPoint:CGPointMake(eX, eY) controlPoint1:cp1 controlPoint2:cp2];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        // transform the image to be 1.3 sizes larger to
        // give the impression that it is popping
        [UIView transitionWithView:bubbleImageView
                          duration:0.1f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            bubbleImageView.transform = CGAffineTransformMakeScale(1.4, 1.4);
                        } completion:^(BOOL finished) {
                            [bubbleImageView removeFromSuperview];
                        }];
    }];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.duration = 2;
    pathAnimation.path = zigzagPath.CGPath;
    // remains visible in it's final state when animation is finished
    // in conjunction with removedOnCompletion
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    
    [bubbleImageView.layer addAnimation:pathAnimation forKey:@"movingAnimation"];
    
    [CATransaction commit];
}

- (CGFloat)randomFloatBetween:(CGFloat)smallNumber and:(CGFloat)bigNumber {
    CGFloat diff = bigNumber - smallNumber;
    return (((CGFloat) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

#pragma mark - Public
/// 开始冒泡
- (void)startAnimation {
    if (_timer == nil) {
        // 开始
        [self createTimer];
        dispatch_resume(_timer);
    }
}

/// 停止冒泡
- (void)stopAnimation {
    if (_timer) {
        // 取消定时器
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}
@end
