#libcolorpicker 

_libcolorpicker is a iOS library that provides an easy to implement Color Picker.
Here are some of it's main features:_

* iPhone & iPad Compatible
* HSB touch color picker
* Option to Use HSB or RGB sliders
* Option for color transparency/opacity/alpha
* No images or "extra components" just the library
* Post settings changed notifications on save (Optional)
* Enter a hex color or copy one to your clipboard
* Made for iOS 7 & Compatible with iOS 6 
* Saves colors instantly to your preferences plist
* iPhone 3.5 inch & 4inch screen compatibility
* Open source

How to add libcolorpicker into your tweak:

First add a this into your Tweaks Preferences specifier plist and modify to your liking:

			<dict>
                <key>cell</key>
                <string>PSLinkCell</string>
                <key>cellClass</key>
                <string>PFColorCell</string>
                <key>label</key>
                <string>A Color</string>
                <key>color_defaults</key>
                <string>com.yourcompany.tweak</string>
                <key>color_key</key>
                <string>aColor</string>
                <key>title</key>
                <string>A Color</string>
                <key>color_fallback</key>
                <string>#10b6ec</string>
				<key>usesRGB</key>
				<false/>
				<key>usesAlpha</key>
				<true/>
                <key>color_postNotification</key>
                <string>com.yourcompany.tweak.settingschanged</string>
            </dict>
			
Next, Place the libcolorpicker.dylib in TweakPreferencesFolder/lib/

Next, Add the following to your Preference Bundle's Makefile:

		$(shell install_name_tool -id /usr/lib/libcolorpicker_PUTTWEAKNAMEHERE.dylib lib/libcolorpicker.dylib)

		TWEAKNAMEPREFERENCES_LDFLAGS = -Llib -lcolorpicker

		include $(THEOS_MAKE_PATH)/bundle.mk

		internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/usr/lib/$(ECHO_END)
	$(ECHO_NOTHING)cp lib/libcolorpicker.dylib $(THEOS_STAGING_DIR)/usr/lib/libcolorpicker_PUTTWEAKNAMEHERE.dylib$(ECHO_END)


Next, Add the following to to your Preference Bundle's PSListController @implementation:

- (void)viewWillAppear:(BOOL)animated
{
    [self clearCache];
    [self reload];  
    [super viewWillAppear:animated];
}

__Check out the screen shots below__

![iOS Simulator Screen shot Aug 27, 2014, 3.49.02 PM.png](https://bitbucket.org/repo/poAx5p/images/3203715933-iOS%20Simulator%20Screen%20shot%20Aug%2027,%202014,%203.49.02%20PM.png)![iOS Simulator Screen shot Aug 27, 2014, 3.55.09 PM.png](https://bitbucket.org/repo/poAx5p/images/3068646252-iOS%20Simulator%20Screen%20shot%20Aug%2027,%202014,%203.55.09%20PM.png)

#License

The MIT License (MIT)

Copyright (c) 2014 PixelFireDev

Permission is hereby granted, free of charge, to any person obtaining a copy    
of this software and associated documentation files (the "Software"), to deal    
in the Software without restriction, including without limitation the rights    
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    
copies of the Software, and to permit persons to whom the Software is    
furnished to do so, subject to the following conditions:    

The above copyright notice and this permission notice shall be included in    
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER    
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,    
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    
THE SOFTWARE.