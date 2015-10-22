//
//  ColorViewController.m
//  UIColors
//
//  Created by Bailey Seymour on 1/23/14.
//
//
#import "PSSpecifier.h"

@interface UIViewController()
- (id)initForContentSize:(CGSize)size;
@end


@interface PSViewController : UIViewController
{
	UIViewController *_parentController;
	id *_rootController;
	PSSpecifier *_specifier;
}

- (void)statusBarWillAnimateByHeight:(double)arg1;
- (_Bool)canBeShownFromSuspendedState;
- (void)formSheetViewDidDisappear;
- (void)formSheetViewWillDisappear;
- (void)popupViewDidDisappear;
- (void)popupViewWillDisappear;
- (void)handleURL:(id)arg1;
- (void)pushController:(id)arg1;
- (void)didWake;
- (void)didUnlock;
- (void)willUnlock;
- (void)didLock;
- (void)suspend;
- (void)willBecomeActive;
- (void)willResignActive;
- (id)readPreferenceValue:(id)arg1;
- (void)setPreferenceValue:(id)arg1 specifier:(id)arg2;
- (id)specifier;
- (void)setSpecifier:(id)arg1;
- (void)dealloc;
- (id)rootController;
- (void)setRootController:(id)arg1;
- (id)parentController;
- (void)setParentController:(id)arg1;
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

- (void)setFrame:(CGRect)frame
{
	frame.origin.y = 64;
	if (self.superview) frame.size.height = self.superview.frame.size.height - 64;
	[super setFrame:frame];
}

@end

@interface PFColorViewController ()  <PFColorPickerDelegate, UIAlertViewDelegate>
{
	UIColor *loadedColor;
	UIView *backdrop;
	PFColorTransparentView *transparent;

	//HSB
	UISlider *hueSlider;
	UISlider *saturationSlider;
	UISlider *brightnessSlider;
	UISlider *alphaSlider;

	UIView *controlsContainer;
	UIBarButtonItem *hexButton;


	CGFloat currentAlpha;

	UIPushedView *_pushedView;
}

@property (nonatomic, retain) PFColorPicker *colorPicker;
@end

@implementation PFColorViewController
@synthesize colorPicker, key, defaults, postNotification, fallback;

#ifdef __cplusplus /* If this is a C++ compiler, use C linkage */
extern "C" {
#endif
UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);

#ifdef __cplusplus /* If this is a C++ compiler, end C linkage */
}
#endif

- (UIColor *)colorFromDefaults:(NSString*)def withKey:(NSString*)aKey
{
	UIColor *_color = colorFromDefaultsWithKey(def, key, self.fallback);

	currentAlpha = _color.alpha;
	alphaSlider.value = _color.alpha;

	return _color;
	// NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", def]];
	// //light gray fallback
	// UIColor *fallbackColor = [UIColor PF_colorWithHex:self.fallback];

	// if(preferencesPlist&&[preferencesPlist objectForKey:aKey]) {
	//     NSString *value = [preferencesPlist objectForKey:aKey];
	//     NSArray *colorAndOrAlpha = [value componentsSeparatedByString:@":"];
	//     if([value rangeOfString:@":"].location != NSNotFound){

	//     if([colorAndOrAlpha objectAtIndex:1]) {
	//         currentAlpha = [colorAndOrAlpha[1] floatValue];
	//         alphaSlider.value = [colorAndOrAlpha[1] floatValue];
	//     }
	//     }
	//     else {
	//         currentAlpha = 1;
	//         alphaSlider.value = 1;
	//     }

	//     if(!value) return fallbackColor;

	//     NSString *color = colorAndOrAlpha[0];

	//     return [[UIColor PF_colorWithHex:color] colorWithAlphaComponent:currentAlpha];
	// }
	// else {
	//     return fallbackColor;
	// }

}

#define isiPhone4 ([[UIScreen mainScreen] bounds].size.height == 480) ? TRUE : FALSE
CGSize _size;

- (id)initForContentSize:(CGSize)size
{
	if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)])
		self = [super initForContentSize:size];
	else
		self = [super init];

	_size = size;

	_pushedView = [[[UIPushedView alloc] initWithFrame:CGRectMake(0, 64, size.width, size.height - 64)] autorelease];
	_pushedView.alpha = 0;
	[self.view addSubview:_pushedView];

	return self;
}

- (id)initForContentSize:(CGSize)size defaults:(NSString *)cdefaults key:(NSString *)ckey usesRGB:(BOOL)cusesRGB usesAlpha:(BOOL)cusesAlpha postNotification:(NSString *)cpostNotification fallback:(NSString *)cfallback
{
	self = [self initForContentSize:size];
	self.defaults = cdefaults;
	self.key = ckey;
	self.usesRGB = cusesRGB;
	self.usesAlpha = cusesAlpha;
	self.postNotification = cpostNotification;
	self.fallback = cfallback;

	return self;
}

- (void)loadCustomViews
{
	_pushedView.frame = CGRectMake(0, 20 + 44, _size.width, _size.height - 64);

	currentAlpha = 1;

	transparent ? [transparent setFrame:_pushedView.frame] : (transparent = [[PFColorTransparentView alloc] initWithFrame:_pushedView.frame]);
	if (!self.usesAlpha) transparent.hidden = YES;

	CGFloat height = _pushedView.frame.size.height / 2;

	if (isiPhone4)
		height = height - 40;

	CGRect colorPickerFrame = CGRectMake(0, 0, _pushedView.frame.size.width, height);
	self.colorPicker ? [self.colorPicker setFrame:colorPickerFrame] : (self.colorPicker = [[[PFColorPicker alloc] initWithFrame:colorPickerFrame] autorelease]);
	[self.colorPicker makeReadyForDisplay];
	[self.colorPicker setDelegate:self];

	CGRect controlsContainerFrame = CGRectMake((_pushedView.frame.size.width / 2) - (_pushedView.frame.size.width / 2), _pushedView.frame.size.height - (self.usesAlpha ? 180 : 140), self.colorPicker.frame.size.width, (self.usesAlpha ? 180 : 140));
	controlsContainer ? [controlsContainer setFrame:controlsContainerFrame] : (controlsContainer = [[[UIView alloc] initWithFrame:controlsContainerFrame] autorelease]);

	CGPoint red = CGPointMake(controlsContainer.frame.size.width / 2, 30);
	CGPoint green = CGPointMake(controlsContainer.frame.size.width / 2, red.y + 40);
	CGPoint blue = CGPointMake(controlsContainer.frame.size.width / 2, green.y + 40);
	CGPoint alpha = CGPointMake(controlsContainer.frame.size.width / 2, blue.y + 40);

	CGRect sliderFrame = CGRectMake(controlsContainer.frame.size.width / 2, 0, controlsContainer.frame.size.width - 40, 20);

	Class viewClass;
	if (objc_getClass("_UIBackdropView"))
		viewClass = NSClassFromString(@"_UIBackdropView");
	else
		viewClass = [UIView class];

	CGRect backdropFrame = CGRectMake(0, 0, controlsContainer.frame.size.width, controlsContainer.frame.size.height);
	backdrop ? [backdrop setFrame:backdropFrame] : (backdrop = [[[viewClass alloc] initWithFrame:backdropFrame] autorelease]);


	hexButton = [[UIBarButtonItem alloc] initWithTitle:@"#" style:UIBarButtonItemStylePlain target:self action:@selector(chooseHexColor)];
	self.navigationItem.rightBarButtonItem = hexButton;

	if (viewClass == [UIView class])
		[backdrop setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5f]];

	hueSlider ? [hueSlider setFrame:sliderFrame] : (hueSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease]);
	[hueSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
	[hueSlider setCenter:red];

	[hueSlider setMaximumValue:1];
	[hueSlider setMinimumValue:0];
	hueSlider.continuous = YES;

	saturationSlider ? [saturationSlider setFrame:sliderFrame] : (saturationSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease]);
	[saturationSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
	[saturationSlider setCenter:green];

	[saturationSlider setMaximumValue:1];
	[saturationSlider setMinimumValue:0];
	saturationSlider.continuous = YES;

	brightnessSlider ? [brightnessSlider setFrame:sliderFrame] : (brightnessSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease]);
	[brightnessSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
	[brightnessSlider setCenter:blue];

	[brightnessSlider setMaximumValue:1];
	[brightnessSlider setMinimumValue:0];
	brightnessSlider.continuous = YES;

	alphaSlider ? [alphaSlider setFrame:sliderFrame] : (alphaSlider = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease]);
	[alphaSlider addTarget:self action:@selector(hueSliderChanged) forControlEvents:UIControlEventValueChanged];
	[alphaSlider setCenter:alpha];

	[alphaSlider setMaximumValue:1];
	[alphaSlider setMinimumValue:0];
	if (!self.usesAlpha) alphaSlider.hidden = YES;

	// UIColor *loadColor = [self colorFromDefaults:self.defaults withKey:self.key];
	// currentAlpha = loadColor.alpha;
	// alphaSlider.value = currentAlpha;
	// [self pickedColor:loadColor];

	alphaSlider.continuous = YES;

	if (self.usesRGB)
	{
		//Tint For RGB
		if (![hueSlider respondsToSelector:@selector(setTintColor:)]){
			hueSlider.minimumTrackTintColor = [UIColor redColor];
			saturationSlider.minimumTrackTintColor = [UIColor greenColor];
			brightnessSlider.minimumTrackTintColor = [UIColor blueColor];
			alphaSlider.minimumTrackTintColor = [UIColor grayColor];
		}
		else
		{
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
		else
		{
			//Tint for HSB
			if (![hueSlider respondsToSelector:@selector(setTintColor:)])
			{
				hueSlider.minimumTrackTintColor =        [UIColor blackColor];
				saturationSlider.minimumTrackTintColor = [UIColor blackColor];
				brightnessSlider.minimumTrackTintColor = [UIColor blackColor];
				alphaSlider.minimumTrackTintColor = [UIColor grayColor];
			}
			else
			{
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

			if (!transparent.superview)
				[_pushedView addSubview:transparent];

			if (!self.colorPicker.superview)
				[_pushedView addSubview:self.colorPicker];

			if (!controlsContainer.superview)
				[_pushedView addSubview:controlsContainer];

			if (!backdrop.superview)
				[controlsContainer addSubview:backdrop];

			if (!hueSlider.superview)
				[controlsContainer addSubview:hueSlider];

			if (!saturationSlider.superview)
				[controlsContainer addSubview:saturationSlider];

			if (!brightnessSlider.superview)
				[controlsContainer addSubview:brightnessSlider];

			if (!alphaSlider.superview)
				[controlsContainer addSubview:alphaSlider];

			if (self.defaults && self.key)
			{
				loadedColor = [self colorFromDefaults:self.defaults withKey:self.key];
				currentAlpha = loadedColor.alpha;
				alphaSlider.value = currentAlpha;
				[self pickedColor:loadedColor];
				[[loadedColor retain] autorelease];
			}


		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

			[_pushedView setAlpha:1];

		}
		completion:nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)chooseHexColor
{
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Hex Color" message:@"Enter a hex color or copy it to your pasteboard." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Set", @"Copy", nil];
	prompt.delegate = self;
	[prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
	[[prompt textFieldAtIndex:0] setText:[UIColor hexFromColor:_pushedView.backgroundColor]];
	[prompt show];
	[prompt release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		if ([[alertView textFieldAtIndex:0].text hasPrefix:@"#"] && [UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text])
		{
			[self pickedColor:[UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text]];
		}
	}
	else if (buttonIndex == 2)
	{
		[[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:_pushedView.backgroundColor]];
	}
}

+ (UIImage *)thumbImageWithColor:(UIColor *)color letter:(unichar)letter
{
	CGFloat size = 28.0f;
	CGRect rect = CGRectMake(0.0f, 0.0f, size + 3, size + 8);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize shadowSize = CGSizeMake(0, 3);
	CGContextSetShadowWithColor(context, shadowSize, 4, [UIColor colorWithWhite:0 alpha:0.25f].CGColor);
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextAddArc(context,rect.size.width / 2, rect.size.width / 2, size / 2, size / 2, 2 * M_PI, 1);
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self performSelector:@selector(loadCustomViews) withObject:nil afterDelay:0];
	[self.colorPicker performSelector:@selector(saveCache) withObject:nil afterDelay:0.5f];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if (self.postNotification && (loadedColor != [self colorFromDefaults:self.defaults withKey:self.key]))
	{
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
												(CFStringRef)self.postNotification,
												NULL,
												NULL,
												YES);
	}
}

- (void)hueSliderChanged
{
	UIColor *color;
	if (!self.usesRGB)
		color = (UIColor*)[UIColor colorWithHue:hueSlider.value saturation:saturationSlider.value brightness:brightnessSlider.value alpha:alphaSlider.value];
	else
		color = (UIColor*)[UIColor colorWithRed:hueSlider.value green:saturationSlider.value blue:brightnessSlider.value alpha:alphaSlider.value];

	[self pickedColor:color];
}

- (void)pickedColor:(UIColor *)color
{
	[_pushedView setBackgroundColor:color];
	[self.view setBackgroundColor:color];

	if (!self.usesRGB)
	{
		CGFloat hue;
		CGFloat saturation;
		CGFloat brightness;

		[color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];

		[hueSlider setValue:hue];
		[saturationSlider setValue:saturation];
		[brightnessSlider setValue:brightness];
	}
	else
	{
		CGFloat red;
		CGFloat green;
		CGFloat blue;

		[color getRed:&red green:&green blue:&blue alpha:NULL];
		[hueSlider setValue:red];
		[saturationSlider setValue:green];
		[brightnessSlider setValue:blue];
	}

	if (self.usesAlpha)
	{
		transparent.alpha = 1 - alphaSlider.value;
		currentAlpha = alphaSlider.value;
	}

	// hax ?
	NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.defaults]];

	if (!preferencesPlist)
		preferencesPlist = [[NSMutableDictionary new] autorelease];

	NSString *saveValue;
	if (self.usesAlpha)
		saveValue = [NSString stringWithFormat:@"%@:%f", [UIColor hexFromColor:color], currentAlpha]; //should be something like @"#a1a1a1:0.5" with the the decimal being the alpha you can ge the color and alpha seperately by [value componentsSeparatedByString:@":"]
	else
		saveValue = [UIColor hexFromColor:color]; // should be something like @"#a1a1a1"

	if (saveValue && self.key)
	{
		[preferencesPlist setObject:saveValue forKey:self.key];
		[preferencesPlist writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", self.defaults] atomically:YES];
		CFPreferencesSetAppValue((CFStringRef)self.key,(CFStringRef)saveValue, (CFStringRef)self.defaults);
		CFPreferencesAppSynchronize((CFStringRef)self.defaults);
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[self.colorPicker saveCache];

	if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
	{
		_size = self.view.frame.size;
		_size.height = (_size.height - 20) - 44;
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

			[self loadCustomViews];

		}
		completion:nil];
	}
	else // both cases seem to be executing the same code basically, right? if so, please fix
	{
		_size = self.view.frame.size;
		_size.height = (_size.height - 20) - 44;
		[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

			[self loadCustomViews];

		}
		completion:nil];
	}
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // Custom Method to determine this is on the iPad
	{
		return UIInterfaceOrientationMaskPortrait;//UIInterfaceOrientationMaskAll;
	}
	else
	{
		return UIInterfaceOrientationMaskPortrait;
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	self.colorPicker = nil;
	self.defaults = nil;
	self.key = nil;
	self.postNotification = nil;
	self.fallback = nil;

	[super dealloc];
}

@end
#endif
