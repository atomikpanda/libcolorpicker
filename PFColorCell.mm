#import "PSTableCell.h"
#import "PSSpecifier.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


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

#import "ColorPicker.h"

@interface PFColorCell : PSTableCell
{

}
@end

@implementation PFColorCell

- (id)initWithStyle:(long long)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier
{

	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier];
	// if ([specifier respondsToSelector:@selector(properties)])
	// if (specifier && [[specifier properties] objectForKey:@"color_key"] && [[specifier properties] objectForKey:@"color_defaults"])
	// {

	// }

	return self;
}

- (SEL)action
{
	return @selector(openColorPicker);
}

- (id)target
{
	return self;
}

- (SEL)cellAction
{
	return @selector(openColorPicker);
}

- (id)cellTarget
{
	return self;
}

- (void)openColorPicker
{
	PSViewController *viewController = (PSViewController *) [self _viewControllerForAncestor];

	PFColorViewController *colorViewController = [[PFColorViewController alloc] initForContentSize:viewController.view.frame.size];

	if (_specifier && [[_specifier properties] objectForKey:@"color_key"] && [[_specifier properties] objectForKey:@"color_defaults"])
    {
    PSSpecifier *specifier = _specifier;
    colorViewController.key = specifier.properties[@"color_key"];
    colorViewController.defaults = specifier.properties[@"color_defaults"];
    colorViewController.usesAlpha = [specifier.properties[@"usesAlpha"] boolValue] ? [specifier.properties[@"usesAlpha"] boolValue] : NO;
    colorViewController.usesRGB = [specifier.properties[@"usesRGB"] boolValue] ? [specifier.properties[@"usesRGB"] boolValue] : NO;
    colorViewController.title = specifier.properties[@"title"] ? specifier.properties[@"title"] : @"Choose Color";
    colorViewController.fallback = [_specifier.properties objectForKey:@"color_fallback"] ? [_specifier.properties objectForKey:@"color_fallback"] : @"#a1a1a1";
    colorViewController.postNotification = specifier.properties[@"color_postNotification"] ? specifier.properties[@"color_postNotification"] : nil;
    }

     colorViewController.view.frame = viewController.view.frame;
	   [viewController.navigationController pushViewController:colorViewController animated:YES];

    [colorViewController release];

}

- (void)didMoveToSuperview
{
	[super didMoveToSuperview];

	UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
	colorPreview.tag = 199; //Stop UIColors from overriding the color :P
	colorPreview.layer.cornerRadius = colorPreview.frame.size.width / 2;
	colorPreview.layer.borderWidth = 2;
	colorPreview.layer.borderColor = [UIColor lightGrayColor].CGColor;
	NSString *fallback = [_specifier.properties objectForKey:@"color_fallback"] ? [_specifier.properties objectForKey:@"color_fallback"] : @"#a1a1a1";
	colorPreview.backgroundColor = colorFromDefaultsWithKey([_specifier properties][@"color_defaults"], [_specifier properties][@"color_key"], fallback);

	[self setAccessoryView:colorPreview];

	[colorPreview release];

	[_specifier setTarget:self];
	[_specifier setButtonAction:@selector(openColorPicker)];
}

- (void)dealloc
{
	[super dealloc];
}

@end
