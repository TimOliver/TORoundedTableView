//
//  ViewController.m
//  TORoundedTableViewExample
//
//  Created by Tim Oliver on 29/11/16.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "TOTableViewController.h"

#import "TORoundedTableView.h"
#import "TORoundedTableViewCell.h"

@interface TOTableViewController ()

@end

@implementation TOTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %ld", section];
}

- (UITableViewCell *)tableView:(TORoundedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *topIdentifier = @"TopCell";
    static NSString *middleIdentifier = @"MidCell";
    static NSString *bottomIdentifier = @"BottomCell";
    
    BOOL isTop = (indexPath.row == 0);
    BOOL isBottom = (indexPath.row == 9);
    
    NSString *identifier = nil;
    if (isTop) {
        identifier = topIdentifier;
    }
    else if (isBottom) {
        identifier = bottomIdentifier;
    }
    else {
        identifier = middleIdentifier;
    }
    
    TORoundedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TORoundedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        [tableView configureStyleForCell:cell firstInSection:isTop lastInSection:isBottom];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %ld", indexPath.row+1];
    cell.detailTextLabel.text = @"Subtitle";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
