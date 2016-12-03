//
//  TOMasterTableViewController.m
//  TORoundedTableView
//
//  Created by Tim Oliver on 12/2/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TOMasterTableViewController.h"

@interface TOMasterTableViewController ()

@end

@implementation TOMasterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.splitViewController.maximumPrimaryColumnWidth = 520.0f;
    self.splitViewController.preferredPrimaryColumnWidthFraction = 0.37f;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %ld", indexPath.row+1];
    return cell;
}

@end
