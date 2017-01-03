//
//  WTRouteFenceManager.h
//  Pods
//
//  Created by Waqas Tahir on 23/12/2016.
//
//

#import <Foundation/Foundation.h>
typedef enum {
    KWT_Location_Authorization_Denied,
    KWT_Location_Authorization_Restricted,
}WTLocationAuthorizationError;

@protocol WTRouteFenceManagerDataSource;

@protocol WTRouteFenceManagerDelegate;

@interface WTRouteFenceManager : NSObject

@property (nonatomic, strong) NSArray* coordinateArray;
/*
 This rate determine the time in seconds the app determine
 */
@property (nonatomic, assign) CGFloat geoFencingRefreshRate;

@property (nonatomic, assign) id<WTRouteFenceManagerDelegate>delegate;
@property (nonatomic, assign) id<WTRouteFenceManagerDataSource>dataSource;

/*
 Designated inilizer
 */
- (instancetype)initWithCoordinateList:(NSArray*)coordinateArray geoFenceAtDistance:(NSArray*)fenceList;
- (void)startGeoFencing;
- (void)stopGeoFencing;

@end

@protocol WTRouteFenceManagerDataSource <NSObject>

@required
- (NSArray *)geofencesForRoutefenceManager:(WTRouteFenceManager *)routefenceManager;
@end

@protocol WTRouteFenceManagerDelegate <NSObject>

- (void)routeFenceManager:(WTRouteFenceManager*)routeFenceManager didReceiveLocationError:(WTLocationAuthorizationError)error;


@end

