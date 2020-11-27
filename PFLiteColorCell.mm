#import "PSTableCell.h"
#import "PSSpecifier.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface PFLiteColorCell : PSTableCell
@property (nonatomic, retain) UIView *colorPreview;
@end

@interface UIColor ()
+ (NSString *)hexFromColor:(UIColor *)color;
@end

@implementation PFLiteColorCell

- (id)initWithStyle:(long long)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier];
}

- (PSSpecifier *)specifier {
    return [super specifier];
}

- (UIColor *)previewColor {
    return [UIColor cyanColor];
}

- (void)updateCellDisplay {
    self.colorPreview.backgroundColor = [self previewColor];
    self.detailTextLabel.text = [UIColor hexFromColor:[self previewColor]];
    self.detailTextLabel.alpha = 0.65;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    self.colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
    self.colorPreview.tag = 199; // Stop UIColors from overriding the color :P
    self.colorPreview.layer.cornerRadius = self.colorPreview.frame.size.width / 2;
    self.colorPreview.layer.borderWidth = 2;
    self.colorPreview.layer.borderColor = [UIColor lightGrayColor].CGColor;

    [self setAccessoryView:self.colorPreview];
    [self updateCellDisplay];
}

@end
