//
//  LYPayPasswordView.m
//  LYMail
//
//  Created by drision on 2016/11/8.
//  Copyright © 2016年 Drision. All rights reserved.
//

#import "LYPayPasswordView.h"

static NSString  * const MONEYNUMBERS = @"0123456789";

@interface LYPayPasswordView ()<UIKeyInput>

@property (strong, nonatomic) UIButton *doneInKeyboardButton;

@end

@implementation LYPayPasswordView

@synthesize doneInKeyboardButton;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private
- (void)initData {
    self.backgroundColor = [UIColor whiteColor];
    _textStore = [NSMutableString string];
    self.passWordNum = 6;
    self.rectColor = [UIColor blackColor];
    self.pointColor = [UIColor blackColor];
    self.radius = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboarWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboarWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//初始化，数字键盘“完成”按钮
- (void)configDoneInKeyBoardButton {
    //初始化
    if (doneInKeyboardButton == nil) {
        doneInKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneInKeyboardButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneInKeyboardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        doneInKeyboardButton.adjustsImageWhenHighlighted = NO;
        [doneInKeyboardButton addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    //每次必须从新设定“完成”按钮的初始化坐标位置
    doneInKeyboardButton.frame = CGRectMake(0, screenHeight, screenWidth / 3, 53);
    
    //由于ios8下，键盘所在的window视图还没有初始化完成，调用在下一次 runloop 下获得键盘所在的window视图
    [self performSelector:@selector(addDoneButton) withObject:nil afterDelay:0.0f];
    
}

- (void) addDoneButton{
    //获得键盘所在的window视图
    
    UIWindow* keyWindow = [[[UIApplication sharedApplication] windows] lastObject];
    if (!doneInKeyboardButton.superview)
    [keyWindow addSubview:doneInKeyboardButton];	// 注意这里直接加到window上
}

#pragma mark - NSNotification
- (void)keyboarWillShow:(NSNotification *)notification {
    [self configDoneInKeyBoardButton];
    NSDictionary *userInfo = notification.userInfo;
    // UIKeyboardAnimationDurationUserInfoKey 对应键盘弹出的动画时间
    CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (self.keyBoardShowEvent) self.keyBoardShowEvent(animationDuration, keyboardHeight);
    // UIKeyboardAnimationCurveUserInfoKey 对应键盘弹出的动画类型
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    //数字彩,数字键盘添加“完成”按钮
    if (doneInKeyboardButton){
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];//设置添加按钮的动画时间
        [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];//设置添加按钮的动画类型
        
        //设置自定制按钮的添加位置(这里为数字键盘添加“完成”按钮)
        doneInKeyboardButton.transform=CGAffineTransformTranslate(doneInKeyboardButton.transform, 0, -53);
        
        [UIView commitAnimations];
    }
}

- (void)keyboarWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    // UIKeyboardAnimationDurationUserInfoKey 对应键盘收起的动画时间
    CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (self.keyBoardHideEvent) self.keyBoardHideEvent(animationDuration);
    
    if (doneInKeyboardButton.superview) {
        [UIView animateWithDuration:animationDuration animations:^{
            //动画内容，将自定制按钮移回初始位置
            doneInKeyboardButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            //动画结束后移除自定制的按钮
            [doneInKeyboardButton removeFromSuperview];
        }];
        
    }
}

#pragma mark - IBAction
- (void)finishAction {
    [self resignFirstResponder];
}

#pragma mark - UIKeyInput
/**
 *  用于显示的文本对象是否有任何文本
 */
- (BOOL)hasText {
    return self.textStore.length > 0;
}

/**
 *  插入文本
 */
- (void)insertText:(NSString *)text {
    if (self.textStore.length < self.passWordNum) {
        //判断是否是数字
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:MONEYNUMBERS] invertedSet];
        NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL basicTest = [text isEqualToString:filtered];
        if(basicTest) {
            [self.textStore appendString:text];
            [self setNeedsDisplay];
        }
    }
}

/**
 *  删除文本
 */
- (void)deleteBackward {
    if (self.textStore.length > 0) {
        [self.textStore deleteCharactersInRange:NSMakeRange(self.textStore.length - 1, 1)];
    }
    [self setNeedsDisplay];
}

/**
 *  是否能成为第一响应者
 */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

/**
 *  点击成为第一相应者
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

/**
 *  设置键盘的类型
 */
- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

/**
 *  绘制
 */
- (void)drawRect:(CGRect)rect {
    CGFloat squareWidth = rect.size.width / self.passWordNum;
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    CGFloat x = (width - squareWidth*self.passWordNum)/2.0;
    CGFloat y = (height - squareWidth)/2.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画外框
    CGContextAddRect(context, CGRectMake( x, y, squareWidth*self.passWordNum, squareWidth));
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, self.rectColor.CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    //画竖条
    for (int i = 1; i <= self.passWordNum; i++) {
        CGContextMoveToPoint(context, x+i*squareWidth, y);
        CGContextAddLineToPoint(context, x+i*squareWidth, y+squareWidth);
        CGContextClosePath(context);
    }
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
    //画黑点
    for (int i = 1; i <= self.textStore.length; i++) {
        CGContextAddArc(context,  x+i*squareWidth - squareWidth/2.0, y+squareWidth/2, self.radius, 0, M_PI*2, YES);
        CGContextDrawPath(context, kCGPathFill);
    }
}

#pragma mark - set
/**
 *  设置密码的位数
 */
- (void)setPassWordNum:(NSUInteger)passWordNum {
    _passWordNum = passWordNum;
    [self setNeedsDisplay];
}

- (void)setRectColor:(UIColor *)rectColor {
    _rectColor = rectColor;
    [self setNeedsDisplay];
}

- (void)setPointColor:(UIColor *)pointColor {
    _pointColor = pointColor;
    [self setNeedsDisplay];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self setNeedsDisplay];
}


@end
