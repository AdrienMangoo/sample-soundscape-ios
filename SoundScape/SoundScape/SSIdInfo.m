//
//  SSIdInfo.m
//  SoundScape
//
//  Created by Prasath Thurgam on 5/29/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

#import "SSIdInfo.h"

@implementation SSIdInfo



+ (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}
@end
