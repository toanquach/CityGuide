//
//  DetailAnnotationViewController.m
//  CityGuide
//
//  Created by Toan Quach on 5/3/13.
//  Copyright (c) 2013 Toan.Quach. All rights reserved.
//

#import "DetailAnnotationViewController.h"


@interface DetailAnnotationViewController ()
@property (retain, nonatomic) IBOutlet UITableView *detailTableView;

- (void)setupView;

@end

@implementation DetailAnnotationViewController

@synthesize dictAddress;

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
    NSLog(@"Dict: %@", self.dictAddress);
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
    [_detailTableView release];
    [super dealloc];
}

- (void)viewDidUnload
{
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
}

#pragma mark - Button Event

- (void)saveButonClicked:(id)sender
{
    
}

#pragma mark - UItableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
