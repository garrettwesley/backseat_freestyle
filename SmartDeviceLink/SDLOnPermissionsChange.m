//  SDLOnPermissionsChange.m
//

#import "SDLOnPermissionsChange.h"

#import "NSMutableDictionary+Store.h"
#import "SDLRPCParameterNames.h"
#import "SDLRPCFunctionNames.h"
#import "SDLPermissionItem.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SDLOnPermissionsChange

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (instancetype)init {
    if (self = [super initWithName:SDLRPCFunctionNameOnPermissionsChange]) {
    }
    return self;
}
#pragma clang diagnostic pop

- (void)setPermissionItem:(NSArray<SDLPermissionItem *> *)permissionItem {
    [self.parameters sdl_setObject:permissionItem forName:SDLRPCParameterNamePermissionItem];
}

- (NSArray<SDLPermissionItem *> *)permissionItem {
    NSError *error = nil;
    return [self.parameters sdl_objectsForName:SDLRPCParameterNamePermissionItem ofClass:SDLPermissionItem.class error:&error];
}

@end

NS_ASSUME_NONNULL_END
