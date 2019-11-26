//
//  PFHaloHueView.m
//  ColorPickerRenderer
//
//  Created by Bailey Seymour on 7/7/15.
//  Copyright © 2015 Bailey Seymour. All rights reserved.
//

#import "PFHaloHueView.h"
#import "PFHaloKnobView.h"

#define MIN_ANGLE 0
#define MAX_ANGLE (M_PI * 2)

@interface PFHaloHueView () {
    CGPoint _barCenter;
    float _barRadius;
    float _knobAngle;
    PFHaloKnobView *_knob;
    float _mid;
    float _maxLength;
    float _paddingBounds;
}
@end

@implementation PFHaloHueView

- (id)initWithFrame:(CGRect)frame
           minValue:(float)minimumValue
           maxValue:(float)maximumValue
              value:(float)initialValue
          tintColor:(UIColor *)tintColor
           delegate:(id<PFHaloHueViewDelegate>)delegate {
    self = [super initWithFrame:frame];

    if (self) {
        // 55.0f on iPhone 6/7/8
        _paddingBounds = [UIScreen mainScreen].bounds.size.width / 6.8f;

        _knob = [[PFHaloKnobView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)
                                            tintColor:tintColor];
        [self addSubview:_knob];

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
    CGPoint touchLocation = [gesture locationInView:self];

    // FIXME: stop the angle from jumping around when sliding finger far away from knob
    // This works better but still requires a magic number for padding the slide distance
    float dx = _mid - touchLocation.x;
    float dy = _mid - touchLocation.y;
    float touchLength = sqrt(dx * dx + dy * dy);
    if (touchLength > _maxLength)
        return;

    // Gets the vector of the difference between the touch location and the knob center
    float touchVector[2] = {touchLocation.x - _knob.center.x, touchLocation.y - _knob.center.y};

    // Gets a vector tangent to the circle at the center of the knob
    float tangentVector[2] = {_knob.center.y - _barCenter.y, _barCenter.x - _knob.center.x};

    // Calculates the scalar projection of the touch vector onto the tangent vector
    float scalarProj = (touchVector[0] * tangentVector[0] + touchVector[1] * tangentVector[1]) /
                       sqrt((tangentVector[0] * tangentVector[0]) + (tangentVector[1] * tangentVector[1]));

    _knobAngle += scalarProj / _barRadius;

    // Ensures _knobAngle is always between 0 and 2 pi
    _knobAngle = fmodf(_knobAngle, 2 * M_PI);

    [self updateKnob];

    if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
        [self.delegate hueChanged:[self hue]];
}

- (void)updateKnob {
    _knob.center = CGPointMake(_barCenter.x + (_barRadius * cosf(_knobAngle)),
                               _barCenter.y - (_barRadius * sinf(_knobAngle)));
    [_knob setColor:[UIColor colorWithHue:[self hue] saturation:1 brightness:1 alpha:1]];
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

    [self updateKnob];

    if (self.delegate && [self.delegate respondsToSelector:@selector(hueChanged:)])
        [self.delegate hueChanged:[self hue]];
}

- (float)hue {
    return [self value];
}

- (void)drawRect:(CGRect)rect {
    _barCenter.x = CGRectGetMidX(rect);
    _barCenter.y = CGRectGetMidY(rect);

    // Gets the width or height, whichever is smallest, and stores it in radius
    _barRadius = fmin(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2 * 0.875f;
    [self updateKnob];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0);

    CGContextDrawPath(context, kCGPathStroke);
    CGContextSaveGState(context);

    // Gradient color circle
    float dim = MIN(self.bounds.size.width, self.bounds.size.height);
    int subdiv = self.bounds.size.width * 2;
    float r = dim / 2.1f;
    float R = dim / 2;

    float halfInteriorPerim = M_PI * r;
    float halfExteriorPerim = M_PI * R;
    float smallBase = halfInteriorPerim / subdiv;
    float largeBase = halfExteriorPerim / subdiv;

    UIBezierPath *cell = [UIBezierPath bezierPath];

    float halfSmallBase = smallBase / 2;
    float halfLargeBase = largeBase / 2;

    [cell moveToPoint:CGPointMake(-halfSmallBase, r)];
    [cell addLineToPoint:CGPointMake(halfSmallBase, r)];
    [cell addLineToPoint:CGPointMake(halfLargeBase , R)];
    [cell addLineToPoint:CGPointMake(-halfLargeBase,  R)];
    [cell closePath];

    float incr = M_PI * 2 / subdiv;
    CGContextTranslateCTM(context, self.bounds.size.width / 2, self.bounds.size.height / 2);

    CGContextScaleCTM(context, 0.9f, 0.9f);
    CGContextRotateCTM(context, M_PI * 3 / 2);
    CGContextRotateCTM(context, -incr / 2);

    for (int i = 0; i < subdiv; i++) {
        [[UIColor colorWithHue:((float)i / subdiv) saturation:1 brightness:1 alpha:1] set];
        [cell fill];
        [cell stroke];
        CGContextRotateCTM(context, -incr);
    }
    // ---

    _mid = self.frame.size.width / 2;
    _maxLength = _mid + _paddingBounds;
}

@end
