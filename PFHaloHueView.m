//
//  PFHaloHueView.m
//  ColorPickerRenderer
//
//  Created by Bailey Seymour on 7/7/15.
//  Copyright © 2015 Bailey Seymour. All rights reserved.
//

#import "PFHaloHueView.h"

#define MIN_ANGLE 0
#define MAX_ANGLE (M_PI * 2)

@interface PFHaloHueView () {
    CGPoint _barCenter;
    CGPoint _knobCenter;
    float _barRadius;
    float _knobRadius;
    float _knobAngle;
}
@end

@implementation PFHaloHueView

- (id)initWithFrame:(CGRect)frame
           minValue:(float)minimumValue
           maxValue:(float)maximumValue
              value:(float)initialValue
           delegate:(id<PFHaloHueViewDelegate>)delegate {
    self = [super initWithFrame:frame];

    if (self) {
        _knobRadius = 15;

        UIPanGestureRecognizer *gesture = [UIPanGestureRecognizer new];
        [gesture addTarget:self action:@selector(dragged:)];
        gesture.maximumNumberOfTouches = 1;
        gesture.minimumNumberOfTouches = 1;

        [self addGestureRecognizer:gesture];
        [self setBackgroundColor:[UIColor clearColor]];

        self.maxValue = maximumValue;
        self.minValue = minimumValue;
        self.delegate = delegate;
        [self setValue:initialValue];

        if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
            [self.delegate hueChanged:[self hue]];
    }

    return self;
}

- (void)dragged:(UIPanGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateChanged)
        return;

    CGPoint touchLocation = [gesture locationInView:self];

    // Gets the vector of the difference between the touch location and the knob center
    float touchVector[2] = {touchLocation.x - _knobCenter.x, touchLocation.y - _knobCenter.y};
    // Gets a vector tangent to the circle at the center of the knob
    float tangentVector[2] = {_knobCenter.y - _barCenter.y, _barCenter.x - _knobCenter.x};
    // Calculates the scalar projection of the touch vector onto the tangent vector
    float scalarProj = (touchVector[0] * tangentVector[0] + touchVector[1] * tangentVector[1]) / sqrt((tangentVector[0] * tangentVector[0]) + (tangentVector[1] * tangentVector[1]));
    _knobAngle += scalarProj / _barRadius;

    // Ensures _knobAngle is always between 0 and 2*Pi
    _knobAngle = fmodf(_knobAngle, 2 * M_PI);

    [self setNeedsDisplay];

    if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
        [self.delegate hueChanged:[self hue]];
}

- (float)value {
    float percentDone = (_knobAngle - MIN_ANGLE) / (MAX_ANGLE - MIN_ANGLE);
    if (percentDone > 1)
        percentDone = percentDone - 1;
    else if (percentDone < 0)
        percentDone = percentDone + 1;

    return percentDone * (self.maxValue - self.minValue);
}

- (void)setValue:(float)val {
    _knobAngle = MIN_ANGLE + (val * (MAX_ANGLE - MIN_ANGLE));

    if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
        [self.delegate hueChanged:[self hue]];

    [self setNeedsDisplay];
}

- (float)hue {
    return [self value];
}

- (void)setDelegate:(id<PFHaloHueViewDelegate>)delegate {
    _delegate = delegate;
    if (_delegate && [_delegate respondsToSelector:@selector(hueChanged:)])
        [_delegate hueChanged:[self hue]];
}

- (void)drawRect:(CGRect)rect {
    _barCenter.x = CGRectGetMidX(rect);
    _barCenter.y = CGRectGetMidY(rect);
    // Gets the width or height, whichever is smallest, and stores it in radius
    _barRadius = (CGRectGetHeight(rect) <= CGRectGetWidth(rect)) ? CGRectGetHeight(rect) / 2 : CGRectGetWidth(rect) / 2;
    _barRadius = _barRadius * 0.875f;
    _knobRadius = _barRadius * 0.11f;

    // Finds the center of the knob by converting from polar to cartesian coordinates
    _knobCenter.x = _barCenter.x + (_barRadius * cosf(_knobAngle));
    _knobCenter.y = _barCenter.y - (_barRadius * sinf(_knobAngle));

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 0);

    CGContextAddArc(context, _barCenter.x, _barCenter.y, _barRadius, fmodf(MIN_ANGLE + M_PI, 2 * M_PI), fmodf(MAX_ANGLE + M_PI, 2 * M_PI), 0);

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

    CGContextSetLineWidth(context, _knobRadius / 2);

    // CGContextSetFillColorWithColor(context, CGColorCreate(cs, components));
    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 0.4f);

    CGContextAddArc(context, _knobCenter.x, _knobCenter.y, _knobRadius, 0, 2 * M_PI, 1);

    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddArc(context, _knobCenter.x, _knobCenter.y, _knobRadius, 0, 2 * M_PI, 1);
    CGContextSetFillColorWithColor(context, [UIColor colorWithHue:[self hue] saturation:1 brightness:1 alpha:1].CGColor);
    CGContextDrawPath(context, kCGPathEOFill);
}

@end
