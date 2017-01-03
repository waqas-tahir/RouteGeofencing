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
@property (nonatomic, strong) NSArray *fenceList;
@property (nonatomic, assign) BOOL isToStopGeoFencing;
@end

@implementation WTRouteFenceManager

- (instancetype)initWithCoordinateList:(NSArray*)coordinateArray geoFenceAtDistance:(NSArray *)fenceList{
    if (self = [super init]) {
        self.coordinateArray = [NSArray arrayWithArray:coordinateArray];
        self.fenceList = fenceList;
        [self checkLocationManagerStatus];
        self.geoFencingRefreshRate = 20.0;
    }
    return self;
}

- (void)checkLocationManagerStatus {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"WT Location is not determined please ask user location permission");
        [self initlizeLocationManager];
        [self.locationManager requestWhenInUseAuthorization];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        NSLog(@"WT Location is restricted please ask user to change restriction in settings");
        if ([self.delegate respondsToSelector:@selector(routeFenceManager:didReceiveLocationError:)]) {
            [self.delegate routeFenceManager:self didReceiveLocationError:KWT_Location_Authorization_Restricted];
        }
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"WT Location is denied please ask user to change restriction in settings");
        if ([self.delegate respondsToSelector:@selector(routeFenceManager:didReceiveLocationError:)]) {
            [self.delegate routeFenceManager:self didReceiveLocationError:KWT_Location_Authorization_Denied];
        }
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"WT Location is authorized ! ");
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

- (void)startGeoFencing {
    CLLocationDistance minDistance = [self closedDistanceToPolyline];
    
    if (self.isToStopGeoFencing ==  NO) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.geoFencingRefreshRate * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf startGeoFencing];
        });
    }
}

- (void)stopGeoFencing {
    self.isToStopGeoFencing = YES;
}

- (CLLocationDistance)closedDistanceToPolyline {
    NSUInteger polylineCount = self.coordinateArray.count;
    CLLocation *currentLoc = self.locationManager.location;
    
    CLLocationDistance minDistance = 0;
    for (int i = 0; i < polylineCount; i++) {
        CLLocation *polylinePart = [self.coordinateArray objectAtIndex:i];
        CLLocationCoordinate2D coord = [polylinePart coordinate];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
        CLLocationDistance distanceBtPt = [currentLoc distanceFromLocation:loc];
        if (minDistance == 0) {
            minDistance = distanceBtPt;
        }
        else if (minDistance > distanceBtPt) {
            minDistance = distanceBtPt;
        }
    }
    NSLog(@"min Distance is %f", minDistance);
    return minDistance;
}


@end
