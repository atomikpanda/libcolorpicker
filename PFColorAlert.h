#import  <UIKit/UIKit.h>

@interface PFColorAlert : NSObject
@property (nonatomic, retain) UIWindow *popWindow;

//- (void)showWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha completion:(void (^)(UIColor *pickedColor))completionBlock;
+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha;
- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha;
- (void)displayWithCompletion:(void (^)(UIColor *pickedColor))fcompletionBlock;
- (void)close;
@end
