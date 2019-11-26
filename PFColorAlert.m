#import "PFColorAlert.h"
#import "PFColorAlertViewController.h"
#import "UIColor+PFColor.h"
#import "UIKitAdditions.h"
#import <objc/runtime.h>

extern void LCPShowTwitterFollowAlert(NSString *title, NSString *welcomeMessage, NSString *twitterUsername);
#define degreesToRadians(x) ((x) * M_PI / 180.0)

@interface PFColorAlert ()
@property (nonatomic, retain) UIWindow *darkeningWindow;
@property (nonatomic, retain) UIWindow *previousKeyWindow;
@property (nonatomic, retain) PFColorAlertViewController *mainViewController;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, copy) void (^completionBlock)(UIColor *pickedColor);
@end

@implementation PFColorAlert

+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
    return [[[PFColorAlert alloc] initWithStartColor:startColor showAlpha:showAlpha] autorelease];
}

- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
    self = [super init];

    self.isOpen = NO;

    CGRect winFrame = [UIScreen mainScreen].bounds;
    CGFloat deviceHeight = winFrame.size.height;
    /* `statusBarOrientation` is deprecated as of iOS 13. However, it
        seems to be the only reliable way to get the device rotation.
        All other ways fail in one way or another. */
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        deviceHeight = winFrame.size.width;
        winFrame.size.width = winFrame.size.height;
        winFrame.size.height = deviceHeight;
    }

    if (@available(iOS 13, *)) {
        NSSet<UIScene *> *connectedScenes = [[UIApplication sharedApplication] connectedScenes];
        UIScene *firstScene = [[connectedScenes allObjects] objectAtIndex:0];
        self.darkeningWindow = [[UIWindow alloc] initWithWindowScene:firstScene];
        self.darkeningWindow.frame = winFrame;
    } else {
        self.darkeningWindow = [[UIWindow alloc] initWithFrame:winFrame];
    }
    self.darkeningWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];

    float winWidthCalc = winFrame.size.width * 0.09f;
    float winHeightCalc = winFrame.size.height * 0.09f;

    winFrame.origin.x = winWidthCalc / 2;

    winFrame.size.width -= winWidthCalc;
    winFrame.size.height -= winHeightCalc;

    if (@available(iOS 13, *)) {
        NSSet<UIScene *> *connectedScenes = [[UIApplication sharedApplication] connectedScenes];
        UIScene *firstScene = [[connectedScenes allObjects] objectAtIndex:0];
        self.popWindow = [[UIWindow alloc] initWithWindowScene:firstScene];
        self.popWindow.frame = winFrame;
    } else {
        self.popWindow = [[UIWindow alloc] initWithFrame:winFrame];
    }
    self.popWindow.layer.masksToBounds = true;
    self.popWindow.layer.cornerRadius = 15;

    CGRect mainFrame = CGRectMake(0, 0, winFrame.size.width, winFrame.size.height);
    self.mainViewController = [[PFColorAlertViewController alloc] initWithViewFrame:mainFrame
                                                                         startColor:startColor
                                                                          showAlpha:showAlpha];

    self.darkeningWindow.hidden = NO;
    self.darkeningWindow.alpha = 0.0f;

    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    [self.darkeningWindow makeKeyAndVisible];

    self.popWindow.rootViewController = self.mainViewController;
#ifndef DEBUG
    self.darkeningWindow.windowLevel = UIWindowLevelAlert - 2;
    self.popWindow.windowLevel = UIWindowLevelAlert - 1;
#endif
    self.popWindow.backgroundColor = UIColor.clearColor;
    self.popWindow.hidden = NO;
    self.popWindow.alpha = 0.0f;

    [self makeViewDynamic:self.popWindow deviceHeight:deviceHeight];

    return self;
}

- (void)makeViewDynamic:(UIView *)view deviceHeight:(CGFloat)deviceHeight {
    CGRect dynamicFrame = view.frame;
    dynamicFrame.size.height = [self.mainViewController topMostSliderLastYCoordinate] +
                               self.mainViewController.view.frame.size.width / 6;
    dynamicFrame.origin.y = deviceHeight / 2 - dynamicFrame.size.height / 2;

    // Rotate 180 deg on iPad if using it upside down
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad &&
        [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown)
        view.transform = CGAffineTransformMakeRotation(degreesToRadians(180));

    view.frame = dynamicFrame;
}

- (void)displayWithCompletion:(void (^)(UIColor *pickedColor))completionBlock {
    if (self.isOpen)
        return;

    self.completionBlock = completionBlock;

    [self retain];

    [self.popWindow makeKeyAndVisible];

    [UIView animateWithDuration:0.3f animations:^{
        self.darkeningWindow.alpha = 1.0f;
        self.popWindow.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.isOpen = YES;

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        self.darkeningWindow.userInteractionEnabled = YES;
        [self.darkeningWindow addGestureRecognizer:tapGesture];
        [tapGesture release];

        NSString *prefPath = @"/var/mobile/Library/Preferences/com.pixelfiredev.libcolorpicker.plist";
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];

        if (!dict)
            dict = [[NSMutableDictionary new] autorelease];

        NSString *kDidShow = @"didShowWelcomeScreen";
        if (!dict[kDidShow]) {
            LCPShowTwitterFollowAlert(@"Welcome to libcolorpicker!", @"Hey there! Thanks for installing libcolorpicker (the color picker library for devs)! If you'd like to follow our team on Twitter for more updates, tweak giveaways and other cool stuff, hit the button below!", @"PixelFireDev");
            [dict setObject:@YES forKey:kDidShow];
            [dict writeToFile:prefPath atomically:YES];
        }

        if (objc_getClass("UIAlertController")) {
            NSString *pasteboard = [UIPasteboard generalPasteboard].string;
            if (!pasteboard || [pasteboard isEqualToString:[[self.mainViewController getColor] hexFromColor]])
                return;

            NSRange range = [pasteboard rangeOfString:@"^#(?:[0-9a-fA-F]{3}){1,2}$" options:NSRegularExpressionSearch];
            if (range.location != NSNotFound)
                [self.mainViewController presentPasteHexStringQuestion:pasteboard];   
        }
    }];
}

- (void)showWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha completion:(void (^)(UIColor *pickedColor))completionBlock {
    UIAlertView *deprecated = [[UIAlertView alloc] initWithTitle:@"libcolorpicker" message:@"Hey! It appears like this preference bundle is trying to use deprecated methods to invoke the color picker and requires an update. Please inform the dev of this tweak about it."
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [deprecated show];
}

- (void)close {
    if (!self.isOpen)
        return;

    [UIView animateWithDuration:0.3f animations:^{
        self.darkeningWindow.alpha = 0.0f;
        self.popWindow.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (self.completionBlock)
            self.completionBlock([self.mainViewController getColor]);

        self.popWindow.hidden = YES;
        self.isOpen = NO;
        [self.previousKeyWindow makeKeyAndVisible];
    }];
}

- (void)dealloc {
    [self.mainViewController release];
    [self.popWindow release];
    [self.darkeningWindow release];
    self.completionBlock = nil;

    [super dealloc];
}

@end
