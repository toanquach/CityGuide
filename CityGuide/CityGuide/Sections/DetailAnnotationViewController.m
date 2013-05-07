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
#import "HomeViewController.h"

@interface DetailAnnotationViewController ()

@property (retain, nonatomic) IBOutlet UITableView *detailTableView;

@property (nonatomic, strong) CLGeocoder *geocoder; // support IOS 5

- (void)setupView;
- (void)setupTableView;
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
    [dictAddress release];
    [_geocoder release];
    [_detailTableView release];
    addressStr = nil;
    cellArray = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setDictAddress:nil];
    [self setGeocoder:nil];
    [self setDetailTableView:nil];
    addressStr = nil;
    cellArray = nil;
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
    if(ISIPHONE)
    {
        [self.detailTableView registerNib:[UINib nibWithNibName:@"DetailAnnotationViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:detailViewCellIdentifer];
    }
    else
    {
        [self.detailTableView registerNib:[UINib nibWithNibName:@"DetailAnnotationViewCell_iPad" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:detailViewCellIdentifer];
    }
    //
    //      If have info
    //
    if (self.dictAddress != nil)
    {
        [self setupTableView];
    }
    else
    {
        //
        //      Get address of annotation
        //
         CLLocation *location = [[CLLocation alloc]initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        if (!self.geocoder)
        {
            self.geocoder = [[CLGeocoder alloc] init];
        }
        [self.geocoder reverseGeocodeLocation:location
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
             if (self.dictAddress != nil)
             {
                 [self.dictAddress release];
                 self.dictAddress = nil;
             }
             self.dictAddress = [[NSDictionary alloc] initWithDictionary:placemark.addressDictionary];
             [self setupTableView];
         }];
    }
}

- (void)setupTableView
{
    NSArray *arr = [self.dictAddress objectForKey:@"FormattedAddressLines"];
    addressStr = @"";
    cellArray = [[NSMutableArray alloc] init];
    for (int i = 0; i <[arr count]; i++)
    {
        if (i < [arr count] - 1)
        {
            NSString *str = [NSString stringWithFormat:@"%@, ",[arr objectAtIndex:i]];
            addressStr = [addressStr stringByAppendingString:str];
            str = nil;
        }
        else
        {
            NSString *str = [NSString stringWithFormat:@"%@",[arr objectAtIndex:i]];
            addressStr = [addressStr stringByAppendingString:str];
            str = nil;
        }
    }
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Name:",@"Caption",@"",@"Info", @"1", @"Type", nil];
    [cellArray addObject:dict];
    dict = nil;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            @"Address:",@"Caption",addressStr,@"Info", @"2", @"Type", nil];
    [cellArray addObject:dict];
    dict = nil;
    
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
            @"City:",@"Caption",[self.dictAddress objectForKey:@"City"],@"Info", @"2", @"Type", nil];
    [cellArray addObject:dict];
    dict = nil;
    
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
                          addressStr, @"address",nil];
    
    BOOL flag = [Places insert:dict];
    [dict release];
    dict = nil;
    if (flag == FALSE)
    {
        //
        //      insert fail
        //      show alert view
        //
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Save place fail" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        alertView = nil;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Save place successs" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        alertView = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //
    //      add pin to mapview at Homepage
    //
    DetailAnnotationViewCell *cell = (DetailAnnotationViewCell *)[self.detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:0];
    if ([viewController isKindOfClass:[HomeViewController class]])
    {
        [(HomeViewController *)viewController addPinToMap:self.coordinate andTitle:[cell getInfoText] andSubTitle:[self.dictAddress objectForKey:@"City"]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UItableview datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            //
            //      cacular height
            //
            int height = 0;
            if (ISIPHONE)
            {
                height = 201;
            }
            else
            {
                height = 582;
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, height, 21)];
            label.font = [UIFont boldSystemFontOfSize:14.0];
            NSDictionary *dict = [cellArray objectAtIndex:indexPath.row];
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
        return [cellArray count];
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
        cell = [[[DetailAnnotationViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:detailViewCellIdentifer] autorelease];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0)
    {
        NSDictionary *dict = [cellArray objectAtIndex:indexPath.row];
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
