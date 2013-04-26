//
//  HomeViewController.m
//  CityGuide
//
//  Created by Mac Mini on 4/26/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@property (retain, nonatomic) IBOutlet UIView *searchContainView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (retain, nonatomic) IBOutlet MKMapView *myMapView;
@property (retain, nonatomic) IBOutlet UIButton *filtersButton;


- (void)setupView;
- (IBAction)filtersButtonClicked:(id)sender;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_searchContainView release];
    [_searchBarView release];
    [_myMapView release];
    [_filtersButton release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setSearchContainView:nil];
    [self setSearchBarView:nil];
    [self setMyMapView:nil];
    [self setFiltersButton:nil];
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
}

#pragma mark - Button Event

- (IBAction)filtersButtonClicked:(id)sender
{
    
}

@end
