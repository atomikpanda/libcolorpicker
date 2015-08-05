#import "PFColorLitePreviewView.h"
#import <CoreGraphics/CoreGraphics.h>

@interface PFColorLitePreviewView ()

@end

@implementation PFColorLitePreviewView
@synthesize mainColor;
@synthesize previousColor;

- (void)updateWithColor:(UIColor *)color
{
  self.mainColor = color;
  [self setNeedsDisplay];
}

- (void)setMainColor:(UIColor *)mc previousColor:(UIColor *)prev
{
  self.mainColor = mc;
  if (prev) self.previousColor = prev;
}

- (id)initWithFrame:(CGRect)frame mainColor:(UIColor *)mc previousColor:(UIColor *)prev
{
	self = [super initWithFrame:frame];

	if (self)
	{
		self.mainColor = mc;

		if (prev) self.previousColor = prev;
		[self setBackgroundColor:[UIColor clearColor]];

		[self setNeedsDisplay];
	}

	return self;
}

- (void)drawRect:(CGRect)rect
{

	if (!self.mainColor) self.mainColor = [UIColor whiteColor];

	CGContextRef context = UIGraphicsGetCurrentContext();

	// CGContextSetLineWidth(context, 4.0);
	// CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.4);
	// CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.width/2, 0, 2*M_PI, 1);
	// CGContextDrawPath(context, kCGPathStroke);
	//
	// CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.width/2, 0, 2*M_PI, 1);
	// CGContextSetFillColorWithColor(context, _mainColor.CGColor);
	// CGContextDrawPath(context, kCGPathFillStroke);

	CGContextScaleCTM(context, 1, 1);

	CGContextSetLineWidth(context, (rect.size.width / 5) / 2);

	// CGContextSetFillColorWithColor(context, CGColorCreate(cs, components));
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

	for (int row = 0; row < rect.size.height; row += kHeight)
	{
		int index = row % (kHeight * 2) == 0 ? 0 : 1;

		for (int col = 0; col < rect.size.width; col += kWidth)
		{
			[[colors objectAtIndex:index++ % 2] setFill];
			UIRectFill(CGRectMake(col, row, kWidth, kHeight));
		}
	}


	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	//   float topOffset = 0.f;
	// // CGContextRef context = UIGraphicsGetCurrentContext();
	//
	// CGContextTranslateCTM(context, 0, topOffset);
	// CGContextSetFillColorWithColor(context, [[UIColor colorWithPatternImage:img] CGColor]);
	// CGContextTranslateCTM(context, 0, (-1*topOffset));
	// CGContextFillEllipseInRect(context, CGRectMake(0, topOffset, rect.size.width/2, rect.size.height/2));

	CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, 0, 2 * M_PI, 1);
	CGContextSetFillColorWithColor(context, [UIColor colorWithPatternImage:img].CGColor);
	CGContextDrawPath(context, kCGPathEOFill);

	if (self.previousColor)
	{
		CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, (M_PI * 3) + (M_PI / 2), (M_PI / 2), 1);
		CGContextSetFillColorWithColor(context, self.mainColor.CGColor);
		CGContextDrawPath(context, kCGPathEOFill);

		CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, (M_PI * 2) / 4, (M_PI * 3) / 2, 0);
		CGContextSetFillColorWithColor(context, self.previousColor.CGColor);
		CGContextDrawPath(context, kCGPathEOFill);
	}
	else
	{
		CGContextAddArc(context, rect.size.width / 2, rect.size.height / 2, rect.size.width / 3, 0, 2 * M_PI, 1);
		CGContextSetFillColorWithColor(context, self.mainColor.CGColor);
		CGContextDrawPath(context, kCGPathEOFill);
	}
}

- (void)dealloc
{
	self.mainColor = nil;
	self.previousColor = nil;
	[super dealloc];
}

@end
