//
//  LYPayPasswordView.h
//  LYMail
//
//  Created by drision on 2016/11/8.
//  Copyright © 2016年 Drision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYPayPasswordView : UIView

@property (nonatomic, strong, readonly) NSMutableString *textStore;

@property (nonatomic, assign) NSUInteger passWordNum;
@property (nonatomic, strong) UIColor *rectColor;
@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, copy) void (^keyBoardShowEvent)(CGFloat duration, CGFloat keyboardHeight);
@property (nonatomic, copy) void (^keyBoardHideEvent)(CGFloat duration);

@end
