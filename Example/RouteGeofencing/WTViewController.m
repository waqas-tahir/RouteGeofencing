//
//  WTViewController.m
//  RouteGeofencing
//
//  Created by Waqas Tahir on 12/23/2016.
//  Copyright (c) 2016 Waqas Tahir. All rights reserved.
//

#import "WTViewController.h"
#import <MapKit/MapKit.h>

@interface WTViewController ()

@end

@implementation WTViewController
#pragma mark Controller_LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeNavBar];
    [self loadMapView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark private_methods
- (void)loadMapView {
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mapView];
}

- (void)initializeNavBar {
    self.navigationItem.title = @"Demo";
}


#pragma mark public_methods

@end
