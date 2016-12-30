//
//  WTViewController.m
//  RouteGeofencing
//
//  Created by Waqas Tahir on 12/23/2016.
//  Copyright (c) 2016 Waqas Tahir. All rights reserved.
//

#import "WTViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface WTViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) UIBarButtonItem *routeModeBtn;
@property (nonatomic, strong) UIBarButtonItem *cancelRouteModeBtn;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isSelectingOrigin;
@property (nonatomic, assign) CLLocationCoordinate2D originCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D destinationCoordinate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *routePtSelectionBtn;

@end

@implementation WTViewController
#pragma mark Controller_LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeBarBtnItem];
    [self initializeNavBar];
    [self setupLocationManager];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark private_methods

- (void)makeBarBtnItem {
    self.routeModeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Find Route" style:UIBarButtonItemStylePlain target:self action:@selector(startRouteMode)];
    self.cancelRouteModeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelRouteMode)];
}

- (void)initializeNavBar {
    self.navigationItem.title = @"Demo";
    self.navigationItem.rightBarButtonItem = self.routeModeBtn;
}

- (void)setupLocationManager {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)startRouteMode {
    self.navigationItem.rightBarButtonItem = self.cancelRouteModeBtn;
    self.routePtSelectionBtn.hidden = NO;
    self.isSelectingOrigin = YES;
}

- (void)cancelRouteMode {
    self.navigationItem.rightBarButtonItem = self.routeModeBtn;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)createAnnotationAtCoordinate:(CLLocationCoordinate2D)coordinate withTitle:(NSString*)title {
    MKPointAnnotation *annotationPt = [[MKPointAnnotation alloc] init];
    annotationPt.coordinate = coordinate;
    annotationPt.title = title;
    [self.mapView addAnnotation:annotationPt];
}

- (void)calculateRoute {
    NSArray *routes = [self calculateRoutesFrom:self.originCoordinate to:self.destinationCoordinate];

    NSInteger numberOfSteps = routes.count;
    
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * numberOfSteps);
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        CLLocation *location = [routes objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    free(coordinates);
    
    [self.mapView addOverlay:polyLine];
}

- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

- (MKOverlayRenderer*)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *polylineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor purpleColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}

-(NSArray*)calculateRoutesFrom:(CLLocationCoordinate2D)origin to: (CLLocationCoordinate2D)destination {
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false&avoid=highways&mode=driving",saddr,daddr]];
    
    NSError *error=nil;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    
    [request setURL:url];
    
    NSURLResponse *response = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    return [self decodePolyLine:[self parseResponse:dic]];
}

- (NSMutableString *)parseResponse:(NSDictionary *)response {
    NSArray *routes = [response objectForKey:@"routes"];
    NSDictionary *route = [routes lastObject];
    if (route) {
        NSString *overviewPolyline = [[route objectForKey:@"overview_polyline"] objectForKey:@"points"];
        return [overviewPolyline mutableCopy];
    }
    return [NSMutableString stringWithFormat:@""];
}

#pragma mark target_action
- (IBAction)routePointSelectionBtnPressed:(id)sender {
    if (self.isSelectingOrigin) {
        self.originCoordinate = self.mapView.centerCoordinate;
        [self createAnnotationAtCoordinate:self.originCoordinate withTitle:@"Origin Point"];
        self.isSelectingOrigin = NO;
        [self.routePtSelectionBtn setImage:[UIImage imageNamed:@"EndAnnotation"] forState:UIControlStateNormal];
    }
    else {
        self.destinationCoordinate = self.mapView.centerCoordinate;
        [self createAnnotationAtCoordinate:self.destinationCoordinate withTitle:@"Destination Point"];
        self.routePtSelectionBtn.hidden = YES;
        [self.routePtSelectionBtn setImage:[UIImage imageNamed:@"StartAnnotation"] forState:UIControlStateNormal];
        [self calculateRoute];
    }
}

#pragma mark public_methods

@end
