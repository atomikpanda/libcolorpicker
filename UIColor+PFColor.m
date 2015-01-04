//
//  NUColor.m
//  Nucleus
//
//  Created by Bailey Seymour on 3/18/14.
//  Copyright (c) 2014 Bailey Seymour. All rights reserved.
//

#import "UIColor+PFColor.h"

#ifdef __cplusplus /* If this is a C++ compiler, use C linkage */
extern "C" {
#endif
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);
UIColor *colorFromHex(NSString *hexString);
#ifdef __cplusplus /* If this is a C++ compiler, end C linkage */
}
#endif


@implementation UIColor (PFColor)

+ (UIColor*)PF_colorWithHex:(NSString*)hexString {
    // unsigned rgbValue = 0;
    // NSScanner *scanner = [NSScanner scannerWithString:hexString];
    // [scanner setScanLocation:1]; // bypass '#' character
    // [scanner scanHexInt:&rgbValue];
    // return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    return colorFromHex(hexString);
}

+ (NSString*)hexFromColor:(UIColor*)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255),  (int)(g * 255), (int)(b * 255)]; return hexString;
}

#pragma mark Components
- (CGFloat)alpha {
    CGFloat a;
    [self getWhite:NULL alpha:&a];
    return a;
}

- (CGFloat)red {
    CGFloat r;
    [self getRed:&r green:NULL blue:NULL alpha:NULL];
    return r;
}

- (CGFloat)green {
    CGFloat g;
    [self getRed:NULL green:&g blue:NULL alpha:NULL];
    return g;
}


- (CGFloat)blue {
    CGFloat b;
    [self getRed:NULL green:NULL blue:&b alpha:NULL];
    return b;
}

- (CGFloat)hue {
    CGFloat h;
    [self getHue:&h saturation:NULL brightness:NULL alpha:NULL];
    return h;
}

- (CGFloat)saturation {
    CGFloat s;
    [self getHue:NULL saturation:&s brightness:NULL alpha:NULL];
    return s;
}

- (CGFloat)brightness {
    CGFloat b;
    [self getHue:NULL saturation:NULL brightness:&b alpha:NULL];
    return b;
}

#pragma mark Manipulation
- (UIColor*)desaturate:(CGFloat)percent {
        return [UIColor colorWithHue:[self hue] saturation:[self saturation]*(1-(percent/100)) brightness:[self brightness] alpha:[self alpha]];
}

- (UIColor*)lighten:(CGFloat)percent {
   return [UIColor colorWithHue:[self hue] saturation:[self saturation]*(1-(percent/100)) brightness:[self brightness]*(1+(percent/100)) alpha:[self alpha]];
}

- (UIColor*)darken:(CGFloat)percent {
    return [UIColor colorWithHue:[self hue] saturation:[self saturation]*(1+(percent/100)) brightness:[self brightness]*(1-(percent/100)) alpha:[self alpha]];
}


@end

