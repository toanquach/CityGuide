//
//  HomeViewController.m
//  CityGuide
//
//  Created by Mac Mini on 4/30/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "HomeViewController.h"
#import "Places+Custom.h"
#import "FilterViewController.h"
#import "PlaceAnnotation.h"
#import "DDAnnotation.h"
#import "DDAnnotationView.h"
#import "Utils.h"
#import "DetailAnnotationViewController.h"

@interface HomeViewController ()

@property (retain, nonatomic) IBOutlet UIView *searchContainView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (retain, nonatomic) IBOutlet MKMapView *myMapView;
@property (retain, nonatomic) IBOutlet UIButton *filtersButton;
@property (retain, nonatomic) MBProgressHUD *hudProgressView;
@property (retain, nonatomic) IBOutlet UIView *radiusView;
@property (retain, nonatomic) IBOutlet UIButton *downUpButton;
@property (retain, nonatomic) IBOutlet UISlider *radiusSlider;
@property (nonatomic) int downUpButtonType;
@property (retain, nonatomic) IBOutlet UIView *blendView;
@property (retain, nonatomic) IBOutlet UILabel *filterMileLabel;
@property (retain, nonatomic) IBOutlet UITableView *filterTableView;
@property (retain, nonatomic) NSMutableArray *mapAnnotationsArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;

@property (retain, nonatomic) IBOutlet UIButton *userLocationButton;

// Method
- (void)setupView;
- (void)fetchData:(NSData *)responseData;
- (void)generatePlacesToMap;
- (BOOL)centerOnUserAnimated:(BOOL)animated;
- (void)centerMapOnCoordinate:(CLLocationCoordinate2D)loc withSpan:(float)spanValue animated:(BOOL)animated;
- (BOOL)checkUserLocationValid;
- (void)searchWithText:(NSString *)searchText andRadius:(int)radius;

- (IBAction)filtersButtonClicked:(id)sender;
- (IBAction)downUpButtonClicked:(id)sender;
- (IBAction)radiusSliderValueChanged:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)userLocationButtonClicked:(id)sender;
- (IBAction)sliderTouchUp:(id)sender;
- (IBAction)sliderTouchOutSide:(id)sender;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    //
    // check type device and load view
    //
    if (ISIPHONE)
    {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"HomeViewController" owner:self options:nil] objectAtIndex:0];
    }
    else
    {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"HomeViewController_iPad" owner:self options:nil] objectAtIndex:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupView];
    //
    //      If you are downloaded
    //
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isDownload = [[userDefault objectForKey:kIsDownloaded] boolValue];
    if (isDownload) // have download
    {
        //
        //      Add list pin to map view
        //
        //[self generatePlacesToMap];
        return;
    }
    
    //
    //      Check Network valid
    //
    if ([UIAppDelegate reachable])
    {
        //
        // Show the HUD while the provided method executes in a new thread
        //
        [self.hudProgressView show:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
           NSURL *url = [[NSURL alloc]initWithString:kLink_Places];
           NSData* data = [NSData dataWithContentsOfURL:url];
           [self performSelectorOnMainThread:@selector(fetchData:) withObject:data waitUntilDone:YES];
           [url release];
        });
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:kNoInternetConnection delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden   = YES;
    self.navigationController.navigationBar.hidden  = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [self.locationManager setDelegate:nil];
    [_locationManager release];
    [geocoder release];
    [_searchContainView release];
    [_searchBarView release];
    [_myMapView release];
    [_filtersButton release];
    [self.hudProgressView setDelegate:nil];
    [_hudProgressView release];
    [_radiusView release];
    [_downUpButton release];
    [_radiusSlider release];
    [_blendView release];
    [_filterMileLabel release];
    [_filterTableView release];
    [_mapAnnotationsArray release];
    [_cancelButton release];
    [_userLocationButton release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setLocationManager:nil];
    [self setHudProgressView:nil];
    [self setSearchContainView:nil];
    [self setSearchBarView:nil];
    [self setMyMapView:nil];
    [self setFiltersButton:nil];
    [self setRadiusView:nil];
    [self setDownUpButton:nil];
    [self setRadiusSlider:nil];
    [self setBlendView:nil];
    [self setFilterMileLabel:nil];
    [self setFilterTableView:nil];
    geocoder = nil;
    [self setMapAnnotationsArray:nil];
    [self setCancelButton:nil];
    [self setUserLocationButton:nil];
    [super viewDidUnload];
}

#pragma mark - SetupView

- (void)zoomIn:(id)sender
{
    [self centerOnUserAnimated:YES];
}

- (void)setupView
{
    //
    // Load custom background image unto toolbar to match the searchbar.
    //
    UIImageView *searchToolbarBackground = [[UIImageView alloc] initWithFrame:self.searchContainView.bounds];
    UIImage *backgroundImage = [[UIImage imageNamed:@"SearchToolbarBackground.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0.0];
    searchToolbarBackground.image = backgroundImage;
    [self.searchContainView addSubview:searchToolbarBackground];
    [self.searchContainView sendSubviewToBack:searchToolbarBackground];
    //
    // custom search bar
    //
    self.searchBarView.placeholder          = @"Search...";
    self.searchBarView.delegate             = self;
    self.searchBarView.showsCancelButton    = NO;
    self.searchBarView.backgroundImage      = backgroundImage;
    self.searchBarView.text = @"";
    [self.searchBarView resignFirstResponder];
    
    [searchToolbarBackground release];
    searchToolbarBackground = nil;
    //
    // setup loading
    // download data store to CoreData
    //
    self.hudProgressView = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.hudProgressView];
	
	self.hudProgressView.dimBackground = YES;
    self.hudProgressView.labelText = @"Loading...";
	//
	// Regiser for HUD callbacks so we can remove it from the window at the right time
    //
	self.hudProgressView.delegate = self;
    
    //
    //      Add gesture on mkMapView
    //
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMapView:)];
    longPressGesture.minimumPressDuration = 1.0;
    [self.myMapView addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    //
    //      Add gesture to blend view
    //
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSearch:)];
    [self.blendView addGestureRecognizer:tapGesture];
    [tapGesture release];
    //
    //      Send view to back
    //
    [self.searchContainView sendSubviewToBack:self.cancelButton];
    [self.view sendSubviewToBack:self.blendView];
    [self.view sendSubviewToBack:self.filterTableView];
    CGRect frame = self.filterTableView.frame;
    frame.size.height = frame.size.height - kIPhone_Height_Keyboard + frame.origin.y + 50;
    self.filterTableView.frame = frame;
    //
    //      Set time deplay searching
    //
    delaySearchUntilQueryUnchangedForTimeOffset = 0.4 * NSEC_PER_SEC;
    //
    //      setup radius slider
    //
    self.filterMileLabel.text = @"10";
    self.radiusSlider.value = 10;
    self.radiusSlider.maximumValue = 100;
    self.radiusSlider.minimumValue = 1;
    
    //
    //  Update location
    //
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}


- (void)longPressOnMapView:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.myMapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.myMapView convertPoint:touchPoint toCoordinateFromView:self.myMapView];
    
    if ([self.myMapView.annotations count] > 0)
    {
        NSMutableArray *listPin = [NSMutableArray arrayWithArray:self.myMapView.annotations];
        for (int i = 0; i < [listPin count]; i++)
        {
            id annotation = [listPin objectAtIndex:i];
            if ([annotation isKindOfClass:[DDAnnotation class]])
            {
                [self.myMapView removeAnnotation:annotation];
            }
        }
        //[listPin release];
    }
    
    //
    // Place a single pin
    //
    DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:touchMapCoordinate addressDictionary:nil] autorelease];
	annotation.title = @"Drag to Move Pin";
	annotation.subtitle = @"Loading...";
	[self.self.myMapView addAnnotation:annotation];
    //[self.myMapView selectAnnotation:annotation animated:YES];
    [self performSelector:@selector(selectedPin:) withObject:annotation afterDelay:1.0];
    if (!geocoder)
    {
        geocoder = [[CLGeocoder alloc] init];
    }
    //
    //      getting address
    //
    if ([UIAppDelegate reachable])
    {
        CLLocation *location = [[CLLocation alloc]initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        [geocoder reverseGeocodeLocation:location
                            completionHandler:^(NSArray *placemarks, NSError *error)
         {
             
             if (error)
             {
                 DLog(@"Geocoder return error: %@", error);
                 return;
             }
             
             if ([placemarks count] == 0)
             {
                 return;
             }
             
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"%@",placemark.addressDictionary);
             NSArray *arr = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
             NSString *address = @"";
             for (int i = 0; i <[arr count]; i++)
             {
                 address = [address stringByAppendingString:[NSString stringWithFormat:@"%@,",[arr objectAtIndex:i]]];
             }
             annotation.subtitle = address;
             annotation.dictAddress = [placemark.addressDictionary retain];
         }];
        [location release];
        location = nil;
    }
    else
    {
        annotation.subtitle = @"";
    }
}

- (void)selectedPin:(PlaceAnnotation *)annotation
{
    [self.myMapView selectAnnotation:annotation animated:YES];
}

- (void)hideSearch:(id)sender
{
    [self.searchBarView setText:nil];
    [self.searchBarView resignFirstResponder];
}

- (void)fetchData:(NSData *)responseData
{
    if (responseData == nil)
    {
        [self.hudProgressView hide:YES];
        [UIAppDelegate showAlertView:nil andMessage:@"Import data from server error"];
        return;
    }
    BOOL flag = NO;
    NSError* error;
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                         options:kNilOptions
                                                           error:&error];
    
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        NSArray* placesList = [dict objectForKey:@"places"]; //2
        if (placesList != nil)
        {
            flag = [Places processUpdate:placesList];
        }
    }
    
    if (flag == YES)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setBool:YES forKey:kIsDownloaded];
        [userDefault synchronize];
    }

    //[self generatePlacesToMap];
    [self.hudProgressView hide:YES];
}

- (void)generatePlacesToMap
{
   //...
}

- (void)searchWithText:(NSString *)searchText andRadius:(int)radius
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:[Places searchItemWithKey:searchText]];
    if (list != nil)
    {
        if ([list count] > 0)
        {
            if ([self checkUserLocationValid] == YES) // User Location Valid
            {
                CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:self.myMapView.userLocation.coordinate.latitude longitude:self.myMapView.userLocation.coordinate.longitude];
                double distanceFilter = [Utils mileToM:[self.filterMileLabel.text intValue]];
                if (self.mapAnnotationsArray == nil)
                {
                    self.mapAnnotationsArray = [[NSMutableArray alloc] init];
                }
                else
                {
                    [self.mapAnnotationsArray removeAllObjects];
                }
                for (int i=0; i<[list count]; i++)
                {
                    Places *obj = [list objectAtIndex:i];
                    
                    CLLocation *endLocation = [[CLLocation alloc]initWithLatitude:[obj.latitude doubleValue] longitude:[obj.longitude doubleValue]];
                    double distance = [Utils distanceFromTwoPoint:startLocation andEndPoint:endLocation];
                    if (distance <= distanceFilter)
                    {
                        CLLocationCoordinate2D coordinate;
                        coordinate.latitude     = [obj.latitude doubleValue];
                        coordinate.longitude    = [obj.longitude doubleValue];
                        PlaceAnnotation *pin    = [[[PlaceAnnotation alloc] initWithCoordinate:coordinate addressDictionary:nil] autorelease];
                        pin.title = obj.text;
                        pin.subtitle = obj.city;
                        [self.mapAnnotationsArray addObject:pin];
                    }
                    
                    [endLocation release];
                }
                [startLocation release];
            }
            else
            {
                if (self.mapAnnotationsArray == nil)
                {
                    self.mapAnnotationsArray = [[NSMutableArray alloc] init];
                }
                else
                {
                    [self.mapAnnotationsArray removeAllObjects];
                }
                for (int i=0; i < [list count]; i++)
                {
                    Places *obj = [list objectAtIndex:i];
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude     = [obj.latitude doubleValue];
                    coordinate.longitude    = [obj.longitude doubleValue];
                    PlaceAnnotation *pin    = [[[PlaceAnnotation alloc] initWithCoordinate:coordinate addressDictionary:nil] autorelease];
                    pin.title = obj.text;
                    pin.subtitle = obj.city;
                    [self.mapAnnotationsArray addObject:pin];
                }

            }
            
            if ([self.mapAnnotationsArray count] > 0)
            {
                if ([self.myMapView.annotations count] > 0)
                {
                    NSMutableArray *listPin = [NSMutableArray arrayWithArray:self.myMapView.annotations];
                    for (int i = 0; i < [listPin count]; i++)
                    {
                        id annotation = [listPin objectAtIndex:i];
                        if ([annotation isKindOfClass:[PlaceAnnotation class]])
                        {
                            [self.myMapView removeAnnotation:annotation];
                        }
                    }
                }
                [self.myMapView addAnnotations:self.mapAnnotationsArray];
                [self.view bringSubviewToFront:self.filterTableView];
                [self.filterTableView reloadData];
            }
        }
    }
    //[list release];
    list = nil;
}

- (void)addPinToMap:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubTitle:(NSString *)subTitle
{
    PlaceAnnotation *pin    = [[[PlaceAnnotation alloc] initWithCoordinate:coordinate addressDictionary:nil] autorelease];
    pin.title = title;
    pin.subtitle = subTitle;
    [self.myMapView addAnnotation:pin];
    
    if ([self.myMapView.annotations count] > 0)
    {
        NSMutableArray *listPin = [[NSMutableArray alloc] initWithArray:self.myMapView.annotations];
        for (int i = 0; i < [listPin count]; i++)
        {
            id annotation = [listPin objectAtIndex:i];
            if ([annotation isKindOfClass:[DDAnnotation class]])
            {
                [self.myMapView removeAnnotation:annotation];
            }
        }
        [listPin release];
    }
}

- (BOOL)centerOnUserAnimated:(BOOL)animated
{
    BOOL userPositionAvailable;
    
    CLLocationCoordinate2D userLocation = self.myMapView.userLocation.coordinate;
    
    if (!self.myMapView.showsUserLocation ||
        (( userLocation.latitude == -180 ) && ( userLocation.longitude == -180 )) ||
        (( userLocation.latitude == 0 ) && ( userLocation.longitude == 0 )))
    {
        userPositionAvailable = NO;
    }
    else
    {
        [self centerMapOnCoordinate:userLocation withSpan:0.006 animated:animated];
        userPositionAvailable = YES;
    }
    
    return userPositionAvailable;
}

- (void)centerMapOnCoordinate:(CLLocationCoordinate2D)loc withSpan:(float)spanValue animated:(BOOL)animated
{
    MKCoordinateRegion region;
	region.center = loc;
	//Set Zoom level using Span
	MKCoordinateSpan span;
	span.latitudeDelta = spanValue;
	span.longitudeDelta = spanValue;
	region.span = span;
	
	[self.myMapView setRegion:region animated:animated];
}

- (BOOL)checkUserLocationValid
{
    BOOL userPositionAvailable;
    
    CLLocationCoordinate2D userLocation = self.myMapView.userLocation.coordinate;
    
    if (!self.myMapView.showsUserLocation ||
        (( userLocation.latitude == -180 ) && ( userLocation.longitude == -180 )) ||
        (( userLocation.latitude == 0 ) && ( userLocation.longitude == 0 )))
    {
        userPositionAvailable = NO;
    }
    else
    {
        userPositionAvailable = YES;
    }
    
    return userPositionAvailable;
}

#pragma mark - Button Event

- (IBAction)filtersButtonClicked:(id)sender
{
    //
    //      push filter view
    //
    FilterViewController *viewController = [[FilterViewController alloc] init];
    //[viewController  setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    //[self.navigationController presentModalViewController:viewController animated:YES];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    viewController = nil;
}

- (IBAction)downUpButtonClicked:(id)sender
{
    if (self.downUpButtonType == 0)
    {
        [UIView animateWithDuration:0.5 animations:^
        {
            CGRect rect = self.radiusView.frame;
            rect.origin.y = 44;
            self.radiusView.frame = rect;
            
            rect = self.downUpButton.frame;
            rect.origin.y = self.radiusView.frame.origin.y + self.radiusView.frame.size.height - 2;
            self.downUpButton.frame = rect;
        }];
        // slider down
        self.downUpButtonType = 1;
        
        [self.downUpButton setBackgroundImage:[UIImage imageNamed:@"up_button.png"] forState:UIControlStateNormal];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.downUpButton.frame;
            rect.origin.y = 42;
            self.downUpButton.frame = rect;
            
            rect = self.radiusView.frame;
            rect.origin.y = 0;
            self.radiusView.frame = rect;
            
        }];        //slider up
        self.downUpButtonType = 0;
        [self.downUpButton setBackgroundImage:[UIImage imageNamed:@"down_button.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)radiusSliderValueChanged:(id)sender
{
    NSUInteger index = (NSUInteger)(self.radiusSlider.value + 0.5); // Round the number.
    [self.radiusSlider setValue:index animated:NO];
    self.filterMileLabel.text = [NSString stringWithFormat:@"%d",index];
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self hideSearch:sender];
}

- (IBAction)userLocationButtonClicked:(id)sender
{
    [self centerOnUserAnimated:YES];
}

- (IBAction)sliderTouchUp:(id)sender
{
    if ([self checkUserLocationValid])
    {
        [self.myMapView removeOverlays:self.myMapView.overlays];
        circle = [MKCircle circleWithCenterCoordinate:self.myMapView.userLocation.coordinate radius:[Utils mileToM:[self.filterMileLabel.text intValue]]];
        [self.myMapView addOverlay:circle];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaySearchUntilQueryUnchangedForTimeOffset);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self.myMapView setVisibleMapRect:circle.boundingMapRect animated:YES];
                           [self.myMapView mapRectThatFits:circle.boundingMapRect];
                       });
    }
}

- (IBAction)sliderTouchOutSide:(id)sender
{
    if ([self checkUserLocationValid])
    {
        [self.myMapView removeOverlays:self.myMapView.overlays];
        circle = [MKCircle circleWithCenterCoordinate:self.myMapView.userLocation.coordinate radius:[Utils mileToM:[self.filterMileLabel.text intValue]]];
        [self.myMapView addOverlay:circle];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaySearchUntilQueryUnchangedForTimeOffset);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [self.myMapView setVisibleMapRect:circle.boundingMapRect animated:YES];
                           [self.myMapView mapRectThatFits:circle.boundingMapRect];
                       });
    }
}

#pragma mark - CLLocationManager delegate

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    DLog(@"Erorr: %@",error.description);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // If user has just accepted using GPS we should center on her position
    if (status == kCLAuthorizationStatusAuthorized)
    {
        // Get rid of locationManager since all other GPS-related
        // functionality is taken care of by our MKMapView
        self.locationManager.delegate = nil;
        self.locationManager = nil;
        //[self centerOnUserAnimated:YES];
         [self performSelector:@selector(zoomIn:) withObject:nil afterDelay:2.0];
    }
}

#pragma mark - MKMapView delegate
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{	
	if (oldState == MKAnnotationViewDragStateDragging)
    {
        if ([annotationView.annotation isKindOfClass:[DDAnnotation class]])
        {
            DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
            annotation.subtitle = @"Loading...";
            
            if (!geocoder)
            {
                geocoder = [[CLGeocoder alloc] init];
            }
            CLLocation *location = [[CLLocation alloc]initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
            [geocoder reverseGeocodeLocation:location
                                completionHandler:^(NSArray *placemarks, NSError *error)
            {
                                    
                if (error)
                {
                    DLog(@"Geocoder return error: %@", error);
                    return;
                }
                
                if ([placemarks count] == 0)
                {
                    return;
                }
                
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                NSLog(@"%@",placemark.addressDictionary);
                NSArray *arr = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
                NSString *address = @"";
                for (int i = 0; i <[arr count]; i++)
                {
                    address = [address stringByAppendingString:[NSString stringWithFormat:@"%@,",[arr objectAtIndex:i]]];
                }
                annotation.subtitle = address;
                annotation.dictAddress = [placemark.addressDictionary retain];
            }];

        }
	}       // Drag
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if(![annotation isKindOfClass:[MKUserLocation class]])
    {
        if ([annotation isKindOfClass:[PlaceAnnotation class]])
        {
            static NSString* placeAnnotationIdentifier = @"placeAnnotationIdentifier";
            
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:placeAnnotationIdentifier];
            
            if (pinView == nil)
            {
                pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placeAnnotationIdentifier] autorelease];
                UIImageView *leftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"starIcon.png"]];
                leftImgView.frame = CGRectMake(0, 0, 20, 20);
                pinView.leftCalloutAccessoryView = leftImgView;
                [leftImgView release];
            }
            
            pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
            pinView.draggable = NO;
            //[pinView setSelected:YES animated:YES];
            return pinView;
        }
        else if ([annotation isKindOfClass:[DDAnnotation class]])
        {
            static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
            MKAnnotationView *draggablePinView = [mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
            
            if (draggablePinView)
            {
                draggablePinView.annotation = annotation;
            } else
            {
                // Use class method to create DDAnnotationView (on iOS 3) or built-in draggble MKPinAnnotationView (on iOS 4).
                draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:mapView];
				
                if ([draggablePinView isKindOfClass:[DDAnnotationView class]])
                {
                    // draggablePinView is DDAnnotationView on iOS 3.
                } else
                {
                    // draggablePinView instance will be built-in draggable MKPinAnnotationView when running on iOS 4.
                }
            }		
            
            draggablePinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
            return draggablePinView;

        }
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[DDAnnotation class]])
    {
        DetailAnnotationViewController *viewController = [[DetailAnnotationViewController alloc] init];
        viewController.dictAddress = ((DDAnnotation *)view.annotation).dictAddress;
        viewController.coordinate  = ((DDAnnotation *)view.annotation).coordinate;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
        viewController = nil;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    return [circleView autorelease];
}

#pragma mark - SearchBar Delegate methods

- (void)searchBar:(UISearchBar *)searchBarSelector textDidChange:(NSString *)searchText
{
    [self.view bringSubviewToFront:self.blendView];
    //
    // waiting when user pressing
    //
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delaySearchUntilQueryUnchangedForTimeOffset);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        //NSLog(@"Search With Key: %@",searchText);
        [self searchWithText:searchText andRadius:[self.filterMileLabel.text intValue]];
    });
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[[self searchBarView] setText:@""];
    [self.view bringSubviewToFront:self.blendView];
    [self.view bringSubviewToFront:self.searchBarView];
    [self.searchContainView bringSubviewToFront:self.cancelButton];
    if([self.searchBarView.text isEqualToString:@""] == FALSE)
    {
        [self.view bringSubviewToFront:self.filterTableView];
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.view sendSubviewToBack:self.blendView];
    [self.view sendSubviewToBack:self.filterTableView];
    [self.searchContainView sendSubviewToBack:self.cancelButton];
    return YES;
}

#pragma mark - UITable View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mapAnnotationsArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    PlaceAnnotation *obj = [self.mapAnnotationsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.title;
    cell.detailTextLabel.text = obj.subtitle;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:14.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

//
// Called after the user changes the selection.
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceAnnotation *obj = [self.mapAnnotationsArray objectAtIndex:indexPath.row];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = obj.coordinate.latitude;
    coordinate.longitude = obj.coordinate.longitude;
    //pan (and zoom) to station
    [self centerMapOnCoordinate:coordinate withSpan:.06 animated:YES];
    [self.searchBarView resignFirstResponder];
    for (int i = 0 ; i < [self.myMapView.annotations count]; i++)
    {
        id pin = [self.myMapView.annotations objectAtIndex:i];
        
        if ([pin isKindOfClass:[PlaceAnnotation class]])
        {
            PlaceAnnotation *pinC = (PlaceAnnotation *)pin;
            if (pinC.coordinate.latitude == coordinate.latitude && pinC.coordinate.longitude == coordinate.longitude)
            {
                [self.myMapView selectAnnotation:pin animated:YES];
                break;
            }
        }
    }
}

@end
