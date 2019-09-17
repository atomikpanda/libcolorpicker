//
//  NUColor.h
//  Nucleus
//
//  Created by Bailey Seymour on 3/18/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface UIColor (PFColor)
+ (UIColor *)PF_colorWithHex:(NSString *)hexString;
+ (NSString *)hexFromColor:(UIColor *)color;
- (NSString *)hexFromColor;
@property (nonatomic, assign, readonly) CGFloat alpha;
@property (nonatomic, assign, readonly) CGFloat red;
@property (nonatomic, assign, readonly) CGFloat green;
@property (nonatomic, assign, readonly) CGFloat blue;
@property (nonatomic, assign, readonly) CGFloat hue;
@property (nonatomic, assign, readonly) CGFloat saturation;
@property (nonatomic, assign, readonly) CGFloat brightness;
- (UIColor *)desaturate:(CGFloat)percent;
- (UIColor *)lighten:(CGFloat)percent;
- (UIColor *)darken:(CGFloat)percent;
@end
#endif
