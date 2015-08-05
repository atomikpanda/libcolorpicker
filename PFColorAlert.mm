#import "PFColorAlert.h"
#import "PFHaloHueView.h"
#import "PFColorLitePreviewView.h"
#import "PFColorLiteSlider.h"
#import "UIColor+PFColor.h"
#import <objc/runtime.h>

@interface PFColorAlertViewController : UIViewController
@end

@interface PFColorAlert() <PFHaloHueViewDelegate>

- (PFColorAlert *)init;

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

@end

@implementation PFColorAlertViewController

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

@end

@implementation PFColorAlert
@synthesize popWindow;
@synthesize haloView;
@synthesize mainViewController;
@synthesize blurView;
@synthesize hexButton;
@synthesize darkeningWindow;
@synthesize brightnessSlider;
@synthesize saturationSlider;
@synthesize alphaSlider;
@synthesize litePreviewView;
@synthesize completionBlock;

- (PFColorAlert *)init
{
	[super init];

	self.isOpen = NO;

	UIColor *startColor = [UIColor whiteColor];

	self.darkeningWindow = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
	self.darkeningWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];

	CGRect winFrame = [UIScreen mainScreen].bounds;

	winFrame.origin.x = (winFrame.size.width * 0.09f) / 2;
	winFrame.origin.y = (winFrame.size.height * 0.09f) / 2;

	winFrame.size.width = winFrame.size.width - (winFrame.size.width * 0.09f);
	winFrame.size.height = winFrame.size.height - (winFrame.size.height * 0.09f);


	self.popWindow = [[[UIWindow alloc] initWithFrame:winFrame] autorelease];
	self.popWindow.layer.masksToBounds = true;
	self.popWindow.layer.cornerRadius = 15;

	self.mainViewController = [[[PFColorAlertViewController alloc] init] autorelease];
	self.mainViewController.view.frame = CGRectMake(0, 0, winFrame.size.width, winFrame.size.height);

	const CGRect mainFrame = self.mainViewController.view.frame;

	Class blurCls;
	if (objc_getClass("_UIBackdropView")) blurCls = objc_getClass("_UIBackdropView");
	else blurCls = [UIView class];

	if (blurCls != [UIView class])
	{
		NSObject *backSettings = [objc_getClass("_UIBackdropViewSettings") settingsForStyle:2010];
		self.blurView = (UIView *)[[[blurCls alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:backSettings] autorelease];
	}
	else
	{
		// UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		// self.blurView = [[[UIVisualEffectView alloc] initWithEffect:blurEffect] autorelease];
		// self.blurView.frame = CGRectMake(0, 0, mainFrame.size.width, mainFrame.size.height);

		 self.blurView = [[[blurCls alloc] initWithFrame:mainFrame] autorelease];
		 self.blurView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9f];
	}

	[self.blurView removeFromSuperview]; // <-- not sure why you're doing this but okay ¯\_(ツ)_/¯
	[self.mainViewController.view addSubview:self.blurView];

	CGRect haloViewFrame = CGRectMake((mainFrame.size.width / 2) - (((mainFrame.size.width / 3) * 2) / 2), (mainFrame.size.width / 6),
		(mainFrame.size.width / 3) * 2, (mainFrame.size.width / 3) * 2);

	self.haloView =
		// HUE HARDCODED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		[[[PFHaloHueView alloc] initWithFrame:haloViewFrame minValue:0 maxValue:1 value:startColor.hue delegate:self] autorelease];

	// [self.haloView makeReadyForDisplay];
	[self.haloView removeFromSuperview];
	[self.mainViewController.view addSubview:self.haloView];

	const CGRect sliderFrame = CGRectMake((mainFrame.size.width / 2) - (((mainFrame.size.width / 3) * 2) / 2),
			haloViewFrame.origin.y + haloViewFrame.size.height, (mainFrame.size.width / 3) * 2, 40);

	self.saturationSlider = [[[PFColorLiteSlider alloc] initWithFrame:sliderFrame color:startColor style:PFSliderBackgroundStyleSaturation] autorelease];
	[self.mainViewController.view addSubview:self.saturationSlider];

	CGRect brightnessSliderFrame = sliderFrame;
	brightnessSliderFrame.origin.y = brightnessSliderFrame.origin.y + brightnessSliderFrame.size.height;

	self.brightnessSlider = [[[PFColorLiteSlider alloc] initWithFrame:brightnessSliderFrame color:startColor style:PFSliderBackgroundStyleBrightness] autorelease];
	[self.mainViewController.view addSubview:self.brightnessSlider];

	CGRect alphaSliderFrame = brightnessSliderFrame;
	alphaSliderFrame.origin.y = alphaSliderFrame.origin.y + alphaSliderFrame.size.height;

	self.alphaSlider = [[[PFColorLiteSlider alloc] initWithFrame:alphaSliderFrame color:startColor style:PFSliderBackgroundStyleAlpha] autorelease];
	[self.mainViewController.view addSubview:self.alphaSlider];

	self.alphaSlider.hidden = NO; // defaulting to NO

	self.hexButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.hexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.hexButton addTarget:self action:@selector(chooseHexColor) forControlEvents:UIControlEventTouchUpInside];
	[self.hexButton setTitle:@"#" forState:UIControlStateNormal];
	self.hexButton.frame = CGRectMake(self.mainViewController.view.frame.size.width - (25 + 10), 10, 25, 25);
	[self.mainViewController.view addSubview:self.hexButton];

	CGRect litePreviewViewFrame = CGRectMake((mainFrame.size.width / 2) - (((mainFrame.size.width / 6) * 2) / 2),
		(((haloViewFrame.origin.y) + (haloViewFrame.size.height)) - (((mainFrame.size.width / 6) * 2)) - ((mainFrame.size.width / 6))),
		(mainFrame.size.width / 6) * 2, (mainFrame.size.width / 6) * 2);

	self.litePreviewView = [[[PFColorLitePreviewView alloc] initWithFrame:litePreviewViewFrame 	// HUE HARDCODED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		mainColor:[UIColor colorWithHue:startColor.hue saturation:startColor.saturation brightness:startColor.brightness alpha:startColor.alpha] previousColor: startColor] autorelease];

	[self.litePreviewView removeFromSuperview]; // why even xD adding view1 to view2 automatically removes view1 from its prior superview
	[self.mainViewController.view addSubview:self.litePreviewView];

	self.darkeningWindow.hidden = NO;
	self.darkeningWindow.alpha = 0.0f;
	[self.darkeningWindow makeKeyAndVisible];

	self.popWindow.rootViewController = self.mainViewController;
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

- (PFColorAlert *)initWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha
{
	[self init];

	[self.haloView setValue:startColor.hue];
	[self.saturationSlider updateGraphicsWithColor:startColor];
	[self.brightnessSlider updateGraphicsWithColor:startColor];
	[self.alphaSlider updateGraphicsWithColor:startColor];
	// [self.litePreviewView setMainColor:[UIColor colorWithHue:startColor.hue saturation:startColor.saturation brightness:startColor.brightness alpha:startColor.alpha] previousColor:startColor];

	[self setPrimaryColor:startColor];

	self.alphaSlider.hidden = showAlpha ? 0 : 1; // invert logic

	return self;
}

- (void)makeViewDynamic:(UIView *)view
{
	CGRect dynamicFrame = view.frame;
	if (!self.alphaSlider.hidden)
		dynamicFrame.size.height =
			self.alphaSlider.frame.origin.y + (self.mainViewController.view.frame.size.width / 6) + self.alphaSlider.frame.size.height;
	else
		dynamicFrame.size.height =
			self.brightnessSlider.frame.origin.y + (self.mainViewController.view.frame.size.width / 6) + self.brightnessSlider.frame.size.height;

	view.frame = dynamicFrame;
}

+ (PFColorAlert *)colorAlertWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha
{
	return [[[PFColorAlert alloc] initWithStartColor:startColor showAlpha:showAlpha] autorelease];
}

- (void)displayWithCompletion:(void (^)(UIColor *pickedColor))fcompletionBlock
{
	if (self.isOpen) return;

	self.completionBlock = fcompletionBlock;

	[self retain];

	[self.popWindow makeKeyAndVisible];

	[UIView animateWithDuration:0.3f animations:^{

		self.darkeningWindow.alpha = 1.0f;
		self.popWindow.alpha = 1.0f;

	} completion:^(BOOL finished) {

		self.isOpen = YES;
		UITapGestureRecognizer *tgr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)] autorelease];
		self.darkeningWindow.userInteractionEnabled = YES;
		[self.darkeningWindow addGestureRecognizer:tgr];

	}];
}

- (void)showWithStartColor:(UIColor *)startColor showAlpha:(BOOL)showAlpha completion:(void (^)(UIColor *pickedColor))fcompletionBlock
{
		UIAlertView *deprecated = [[UIAlertView alloc] initWithTitle:@"libColorPicker" message:@"Hey! It appears like this preference bundle is trying to use deprecated methods to invoke the color picker and requires an update. Please inform the dev of this tweak about it." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[deprecated show];
		[deprecated release];
}

- (void)setPrimaryColor:(UIColor *)primary
{
	//UIColor *pr = [primary retain];
	[self.litePreviewView updateWithColor:primary];

	[self.saturationSlider updateGraphicsWithColor:primary];
	[self.brightnessSlider updateGraphicsWithColor:primary];
	[self.alphaSlider updateGraphicsWithColor:primary];
}

- (void)hueChanged:(float)hue
{
	[self.litePreviewView updateWithColor:
		[UIColor colorWithHue:hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha]];

	[self.saturationSlider updateGraphicsWithColor:
		[UIColor colorWithHue:hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha]];

	[self.brightnessSlider updateGraphicsWithColor:
		[UIColor colorWithHue:hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha]];

	[self.alphaSlider updateGraphicsWithColor:
		[UIColor colorWithHue:hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha]];
}

- (void)saturationChanged:(UISlider *)_slider
{
	[self.litePreviewView updateWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:_slider.value brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha]];

	[self.saturationSlider updateGraphicsWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:_slider.value brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha]];

	[self.alphaSlider updateGraphicsWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:_slider.value brightness:self.litePreviewView.mainColor.brightness alpha:self.litePreviewView.mainColor.alpha]];
}

- (void)brightnessChanged:(UISlider *)_slider
{
	[self.litePreviewView updateWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:self.litePreviewView.mainColor.saturation brightness:_slider.value alpha:self.litePreviewView.mainColor.alpha]];

	[self.brightnessSlider updateGraphicsWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:self.litePreviewView.mainColor.saturation brightness:_slider.value alpha:self.litePreviewView.mainColor.alpha]];

	[self.alphaSlider updateGraphicsWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:self.litePreviewView.mainColor.saturation brightness:_slider.value alpha:self.litePreviewView.mainColor.alpha]];
}

- (void)alphaChanged:(UISlider *)_slider
{
	[self.litePreviewView updateWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:_slider.value]];

	[self.alphaSlider updateGraphicsWithColor:
		[UIColor colorWithHue:self.litePreviewView.mainColor.hue saturation:self.litePreviewView.mainColor.saturation brightness:self.litePreviewView.mainColor.brightness alpha:_slider.value]];
}

- (void)chooseHexColor
{
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Hex Color" message:@"Enter a hex color or copy it to your pasteboard." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Set", @"Copy", nil];
	prompt.delegate = self;
	[prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
	[[prompt textFieldAtIndex:0] setText:[UIColor hexFromColor:self.litePreviewView.mainColor]];
	[prompt show];
	[prompt release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		if ([[alertView textFieldAtIndex:0].text hasPrefix:@"#"] && [UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text])
		{
			[self setPrimaryColor:[UIColor PF_colorWithHex:[alertView textFieldAtIndex:0].text]];
		}
	}
	else if (buttonIndex == 2)
	{
		[[UIPasteboard generalPasteboard] setString:[UIColor hexFromColor:self.litePreviewView.mainColor]];
	}
}

- (void)close
{
	if (!self.isOpen) return;

	[UIView animateWithDuration:0.3f animations:^{

		self.darkeningWindow.alpha = 0.0f;
		self.popWindow.alpha = 0.0f;

	} completion:^(BOOL finished) {

		if (self.completionBlock)
		self.completionBlock(self.litePreviewView.mainColor);

		self.popWindow.hidden = YES;
		self.isOpen = NO;

		[self release];

	}];
}

- (void)dealloc
{
	self.popWindow = nil;
	self.haloView = nil;
	self.mainViewController = nil;
	self.blurView = nil;
	self.hexButton = nil;
	self.darkeningWindow = nil;
	self.brightnessSlider = nil;
	self.saturationSlider = nil;
	self.alphaSlider = nil;
	self.litePreviewView = nil;
	self.completionBlock = nil;

	[super dealloc];
}

@end
