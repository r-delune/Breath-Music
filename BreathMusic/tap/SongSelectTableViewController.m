//
//  SongSelectTableViewController.m
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "SongSelectTableViewController.h"

@interface SongSelectTableViewController ()
@property(nonatomic,strong)NSArray *songs;
@property int toggleIndex;

@end

@implementation SongSelectTableViewController

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
   // self.songs=@[@"themorningdew",@"ohmydarlingclementine"];
    if (!self.songs) {
        self.songs=@[@"themorningdew",@"ohmydarlingclementine"];
        
    }
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
    return [self.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text=self.songs[indexPath.row];
    // Configure the cell...
    
    return cell;
}

-(void)toggle
{
    if (!self.songs) {
        self.songs=@[@"themorningdew",@"ohmydarlingclementine"];

    }
    
    self.toggleIndex++;
    
    if (self.toggleIndex>=[self.songs count]) {
        self.toggleIndex=0;
    }
    
    [self.delegate songSelected:self.songs[self.toggleIndex]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString  *key=self.songs[indexPath.row];
    
    [self.delegate songSelected:key];
    
}

@end
