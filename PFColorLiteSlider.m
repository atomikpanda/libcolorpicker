#import "PFColorLiteSlider.h"
#import "UIColor+PFColor.h"

@interface PFColorSliderBackgroundView : UIView
@property (nonatomic, assign) UIColor *color;
@property (assign) PFSliderBackgroundStyle style;
- (id)initWithFrame:(CGRect)frame color:(UIColor *)color style:(PFSliderBackgroundStyle)s;
@end

@implementation PFColorSliderBackgroundView

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color style:(PFSliderBackgroundStyle)s
{
  self = [super initWithFrame:frame];
  self.color = color;
  self.style = s;
  self.backgroundColor = [UIColor clearColor];
  return self;
}

- (void)drawRect:(CGRect)rect
{
  // UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, 10), NO, [UIScreen mainScreen].scale);
  CGContextRef context = UIGraphicsGetCurrentContext();


  for (int x = 0; x < rect.size.width; x++) {
    float percent = 100-(((rect.size.width - x)/rect.size.width)*100.f);

    if (self.style == PFSliderBackgroundStyleSaturation)
      [[UIColor colorWithHue:[self.color hue] saturation:percent/100 brightness:1 alpha:1] setFill];
    else if (self.style == PFSliderBackgroundStyleBrightness)
      [[UIColor colorWithHue:[self.color hue] saturation:1 brightness:percent/100 alpha:1] setFill];
    else if (self.style == PFSliderBackgroundStyleAlpha)
      [[UIColor colorWithHue:self.color.hue saturation:self.color.saturation brightness:self.color.brightness alpha:percent/100] setFill];

    CGContextFillRect(context, CGRectMake(x, 0, 1, rect.size.height));
  }


  // UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  // UIGraphicsEndImageContext();
}

@end

@interface PFColorLiteSlider ()
@property (nonatomic, retain) PFColorSliderBackgroundView *backgroundView;
@property (assign) PFSliderBackgroundStyle style;
@end

@implementation PFColorLiteSlider

- (id)initWithFrame:(CGRect)frame color:(UIColor *)c style:(PFSliderBackgroundStyle)s
{
  self = [super initWithFrame:frame];

  CGRect internalFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);

  self.style = s;

  self.slider = [[[UISlider alloc] initWithFrame:internalFrame] autorelease];
  self.slider.minimumValue = 0.0000001f;
  self.slider.maximumValue = 1.0;
  internalFrame.size.height = 10; // set to ten because we want a thin BG
  internalFrame.origin.y = ((frame.size.height-10)/2);
  self.backgroundView = [[[PFColorSliderBackgroundView alloc] initWithFrame:internalFrame color:c style:s] autorelease];

  [self addSubview:_backgroundView];
  [self addSubview:_slider];

  [self updateGraphicsWithColor:c];


  return self;
}

- (void)updateGraphicsWithColor:(UIColor *)color
{
  if (self.style == PFSliderBackgroundStyleSaturation)
  {
    [self.slider setThumbImage:[self thumbImageWithColor:
    [UIColor colorWithHue:color.hue saturation:color.saturation brightness:1 alpha:1]]
    forState:UIControlStateNormal];
  }
  else if (self.style == PFSliderBackgroundStyleBrightness)
  {
    [self.slider setThumbImage:[self thumbImageWithColor:
    [UIColor colorWithHue:color.hue saturation:1 brightness:color.brightness alpha:1]]
    forState:UIControlStateNormal];
  }
  else if (self.style == PFSliderBackgroundStyleAlpha)
  {
    [self.slider setThumbImage:[self thumbImageWithColor:
    [UIColor colorWithHue:color.hue saturation:color.saturation brightness:color.brightness alpha:color.alpha]]
    forState:UIControlStateNormal];
  }

  self.slider.maximumTrackTintColor = [UIColor clearColor];
  self.slider.minimumTrackTintColor = [UIColor clearColor];

  self.backgroundView.color = color;
  [self.backgroundView setNeedsDisplay];

  if (self.style == PFSliderBackgroundStyleSaturation)
    self.slider.value = color.saturation;
  else if (self.style == PFSliderBackgroundStyleBrightness)
    self.slider.value = color.brightness;
  else if (self.style == PFSliderBackgroundStyleAlpha)
    self.slider.value = color.alpha;

  // self.backgroundColor = [UIColor colorWithPatternImage:[self trackImageWithColor:[UIColor purpleColor]]];

}

// - (UIImage *)trackImageWithColor:(UIColor *)color
// {
//   CGRect rect = self.bounds;
//   rect.size.height = 10;
//   UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width, 10), NO, [UIScreen mainScreen].scale);
//   CGContextRef context = UIGraphicsGetCurrentContext();
//
//
//   for (int x = 0; x < rect.size.width; x++) {
//     float percent = 100-(((rect.size.width - x)/rect.size.width)*100.f);
//
//     if (self.style == PFSliderBackgroundStyleSaturation)
//       [[UIColor colorWithHue:[color hue] saturation:percent/100 brightness:1 alpha:1] setFill];
//     else if (self.style == PFSliderBackgroundStyleBrightness)
//       [[UIColor colorWithHue:[color hue] saturation:1 brightness:percent/100 alpha:1] setFill];
//       else if (self.style == PFSliderBackgroundStyleBrightness)
//         [[UIColor colorWithHue:[color hue] saturation:1 brightness:percent/100 alpha:1] setFill];
//
//     CGContextFillRect(context, CGRectMake(x, 0, 1, rect.size.height));
//   }
//
//
//   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//   UIGraphicsEndImageContext();
//   return image;
// }

- (UIImage *)thumbImageWithColor:(UIColor *)color
{
    CGFloat size = 28.0f;
    CGRect rect = CGRectMake(0.0f, 0.0f, size, size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 6);

    // CGContextSetFillColorWithColor(context, CGColorCreate(cs, components));
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.3);

    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.width/3, 0, 2*M_PI, 1);

    CGContextDrawPath(context, kCGPathStroke);

    // CGContextScaleCTM(context, 0.8, 0.8);

    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, (rect.size.width/3)-3, 0, 2*M_PI, 1);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathEOFill);

    // CGContextSetShadow(context, CGSizeMake(0, 0), 0);
    // CGContextTranslateCTM(context, 0, rect.size.height);
    // CGContextScaleCTM(context, 1, -1);
    // CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    // CGContextSetLineWidth(context, 2.0);
    // CGContextSelectFont(context, "Helvetica Neue Bold", 15.0, kCGEncodingMacRoman);
    // CGContextSetCharacterSpacing(context, 1.7);
    // CGContextSetTextDrawingMode(context, kCGTextFill);
    // CGContextShowTextAtPoint(context, 10, 15, [NSString stringWithCharacters:&letter length:1].UTF8String, 1);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


@end
