#import "PFColorLitePreviewView.h"
#import <CoreGraphics/CoreGraphics.h>

@interface PFColorLitePreviewView ()
@end

@implementation PFColorLitePreviewView

- (void)updateWithColor:(UIColor *)color {
    self.mainColor = color;
    [self setNeedsDisplay];
}

- (void)setMainColor:(UIColor *)mainColor previousColor:(UIColor *)prevColor {
    self.mainColor = mainColor;
    if (prevColor)
        self.previousColor = prevColor;
}

- (id)initWithFrame:(CGRect)frame mainColor:(UIColor *)mainColor previousColor:(UIColor *)prevColor {
    self = [super initWithFrame:frame];

    if (self) {
        self.mainColor = mainColor;

        if (prevColor)
            self.previousColor = prevColor;
        [self setBackgroundColor:[UIColor clearColor]];
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    if (!self.mainColor)
        self.mainColor = [UIColor whiteColor];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, 1);
    CGContextSetLineWidth(context, (rect.size.width / 5) / 2);

    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 0.3f);

    CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, 0, 2 * M_PI, 1);

    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, 0, 2 * M_PI, 1);

    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);

    int kHeight = 11;
    int kWidth = 11;
    NSArray *colors = [NSArray arrayWithObjects:
                        [UIColor whiteColor],
                        [UIColor grayColor],
                        nil];

    for (int row = 0; row < rect.size.height; row += kHeight) {
        int index = row % (kHeight * 2) == 0 ? 0 : 1;

        for (int col = 0; col < rect.size.width; col += kWidth) {
            [[colors objectAtIndex:index++ % 2] setFill];
            UIRectFill(CGRectMake(col, row, kWidth, kHeight));
        }
    }

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, 0, 2 * M_PI, 1);
    CGContextSetFillColorWithColor(context, [UIColor colorWithPatternImage:img].CGColor);
    CGContextDrawPath(context, kCGPathEOFill);

    if (self.previousColor) {
        CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, (M_PI * 3) + (M_PI / 2), (M_PI / 2), 1);
        CGContextSetFillColorWithColor(context, self.mainColor.CGColor);
        CGContextDrawPath(context, kCGPathEOFill);

        CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, (M_PI * 2) / 4, (M_PI * 3) / 2, 0);
        CGContextSetFillColorWithColor(context, self.previousColor.CGColor);
        CGContextDrawPath(context, kCGPathEOFill);
    } else {
        CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, 0, 2 * M_PI, 1);
        CGContextSetFillColorWithColor(context, self.mainColor.CGColor);
        CGContextDrawPath(context, kCGPathEOFill);
    }
}

@end
