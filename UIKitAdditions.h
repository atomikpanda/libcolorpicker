#if __IPHONE_OS_VERSION_MAX_ALLOWED < 130000
@interface UIScene : NSObject
@end

@interface UIWindowScene
@property (nonatomic, retain) NSSet<UIWindow *> *windows;
@end

@interface UIWindow (NewiOSMethods)
- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene;
@end

@interface UIApplication (NewiOSMethods)
-(id)connectedScenes;
@end
#endif