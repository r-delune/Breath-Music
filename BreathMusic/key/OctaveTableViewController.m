//
//  OctaveTableViewController.m
//  BreathMusic
//
//  Created by barry on 09/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "OctaveTableViewController.h"

@interface OctaveTableViewController ()
@property(nonatomic,strong)NSArray  *octaves;
@end

@implementation OctaveTableViewController

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
    self.octaves=@[[NSNumber numberWithInt:0],
                   [NSNumber numberWithInt:1],
                   [NSNumber numberWithInt:2],
                   [NSNumber numberWithInt:3],
                   [NSNumber numberWithInt:4],
                   [NSNumber numberWithInt:5],
                   [NSNumber numberWithInt:6],
                   [NSNumber numberWithInt:7]];
    
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
    return [self.octaves count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSNumber  *dict=self.octaves[indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%i",[dict intValue]];    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber  *dict=self.octaves[indexPath.row];
    
    [self.delegate ocatveSelected:dict];
    
}

@end
