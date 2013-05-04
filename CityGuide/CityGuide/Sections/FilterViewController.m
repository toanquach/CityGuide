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

- (void)loadView
{
    //
    // check type device and load view
    //
    if (ISIPHONE)
    {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"FilterViewController" owner:self options:nil] objectAtIndex:0];
    }
    else
    {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"FilterViewController_iPad" owner:self options:nil] objectAtIndex:0];
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
    //      list section in list customer sort by alphabe
    //
    self.placesGroupArray = [[NSMutableArray alloc] init];
    //
    //      get group by country
    //
    NSArray *groupByPlaceArray = [[NSArray alloc] initWithArray:[Places selectGroupBy]];
    //
    //      get list group
    //
    for (int i = 0; i < [self.alphaBetArray count]; i++)
    {
        NSString *keyChar = [self.alphaBetArray objectAtIndex:i];
        NSMutableArray *rowAray = [[NSMutableArray alloc] init];
        for (int j = 0; j < [groupByPlaceArray count]; j++)
        {
            NSDictionary *dict = [groupByPlaceArray objectAtIndex:j];
            NSString *key = [dict objectForKey:@"city"];
            if ([key isEqualToString:@""] || key == nil)
            {
                key = @"#";
            }
            NSString *firtChar = [key substringWithRange:NSMakeRange(0, 1)];
            if ([firtChar isEqualToString:keyChar])
            {
                // get list item by city
                if ([key isEqualToString:@"#"])
                {
                    key = @"";
                }
                NSArray *list = [[NSArray alloc] initWithArray:[Places selectItemByCity:key]];
                if (list != nil && [list count] > 0)
                {
                    if ([key isEqualToString:@""] == FALSE)
                    {
                        //
                        //      add item first
                        //
                        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"type",key,@"value", nil];
                        [rowAray addObject:dict];
                        [dict release];
                    }
                    
                    for (int k = 0; k < [list count]; k++)
                    {
                        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"type",[list objectAtIndex:k],@"value", nil];
                        [rowAray addObject:dict];
                        [dict release];
                    }
                }
            }
        }   // end for J
        [self.placesGroupArray addObject:rowAray];
        [rowAray release];
    }
    [groupByPlaceArray release];
    //
    //Regiter Xib for table view cell
    //
    [self.filterTableView registerNib:[UINib nibWithNibName:@"FilterViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:filterCellIdentifier];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"FilterViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:filterCellIdentifier];
    
    //
    // add right Button
    //
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addButonClicked:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    //
    //
    //
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
        if (self.isSearch == 1)
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
        return [[self.placesGroupArray objectAtIndex:section] count];
    }
    return [self.filterPlacesArray count];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //Places *obj = [self.fullPlacesArray objectAtIndex:indexPath.row];
    //[cell setupCellWithPlace:obj];
    NSDictionary *dict = nil;
    if (self.isSearch == 1)
    {
         dict = [self.filterPlacesArray objectAtIndex:indexPath.row];
    }
    else
    {
         dict = [[self.placesGroupArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [cell setupCellWithDict:dict];
    return cell;
}

//
//      Section Index
//
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.filterTableView])
    {
        if (self.isSearch == 0)
        {
            return self.alphaBetArray;
        }
    }
	return [[[NSArray alloc]initWithObjects:@"", nil] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.filterTableView])
    {
        if (self.isSearch == 1)
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
        [label release];
        
        headerView.tintColor = [UIColor colorWithRed:231/255.f green:231/255.f blue:231/255.f alpha:1];
        return headerView;
    }
    
    return nil;
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
 
    if (self.filterPlacesArray)
    {
        [self.filterPlacesArray  release];
        self.filterPlacesArray  = nil;
    }
    self.filterPlacesArray = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:[Places searchItemWithKey:searchText]];
    for (int i = 0; i < [list count]; i++)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"type",[list objectAtIndex:i],@"value", nil];
        [self.filterPlacesArray  addObject:dict];
        [dict release];
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.isSearch = 1;
    [self filterContentForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.isSearch = 0;
}

#pragma mark - Life Cycle

- (void)dealloc
{
    [_alphaBetArray release];
    [_placesGroupArray release];
    [_filterPlacesArray release];
    [_filterTableView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setAlphaBetArray:nil];
    [self setPlacesGroupArray:nil];
    [self setFilterPlacesArray:nil];
    [self setFilterPlacesArray:nil];
    [self setFilterTableView:nil];
    [super viewDidUnload];
}

@end
