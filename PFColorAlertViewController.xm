#import "PFColorAlertViewController.h"
#import "PFHaloHueView.h"
#import "PFColorLitePreviewView.h"
#import "PFColorLiteSlider.h"
#import "UIColor+PFColor.h"

@interface PFColorAlertViewController () <PFHaloHueViewDelegate> { 
    PFHaloHueView *_haloView;
    UIView *_blurView;
    UIButton *_hexButton;
    PFColorLiteSlider *_brightnessSlider;
    PFColorLiteSlider *_saturationSlider;
    PFColorLiteSlider *_alphaSlider;
    PFColorLitePreviewView *_litePreviewView;   
}
@end

@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(long long)style;
@end

@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)fitsSuperview settings:(_UIBackdropViewSettings *)settings;
@end


@implementation PFColorAlertViewController

- (id)initWithViewFrame:(CGRect)frame startColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha {
    self = [super init];

    self.view.frame = frame;

    if (%c(_UIBackdropView)) {
        _UIBackdropViewSettings *backSettings = [%c(_UIBackdropViewSettings) settingsForStyle:2010];
        _blurView = [[%c(_UIBackdropView) alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:backSettings];
    } else {
        _blurView = [[UIView alloc] initWithFrame:frame];
        _blurView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9f];
    }

    [self.view addSubview:_blurView];

    float padding = frame.size.width / 6;
    float width = frame.size.width - padding * 2;
    CGRect haloViewFrame = CGRectMake(padding, padding, width, width);

    _haloView = [[PFHaloHueView alloc] initWithFrame:haloViewFrame minValue:0 maxValue:1 value:startColor.hue delegate:self];
    [self.view addSubview:_haloView];

    const CGRect sliderFrame = CGRectMake(padding,
                                          haloViewFrame.origin.y + haloViewFrame.size.height,
                                          width,
                                          40);

    _saturationSlider = [[PFColorLiteSlider alloc] initWithFrame:sliderFrame color:startColor style:PFSliderBackgroundStyleSaturation];
    [self.view addSubview:_saturationSlider];

    CGRect brightnessSliderFrame = sliderFrame;
    brightnessSliderFrame.origin.y = brightnessSliderFrame.origin.y + brightnessSliderFrame.size.height;

    _brightnessSlider = [[PFColorLiteSlider alloc] initWithFrame:brightnessSliderFrame color:startColor style:PFSliderBackgroundStyleBrightness];
    [self.view addSubview:_brightnessSlider];

    CGRect alphaSliderFrame = brightnessSliderFrame;
    alphaSliderFrame.origin.y = alphaSliderFrame.origin.y + alphaSliderFrame.size.height;

    _alphaSlider = [[PFColorLiteSlider alloc] initWithFrame:alphaSliderFrame color:startColor style:PFSliderBackgroundStyleAlpha];
    [self.view addSubview:_alphaSlider];

    _hexButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_hexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_hexButton addTarget:self action:@selector(chooseHexColor) forControlEvents:UIControlEventTouchUpInside];
    [_hexButton setTitle:@"#" forState:UIControlStateNormal];
    _hexButton.frame = CGRectMake(self.view.frame.size.width - (25 + 10), 10, 25, 25);
    [self.view addSubview:_hexButton];

    float halfWidth = frame.size.width / 2;
    CGRect litePreviewViewFrame = CGRectMake(halfWidth - padding,
                                             haloViewFrame.origin.y + haloViewFrame.size.height - halfWidth,
                                             padding * 2,
                                             padding * 2);

    _litePreviewView = [[PFColorLitePreviewView alloc] initWithFrame:litePreviewViewFrame
                                                           mainColor:startColor
                                                       previousColor:startColor];
    [self.view addSubview:_litePreviewView];


    [_saturationSlider.slider addTarget:self action:@selector(saturationChanged:) forControlEvents:UIControlEventValueChanged];
    [_brightnessSlider.slider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
    [_alphaSlider.slider addTarget:self action:@selector(alphaChanged:) forControlEvents:UIControlEventValueChanged];

    _alphaSlider.hidden = !showAlpha;

    return self;
}

- (float)topMostSliderLastYCoordinate {
    UIView *firstVisibleSlider = !_alphaSlider.hidden ? _alphaSlider : _brightnessSlider;
    return firstVisibleSlider.frame.origin.y + firstVisibleSlider.frame.size.height;
}

- (void)setPrimaryColor:(UIColor *)primary {
    [_litePreviewView updateWithColor:primary];

    [_saturationSlider updateGraphicsWithColor:primary];
    [_brightnessSlider updateGraphicsWithColor:primary];
    [_alphaSlider updateGraphicsWithColor:primary];

    [_haloView setValue:primary.hue];
}

- (UIColor *)getColor {
    return _litePreviewView.mainColor;
}

- (void)hueChanged:(float)hue {
    UIColor *color = [UIColor colorWithHue:hue saturation:_litePreviewView.mainColor.saturation brightness:_litePreviewView.mainColor.brightness alpha:_litePreviewView.mainColor.alpha];
    [_litePreviewView updateWithColor:color];
    [_saturationSlider updateGraphicsWithColor:color hue:hue];
    [_brightnessSlider updateGraphicsWithColor:color hue:hue];
    [_alphaSlider updateGraphicsWithColor:color hue:hue];
}

- (void)saturationChanged:(UISlider *)slider {
    UIColor *color = [UIColor colorWithHue:_litePreviewView.mainColor.hue saturation:slider.value brightness:_litePreviewView.mainColor.brightness alpha:_litePreviewView.mainColor.alpha];
    [_litePreviewView updateWithColor:color];
    [_saturationSlider updateGraphicsWithColor:color];
    [_alphaSlider updateGraphicsWithColor:color];
}

- (void)brightnessChanged:(UISlider *)slider {
    UIColor *color = [UIColor colorWithHue:_litePreviewView.mainColor.hue saturation:_litePreviewView.mainColor.saturation brightness:slider.value alpha:_litePreviewView.mainColor.alpha];
    [_litePreviewView updateWithColor:color];
    [_brightnessSlider updateGraphicsWithColor:color];
    [_alphaSlider updateGraphicsWithColor:color];
}

- (void)alphaChanged:(UISlider *)slider {
    UIColor *color = [UIColor colorWithHue:_litePreviewView.mainColor.hue saturation:_litePreviewView.mainColor.saturation brightness:_litePreviewView.mainColor.brightness alpha:slider.value];
    [_litePreviewView updateWithColor:color];
    [_alphaSlider updateGraphicsWithColor:color];
}

- (void)chooseHexColor {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hex Color" message:@"Enter a hex color or copy it to your pasteboard." preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [UIColor hexFromColor:[self getColor]];
    }];
    
    // Set from hex color
    [alertController addAction:[UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = [alertController textFields].firstObject;
        if (!textField) return;
        
        NSString *userHexString = textField.text;
        if ([userHexString hasPrefix:@"#"] && [UIColor PF_colorWithHex:userHexString])
            [self setPrimaryColor:[UIColor PF_colorWithHex:userHexString]];
    }]];
    
    // Copy to pasteboard
    [alertController addAction:[UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:[self getColor]]];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)presentPasteHexStringQuestion:(NSString *)pasteboard {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Detected pasted color" message:@"It seems like your pasteboard consists of a hex color. Would you like to use it?" preferredStyle:UIAlertControllerStyleAlert];
    
    // Set from hex color
    [alertController addAction:[UIAlertAction actionWithTitle:@"Use pasteboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setPrimaryColor:[UIColor PF_colorWithHex:pasteboard]];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

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
