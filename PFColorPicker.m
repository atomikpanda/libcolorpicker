//
//  ColorPicker.m
//  ColorPicker
//
//  Created by Bailey Seymour on 3/16/14.
//  Copyright (c) 2011 Bailey Seymour All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PFColorPicker.h"
#import "UIColor+PFColor.h"

#if TARGET_OS_IPHONE
@implementation PFColorPicker

@synthesize lastSelectedColor=_lastSelectedColor;
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //CAGradientLayer *bgLayer = [PFColorPicker rainbowGradient];
        //bgLayer.frame = self.bounds;
        //[self.layer insertSublayer:bgLayer atIndex:0];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

+ (UIColor *)colorWithHueForLocation:(CGFloat)location
{
    return [UIColor colorWithHue:location saturation:1 brightness:1 alpha:1];
}

- (void)drawRect:(CGRect)rect
{
    float widthX = rect.size.width;
    float widthY = rect.size.height;
    
    int size = 1;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (float posY = 0; posY <= widthY; posY += size)
    {
        for (float posX = 0; posX <= widthX; posX += size)
        {
            float h = (posY / widthY);
            float s = (((posX / widthX) <= 0.5 ? 1 : 1 - (posX / widthX))) * 2;
            float b = (((posX / widthX) <= 0.5 ? (posX / widthX) : 1)) * 2;
            
            [[UIColor colorWithHue:h saturation:s brightness:b alpha:1] setFill];
            CGContextFillRect(context, CGRectMake(posX, posY, size, size));
        }
    }
}

- (void)makeReadyForDisplay
{

    
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(selectColor:)];
    [self addGestureRecognizer:drag];
    [self setUserInteractionEnabled:YES];
}

- (UIColor *)colorAtPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    if (!color)
        color = [self lastSelectedColor];

    return color;
}

- (void)selectColor:(UIPanGestureRecognizer*)gest
{
	CGPoint point = [gest locationInView:self]; //where user stopped dragging on image
    [self useColorAtPoint:point];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self]; //where image was tapped
    [self useColorAtPoint:point];
}

- (void)useColorAtPoint:(CGPoint)point {
    CGRect r = self.frame;
    r.origin = CGPointZero;
    
    if (CGRectContainsPoint(r, point)) {
        UIColor *color = [[self colorAtPoint:point] retain];
        if(!color) {
            return;
        }
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        if (components[3]!=0) {
            _lastSelectedColor = color;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(pickedColor:)]) {
        [_delegate performSelector:@selector(pickedColor:) withObject:_lastSelectedColor];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
#endif