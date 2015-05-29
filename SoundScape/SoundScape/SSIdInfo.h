//
//  SSIdInfo.h
//  SoundScape
//
//  Created by Prasath Thurgam on 5/29/15.
//  Copyright (c) 2015 samsung. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SystemConfiguration.CaptiveNetwork;

@interface SSIdInfo : NSObject

+ (NSString *)currentWifiSSID;
@end
