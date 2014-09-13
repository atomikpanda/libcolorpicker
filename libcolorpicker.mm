int main(int argc, char **argv, char **envp) {
	return 0;
}

UIColor *colorFromHex(NSString *hexString)
{
    unsigned rgbValue = 0;
    if (hexString) {
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    if ([hexString hasPrefix:@"#"])
    [scanner setScanLocation:1]; // bypass '#' character

    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    }
    else {
        //Random
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    }
}

UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback)
{
    NSMutableDictionary *preferencesPlist = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", defaults]];
    //fallback
    UIColor *fallbackColor = colorFromHex(fallback);
    CGFloat currentAlpha = 1;
    
    if(preferencesPlist && [preferencesPlist objectForKey:key]) {
        NSString *value = [preferencesPlist objectForKey:key];
        NSArray *colorAndOrAlpha = [value componentsSeparatedByString:@":"];
        if([value rangeOfString:@":"].location != NSNotFound){
        
        if([colorAndOrAlpha objectAtIndex:1]) {
            currentAlpha = [colorAndOrAlpha[1] floatValue];
        }
        }

        if(!value) return fallbackColor;
        
        NSString *color = colorAndOrAlpha[0];

        return [colorFromHex(color) colorWithAlphaComponent:currentAlpha];
    }
    else {
        return fallbackColor;
    }

}

// vim:ft=objc
