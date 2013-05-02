//
//  HomeViewController.m
//  CityGuide
//
//  Created by Mac Mini on 4/26/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "HomeViewController.h"
#import "Places+Custom.h"
#import "FilterViewController.h"

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

- (void)setupView;
- (void)fetchData:(NSData *)responseData;

- (IBAction)filtersButtonClicked:(id)sender;
- (IBAction)downUpButtonClicked:(id)sender;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    //      Check Network valid
    //
    if ([UIAppDelegate reachable])
    {
        //
        //      If you are downloaded
        //
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        BOOL isDownload = [[userDefault objectForKey:kIsDownloaded] boolValue];
        if (isDownload) // have download
        {
            return;
        }
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
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.myMapView.userLocation.coordinate radius:1000];
    [self.myMapView addOverlay:circle];
}

- (void)dealloc
{
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
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setHudProgressView:nil];
    [self setSearchContainView:nil];
    [self setSearchBarView:nil];
    [self setMyMapView:nil];
    [self setFiltersButton:nil];
    [self setRadiusView:nil];
    [self setDownUpButton:nil];
    [self setRadiusSlider:nil];
    [self setBlendView:nil];
    [super viewDidUnload];
}

#pragma mark - SetupView

- (void)setupView
{
    // Load custom background image unto toolbar to match the searchbar.
    UIImageView *searchToolbarBackground = [[UIImageView alloc] initWithFrame:self.searchContainView.bounds];
    UIImage *backgroundImage = [[UIImage imageNamed:@"SearchToolbarBackground.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0.0];
    searchToolbarBackground.image = backgroundImage;
    [self.searchContainView addSubview:searchToolbarBackground];
    [self.searchContainView sendSubviewToBack:searchToolbarBackground];
    
    // custom search bar
    self.searchBarView.placeholder          = @"Search...";
    self.searchBarView.delegate             = self;
    self.searchBarView.showsCancelButton    = NO;
    self.searchBarView.backgroundImage      = backgroundImage;
    self.searchBarView.text = @"";
    [self.searchBarView resignFirstResponder];
    
    [searchToolbarBackground release];
    searchToolbarBackground = nil;
    
    // setup loading
    // download data store to CoreData
    self.hudProgressView = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.hudProgressView];
	
	self.hudProgressView.dimBackground = YES;
    self.hudProgressView.labelText = @"Loading...";
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
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
    
    [self.view sendSubviewToBack:self.blendView];
}


- (void)longPressOnMapView:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
//        [self.myMapView removeGestureRecognizer:gestureRecognizer];
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.myMapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.myMapView convertPoint:touchPoint toCoordinateFromView:self.myMapView];
    
    //
    // Place a single pin
    //
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:touchMapCoordinate];
    [annotation setTitle:@"Getting address..."]; //You can set the subtitle too
    [self.myMapView addAnnotation:annotation];
    [self.myMapView selectAnnotation:annotation animated:YES];
}

- (void)hideSearch:(id)sender
{
    //self.textSearchViewController.tableView.hidden = YES;
    [self.searchBarView setText:nil];
    [self.searchBarView resignFirstResponder];
    
    //self.navigationItem.rightBarButtonItem = self.centeringBarButtonItem;
}


- (void)fetchData:(NSData *)responseData
{
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
    [self.hudProgressView hide:YES];
}

#pragma mark - Button Event

- (IBAction)filtersButtonClicked:(id)sender
{
    FilterViewController *viewController = [[FilterViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    viewController = nil;
}

- (IBAction)downUpButtonClicked:(id)sender
{
    if (self.downUpButtonType == 0)
    {
        [UIView animateWithDuration:0.5 animations:^{
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

#pragma mark - MKMapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if(![annotation isKindOfClass:[MKUserLocation class]])
    {
        static NSString* placeAnnotationIdentifier = @"placeAnnotationIdentifier";
        
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:placeAnnotationIdentifier];
        
        if (pinView == nil)
        {
            pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:placeAnnotationIdentifier] autorelease];
        }
        
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        pinView.draggable = YES;
        [pinView setSelected:YES animated:YES];
        return pinView;
    }
    return nil;
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
//    //[self.textSearchViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 320, 10) animated:NO];
//   // self.dataProvider.textFilter = searchText;
//    
//    //if([self.textSearchViewController.data count] == 0 && !self.textSearchViewController.shouldShowTable)
//    {
//        [self.view bringSubviewToFront:self.blendView];
//    }
//    else
//    {
//        [self.view bringSubviewToFront:self.textSearchViewController.view];
//    }
//    
//    self.textSearchViewController.shouldShowTable = ([self.searchBar.text length] != 0);
//    
//    [self.textSearchViewController.tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[self.dataProvider filterContent:self.mapView];
    
    //self.textSearchViewController.tableView.hidden = NO;
    
    [[self searchBarView] setText:@""];
    [self.view bringSubviewToFront:self.blendView];
    [self.view bringSubviewToFront:self.searchBarView];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    self.navigationItem.rightBarButtonItem = nil;
//    
//    [UIView animateWithDuration:0.3
//                          delay:0.0
//                        options:UIViewAnimationOptionAllowUserInteraction
//                     animations:^
//    {
//                         
//         CGRect searchContainerRect = self.searchContainerView.frame;
//         searchContainerRect.origin.y = self.view.frame.size.height - searchContainerRect.size.height;
//         self.searchContainerView.frame = searchContainerRect;
//         
//         [self adjustSearchBarWidth];
//         [self.searchBar layoutSubviews];
//         
//         CGRect filterButtonRect = self.filterButton.frame;
//         filterButtonRect.origin.x = self.searchContainerView.frame.size.width - self.filterButton.bounds.size.width - 5.0;
//         self.filterButton.frame = filterButtonRect;
//         
//         CGRect blendViewRect = self.blendView.frame;
//         blendViewRect.origin.y = self.view.frame.size.height;
//         self.blendView.frame = blendViewRect;
//     }completion:^(BOOL finish){
//         
//         [self.view sendSubviewToBack:self.textSearchViewController.view];
//         [self.view sendSubviewToBack:self.blendView];
//     }];
    
    [self.view sendSubviewToBack:self.blendView];
    return YES;
}









@end
