GO_EASY_ON_ME = 1

ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:6.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libcolorpicker
libcolorpicker_FILES = libcolorpicker.mm UIColor+PFColor.m PFColorPicker.m PFColorTransparentView.m PFColorViewController.m
libcolorpicker_FRAMEWORKS = CoreGraphics UIKit

include $(THEOS_MAKE_PATH)/library.mk
