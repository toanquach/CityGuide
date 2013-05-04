//
//  DetailAnnotationViewController.m
//  CityGuide
//
//  Created by Toan Quach on 5/3/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "DetailAnnotationViewController.h"
#import "DetailAnnotationViewCell.h"
#import "UILabel+Custom.h"
#import "Places+Custom.h"

@interface DetailAnnotationViewController ()

@property (retain, nonatomic) NSMutableArray *cellArray;
@property (retain, nonatomic) IBOutlet UITableView *detailTableView;
@property (retain, nonatomic) NSString *addressStr;
- (void)setupView;

@end

@implementation DetailAnnotationViewController

static NSString *detailViewCellIdentifer = @"detailViewCellIdentifer";

@synthesize dictAddress;
@synthesize coordinate;

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
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"DetailAnnotationViewController" owner:self options:nil] objectAtIndex:0];
    }
    else
    {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"DetailAnnotationViewController_iPad" owner:self options:nil] objectAtIndex:0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden   = NO;
    self.navigationController.navigationBar.hidden  = NO;
    self.navigationItem.title   = @"Infos";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_addressStr release];
    [_cellArray release];
    [_detailTableView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setAddressStr:nil];
    [self setCellArray:nil];
    [self setDetailTableView:nil];
    [super viewDidUnload];
}

#pragma mark - util

- (void)setupView
{
    //
    // add right Button
    //
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButonClicked:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    //
    //      register Nib for tablview
    //
    [self.detailTableView registerNib:[UINib nibWithNibName:@"DetailAnnotationViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:detailViewCellIdentifer];
    
    self.cellArray = [[NSMutableArray alloc] init];
    
    NSArray *arr = [self.dictAddress objectForKey:@"FormattedAddressLines"];
    NSString *address = @"";
    for (int i = 0; i <[arr count]; i++)
    {
        if (i < [arr count] - 1)
        {
            address = [address stringByAppendingString:[NSString stringWithFormat:@"%@, ",[arr objectAtIndex:i]]];
        }
        else
        {
            address = [address stringByAppendingString:[NSString stringWithFormat:@"%@",[arr objectAtIndex:i]]];   
        }
    }
    
    self.addressStr = [address retain];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"Name:",@"Caption",@"",@"Info", @"1", @"Type", nil];
    [self.cellArray addObject:dict];
    [dict release];
    
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"Address:",@"Caption",address,@"Info", @"2", @"Type", nil];
    [self.cellArray addObject:dict];
    [dict release];
    
    dict = [[NSDictionary alloc] initWithObjectsAndKeys:
            @"City:",@"Caption",[self.dictAddress objectForKey:@"City"],@"Info", @"2", @"Type", nil];
    [self.cellArray addObject:dict];
    [dict release];
    
    [self.detailTableView reloadData];
}

#pragma mark - Button Event

- (void)saveButonClicked:(id)sender
{
    DetailAnnotationViewCell *cell = (DetailAnnotationViewCell *)[self.detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if ([cell getInfoText] == nil || [[cell getInfoText] isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please input name" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        alertView = nil;
        return;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [cell getInfoText], @"text",
                          [self.dictAddress objectForKey:@"City"], @"city",
                          @"", @"image",
                          [NSString stringWithFormat:@"%f",self.coordinate.latitude], @"latitude",
                          [NSString stringWithFormat:@"%f",self.coordinate.longitude], @"longtitude",
                          self.addressStr, @"address",nil];
    
    BOOL flag = [Places insert:dict];
    if (flag == FALSE)
    {
        //
        //      insert fail
        //      show alert view
        //
    }
}

#pragma mark - UItableview datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 201, 21)];
            label.font = [UIFont boldSystemFontOfSize:14.0];
            NSDictionary *dict = [self.cellArray objectAtIndex:indexPath.row];
            label.text = [dict objectForKey:@"Info"];
            [UILabel setHeightForLabel:label];
            CGSize size = label.frame.size;
            [label release];
            return size.height + 22;
        }
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailAnnotationViewCell *cell = (DetailAnnotationViewCell *)[tableView dequeueReusableCellWithIdentifier:detailViewCellIdentifer];
    
    if(cell == nil)
    {
        cell = [[DetailAnnotationViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:detailViewCellIdentifer];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0)
    {
        NSDictionary *dict = [self.cellArray objectAtIndex:indexPath.row];
        [cell setupViewWithDict:dict];
    }
    else
    {
        
    }
    return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Nothing here
}

@end
