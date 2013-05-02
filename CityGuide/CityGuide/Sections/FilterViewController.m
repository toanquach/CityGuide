//
//  FilterViewController.m
//  CityGuide
//
//  Created by Mac Mini on 4/27/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "FilterViewController.h"
#import "Places+Custom.h"
#import "FilterViewCell.h"

@interface FilterViewController ()

@property (retain, nonatomic) IBOutlet UITableView *filterTableView;

@property (retain, nonatomic) NSMutableArray *filterPlacesArray;

@property (retain, nonatomic) NSMutableArray *fullPlacesArray;

@property (nonatomic) int currentTypeSearch;


- (void)setupView;

- (void)filterContentForSearchText:(NSString*)searchText;

@end

@implementation FilterViewController

static NSString *filterCellIdentifier = @"filterViewCellIdentifier";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden   = NO;
    self.navigationController.navigationBar.hidden  = NO;
    self.navigationItem.title   = @"Filters";
}

#pragma mark - Util

- (void)setupView
{
    //
    //Regiter Xib for table view cell
    //
    [self.filterTableView registerNib:[UINib nibWithNibName:@"FilterViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:filterCellIdentifier];
    //
    // add right Button
    //
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addButonClicked:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    //
    //
    //
    self.fullPlacesArray = [[NSMutableArray alloc] initWithArray:[Places getAllPlaces]];
    [self.filterTableView reloadData];
}

#pragma mark - Button Event

- (void)addButonClicked:(id)sender
{
        // something here
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:@"UnderContruction" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alerView show];
    [alerView release];
}

#pragma mark - UITableViewDelegate - Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_currentTypeSearch == 0)
    {
        return [self.fullPlacesArray count];
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = @"cellIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
//    }
//    Places *obj = [self.fullPlacesArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = obj.text;
//    cell.detailTextLabel.text = obj.city;
//    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
//    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:14.0];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    FilterViewCell *cell = (FilterViewCell *)[tableView dequeueReusableCellWithIdentifier:filterCellIdentifier];
    
    if(cell == nil)
    {
        cell = [[FilterViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:filterCellIdentifier];
        
    }
    
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Places *obj = [self.fullPlacesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.text;
    cell.detailTextLabel.text = obj.city;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:14.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    
}

#pragma mark - Life Cycle

- (void)dealloc
{
    [_fullPlacesArray release];
    [_filterPlacesArray release];
    [_filterTableView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setFullPlacesArray:nil];
    [self setFilterPlacesArray:nil];
    [self setFilterPlacesArray:nil];
    [self setFilterTableView:nil];
    [super viewDidUnload];
}

@end
