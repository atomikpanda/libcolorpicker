//
//  PFHaloHueView.h
//  ColorPickerRenderer
//
//  Created by Bailey Seymour on 7/7/15.
//  Copyright © 2015 Bailey Seymour. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PFHaloHueViewDelegate <NSObject>
- (void)hueChanged:(float)hue;
@end

@interface PFHaloHueView : UIView
- (id)initWithFrame:(CGRect)frame
           minValue:(float)minimumValue
           maxValue:(float)maximumValue
              value:(float)initialValue
          tintColor:(UIColor *)tintColor
           delegate:(id<PFHaloHueViewDelegate>)delegate;
@property (assign, getter = value, setter = setValue:) float value;
@property (assign) float minValue;
@property (assign) float maxValue;
@property (nonatomic, retain) id<PFHaloHueViewDelegate> delegate;
@end
