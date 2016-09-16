//
//  SongModeTableViewController.m
//  BreathMusic
//
//  Created by barry on 08/09/2014.
//  Copyright (c) 2014 rocudo. All rights reserved.
//

#import "SongModeTableViewController.h"

@interface SongModeTableViewController ()
@property(nonatomic,strong)NSArray  *songs;
@property int toggleIndex;
@end

@implementation SongModeTableViewController

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
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"BreathMusicSongList" ofType:@"plist"];
    self.songs = [NSArray arrayWithContentsOfFile:plistPath];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
/*-(void)toggle
{
    if (!self.songs) {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Styles" ofType:@"plist"];
        self.songs = [NSArray arrayWithContentsOfFile:plistPath];
        self.toggleIndex=0;
    
    }
    
    
    
    self.toggleIndex++;
    if (self.toggleIndex>=[self.songs count]) {
        self.toggleIndex=0;
    }
    
    [self.delegate songSelected:self.songs[self.toggleIndex]];
    
    
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songs count];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary  *style=self.songs[indexPath.row];
    
    NSLog(@"%@ at index %li",[style objectForKey:@"SongDisplayName"],(long)indexPath.row);
    [self.delegate songSelected:style];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary  *style=[self.songs objectAtIndex:indexPath.row];
    cell.textLabel.text=[style objectForKey:@"SongDisplayName"];
    // Configure the cell...
    NSLog(@"%@ at index %li",[style objectForKey:@"SongDisplayName"],(long)indexPath.row);
    return cell;
    
}

@end
