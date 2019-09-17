#import <UIKit/UIKit.h>

@interface PFColorLitePreviewView : UIView
@property (nonatomic, retain) UIColor *mainColor;
@property (nonatomic, retain) UIColor *previousColor;
- (void)updateWithColor:(UIColor *)color;
- (id)initWithFrame:(CGRect)frame mainColor:(UIColor *)mc previousColor:(UIColor *)prev;
- (void)setMainColor:(UIColor *)mc previousColor:(UIColor *)prev;
@end
