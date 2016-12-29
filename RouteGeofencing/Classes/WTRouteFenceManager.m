//
//  WTRouteFenceManager.m
//  Pods
//
//  Created by Waqas Tahir on 23/12/2016.
//
//

#import "WTRouteFenceManager.h"
#import <CoreLocation/CoreLocation.h>

@interface WTRouteFenceManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation WTRouteFenceManager

- (instancetype)initWithCoordinateList:(NSArray*)coordinateArray {
    if (self = [super init]) {
        self.coordinateArray = [NSArray arrayWithArray:coordinateArray];
        [self checkLocationManagerStatus];
        
    }
    return self;
}

- (void)checkLocationManagerStatus {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self initlizeLocationManager];
        [self.locationManager requestWhenInUseAuthorization];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        if ([self.delegate respondsToSelector:@selector(routeFenceManager:didReceiveLocationError:)]) {
            [self.delegate routeFenceManager:self didReceiveLocationError:KWT_Location_Authorization_Restricted];
        }
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        if ([self.delegate respondsToSelector:@selector(routeFenceManager:didReceiveLocationError:)]) {
            [self.delegate routeFenceManager:self didReceiveLocationError:KWT_Location_Authorization_Denied];
        }
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self initlizeLocationManager];
    }
}

- (void)initlizeLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self checkLocationManagerStatus];
}



@end
