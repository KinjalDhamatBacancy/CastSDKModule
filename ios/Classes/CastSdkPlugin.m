#import "CastSdkPlugin.h"
#if __has_include(<cast_sdk/cast_sdk-Swift.h>)
#import <cast_sdk/cast_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cast_sdk-Swift.h"
#endif

@implementation CastSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCastSdkPlugin registerWithRegistrar:registrar];
}
@end
