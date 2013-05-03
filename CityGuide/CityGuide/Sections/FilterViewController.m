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

@property (retain, nonatomic) NSMutableArray *placesGroupArray;

@property (nonatomic) int isSearch;

@property (retain, nonatomic) NSMutableArray *alphaBetArray;

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
    self.alphaBetArray = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"K",@"L",@"M",@"N",@"O",@"P",@"R",@"S",@"T",@"U",@"V",@"X",@"Y",@"Z",@"#",nil];
    //
    // list section in list customer sort by alphabe
    //
    self.placesGroupArray = [[NSMutableArray alloc] init];
    NSArray *groupByPlaceArray = [[NSArray alloc] initWithArray:[Places selectGroupBy]];
    
    //get list group
    for (int i = 0; i < [self.alphaBetArray count]; i++)
    {
        for (int j = 0; j < [groupByPlaceArray count]; j++)
        {
            NSDictionary *dict = [groupByPlaceArray objectAtIndex:j];
            NSString *key = [dict objectForKey:@"city"];
            if ([key isEqualToString:@""] || key == nil)
            {
                key = @"#";
            }
            NSString *firtChar = [key substringWithRange:NSMakeRange(0, 1)];
            if ([firtChar isEqualToString:[self.alphaBetArray objectAtIndex:i]])
            {
                // get list item by city
                NSArray *list = [[NSArray alloc] initWithArray:[Places selectItemByCity:key]];
                if (list != nil && [list count] > 0)
                {
                    [self.placesGroupArray addObject:list];
                }
            }
        }
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.filterTableView])
    {
        if (self.isSearch)
        {
            return 1;
        }
        return [self.placesGroupArray count];
    }
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearch == 0)
    {
//        return [self.fullPlacesArray count];
        return [[self.fullPlacesArray objectAtIndex:section] count];
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    FilterViewCell *cell = (FilterViewCell *)[tableView dequeueReusableCellWithIdentifier:filterCellIdentifier];
    
    if(cell == nil)
    {
        cell = [[FilterViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:filterCellIdentifier];
        
    }

    Places *obj = [self.fullPlacesArray objectAtIndex:indexPath.row];
    [cell setupCellWithPlace:obj];
    return cell;
}

//
//      Section Index
//
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.filterTableView])
    {
        if (!self.isSearch)
        {
            return self.alphaBetArray;
        }
    }
	return [[[NSArray alloc]init] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.filterTableView])
    {
        if (self.isSearch)
        {
            return 0;
        }
        if (((NSMutableArray*)[self.placesGroupArray objectAtIndex:section]).count > 0)
        {
            return 20;
        }
    }
    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.filterTableView])
    {
        UITableViewHeaderFooterView *headerView = [[[UITableViewHeaderFooterView alloc] init] autorelease];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"customer_header_cell_bg.png"]];
        imgView.frame = CGRectMake(0, 0, 380 , 22);
        [headerView addSubview:imgView];
        [imgView release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 20)];
        label.text = [self.alphaBetArray objectAtIndex:section];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
        
        [headerView addSubview:label];
        
        headerView.tintColor = [UIColor colorWithRed:231/255.f green:231/255.f blue:231/255.f alpha:1];
        
        return headerView;
    }
    
    return nil;
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
    [_alphaBetArray release];
    [_placesGroupArray release];
    [_fullPlacesArray release];
    [_filterPlacesArray release];
    [_filterTableView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setAlphaBetArray:nil];
    [self setPlacesGroupArray:nil];
    [self setFullPlacesArray:nil];
    [self setFilterPlacesArray:nil];
    [self setFilterPlacesArray:nil];
    [self setFilterTableView:nil];
    [super viewDidUnload];
}

@end
