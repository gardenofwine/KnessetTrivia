//
//  GoogleAnalyticsManager.h
//  KnessetTrivia
//
//  Created by Stav Ashuri on 2/2/12.
//

#import <Foundation/Foundation.h>
#import "GANTracker.h"

@interface GoogleAnalyticsManager : NSObject <GANTrackerDelegate>
{
    BOOL trackingNumberSet;
}

//General
+ (GoogleAnalyticsManager *)sharedGoogleAnalyticsManager;

- (void)setAnalyticsTrackingNumber:(NSString *)trackingNum;
- (void)sendGoogleAnalyticsTrackPageForTab:(NSString *)tabName;
- (void)sendGoogleAnalyticsTrackEventCategory:(NSString *)eventCategory withEventName:(NSString *)eventName;
- (void)sendGoogleAnalyticsTrackEventCategory:(NSString *)eventCategory withEventName:(NSString *)eventName andLabel:(NSString *)aLabel withValue:(NSInteger)aValue;
@end
