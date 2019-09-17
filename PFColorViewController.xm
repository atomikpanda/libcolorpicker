//
//  ColorViewController.m
//  UIColors
//
//  Created by Bailey Seymour on 1/23/14.
//
//
#import "PSSpecifier.h"

@interface UIViewController ()
- (id)initForContentSize:(CGSize)size;
@end


#if TARGET_OS_IPHONE
#import "PFColorViewController.h"
#import "PFColorPicker.h"
#import "UIColor+PFColor.h"
#import "PFColorTransparentView.h"
#import <objc/runtime.h>

@interface UIPushedView : UIView
@end

@implementation UIPushedView

- (void)setFrame:(CGRect)frame {
    frame.origin.y = 64;
    if (self.superview)
        frame.size.height = self.superview.frame.size.height - 64;
    [super setFrame:frame];
}

@end

@interface PFColorViewController () <PFColorPickerDelegate, UIAlertViewDelegate> {
    UIColor *_loadedColor;
    UIView *_backdrop;
    PFColorTransparentView *_transparent;
    CGSize _size;

    // HSB
    UISlider *_hueSlider;
    UISlider *_saturationSlider;
    UISlider *_brightnessSlider;
    UISlider *_alphaSlider;

    UIView *_controlsContainer;
    UIBarButtonItem *_hexButton;
    CGFloat _currentAlpha;
    UIPushedView *_pushedView;
}

@property (nonatomic, retain) PFColorPicker *colorPicker;
@end

@implementation PFColorViewController

#ifdef __cplusplus /* If this is a C++ compiler, use C linkage */
extern "C" {
#endif
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);

#ifdef __cplusplus /* If this is a C++ compiler, end C linkage */
}
#endif

- (UIColor *)colorFromDefaults:(NSString *)def withKey:(NSString *)key {
    UIColor *color = colorFromDefaultsWithKey(def, key, self.fallback);

    _currentAlpha = color.alpha;
    _alphaSlider.value = color.alpha;

    return color;
}

#define isiPhone4 ([[UIScreen mainScreen] bounds].size.height == 480)

- (id)initForContentSize:(CGSize)size {
    if ([%c(PSViewController) instancesRespondToSelector:@selector(initForContentSize:)])
        self = [super initForContentSize:size];
    else
        self = [super init];

    _size = size;

    _pushedView = [[UIPushedView alloc] initWithFrame:CGRectMake(0, 64, size.width, size.height - 64)];
    _pushedView.alpha = 0;
    [self.view addSubview:_pushedView];

    return self;
}

- (id)initForContentSize:(CGSize)size
                defaults:(NSString *)cdefaults
                     key:(NSString *)ckey
                 usesRGB:(BOOL)cusesRGB
               usesAlpha:(BOOL)cusesAlpha
        postNotification:(NSString *)cpostNotification
                fallback:(NSString *)cfallback {
    self = [self initForContentSize:size];
    self.defaults = cdefaults;
    self.key = ckey;
    self.usesRGB = cusesRGB;
    self.usesAlpha = cusesAlpha;
    self.postNotification = cpostNotification;
    self.fallback = cfallback;

    return self;
}

- (void)loadCustomViews {
    _pushedView.frame = CGRectMake(0, 20 + 44, _size.width, _size.height - 64);

    _currentAlpha = 1;

    if (_transparent)
        [_transparent setFrame:_pushedView.frame];
    else
        _transparent = [[PFColorTransparentView alloc] initWithFrame:_pushedView.frame];

    if (!self.usesAlpha)
        _transparent.hidden = YES;

    CGFloat height = _pushedView.frame.size.height / 2;

    if (isiPhone4)
        height -= 40;

    CGRect colorPickerFrame = CGRectMake(0, 0, _pushedView.frame.size.width, height);
    if (self.colorPicker)
        [self.colorPicker setFrame:colorPickerFrame];
    else
        self.colorPicker = [[PFColorPicker alloc] initWithFrame:colorPickerFrame];
    [self.colorPicker makeReadyForDisplay];
    [self.colorPicker setDelegate:self];

    float controlsContainerHeight = self.usesAlpha ? 180 : 140;
    CGRect controlsContainerFrame = CGRectMake(0,
                                               _pushedView.frame.size.height - controlsContainerHeight,
                                               self.colorPicker.frame.size.width,
                                               controlsContainerHeight);
    if (_controlsContainer)
        [_controlsContainer setFrame:controlsContainerFrame];
    else
        _controlsContainer = [[UIView alloc] initWithFrame:controlsContainerFrame];

    float halfWidth = _controlsContainer.frame.size.width / 2;
    CGPoint red = CGPointMake(halfWidth, 30);
    CGPoint green = CGPointMake(halfWidth, red.y + 40);
    CGPoint blue = CGPointMake(halfWidth, green.y + 40);
    CGPoint alpha = CGPointMake(halfWidth, blue.y + 40);

    CGRect sliderFrame = CGRectMake(halfWidth, 0, _controlsContainer.frame.size.width - 40, 20);

    Class viewClass;
    if (%c(UIBackdropView))
        viewClass = %c(UIBackdropView);
    else
        viewClass = [UIView class];

    CGRect backdropFrame = CGRectMake(0, 0, _controlsContainer.frame.size.width, _controlsContainer.frame.size.height);
    if (_backdrop)
        [_backdrop setFrame:backdropFrame];
    else
        _backdrop = [[viewClass alloc] initWithFrame:backdropFrame];

    _hexButton = [[UIBarButtonItem alloc] initWithTitle:@"#"
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(chooseHexColor)];
    self.navigationItem.rightBarButtonItem = _hexButton;

    if (viewClass == [UIView class])
        [_backdrop setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5f]];

    if (_hueSlider)
        [_hueSlider setFrame:sliderFrame];
    else
        _hueSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    [_hueSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_hueSlider setCenter:red];

    [_hueSlider setMaximumValue:1];
    [_hueSlider setMinimumValue:0];
    _hueSlider.continuous = YES;

    if (_saturationSlider)
        [_saturationSlider setFrame:sliderFrame];
    else
        _saturationSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    [_saturationSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_saturationSlider setCenter:green];

    [_saturationSlider setMaximumValue:1];
    [_saturationSlider setMinimumValue:0];
    _saturationSlider.continuous = YES;

    if (_brightnessSlider)
        [_brightnessSlider setFrame:sliderFrame];
    else
        _brightnessSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    [_brightnessSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_brightnessSlider setCenter:blue];

    [_brightnessSlider setMaximumValue:1];
    [_brightnessSlider setMinimumValue:0];
    _brightnessSlider.continuous = YES;

    if (_alphaSlider)
        [_alphaSlider setFrame:sliderFrame];
    else
        _alphaSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    [_alphaSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
    [_alphaSlider setCenter:alpha];

    [_alphaSlider setMaximumValue:1];
    [_alphaSlider setMinimumValue:0];
    if (!self.usesAlpha)
        _alphaSlider.hidden = YES;

    // UIColor *loadColor = [self colorFromDefaults:self.defaults withKey:self.key];
    // currentAlpha = loadColor.alpha;
    // _alphaSlider.value = currentAlpha;
    // [self pickedColor:loadColor];

    _alphaSlider.continuous = YES;

    if (self.usesRGB) {
        // Tint For RGB
        if (![_hueSlider respondsToSelector:@selector(setTintColor:)]) {
            _hueSlider.minimumTrackTintColor = [UIColor redColor];
            _saturationSlider.minimumTrackTintColor = [UIColor greenColor];
            _brightnessSlider.minimumTrackTintColor = [UIColor blueColor];
            _alphaSlider.minimumTrackTintColor = [UIColor grayColor];
        } else {
            // iOS 7
            _hueSlider.tintColor = [UIColor redColor];
            _saturationSlider.tintColor = [UIColor greenColor];
            _brightnessSlider.tintColor = [UIColor blueColor];
            _alphaSlider.tintColor = [UIColor grayColor];
        }

        [_hueSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'R'] forState:UIControlStateNormal];
        [_saturationSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'G'] forState:UIControlStateNormal];
        [_brightnessSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'B'] forState:UIControlStateNormal];
        [_alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateNormal];
        [_alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateHighlighted];
    } else {
        // Tint for HSB
        UIColor *black = [UIColor blackColor];
        UIColor *gray = [UIColor grayColor];
        if (![_hueSlider respondsToSelector:@selector(setTintColor:)]) {
            _hueSlider.minimumTrackTintColor = black;
            _saturationSlider.minimumTrackTintColor = black;
            _brightnessSlider.minimumTrackTintColor = black;
            _alphaSlider.minimumTrackTintColor = gray;
        } else {
            // iOS 7
            _hueSlider.tintColor = black;
            _saturationSlider.tintColor = black;
            _brightnessSlider.tintColor = black;
            _alphaSlider.tintColor = gray;
        }

        [_hueSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'H'] forState:UIControlStateNormal];
        [_saturationSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'S'] forState:UIControlStateNormal];
        [_brightnessSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'B'] forState:UIControlStateNormal];
        [_alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateNormal];
        [_alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateHighlighted];
    }

    if (!_transparent.superview)
        [_pushedView addSubview:_transparent];

    if (!self.colorPicker.superview)
        [_pushedView addSubview:self.colorPicker];

    if (!_controlsContainer.superview)
        [_pushedView addSubview:_controlsContainer];

    if (!_backdrop.superview)
        [_controlsContainer addSubview:_backdrop];

    if (!_hueSlider.superview)
        [_controlsContainer addSubview:_hueSlider];

    if (!_saturationSlider.superview)
        [_controlsContainer addSubview:_saturationSlider];

    if (!_brightnessSlider.superview)
        [_controlsContainer addSubview:_brightnessSlider];

    if (!_alphaSlider.superview)
        [_controlsContainer addSubview:_alphaSlider];

    if (self.defaults && self.key) {
        _loadedColor = [self colorFromDefaults:self.defaults withKey:self.key];
        _currentAlpha = _loadedColor.alpha;
        _alphaSlider.value = _currentAlpha;
        [self pickedColor:_loadedColor];
    }

    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                            [_pushedView setAlpha:1];
                        }
                     completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)chooseHexColor {
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Hex Color" message:@"Enter a hex color or copy it to your pasteboard." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Set", @"Copy", nil];
    prompt.delegate = self;
    [prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[prompt textFieldAtIndex:0] setText:[UIColor hexFromColor:_pushedView.backgroundColor]];
    [prompt show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([[alertView textFieldAtIndex:0].text hasPrefix:@"#"] && [UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text])
            [self pickedColor:[UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text]];
    } else if (buttonIndex == 2) {
        [[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:_pushedView.backgroundColor]];
    }
}

+ (UIImage *)thumbImageWithColor:(UIColor *)color letter:(unichar)letter {
    CGFloat size = 28.0f;
    CGRect rect = CGRectMake(0.0f, 0.0f, size + 3, size + 8);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize shadowSize = CGSizeMake(0, 3);
    CGContextSetShadowWithColor(context, shadowSize, 4, [UIColor colorWithWhite:0 alpha:0.25f].CGColor);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextAddArc(context, rect.size.width / 2, rect.size.width / 2, size / 2, size / 2, 2 * M_PI, 1);
    CGContextSetStrokeColorWithColor(context, [[UIColor PF_colorWithHex:@"#f0f0f0"] colorWithAlphaComponent:0].CGColor);

    CGContextDrawPath(context, kCGPathFill);

    CGContextSetShadow(context, CGSizeMake(0, 0), 0);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextSetLineWidth(context, 2.0f);
    CGContextSelectFont(context, "Helvetica Neue Bold", 15.0f, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing(context, 1.7f);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextShowTextAtPoint(context, 10, 15, [NSString stringWithCharacters:&letter length:1].UTF8String, 1);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self performSelector:@selector(loadCustomViews) withObject:nil afterDelay:0];
    [self.colorPicker performSelector:@selector(saveCache) withObject:nil afterDelay:0.5f];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.postNotification && _loadedColor != [self colorFromDefaults:self.defaults withKey:self.key]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             (CFStringRef)self.postNotification,
                                             NULL,
                                             NULL,
                                             YES);
    }
}

- (void)hueSliderChanged {
    UIColor *color;
    if (!self.usesRGB)
        color = [UIColor colorWithHue:_hueSlider.value
                           saturation:_saturationSlider.value
                           brightness:_brightnessSlider.value
                                alpha:_alphaSlider.value];
    else
        color = [UIColor colorWithRed:_hueSlider.value
                                green:_saturationSlider.value
                                 blue:_brightnessSlider.value
                                alpha:_alphaSlider.value];

    [self pickedColor:color];
}

- (void)pickedColor:(UIColor *)color {
    [_pushedView setBackgroundColor:color];
    [self.view setBackgroundColor:color];

    if (!self.usesRGB) {
        CGFloat hue;
        CGFloat saturation;
        CGFloat brightness;

        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];

        [_hueSlider setValue:hue];
        [_saturationSlider setValue:saturation];
        [_brightnessSlider setValue:brightness];
    } else {
        CGFloat red;
        CGFloat green;
        CGFloat blue;

        [color getRed:&red green:&green blue:&blue alpha:NULL];
        [_hueSlider setValue:red];
        [_saturationSlider setValue:green];
        [_brightnessSlider setValue:blue];
    }

    if (self.usesAlpha) {
        _transparent.alpha = 1 - _alphaSlider.value;
        _currentAlpha = _alphaSlider.value;
    }

    NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.defaults]];

    if (!preferencesPlist)
        preferencesPlist = [NSMutableDictionary new];

    NSString *saveValue;
    if (self.usesAlpha)
        saveValue = [NSString stringWithFormat:@"%@:%f", [UIColor hexFromColor:color], _currentAlpha]; //should be something like @"#a1a1a1:0.5" with the the decimal being the alpha you can ge the color and alpha seperately by [value componentsSeparatedByString:@":"]
    else
        saveValue = [UIColor hexFromColor:color]; // should be something like @"#a1a1a1"

    if (saveValue && self.key) {
        [preferencesPlist setObject:saveValue forKey:self.key];
        [preferencesPlist writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.defaults] atomically:YES];
        CFPreferencesSetAppValue((CFStringRef)self.key,(CFStringRef)saveValue, (CFStringRef)self.defaults);
        CFPreferencesAppSynchronize((CFStringRef)self.defaults);
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self.colorPicker saveCache];

    _size = self.view.frame.size;
    _size.height = _size.height - 20 - 44;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self loadCustomViews];
    }
    completion:nil];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
#endif
