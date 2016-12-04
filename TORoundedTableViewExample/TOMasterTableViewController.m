//
//  TOMasterTableViewController.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 12/2/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TOMasterTableViewController.h"
#import "TODetailTableViewController.h"

@implementation TOMasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Configure the split view controller
    self.splitViewController.maximumPrimaryColumnWidth = 520.0f;
    self.splitViewController.preferredPrimaryColumnWidthFraction = 0.37f;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    // Register a standard cell for this table view
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [@[@(3), @(1), @(2), @(4), @(1)][section] integerValue];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %ld", indexPath.row+1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Don't bother if we're already in a state where one is being showed
    if (self.splitViewController.collapsed == NO) {
        return;
    }
    
    //Create a new instance of the rounded table view controller and present it
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TODetailTableViewController *tableViewController = [storyboard instantiateViewControllerWithIdentifier:@"detailtableViewController"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    [self.splitViewController showDetailViewController:navController sender:self];
}

@end
