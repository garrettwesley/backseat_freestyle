//
//  SDLRemoteControlCapabilities.m
//

#import "SDLAudioControlCapabilities.h"
#import "SDLButtonCapabilities.h"
#import "SDLClimateControlCapabilities.h"
#import "SDLHMISettingsControlCapabilities.h"
#import "SDLLightControlCapabilities.h"
#import "SDLRemoteControlCapabilities.h"
#import "SDLRadioControlCapabilities.h"
#import "SDLSeatControlCapabilities.h"
#import "NSMutableDictionary+Store.h"
#import "SDLRPCParameterNames.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SDLRemoteControlCapabilities

- (instancetype)initWithClimateControlCapabilities:(nullable NSArray<SDLClimateControlCapabilities *> *)climateControlCapabilities radioControlCapabilities:(nullable NSArray<SDLRadioControlCapabilities *> *)radioControlCapabilities buttonCapabilities:(nullable NSArray<SDLButtonCapabilities *> *)buttonCapabilities {

    return [self initWithClimateControlCapabilities:climateControlCapabilities radioControlCapabilities:radioControlCapabilities buttonCapabilities:buttonCapabilities seatControlCapabilities:nil audioControlCapabilities:nil hmiSettingsControlCapabilities:nil lightControlCapabilities:nil];
}

- (instancetype)initWithClimateControlCapabilities:(nullable NSArray<SDLClimateControlCapabilities *> *)climateControlCapabilities radioControlCapabilities:(nullable NSArray<SDLRadioControlCapabilities *> *)radioControlCapabilities buttonCapabilities:(nullable NSArray<SDLButtonCapabilities *> *)buttonCapabilities seatControlCapabilities:(nullable NSArray<SDLSeatControlCapabilities *> *)seatControlCapabilities audioControlCapabilities:(nullable NSArray<SDLAudioControlCapabilities *> *)audioControlCapabilities hmiSettingsControlCapabilities:(nullable NSArray<SDLHMISettingsControlCapabilities *> *)hmiSettingsControlCapabilities lightControlCapabilities:(nullable NSArray<SDLLightControlCapabilities *> *)lightControlCapabilities {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.climateControlCapabilities = climateControlCapabilities;
    self.radioControlCapabilities = radioControlCapabilities;
    self.buttonCapabilities = buttonCapabilities;
    self.seatControlCapabilities = seatControlCapabilities;
    self.audioControlCapabilities = audioControlCapabilities;
    self.hmiSettingsControlCapabilities = hmiSettingsControlCapabilities;
    self.lightControlCapabilities = lightControlCapabilities;

    return self;
}

- (void)setClimateControlCapabilities:(nullable NSArray<SDLClimateControlCapabilities *> *)climateControlCapabilities {
    [self.store sdl_setObject:climateControlCapabilities forName:SDLRPCParameterNameClimateControlCapabilities];
}

- (nullable NSArray<SDLClimateControlCapabilities *> *)climateControlCapabilities {
    return [self.store sdl_objectsForName:SDLRPCParameterNameClimateControlCapabilities ofClass:SDLClimateControlCapabilities.class error:nil];
}

-(void)setRadioControlCapabilities:(nullable NSArray<SDLRadioControlCapabilities *> *)radioControlCapabilities {
    [self.store sdl_setObject:radioControlCapabilities forName:SDLRPCParameterNameRadioControlCapabilities ];
}

- (nullable NSArray<SDLRadioControlCapabilities *> *)radioControlCapabilities {
    return [self.store sdl_objectsForName:SDLRPCParameterNameRadioControlCapabilities ofClass:SDLRadioControlCapabilities.class error:nil];
}

- (void)setButtonCapabilities:(nullable NSArray<SDLButtonCapabilities *> *)buttonCapabilities {
    [self.store sdl_setObject:buttonCapabilities forName:SDLRPCParameterNameButtonCapabilities];}

- (nullable NSArray<SDLButtonCapabilities *> *)buttonCapabilities {
    return [self.store sdl_objectsForName:SDLRPCParameterNameButtonCapabilities ofClass:SDLButtonCapabilities.class error:nil];
}

- (void)setSeatControlCapabilities:(nullable NSArray<SDLSeatControlCapabilities *> *)seatControlCapabilities {
    [self.store sdl_setObject:seatControlCapabilities forName:SDLRPCParameterNameSeatControlCapabilities];
}

- (nullable NSArray<SDLSeatControlCapabilities *> *)seatControlCapabilities {
    return [self.store sdl_objectsForName:SDLRPCParameterNameSeatControlCapabilities ofClass:SDLSeatControlCapabilities.class error:nil];
}

- (void)setAudioControlCapabilities:(nullable NSArray<SDLAudioControlCapabilities *> *)audioControlCapabilities {
    [self.store sdl_setObject:audioControlCapabilities forName:SDLRPCParameterNameAudioControlCapabilities];
}

- (nullable NSArray<SDLAudioControlCapabilities *> *)audioControlCapabilities {
    return [self.store sdl_objectsForName:SDLRPCParameterNameAudioControlCapabilities ofClass:SDLAudioControlCapabilities.class error:nil];

}

- (void)setHmiSettingsControlCapabilities:(nullable NSArray<SDLHMISettingsControlCapabilities *> *)hmiSettingsControlCapabilities {
    [self.store sdl_setObject:hmiSettingsControlCapabilities forName:SDLRPCParameterNameHmiSettingsControlCapabilities];
}

- (nullable NSArray<SDLHMISettingsControlCapabilities *> *)hmiSettingsControlCapabilities {
    return [self.store sdl_objectsForName:SDLRPCParameterNameHmiSettingsControlCapabilities ofClass:SDLHMISettingsControlCapabilities.class error:nil];
}

- (void)setLightControlCapabilities:(nullable NSArray<SDLLightControlCapabilities *> *)lightControlCapabilities {
    [self.store sdl_setObject:lightControlCapabilities forName:SDLRPCParameterNameLightControlCapabilities];
}

- (nullable NSArray<SDLLightControlCapabilities *> *)lightControlCapabilities {
    return [self.store sdl_objectsForName:SDLRPCParameterNameLightControlCapabilities ofClass:SDLLightControlCapabilities.class error:nil];
}

@end

NS_ASSUME_NONNULL_END
