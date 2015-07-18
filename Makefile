GO_EASY_ON_ME = 1

ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:6.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libcolorpicker

libcolorpicker_FILES = libcolorpicker.mm UIColor+PFColor.m PFColorPicker.m PFColorTransparentView.m PFColorViewController.m PFColorCell.mm PFColorAlert.mm PFHaloHueView.m PFColorLitePreviewView.m PFColorLiteSlider.m

libcolorpicker_FRAMEWORKS = UIKit CoreGraphics Foundation
libcolorpicker_PRIVATE_FRAMEWORKS = Preferences

after-install::
	install.exec "killall -9 Preferences"

include $(THEOS_MAKE_PATH)/library.mk
