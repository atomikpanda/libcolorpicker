//
//  PFHaloHueView.m
//  ColorPickerRenderer
//
//  Created by Bailey Seymour on 7/7/15.
//  Copyright © 2015 Bailey Seymour. All rights reserved.
//

#import "PFHaloHueView.h"

#define MIN_ANGLE 0
#define MAX_ANGLE (M_PI*2)

@interface PFHaloHueView ()
    @property (assign) BOOL isKnobBeingTouched;
    @property (assign) CGPoint barCenter;
    @property (assign) CGPoint knobCenter;
    @property (assign) float barRadius;
    @property (assign) float knobRadius;
    @property (assign) float knobAngle;
    @property (nonatomic, retain) UIPanGestureRecognizer *gest;
@end

@implementation PFHaloHueView
@synthesize isKnobBeingTouched, barCenter, knobCenter, barRadius, knobRadius, knobAngle, gest;

- (id)initWithFrame:(CGRect)frame minValue:(float)minimumValue maxValue:(float)maximumValue value:(float)initialValue delegate:(id<PFHaloHueViewDelegate>)del;
{
    self = [super initWithFrame:frame];

    if (self)
    {
        knobRadius = 15;

        UIPanGestureRecognizer *pan = [UIPanGestureRecognizer new];
        [pan addTarget:self action:@selector(dragged:)];
        pan.maximumNumberOfTouches = 1;
        pan.minimumNumberOfTouches = 1;

        self.gest = pan;
        [self addGestureRecognizer:self.gest];

        [self setBackgroundColor:[UIColor clearColor]];

        self.maxValue = maximumValue;
        self.minValue = minimumValue;
        self.delegate = del;
        [self setValue:initialValue];

        if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
            [self.delegate hueChanged:[self hue]];

//        //calclulate initial angle from initial value
//        float percentDone = 1-(initialValue/(self.maxValue - self.minValue));
//        //        float percentDone = 1.000000-((initialValue-MIN_ANGLE)/(MAX_ANGLE-MIN_ANGLE));
//        if (percentDone > 1) percentDone = percentDone-1;
//        else if (percentDone < 0) percentDone = percentDone+1;
//
//        knobAngle = MIN_ANGLE+(percentDone*(MAX_ANGLE-MIN_ANGLE));

    }

    return self;
}

// - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
// {
//     if (touches.count > 1) return;
//
//     CGPoint touchLocation = [[touches anyObject] locationInView:self];
//     isKnobBeingTouched = false;
//     CGFloat xDist = touchLocation.x - knobCenter.x;
//     CGFloat yDist = touchLocation.y - knobCenter.y;
//
//     if (sqrt((xDist*xDist)+(yDist*yDist)) <= knobRadius) //if the touch is within the slider knob
//     {
//         isKnobBeingTouched = true;
//     }
// }

// - (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
- (void)dragged:(UIPanGestureRecognizer *)pan
{

  if (pan.state == UIGestureRecognizerStateBegan)
  {
    CGPoint touchLocationA = [self.gest locationInView:self];
    isKnobBeingTouched = false;
    CGFloat xDist = touchLocationA.x - knobCenter.x;
    CGFloat yDist = touchLocationA.y - knobCenter.y;

    if (sqrt((xDist*xDist)+(yDist*yDist)) <= knobRadius) //if the touch is within the slider knob
    {
        isKnobBeingTouched = true;
    }
    else {
      return;
    }
  }

  if ((self.gest.state == UIGestureRecognizerStateChanged) ||
      (self.gest.state == UIGestureRecognizerStateEnded)) {




    // if (isKnobBeingTouched)
    // {
        CGPoint touchLocation = [self.gest locationInView:self];//[[touches anyObject] locationInView:self];



        float touchVector[2] = {touchLocation.x - knobCenter.x, touchLocation.y - knobCenter.y}; //gets the vector of the difference between the touch location and the knob center
        float tangentVector[2] = {knobCenter.y - barCenter.y, barCenter.x - knobCenter.x}; //gets a vector tangent to the circle at the center of the knob
        float scalarProj = (touchVector[0] * tangentVector[0] + touchVector[1] * tangentVector[1]) / sqrt((tangentVector[0] * tangentVector[0]) + (tangentVector[1] * tangentVector[1])); //calculates the scalar projection of the touch vector onto the tangent vector
        knobAngle += scalarProj / barRadius;

        // we want it to not stop at a point so comment it out
//        if (knobAngle > MAX_ANGLE) //ensure knob is always on the bar
//            knobAngle = MAX_ANGLE;
//        if (knobAngle < MIN_ANGLE)
//            knobAngle = MIN_ANGLE;

        knobAngle = fmodf(knobAngle, 2 * M_PI); //ensures knobAngle is always between 0 and 2*Pi

        [self setNeedsDisplay];

        if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
            [self.delegate hueChanged:[self hue]];
    // }
  }
}

// - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
// {
//     isKnobBeingTouched = false;
// }
//
// - (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
// {
//     isKnobBeingTouched = false;
// }

- (float)value
{
    float percentDone = ((knobAngle - MIN_ANGLE) / (MAX_ANGLE - MIN_ANGLE));
    if (percentDone > 1) percentDone = percentDone - 1;
    else if (percentDone < 0) percentDone = percentDone + 1;

    return percentDone * (self.maxValue - self.minValue); // percentDone*(maxValue-minValue)
}

- (void)setValue:(float)val
{
    // if (val == 0) val = 0.0000001f;
    // if (val == 1) val = val - 0.0000001f;
    // if (val == 0.5) val = val - 0.0000001f;
    //calclulate initial angle from initial value
    float percentDone = (val / (self.maxValue - self.minValue));

    float h = percentDone * (self.maxValue - self.minValue);

    // if (h > 0.75f && h < 1)
    //     h = 1 - (fabsf(1 - (h * 2)) / 2);
    // else if (h < 0.75f && h > 0.5f)
    //     h = 1 - (fabsf(1 - (h * 2)) / 2);
    // else if (h < 0.25f && h > 0)
    //     h = (1 - h) / 2;
    // else if (h > 0.25f && h < 0.5f)
    //     h = (fabsf(1 - (h * 2)) / 2);

    knobAngle = MIN_ANGLE + (h * (MAX_ANGLE - MIN_ANGLE));

    if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
        [self.delegate hueChanged:[self hue]];

    [self setNeedsDisplay];
}

// - (void)setValue:(float)val
// {
//     if (val == 0) val = 0.0000001f;
//     if (val == 1) val = val - 0.0000001f;
//     if (val == 0.5) val = val - 0.0000001f;
//     //calclulate initial angle from initial value
//     float percentDone = 1 - (val / (self.maxValue - self.minValue));
//
//     float h = percentDone * (self.maxValue - self.minValue);
//
//     if (h > 0.75f && h < 1)
//         h = 1 - (fabsf(1 - (h * 2)) / 2);
//     else if (h < 0.75f && h > 0.5f)
//         h = 1 - (fabsf(1 - (h * 2)) / 2);
//     else if (h < 0.25f && h > 0)
//         h = (1 - h) / 2;
//     else if (h > 0.25f && h < 0.5f)
//         h = (fabsf(1 - (h * 2)) / 2);
//
//     knobAngle = MIN_ANGLE + (h * (MAX_ANGLE - MIN_ANGLE));
//
//     [self setNeedsDisplay];
// }

- (float)hue
{
    float h = [self value];
    // if (h > 0.75f && h < 1)
    //     h = 1 - (fabsf(1 - (h * 2)) / 2);
    // else if (h < 0.75f && h > 0.5f)
    //     h = 1 - (fabsf(1 - (h * 2)) / 2);
    // else if (h < 0.25f && h > 0)
    //     h = (1 - h) / 2;
    // else if (h > 0.25f && h < 0.5f)
    //     h = (fabsf(1 - (h * 2)) / 2);

    return h;
}

- (void)setDelegate:(id<PFHaloHueViewDelegate>)delegate
{
    _delegate = delegate;
    if (_delegate && [_delegate respondsToSelector:@selector(hueChanged:)])
    [_delegate hueChanged:[self hue]];
}

- (void)drawRect:(CGRect)rect
{
    barCenter.x = CGRectGetMidX(rect);
    barCenter.y = CGRectGetMidY(rect);
    barRadius = (CGRectGetHeight(rect) <= CGRectGetWidth(rect)) ? CGRectGetHeight(rect) / 2 : CGRectGetWidth(rect) / 2; //gets the width or height, whichever is smallest, and stores it in radius
    barRadius = barRadius * 0.875f;
    knobRadius = barRadius * 0.11f;

    //finds the center of the knob by converting from polar to cartesian coordinates
    knobCenter.x = barCenter.x + (barRadius * cosf(knobAngle));
    knobCenter.y = barCenter.y - (barRadius * sinf(knobAngle));

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 0);

    CGContextAddArc(context, barCenter.x, barCenter.y, barRadius, fmodf(MIN_ANGLE + M_PI, 2 * M_PI), fmodf(MAX_ANGLE + M_PI, 2 * M_PI), 0);

    CGContextDrawPath(context, kCGPathStroke);
    CGContextSaveGState(context);

    float dim = MIN(self.bounds.size.width, self.bounds.size.height);
    int subdiv = self.bounds.size.width * 2;
    float r = dim / 2.1f;
    float R = dim / 2;

    float halfinteriorPerim = M_PI * r;
    float halfexteriorPerim = M_PI * R;
    float smallBase = halfinteriorPerim / subdiv;
    float largeBase = halfexteriorPerim / subdiv;

    UIBezierPath *cell = [UIBezierPath bezierPath];

    [cell moveToPoint:CGPointMake(-smallBase / 2, r)];

    [cell addLineToPoint:CGPointMake(smallBase / 2, r)];

    [cell addLineToPoint:CGPointMake(largeBase / 2 , R)];
    [cell addLineToPoint:CGPointMake(-largeBase / 2,  R)];
    [cell closePath];

    float incr = M_PI * 2 / subdiv;

    CGContextTranslateCTM(context, self.bounds.size.width / 2, self.bounds.size.height / 2);

    CGContextScaleCTM(context, 0.9f, 0.9f);
    CGContextRotateCTM(context, M_PI * 3 / 2);
    CGContextRotateCTM(context, -incr / 2);

    for (int i = 0; i < subdiv; i++) {
        // replace this color with a color extracted from your gradient object
        [[UIColor colorWithHue:((float)i / subdiv) saturation:1 brightness:1 alpha:1] set];
        [cell fill];
        [cell stroke];
        CGContextRotateCTM(context, -incr);
    }

    CGContextRestoreGState(context);

    CGContextSetLineWidth(context, knobRadius / 2);

    // CGContextSetFillColorWithColor(context, CGColorCreate(cs, components));
    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 0.4f);

    CGContextAddArc(context, knobCenter.x, knobCenter.y, knobRadius, 0, 2 * M_PI, 1);

    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddArc(context, knobCenter.x, knobCenter.y, knobRadius, 0, 2 * M_PI, 1);
    CGContextSetFillColorWithColor(context, [UIColor colorWithHue:[self hue] saturation:1 brightness:1 alpha:1].CGColor);
    CGContextDrawPath(context, kCGPathEOFill);
}

- (void)dealloc
{

  self.gest = nil;

  [super dealloc];
}

@end
