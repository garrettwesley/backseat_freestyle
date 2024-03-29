//
//  SDLGetInteriorVehicleData.m
//

#import "SDLGetInteriorVehicleData.h"
#import "SDLRPCParameterNames.h"
#import "SDLRPCFunctionNames.h"
#import "NSMutableDictionary+Store.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SDLGetInteriorVehicleData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (instancetype)init {
    if (self = [super initWithName:SDLRPCFunctionNameGetInteriorVehicleData]) {
    }
    return self;
}
#pragma clang diagnostic pop

- (instancetype)initWithModuleType:(SDLModuleType)moduleType; {
    self = [self init];
    if (!self) {
        return nil;
    }
    
    self.moduleType = moduleType;
    
    return self;
}

- (instancetype)initAndSubscribeToModuleType:(SDLModuleType)moduleType {
    self = [self init];
    if (!self) {
        return nil;
    }

    self.moduleType = moduleType;
    self.subscribe = @(YES);

    return self;
}

- (instancetype)initAndUnsubscribeToModuleType:(SDLModuleType)moduleType {
    self = [self init];
    if (!self) {
        return nil;
    }

    self.moduleType = moduleType;
    self.subscribe = @(NO);

    return self;
}

- (void)setModuleType:(SDLModuleType)moduleType {
    [self.parameters sdl_setObject:moduleType forName:SDLRPCParameterNameModuleType];
}

- (SDLModuleType)moduleType {
    NSError *error = nil;
    return [self.parameters sdl_enumForName:SDLRPCParameterNameModuleType error:&error];
}

- (void)setSubscribe:(nullable NSNumber<SDLBool> *)subscribe {
    [self.parameters sdl_setObject:subscribe forName:SDLRPCParameterNameSubscribe];
}

- (nullable NSNumber<SDLBool> *)subscribe {
    return [self.parameters sdl_objectForName:SDLRPCParameterNameSubscribe ofClass:NSNumber.class error:nil];
}

@end

NS_ASSUME_NONNULL_END
