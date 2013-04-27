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
            rect.origin.y = self.radiusView.frame.origin.y + self.radiusView.frame.size.height;
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
            rect.origin.y = 44;
            self.downUpButton.frame = rect;
            
            rect = self.radiusView.frame;
            rect.origin.y = 0;
            self.radiusView.frame = rect;
            
        }];        //slider up
        self.downUpButtonType = 0;
        [self.downUpButton setBackgroundImage:[UIImage imageNamed:@"down_button.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - util

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


@end
