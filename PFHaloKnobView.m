//
//  PFHaloKnowView.m
//  ColorPickerRenderer
//
//  Created by Andreas Henriksson on 23/7/19.
//  Copyright © 2019 Andreas Henriksson. All rights reserved.
//

#import "PFHaloKnobView.h"

@interface PFHaloKnobView () {
    UIView *_colorView;
}
@end

@implementation PFHaloKnobView

- (id)initWithFrame:(CGRect)frame
          tintColor:(UIColor *)tintColor {
    self = [super initWithFrame:frame];

    if (self) {
        float borderWidth = frame.size.width / 10.0;

        float doubleBorderWidth = borderWidth * 2;
        CGRect circleFrame = CGRectMake(borderWidth, borderWidth,
                                        self.frame.size.width - doubleBorderWidth,
                                        self.frame.size.width - doubleBorderWidth);
        _colorView = [[UIView alloc] initWithFrame:circleFrame];
        _colorView.layer.cornerRadius = circleFrame.size.width / 2.0;
        _colorView.layer.masksToBounds = true;
        [self addSubview:_colorView];

        self.backgroundColor = [tintColor colorWithAlphaComponent:0.4f];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    self.layer.cornerRadius = frame.size.width / 2.0;
    _colorView.layer.cornerRadius = _colorView.frame.size.width / 2.0;
}

- (void)setColor:(UIColor *)color {
    _colorView.backgroundColor = color;
}

@end
