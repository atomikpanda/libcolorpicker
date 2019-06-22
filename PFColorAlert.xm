#import "PFColorAlert.h"
#import "PFHaloHueView.h"
#import "PFColorLitePreviewView.h"
#import "PFColorLiteSlider.h"
#import "UIColor+PFColor.h"
#import <objc/runtime.h>

extern "C" void LCPShowTwitterFollowAlert(NSString *title, NSString *welcomeMessage, NSString *twitterUsername);

@interface PFColorAlertViewController : UIViewController
@end

@interface PFColorAlert() <PFHaloHueViewDelegate>
@property (nonatomic, retain) PFHaloHueView *haloView;
@property (nonatomic, retain) PFColorAlertViewController *mainViewController;
@property (nonatomic, retain) UIView *blurView;
@property (nonatomic, retain) UIButton *hexButton;
@property (nonatomic, retain) UIWindow *darkeningWindow;
@property (nonatomic, retain) PFColorLiteSlider *brightnessSlider;
@property (nonatomic, retain) PFColorLiteSlider *saturationSlider;
@property (nonatomic, retain) PFColorLiteSlider *alphaSlider;
@property (nonatomic, retain) PFColorLitePreviewView *litePreviewView;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, copy) void (^completionBlock)(UIColor *pickedColor);
- (PFColorAlert *)init;
@end

@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(long long)style;
@end

@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)fitsSuperview settings:(_UIBackdropViewSettings *)settings;
@end

@implementation PFColorAlertViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end

@implementation PFColorAlert

- (PFColorAlert *)init {
    self = [super init];

    self.isOpen = NO;

    UIColor *startColor = [UIColor whiteColor];

    self.darkeningWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.darkeningWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];

    CGRect winFrame = [UIScreen mainScreen].bounds;

    winFrame.origin.x = (winFrame.size.width * 0.09f) / 2;
    winFrame.origin.y = (winFrame.size.height * 0.09f) / 2;

    winFrame.size.width = winFrame.size.width - (winFrame.size.width * 0.09f);
    winFrame.size.height = winFrame.size.height - (winFrame.size.height * 0.09f);


    self.popWindow = [[UIWindow alloc] initWithFrame:winFrame];
    self.popWindow.layer.masksToBounds = true;
    self.popWindow.layer.cornerRadius = 15;

    self.mainViewController = [[PFColorAlertViewController alloc] init];
    self.mainViewController.view.frame = CGRectMake(0, 0, winFrame.size.width, winFrame.size.height);

    const CGRect mainFrame = self.mainViewController.view.frame;

    if (%c(_UIBackdropView)) {
        _UIBackdropViewSettings *backSettings = [%c(_UIBackdropViewSettings) settingsForStyle:2010];
        self.blurView = [[%c(_UIBackdropView) alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:backSettings];
    } else {
        self.blurView = [[UIView alloc] initWithFrame:mainFrame];
        self.blurView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9f];
    }

    [self.mainViewController.view addSubview:self.blurView];

    float padding = mainFrame.size.width / 6;
    float width = mainFrame.size.width - padding * 2;
    CGRect haloViewFrame = CGRectMake(padding, padding, width, width);

    // HUE HARDCODED !!
    self.haloView = [[PFHaloHueView alloc] initWithFrame:haloViewFrame minValue:0 maxValue:1 value:startColor.hue delegate:self];

    [self.mainViewController.view addSubview:self.haloView];

    const CGRect sliderFrame = CGRectMake(padding,
                                          haloViewFrame.origin.y + haloViewFrame.size.height,
                                          width,
                                          40);

    self.saturationSlider = [[PFColorLiteSlider alloc] initWithFrame:sliderFrame color:startColor style:PFSliderBackgroundStyleSaturation];
    [self.mainViewController.view addSubview:self.saturationSlider];

    CGRect brightnessSliderFrame = sliderFrame;
    brightnessSliderFrame.origin.y = brightnessSliderFrame.origin.y + brightnessSliderFrame.size.height;

    self.brightnessSlider = [[PFColorLiteSlider alloc] initWithFrame:brightnessSliderFrame color:startColor style:PFSliderBackgroundStyleBrightness];
    [self.mainViewController.view addSubview:self.brightnessSlider];

    CGRect alphaSliderFrame = brightnessSliderFrame;
    alphaSliderFrame.origin.y = alphaSliderFrame.origin.y + alphaSliderFrame.size.height;

    self.alphaSlider = [[PFColorLiteSlider alloc] initWithFrame:alphaSliderFrame color:startColor style:PFSliderBackgroundStyleAlpha];
    [self.mainViewController.view addSubview:self.alphaSlider];

    self.hexButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.hexButton addTarget:self action:@selector(chooseHexColor) forControlEvents:UIControlEventTouchUpInside];
    [self.hexButton setTitle:@"#" forState:UIControlStateNormal];
    self.hexButton.frame = CGRectMake(self.mainViewController.view.frame.size.width - (25 + 10), 10, 25, 25);
    [self.mainViewController.view addSubview:self.hexButton];

    CGRect litePreviewViewFrame = CGRectMake(mainFrame.size.width / 2 - padding,
                                             haloViewFrame.origin.y + haloViewFrame.size.height - mainFrame.size.width / 2,
                                             padding * 2,
                                             padding * 2);

    // HUE HARDCODED !!
    self.litePreviewView = [[PFColorLitePreviewView alloc] initWithFrame:litePreviewViewFrame
                                                               mainColor:[UIColor colorWithHue:startColor.hue saturation:startColor.saturation brightness:startColor.brightness alpha:startColor.alpha] previousColor: startColor];
    [self.mainViewController.view addSubview:self.litePreviewView];

    self.darkeningWindow.hidden = NO;
    self.darkeningWindow.alpha = 0.0f;
    [self.darkeningWindow makeKeyAndVisible];

    self.popWindow.rootViewController = self.mainViewController;
    self.darkeningWindow.windowLevel = UIWindowLevelAlert - 2.0f;
    self.popWindow.windowLevel = UIWindowLevelAlert - 1.0f;
    self.popWindow.backgroundColor = [UIColor clearColor];
    self.popWindow.hidden = NO;
    self.popWindow.alpha = 0.0f;

    [self makeViewDynamic:self.popWindow];
    CGRect popWindowFrame = self.popWindow.frame;
    popWindowFrame.origin.y = ([UIScreen mainScreen].bounds.size.height - popWindowFrame.size.height) / 2;

    self.popWindow.frame = popWindowFrame;

    [self.saturationSlider.slider addTarget:self action:@selector(saturationChanged:) forControlEvents:UIControlEventValueChanged];
    [self.brightnessSlider.slider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [self.alphaSlider.slider addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];

    [self setPrimaryColor:startColor];

    return self;
}

- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
    self = [self init];

    [self.haloView setValue:startColor.hue];
    [self.saturationSlider updateGraphicsWithColor:startColor];
    [self.brightnessSlider updateGraphicsWithColor:startColor];
    [self.alphaSlider updateGraphicsWithColor:startColor];
    [self.litePreviewView setMainColor:[UIColor colorWithHue:startColor.hue saturation:startColor.saturation brightness:startColor.brightness alpha:startColor.alpha]
                         previousColor:startColor];

    [self setPrimaryColor:startColor];

    self.alphaSlider.hidden = !showAlpha;

    return self;
}

- (void)makeViewDynamic:(UIView *)view {
    CGRect dynamicFrame = view.frame;
    if (!self.alphaSlider.hidden)
        dynamicFrame.size.height = self.alphaSlider.frame.origin.y +
                                   self.mainViewController.view.frame.size.width / 6 + self.alphaSlider.frame.size.height;
    else
        dynamicFrame.size.height = self.brightnessSlider.frame.origin.y +
                                   self.mainViewController.view.frame.size.width / 6 + self.brightnessSlider.frame.size.height;

    view.frame = dynamicFrame;
}

+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
    return [[PFColorAlert alloc] initWithStartColor:startColor showAlpha:showAlpha];
}

- (void)displayWithCompletion:(void (^)(UIColor *pickedColor))completionBlock {
    if (self.isOpen)
        return;

    self.completionBlock = completionBlock;

    [self.popWindow makeKeyAndVisible];

    [UIView animateWithDuration:0.3f animations:^{
        self.darkeningWindow.alpha = 1.0f;
        self.popWindow.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.isOpen = YES;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        self.darkeningWindow.userInteractionEnabled = YES;
        [self.darkeningWindow addGestureRecognizer:tgr];

        NSString *prefPath = @"/var/mobile/Library/Preferences/com.pixelfiredev.libcolorpicker.plist";
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];
        if (!dict)
            dict = [NSMutableDictionary new];

        NSString *kDidShow = @"didShowWelcomeScreen";
        if (!dict[kDidShow])
            LCPShowTwitterFollowAlert(@"Welcome to libcolorpicker!", @"Hey there! Thanks for installing libcolorpicker (the color picker library for devs)! If you'd like to follow our team on Twitter for more updates, tweak giveaways and other cool stuff, hit the button below!", @"PixelFireDev");

        [dict setObject:@YES forKey:kDidShow];
        [dict writeToFile:prefPath atomically:YES];
    }];
}

- (void)showWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha completion:(void (^)(UIColor *pickedColor))completionBlock {
    UIAlertView *deprecated = [[UIAlertView alloc] initWithTitle:@"libcolorpicker" message:@"Hey! It appears like this preference bundle is trying to use deprecated methods to invoke the color picker and requires an update. Please inform the dev of this tweak about it."
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [deprecated show];
}

- (void)setPrimaryColor:(UIColor *)primary {
    [self.litePreviewView updateWithColor:primary];

    [self.saturationSlider updateGraphicsWithColor:primary];
    [self.brightnessSlider updateGraphicsWithColor:primary];
    [self.alphaSlider updateGraphicsWithColor:primary];

    // THIS LINE SHOULD BE ACTIVE BUT DISABLED IT FOR NOW
    // UNTIL WE CAN GET THE HUE SLIDER WORKING
    [self.haloView setValue:primary.hue];
}

- (void)hueChanged:(float)hue {
    UIColor *color = [UIColor colorWithHue:hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha];
    [self.litePreviewView updateWithColor:color];
    [self.saturationSlider updateGraphicsWithColor:color];
    [self.brightnessSlider updateGraphicsWithColor:color];
    [self.alphaSlider updateGraphicsWithColor:color];
}

- (void)saturationChanged:(UISlider *)_slider {
    UIColor *color = [UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:_slider.value brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha];
    [self.litePreviewView updateWithColor:color];
    [self.saturationSlider updateGraphicsWithColor:color];
    [self.alphaSlider updateGraphicsWithColor:color];
}

- (void)brightnessChanged:(UISlider *)_slider {
    UIColor *color = [UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:self.litePreviewView.mainColor.saturation brightness:_slider.value alpha:self.litePreviewView.mainColor.alpha];
    [self.litePreviewView updateWithColor:color];
    [self.brightnessSlider updateGraphicsWithColor:color];
    [self.alphaSlider updateGraphicsWithColor:color];
}

- (void)alphaChanged:(UISlider *)_slider {
    UIColor *color = [UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:_slider.value];
    [self.litePreviewView updateWithColor:color];
    [self.alphaSlider updateGraphicsWithColor:color];
}

- (void)chooseHexColor {
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Hex Color"
                                                     message:@"Enter a hex color or copy it to your pasteboard."
                                                    delegate:self
                                           cancelButtonTitle:@"Close"
                                           otherButtonTitles:@"Set", @"Copy", nil];
    prompt.delegate = self;
    [prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[prompt textFieldAtIndex:0] setText:[UIColor hexFromColor:self.litePreviewView.mainColor]];
    [prompt show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([[alertView textFieldAtIndex:0].text hasPrefix:@"#"] && [UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text])
            [self setPrimaryColor:[UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text]];
    } else if (buttonIndex == 2) {
        [[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:self.litePreviewView.mainColor]];
    }
}

- (void)close {
    if (!self.isOpen)
        return;

    [UIView animateWithDuration:0.3f animations:^{
        self.darkeningWindow.alpha = 0.0f;
        self.popWindow.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (self.completionBlock)
            self.completionBlock(self.litePreviewView.mainColor);

        self.popWindow.hidden = YES;
        self.isOpen = NO;
    }];
}

@end
