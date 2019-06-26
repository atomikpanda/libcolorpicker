#import "PSTableCell.h"
#import "PSSpecifier.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ColorPicker.h"

@interface PFColorCell : PSTableCell
@end

@implementation PFColorCell

- (SEL)action {
    return @selector(openColorPicker);
}

- (id)target {
    return self;
}

- (SEL)cellAction {
    return @selector(openColorPicker);
}

- (id)cellTarget {
    return self;
}

- (void)openColorPicker {
    UIViewController *viewController = [self _viewControllerForAncestor];
    PFColorViewController *colorViewController = [[PFColorViewController alloc] initForContentSize:viewController.view.frame.size];

    if (_specifier) {
        NSDictionary *properties = _specifier.properties;
        if (properties[@"color_key"] && properties[@"color_defaults"]) {
            colorViewController.key = properties[@"color_key"];
            colorViewController.defaults = properties[@"color_defaults"];

            if (properties[@"usesAlpha"])
                colorViewController.usesAlpha = [properties[@"usesAlpha"] boolValue];

            if (properties[@"usesRGB"])
                colorViewController.usesRGB = [properties[@"usesRGB"] boolValue];

            colorViewController.title = properties[@"title"] ?: @"Choose Color";
            colorViewController.fallback = properties[@"color_fallback"] ?: @"#a1a1a1";
            colorViewController.postNotification = properties[@"color_postNotification"];
        }
    }

    colorViewController.view.frame = viewController.view.frame;
    [viewController.navigationController pushViewController:colorViewController animated:YES];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    colorPreview.tag = 199; //Stop UIColors from overriding the color :P
    colorPreview.layer.cornerRadius = colorPreview.frame.size.width / 2;
    colorPreview.layer.borderWidth = 2;
    colorPreview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    NSString *fallback = _specifier.properties[@"color_fallback"];
    if (!fallback)
        fallback = @"#a1a1a1";
    colorPreview.backgroundColor = colorFromDefaultsWithKey([_specifier properties][@"color_defaults"], [_specifier properties][@"color_key"], fallback);

    [self setAccessoryView:colorPreview];

    [_specifier setTarget:self];
    [_specifier setButtonAction:@selector(openColorPicker)];
}

@end
