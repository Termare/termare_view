#import "TermarePlugin.h"
#if __has_include(<termare/termare-Swift.h>)
#import <termare/termare-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "termare-Swift.h"
#endif

@implementation TermarePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTermarePlugin registerWithRegistrar:registrar];
}
@end
