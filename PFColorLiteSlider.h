#import <UIKit/UIKit.h>

typedef enum PFSliderBackgroundStyle : NSUInteger {
    PFSliderBackgroundStyleSaturation = 5,
    PFSliderBackgroundStyleBrightness = 6,
    PFSliderBackgroundStyleAlpha      = 7
} PFSliderBackgroundStyle;

@interface PFColorLiteSlider : UIView
@property (nonatomic, retain) UISlider *slider;
- (id)initWithFrame:(CGRect)frame color:(UIColor *)c style:(PFSliderBackgroundStyle)s;
- (void)updateGraphicsWithColor:(UIColor *)color;
@end
