#import "PFColorLitePreviewView.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation PFColorLitePreviewView {
    UIColor *_tintColor;
}

- (void)updateWithColor:(UIColor *)color {
    self.mainColor = color;
    [self setNeedsDisplay];
}

- (void)setMainColor:(UIColor *)mainColor
       previousColor:(UIColor *)prevColor {
    self.mainColor = mainColor;
    if (prevColor)
        self.previousColor = prevColor;
}

- (id)initWithFrame:(CGRect)frame
          tintColor:(UIColor *)tintColor
          mainColor:(UIColor *)mainColor
      previousColor:(UIColor *)prevColor {
    self = [super initWithFrame:frame];

    if (self) {
        self.mainColor = mainColor;
        _tintColor = tintColor;

        if (prevColor)
            self.previousColor = prevColor;
        [self setBackgroundColor:[UIColor clearColor]];
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    if (!self.mainColor)
        self.mainColor = [UIColor whiteColor];

    float halfWidth = rect.size.width / 2;
    float halfHeight = rect.size.height / 2;
    float oneThirdWidth = rect.size.width / 3;

    float twoPi = M_PI * 2;
    float threePi = M_PI * 3;
    float halfPi = M_PI / 2;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, 1);
    CGContextSetLineWidth(context, halfWidth / 5);
    CGFloat red, green, blue;
    [_tintColor getRed:&red green:&green blue:&blue alpha:nil];
    CGContextSetRGBStrokeColor(context, red, green, blue, 0.3f);

    CGContextAddArc(context, halfWidth, halfHeight, oneThirdWidth, 0, twoPi, 1);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextAddArc(context, halfWidth, halfHeight, oneThirdWidth, 0, twoPi, 1);

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);

    int kHeight = 12;
    int kWidth = 12;
    NSArray *colors = @[UIColor.whiteColor, UIColor.grayColor];
    for (int row = 0; row < rect.size.height; row += kHeight) {
        int index = row % (kHeight * 2) == 0 ? 0 : 1;

        for (int col = 0; col < rect.size.width; col += kWidth) {
            [colors[index++ % 2] setFill];
            UIRectFill(CGRectMake(col, row, kWidth, kHeight));
        }
    }

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGContextSetFillColorWithColor(context, [UIColor colorWithPatternImage:img].CGColor);
    CGContextDrawPath(context, kCGPathEOFill);

    if (self.previousColor) {
        CGContextAddArc(context, halfWidth, halfHeight, oneThirdWidth, threePi + halfPi, halfPi, 1);
        CGContextSetFillColorWithColor(context, self.mainColor.CGColor);
        CGContextDrawPath(context, kCGPathEOFill);

        CGContextAddArc(context, halfWidth, halfHeight, oneThirdWidth, halfPi, threePi / 2, 0);
        CGContextSetFillColorWithColor(context, self.previousColor.CGColor);
        CGContextDrawPath(context, kCGPathEOFill);
    } else {
        CGContextAddArc(context, halfWidth, halfHeight, oneThirdWidth, 0, twoPi, 1);
        CGContextSetFillColorWithColor(context, self.mainColor.CGColor);
        CGContextDrawPath(context, kCGPathEOFill);
    }
}

@end
