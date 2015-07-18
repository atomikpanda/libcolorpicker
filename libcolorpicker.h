#import  <UIKit/UIKit.h>

#ifdef __cplusplus /* If this is a C++ compiler, use C linkage */
extern "C" {
#endif
UIColor *LCPParseColorString(NSString *colorStringFromPrefs, NSString *colorStringFallback);
//old DONT USE
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);

#ifdef __cplusplus /* If this is a C++ compiler, end C linkage */
}
#endif

@interface PFColorAlert : NSObject
@property (nonatomic, retain) UIWindow *popWindow;
- (void)showWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha completion:(void (^)(UIColor *pickedColor))completionBlock;
- (void)close;
@end
