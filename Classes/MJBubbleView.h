//
//  MJBubbleView.h
//  MJBubbleView
//
//  Created by 刘鹏 on 2018/4/26.
//  Copyright © 2018年 musjoy. All rights reserved.
//  由下向上不停的冒泡泡

#import <UIKit/UIKit.h>

@interface MJBubbleView : UIView
/// 开始冒泡
- (void)startAnimation;
/// 停止冒泡
- (void)stopAnimation;
@end
