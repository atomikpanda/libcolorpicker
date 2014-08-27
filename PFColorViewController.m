//
//  ColorViewController.m
//  UIColors
//
//  Created by Bailey Seymour on 1/23/14.
//
//
#if TARGET_OS_IPHONE
#import "PFColorViewController.h"
#import "PFColorPicker.h"
#import "UIColor+PFColor.h"
#import "PFColorTransparentView.h"
#import <objc/runtime.h>

@interface PFColorViewController ()
{
    UIColor *loadedColor;
    UIView *backdrop;
}
@end

@implementation PFColorViewController

@synthesize colorPicker, title, key, defaults, postNotification;


- (UIColor*)colorFromDefaults:(NSString*)def withKey:(NSString*)aKey {
    NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", def]];
    //light gray fallback
    UIColor *fallback = [UIColor colorWithHex:@"#a1a1a1"];
    
    if(preferencesPlist&&[preferencesPlist objectForKey:aKey]) {
        NSString *value = [preferencesPlist objectForKey:aKey];
        NSArray *colorAndOrAlpha = [value componentsSeparatedByString:@":"];
        if([value rangeOfString:@":"].location != NSNotFound){
        
        if([colorAndOrAlpha objectAtIndex:1]) {
            currentAlpha = [colorAndOrAlpha[1] floatValue];
            alphaSlider.value = [colorAndOrAlpha[1] floatValue];
        }
        }

        if(!value) return fallback;
        
        NSString *color = colorAndOrAlpha[0];

        return [[UIColor colorWithHex:color] colorWithAlphaComponent:currentAlpha];
    }
    else {
        return fallback;
    }

}
- (id)init
{
    self = [super init];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBar.hidden = YES;
    
    // Do any additional setup after loading the view from its nib.
    if (self.colorPicker == nil) {
        currentAlpha = 1;

        transparent = [[PFColorTransparentView alloc] initWithFrame:self.view.frame];
        transparent.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;

        [self.view addSubview:transparent];
        if(!self.usesAlpha)
        transparent.hidden = YES;
        
        CGFloat height = self.view.frame.size.height/2;

        self.colorPicker = [[[PFColorPicker alloc] initWithFrame:CGRectMake(0, 64,self.view.frame.size.width, height)] autorelease];

        self.colorPicker.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
        [self.colorPicker makeReadyForDisplay];
        [self.view addSubview:self.colorPicker];
        
        CGFloat ccx = CGRectGetMidX(self.view.bounds) - self.view.frame.size.width / 2;
        CGFloat ccy = CGRectGetMidY(self.view.bounds) - 202 / 2;

        controlsContainer = [[[UIView alloc] initWithFrame:CGRectMake(ccx, ccy, self.colorPicker.frame.size.width, 180)] autorelease];
        
        controlsContainer.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
        
        
        if(!self.usesAlpha){
            CGRect newFrame = controlsContainer.frame;
            newFrame.size.height = newFrame.size.height-40;
            controlsContainer.frame = newFrame;
        }
        [controlsContainer setCenter:CGPointMake(0, 0)];
        [self.view addSubview:controlsContainer];
        [self.colorPicker setDelegate:self];


        CGPoint red = CGPointMake(controlsContainer.frame.size.width/2, 30);
        CGPoint green = CGPointMake(controlsContainer.frame.size.width/2,red.y+40);
        CGPoint blue = CGPointMake(controlsContainer.frame.size.width/2, green.y+40);
        CGPoint alpha = CGPointMake(controlsContainer.frame.size.width/2, blue.y+40);
        

        CGRect sliderFrame = CGRectMake(controlsContainer.frame.size.width/2, 0, controlsContainer.frame.size.width-30, 20);
        
        [controlsContainer setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height-(controlsContainer.frame.size.height/2))];
        Class viewClass;
        if(objc_getClass("_UIBackdropView"))
            viewClass = NSClassFromString(@"_UIBackdropView");
        else
            viewClass = [UIView class];
        

        backdrop = [[[viewClass alloc] initWithFrame:CGRectMake(0, 0, controlsContainer.frame.size.width, controlsContainer.frame.size.height)] autorelease];
        [controlsContainer addSubview:backdrop];
        
        UIButton *hexButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [hexButton setFrame:CGRectMake(0, 0, 20, 20)];
        [hexButton setTitle:@"#" forState:UIControlStateNormal];
        [hexButton addTarget:self action:@selector(chooseHexColor) forControlEvents:UIControlEventTouchUpInside];
        [controlsContainer addSubview:hexButton];
        
        if (viewClass == [UIView class]) {
            [backdrop setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
        }
        
        
        hueSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease];
        [hueSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
        [hueSlider setCenter:red];

        [hueSlider setMaximumValue:1];
        [hueSlider setMinimumValue:0];
        [controlsContainer addSubview:hueSlider];
        hueSlider.continuous = YES;
        
        saturationSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease];
        [saturationSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
        [saturationSlider setCenter:green];

        [saturationSlider setMaximumValue:1];
        [saturationSlider setMinimumValue:0];
        [controlsContainer addSubview:saturationSlider];
        saturationSlider.continuous = YES;
        
        brightnessSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease];
        [brightnessSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
        [brightnessSlider setCenter:blue];

        [brightnessSlider setMaximumValue:1];
        [brightnessSlider setMinimumValue:0];
        [controlsContainer addSubview:brightnessSlider];
        brightnessSlider.continuous = YES;

        alphaSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease];
        [alphaSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
        [alphaSlider setCenter:alpha];
        if(!self.usesAlpha)
            alphaSlider.hidden = YES;
        
        [alphaSlider setMaximumValue:1];
        [alphaSlider setMinimumValue:0];
        UIColor *loadColor = [self colorFromDefaults:self.defaults withKey:self.key];
        alphaSlider.value = currentAlpha;
        [self pickedColor:loadColor];
        
        
        [controlsContainer addSubview:alphaSlider];
        
        alphaSlider.continuous = YES;
        
        if (self.usesRGB) {
            //Tint For RGB
            if(![hueSlider respondsToSelector:@selector(setTintColor:)]){
            hueSlider.minimumTrackTintColor = [UIColor redColor];
            saturationSlider.minimumTrackTintColor = [UIColor greenColor];
            brightnessSlider.minimumTrackTintColor = [UIColor blueColor];
            alphaSlider.minimumTrackTintColor = [UIColor grayColor];
            }
            else {
                //iOS 7
                hueSlider.tintColor = [UIColor redColor];
                saturationSlider.tintColor = [UIColor greenColor];
                brightnessSlider.tintColor = [UIColor blueColor];
                alphaSlider.tintColor = [UIColor grayColor];
            }
            [hueSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'R'] forState:UIControlStateNormal];
            [saturationSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'G'] forState:UIControlStateNormal];
            [brightnessSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'B'] forState:UIControlStateNormal];
            [alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateNormal];
            [alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateHighlighted];
        }
        else {
            //Tint for HSB
            if(![hueSlider respondsToSelector:@selector(setTintColor:)]){
            hueSlider.minimumTrackTintColor =        [UIColor blackColor];
            saturationSlider.minimumTrackTintColor = [UIColor blackColor];
            brightnessSlider.minimumTrackTintColor = [UIColor blackColor];
            alphaSlider.minimumTrackTintColor = [UIColor grayColor];
            }
            else {
                //iOS 7
                hueSlider.tintColor = [UIColor blackColor];
                saturationSlider.tintColor = [UIColor blackColor];
                brightnessSlider.tintColor = [UIColor blackColor];
                alphaSlider.tintColor = [UIColor grayColor];
            }
            
            [hueSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'H'] forState:UIControlStateNormal];
            [saturationSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'S'] forState:UIControlStateNormal];
            [brightnessSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'B'] forState:UIControlStateNormal];
            [alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateNormal];
            [alphaSlider setThumbImage:[PFColorViewController thumbImageWithColor:[UIColor whiteColor] letter:'A'] forState:UIControlStateHighlighted];
        }
        

    }
	
}

- (void)chooseHexColor
{
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Hex Color" message:@"Enter a hex color or copy it to your pasteboard." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Set", @"Copy", nil];
    prompt.delegate = self;
    [prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[prompt textFieldAtIndex:0] setText:[UIColor hexFromColor:self.view.backgroundColor]];
    [prompt show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if ([[alertView textFieldAtIndex:0].text hasPrefix:@"#"] && [UIColor colorWithHex:[alertView textFieldAtIndex:0].text]) {
            [self pickedColor:[UIColor colorWithHex:[alertView textFieldAtIndex:0].text]];
        }
    }
    else if (buttonIndex == 2)
    {
        [[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:self.view.backgroundColor]];
    }
}

+ (UIImage *)thumbImageWithColor:(UIColor *)color letter:(unichar)letter {
    CGFloat size = 28.0f;
    CGRect rect = CGRectMake(0.0f, 0.0f, size+3, size+8);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize shadowSize = CGSizeMake(0, 3);
    CGContextSetShadowWithColor(context, shadowSize, 4,
                                [UIColor colorWithWhite:0 alpha:0.25].CGColor);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextAddArc(context,rect.size.width/2,rect.size.width/2,size/2,size/2,2*3.1415926535898,1);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithHex:@"#f0f0f0"] colorWithAlphaComponent:0].CGColor);

    CGContextDrawPath(context, kCGPathFill);
    
    CGContextSetShadow(context, CGSizeMake(0, 0), 0);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextSelectFont(context, "Helvetica Neue Bold", 15.0, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing(context, 1.7);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextShowTextAtPoint(context, 10, 15, [NSString stringWithCharacters:&letter length:1].UTF8String, 1);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.defaults && self.key)
    loadedColor = [self colorFromDefaults:self.defaults withKey:self.key];
    [[loadedColor retain] autorelease];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.postNotification && ( loadedColor !=  [self colorFromDefaults:self.defaults withKey:self.key] )) {
        CFNotificationCenterPostNotification(
                                             CFNotificationCenterGetDarwinNotifyCenter(),
                                             (CFStringRef)self.postNotification,
                                             NULL,
                                             NULL,
                                             YES
                                             );
    }
}

- (void)hueSliderChanged
{
    UIColor *color;
    if(!self.usesRGB)
    color = (UIColor*)[UIColor colorWithHue:hueSlider.value saturation:saturationSlider.value brightness:brightnessSlider.value alpha:alphaSlider.value];
    else
    color = (UIColor*)[UIColor colorWithRed:hueSlider.value green:saturationSlider.value blue:brightnessSlider.value alpha:alphaSlider.value];
    
    [self pickedColor:color];
}

- (void)pickedColor:(UIColor *)color {
    [self.view setBackgroundColor:color];
    if(!self.usesRGB){
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;

        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];

        [hueSlider setValue:hue];
        [saturationSlider setValue:saturation];
        [brightnessSlider setValue:brightness];
        
    }
    else {
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        
        [color getRed:&red green:&green blue:&blue alpha:NULL];
        [hueSlider setValue:red];
        [saturationSlider setValue:green];
        [brightnessSlider setValue:blue];

    }
    
    if(self.usesAlpha){
        transparent.alpha = 1-alphaSlider.value;
        currentAlpha = alphaSlider.value;
    }

    NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.defaults]];
    if(!preferencesPlist)
        preferencesPlist = [NSMutableDictionary new];
    NSString *saveValue;
    if(self.usesAlpha)
    saveValue = [NSString stringWithFormat:@"%@:%f", [UIColor hexFromColor:color], currentAlpha]; //should be something like @"#a1a1a1:0.5" with the the decimal being the alpha you can ge the color and alpha seperately by [value componentsSeparatedByString:@":"]
    else
        saveValue = [UIColor hexFromColor:color]; // should be something like @"#a1a1a1"
    

    [preferencesPlist setObject:saveValue forKey:self.key];
    [preferencesPlist writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.defaults] atomically:YES];

    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        self.colorPicker.center = CGPointMake((self.view.frame.size.width/2)+self.view.frame.size.width/6, (self.colorPicker.frame.size.height/2));
        controlsContainer.center = CGPointMake((controlsContainer.frame.size.width/2)+controlsContainer.frame.size.width/6, ((self.view.frame.size.height/2)+controlsContainer.frame.size.height)-14);

    }
    else {
        self.colorPicker.center = CGPointMake(self.view.frame.size.width/2, (self.colorPicker.frame.size.height/2));
        controlsContainer.center = CGPointMake(self.view.frame.size.width/2, ((self.view.frame.size.height)-(controlsContainer.frame.size.height)+(controlsContainer.frame.size.height/2)));
    }
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // Custom Method to determine this is on the iPad
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
#endif
