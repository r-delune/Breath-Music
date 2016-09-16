//
//  KeyTableViewController.m
//  BreathMusic
//
//  Created by barry on 05/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "KeyTableViewController.h"

@interface KeyTableViewController ()
@property(nonatomic,strong)NSArray  *keyArray;
@property int arrayIndex;
@end

@implementation KeyTableViewController

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
    
    if (!self.keyArray) {
        self.keyArray=@[@"C Major",@"D Major",@"E Major",@"F Major",@"G Major",@"A Major",@"B Major"];
        self.arrayIndex=0;
    }
   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(NSString*)toggleKey
{
    if (!self.keyArray) {
        self.keyArray=@[@"C Major",@"D Major",@"E Major",@"F Major",@"G Major",@"A Major",@"B Major"];
        self.arrayIndex=0;
    }
    self.arrayIndex++;
    if (self.arrayIndex>=[self.keyArray count]) {
        self.arrayIndex=0;
    }
    
    return self.keyArray[self.arrayIndex];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.keyArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.isAccessibilityElement=YES;
    cell.textLabel.text=self.keyArray[indexPath.row];
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString  *key=self.keyArray[indexPath.row];
    
    [self.delegate keySelected:key];

}
@end
