//  SDLOnHMIStatus.m
//

#import "SDLOnHMIStatus.h"

#import "NSMutableDictionary+Store.h"
#import "SDLAudioStreamingState.h"
#import "SDLHMILevel.h"
#import "SDLRPCParameterNames.h"
#import "SDLRPCFunctionNames.h"
#import "SDLSystemContext.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SDLOnHMIStatus

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (instancetype)init {
    if (self = [super initWithName:SDLRPCFunctionNameOnHMIStatus]) {
    }
    return self;
}
#pragma clang diagnostic pop

- (void)setHmiLevel:(SDLHMILevel)hmiLevel {
    [self.parameters sdl_setObject:hmiLevel forName:SDLRPCParameterNameHMILevel];
}

- (SDLHMILevel)hmiLevel {
    NSError *error = nil;
    return [self.parameters sdl_enumForName:SDLRPCParameterNameHMILevel error:&error];
}

- (void)setAudioStreamingState:(SDLAudioStreamingState)audioStreamingState {
    [self.parameters sdl_setObject:audioStreamingState forName:SDLRPCParameterNameAudioStreamingState];
}

- (SDLAudioStreamingState)audioStreamingState {
    NSError *error = nil;
    return [self.parameters sdl_enumForName:SDLRPCParameterNameAudioStreamingState error:&error];
}

- (void)setVideoStreamingState:(nullable SDLVideoStreamingState)videoStreamingState {
    [self.parameters sdl_setObject:videoStreamingState forName:SDLRPCParameterNameVideoStreamingState];
}

- (nullable SDLVideoStreamingState)videoStreamingState {
    return [self.parameters sdl_enumForName:SDLRPCParameterNameVideoStreamingState error:nil];
}

- (void)setSystemContext:(SDLSystemContext)systemContext {
    [self.parameters sdl_setObject:systemContext forName:SDLRPCParameterNameSystemContext];
}

- (SDLSystemContext)systemContext {
    NSError *error = nil;
    return [self.parameters sdl_enumForName:SDLRPCParameterNameSystemContext error:&error];
}

@end

NS_ASSUME_NONNULL_END
