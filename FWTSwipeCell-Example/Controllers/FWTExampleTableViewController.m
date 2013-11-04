//
//  FWTExampleTableViewController.m
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 04/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import "FWTExampleTableViewController.h"

@interface FWTExampleObject : NSObject

@property (nonatomic, strong) NSDate *entryDate;

@end

@implementation FWTExampleObject

@synthesize entryDate;

@end



NSString * kNavigationBarTitleText = @"FWTSwipeCell";

typedef enum{
    FWTExampleTableViewUnarchivedSection = 0,
    FWTExampleTableViewArchivedSection,
    FWTExampleTableViewSectionCount
} FWTExampleTableViewSection;

@interface FWTExampleTableViewController ()

@property (nonatomic, strong) NSMutableArray *unarchivedEntries;
@property (nonatomic, strong) NSMutableArray *archivedEntries;

@end

@implementation FWTExampleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _setupNavigationBar];
    [self _setupTableView];
}

#pragma mark - Private methods
- (void)_setupNavigationBar
{
    self.title = kNavigationBarTitleText;
    
    UIBarButtonItem *addEntryButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                        target:self
                                                                                        action:@selector(_addEntry)];
    self.navigationItem.rightBarButtonItem = addEntryButtonItem;
}

- (void)_setupTableView
{
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)]];
}

- (void)_addEntry
{
    FWTExampleObject *exampleObject = [[FWTExampleObject alloc] init];
    exampleObject.entryDate = [NSDate date];
    
    [self.unarchivedEntries addObject:exampleObject];
    
    [self.tableView reloadData];
}

- (id)_objectForRowAtIndexPath:(NSIndexPath*)indexPath
{
    FWTExampleObject *cellObject;
    
    switch (indexPath.section) {
        case FWTExampleTableViewUnarchivedSection:
            cellObject = self.unarchivedEntries[indexPath.row];
            break;
        case FWTExampleTableViewArchivedSection:
            cellObject = self.archivedEntries[indexPath.row];
            break;
        default:
            break;
    }
    
    return cellObject;
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return FWTExampleTableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case FWTExampleTableViewUnarchivedSection:
            return self.unarchivedEntries.count;
        case FWTExampleTableViewArchivedSection:
            return self.archivedEntries.count;
        default:
            return 0;
    }
}

#pragma mark - UITableViewDelegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FWTExampleObject *cellObject = [self _objectForRowAtIndexPath:indexPath];
    
    NSString *cellIdentifier = NSStringFromClass([UITableViewCell class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = cellObject.debugDescription;
    
    return cell;
}

#pragma mark - Lazy loading
- (NSMutableArray*)unarchivedEntries
{
    if (self->_unarchivedEntries == nil){
        self->_unarchivedEntries = [NSMutableArray array];
    }
    
    return self->_unarchivedEntries;
}

- (NSMutableArray*)archivedEntries
{
    if (self->_archivedEntries == nil){
        self->_archivedEntries = [NSMutableArray array];
    }
    
    return self->_archivedEntries;
}

@end
