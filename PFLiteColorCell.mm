#import "PSTableCell.h"
#import "PSSpecifier.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
// #import <libcolorpicker.h>


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

@end

@interface NSDistributedNotificationCenter : NSNotificationCenter  {
}

@property BOOL suspended;

+ (id)defaultCenter;
+ (id)notificationCenterForType:(id)arg1;

- (void)setSuspended:(BOOL)arg1;
- (void)postNotification:(id)arg1;
- (id)addObserverForName:(id)arg1 object:(id)arg2 queue:(id)arg3 usingBlock:(id)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
- (void)postNotificationName:(id)arg1 object:(id)arg2;
- (void)removeObserver:(id)arg1 name:(id)arg2 object:(id)arg3;
- (id)init;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (BOOL)suspended;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 deliverImmediately:(BOOL)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 options:(unsigned int)arg4;
- (id)addObserverForName:(id)arg1 object:(id)arg2 suspensionBehavior:(unsigned int)arg3 queue:(id)arg4 usingBlock:(id)arg5;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4 suspensionBehavior:(unsigned int)arg5;

@end

//#import "ColorPicker.h"

@interface PFLiteColorCell : PSTableCell
{
	// UIView *_colorPreview;

}
@property (nonatomic, retain) UIView *colorPreview;
@property (nonatomic, assign) CFNotificationCallback callBack;
- (void)updateCellDisplay;
@end

@interface UIColor()
+ (NSString *)hexFromColor:(UIColor *)color;
@end

static void PFLiteColorCellNotifCB(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    PFLiteColorCell *l = (PFLiteColorCell *)observer;
    [UIView animateWithDuration:0.45
                         animations:^{
                           [l updateCellDisplay];
                         }
     completion:^(BOOL finished){}];

}

@implementation PFLiteColorCell

@synthesize colorPreview;

- (id)initWithStyle:(long long)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier
{

	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier];
	// if ([specifier respondsToSelector:@selector(properties)])
	// if (specifier && [[specifier properties] objectForKey:@"color_key"] && [[specifier properties] objectForKey:@"color_defaults"])
	// {

	// }

	return self;
}

// - (SEL)action
// {
// 	return @selector(openColorPicker);
// }
//
// - (id)target
// {
// 	return self;
// }

// - (SEL)cellAction
// {
// 	return @selector(openColorPicker);
// }

// - (id)cellTarget
// {
// 	return self;
// }

// - (void)openColorPicker
// {
// 	CFStringRef colorKey = (CFStringRef)[[self specifier] propertyForKey:@"key"];
// 	CFStringRef defaultKey = (CFStringRef)[[self specifier] propertyForKey:@"defaults"];
//
// 	//NSString *postNotification = [[self specifier] propertyForKey:@"postNotification"];
//
// 	PFColorAlert *alert = [PFColorAlert new];
// 			CFPreferencesAppSynchronize(defaultKey);
// 			UIColor *startColor = LCPParseColorString((NSString *)CFPreferencesCopyAppValue(colorKey,defaultKey), @"#000000:0"); // this color will be used at startup
// 			// show alert                               // Show alpha slider? // Code to run after close
// 			[alert showWithStartColor:startColor showAlpha:YES completion:
// 			^void (UIColor *pickedColor){
// 					_colorPreview.backgroundColor = pickedColor;
// 					// save pickedColor or do something with it
// 					NSString *hexString = [UIColor hexFromColor:pickedColor];
// 					hexString = [hexString stringByAppendingFormat:@":%g", pickedColor.alpha]; //if you want to use alpha
// 					//                                                                                                                              ^^ parse fallback to ^red
// 					// save hexString to your plist if desired
// 					CFPreferencesSetAppValue(colorKey, (CFStringRef)hexString, defaultKey);
// 					CFPreferencesAppSynchronize(defaultKey);
//
// 					//CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.delewhopper.statusbarcolorprefs.reloadPrefs"), NULL, NULL, TRUE);
//
// 			}];
// }

- (PSSpecifier *)specifier
{
  return [super specifier];
}

- (UIColor *)previewColor
{
  return [UIColor cyanColor];
}

- (void)updateCellDisplay
{
  self.colorPreview.backgroundColor = [self previewColor];
  self.detailTextLabel.text = [UIColor hexFromColor:[self previewColor]];
  self.detailTextLabel.alpha = 0.65;
}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];

	NSString *notificationId = [[self specifier] propertyForKey:@"NotificationListener"];

  if (notificationId)
  {

    CFNotificationCenterRemoveEveryObserver ( CFNotificationCenterGetDarwinNotifyCenter(),
    (void *)self);

    CFNotificationCenterAddObserver ( CFNotificationCenterGetDarwinNotifyCenter(),
      (void *)self,
      PFLiteColorCellNotifCB,
      (CFStringRef)notificationId,
      NULL,
      CFNotificationSuspensionBehaviorCoalesce
    );
  }

	self.colorPreview = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)] autorelease];
	// _colorPreview = colorPreview;
	self.colorPreview.tag = 199; //Stop UIColors from overriding the color :P
	self.colorPreview.layer.cornerRadius = self.colorPreview.frame.size.width / 2;
	self.colorPreview.layer.borderWidth = 2;
	self.colorPreview.layer.borderColor = [UIColor lightGrayColor].CGColor;
	//NSString *fallback = [_specifier.properties objectForKey:@"color_fallback"] ? [_specifier.properties objectForKey:@"color_fallback"] : @"#a1a1a1";//LCPParseColorString((NSString *)CFPreferencesCopyAppValue(colorKey,defaultKey), @"#000000:0");

	[self setAccessoryView:self.colorPreview];

  [self updateCellDisplay];



	// [_specifier setTarget:self];
	// [_specifier setButtonAction:@selector(openColorPicker)];
}

- (void)dealloc
{
  CFNotificationCenterRemoveEveryObserver ( CFNotificationCenterGetDarwinNotifyCenter(),
  (void *)self);
  self.colorPreview = nil;
	[super dealloc];
}

@end
