//
//  ScaleTableViewController.m
//  BreathMusic
//
//  Created by barry on 02/10/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "ScaleTableViewController.h"

@interface ScaleTableViewController ()
@property(nonatomic,strong)NSArray  *scales;

@end

@implementation ScaleTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.scales=@[@"Major",@"Have Nagila",@"Pentatonic"];
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"ScaleData" ofType:@"plist"];
    self.scales = [NSArray arrayWithContentsOfFile:plistPath];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.scales count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString  *dict=[self.scales[indexPath.row]valueForKey:@"ScaleName"];
    cell.textLabel.text=dict;    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.delegate scaleSelected:self.scales[indexPath.row]];
}

@end
