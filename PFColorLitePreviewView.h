#import <UIKit/UIKit.h>

@interface PFColorLitePreviewView : UIView
@property (nonatomic, retain) UIColor *mainColor;
@property (nonatomic, retain) UIColor *previousColor;
- (void)updateWithColor:(UIColor *)color;
- (id)initWithFrame:(CGRect)frame
          tintColor:(UIColor *)tintColor
          mainColor:(UIColor *)mainColor
      previousColor:(UIColor *)prevColor;
- (void)setMainColor:(UIColor *)mainColor
       previousColor:(UIColor *)previousColor;
@end
