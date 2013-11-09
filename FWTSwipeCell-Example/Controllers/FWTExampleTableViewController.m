//
//  FWTExampleTableViewController.m
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 04/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import "FWTExampleTableViewController.h"
#import "FWTWebViewController.h"
#import "FWTSwipeCell.h"

@interface FWTExampleObject : NSObject

@property (nonatomic, strong) NSDate *entryDate;

@end

@implementation FWTExampleObject

@synthesize entryDate;

- (NSString*)dateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    return [dateFormatter stringFromDate:self.entryDate];
}

- (NSString*)dateDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    
    return [dateFormatter stringFromDate:self.entryDate];
}

@end



NSString * const kNavigationBarTitleText        =       @"FWTSwipeCell";
NSString * const kUnarchiveSectionTitle         =       @"Unarchived";
NSString * const kArchiveSectionTitle           =       @"Archived";

CGFloat const kSectionHeaderHeight              =       30.f;
CGFloat const kRowHeight                        =       52.f;

typedef enum{
    FWTExampleTableViewUnarchivedSection = 0,
    FWTExampleTableViewArchivedSection,
    FWTExampleTableViewSectionCount
} FWTExampleTableViewSection;

@interface FWTExampleTableViewController () <FWTSwipeCellDelegate>

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
    
    [self _restoreAllVisibleCellsPreservingStateForCell:nil];
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

- (void)_presentWebViewController
{
    FWTWebViewController *webViewController = [[FWTWebViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_restoreAllVisibleCellsPreservingStateForCell:(UITableViewCell*)cell
{
    for (FWTSwipeCell *cell in self.tableView.visibleCells){
        if ([cell isEqual:cell]){
            [cell restoreContentScrollViewOffset];
        }
    }
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

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case FWTExampleTableViewUnarchivedSection:
            return kUnarchiveSectionTitle;
        case FWTExampleTableViewArchivedSection:
            return kArchiveSectionTitle;
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self tableView:tableView numberOfRowsInSection:section] > 0 ? kSectionHeaderHeight : 0.f);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FWTExampleObject *cellObject = [self _objectForRowAtIndexPath:indexPath];
    
    NSString *cellIdentifier = NSStringFromClass([FWTSwipeCell class]);
    FWTSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil){
        cell = [[FWTSwipeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionBlock:[self _swipeCellSelectionBlock]];
        [cell setPrimaryActionBlock:[self _swipeCellPrimaryActionBlock]];
        [cell setSecondaryActionBlock:[self _swipeCellSecondaryActionBlock]];
    }
    
    [cell.textLabel setText:[cellObject dateTime]];
    [cell.detailTextLabel setText:[cellObject dateDay]];
    
    [cell configureButtonWithCustomizationBlock:[self _swipeCellPrimaryButtonConfigurationBlockForRowAtIndexPath:indexPath]
                          isPrimaryActionButton:YES];
    [cell configureButtonWithCustomizationBlock:[self _swipeCellSecondaryButtonConfigurationBlockForRowAtIndexPath:indexPath]
                          isPrimaryActionButton:NO];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _restoreAllVisibleCellsPreservingStateForCell:nil];
}

#pragma mark - FWTSwipeCellDelegate methods
- (void)swipeCellWillBeginDragging:(FWTSwipeCell *)cell
{
    [self _restoreAllVisibleCellsPreservingStateForCell:cell];
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

- (FWTSwipeCellSelectionBlock)_swipeCellSelectionBlock
{
    __weak FWTExampleTableViewController *weakSelf = self;
    
    FWTSwipeCellSelectionBlock selectionBlock = ^(FWTSwipeCell *cell){
        NSIndexPath *selectedIndexPath = [weakSelf.tableView indexPathForCell:cell];
        if (!cell.selected){
            [weakSelf.tableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [weakSelf _presentWebViewController];
        }
        else if (cell.selected){
            [weakSelf.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
        }
    };
    
    return selectionBlock;
}

- (FWTSwipeCellPrimaryActionBlock)_swipeCellPrimaryActionBlock
{
    __weak FWTExampleTableViewController *weakSelf = self;
    
    FWTSwipeCellPrimaryActionBlock primaryActionBlock = ^(FWTSwipeCell *cell){
        NSIndexPath *cellIndexPath = [weakSelf.tableView indexPathForCell:cell];
    
        if (cellIndexPath.section == FWTExampleTableViewUnarchivedSection){
            [weakSelf.unarchivedEntries removeObjectAtIndex:cellIndexPath.row];
        }
        else{
            [weakSelf.archivedEntries removeObjectAtIndex:cellIndexPath.row];
        }
        
        [weakSelf.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    
    return primaryActionBlock;
}

- (FWTSwipeCellSecondaryActionBlock)_swipeCellSecondaryActionBlock
{
    __weak FWTExampleTableViewController *weakSelf = self;
    
    FWTSwipeCellSecondaryActionBlock secondaryActionBlock = ^(FWTSwipeCell *cell){
        NSIndexPath *cellIndexPath = [weakSelf.tableView indexPathForCell:cell];
        
        id movedObject;
        if (cellIndexPath.section == FWTExampleTableViewUnarchivedSection){
            movedObject = weakSelf.unarchivedEntries[cellIndexPath.row];
            [weakSelf.unarchivedEntries removeObjectAtIndex:cellIndexPath.row];
        }
        else{
            movedObject = weakSelf.archivedEntries[cellIndexPath.row];
            [weakSelf.archivedEntries removeObjectAtIndex:cellIndexPath.row];
        }
        
        [weakSelf.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (cellIndexPath.section == FWTExampleTableViewUnarchivedSection){
            [weakSelf.archivedEntries addObject:movedObject];
        }
        else{
            [weakSelf.unarchivedEntries addObject:movedObject];
        }
        
        [weakSelf.tableView reloadData];
    };
    
    return secondaryActionBlock;
}

- (FWTSwipeCellOnButtonCreationBlock)_swipeCellPrimaryButtonConfigurationBlockForRowAtIndexPath:(NSIndexPath*)indexPath
{
    FWTSwipeCellOnButtonCreationBlock configurationBlock = ^UIButton *(UIButton *inputButton){
        [inputButton setImage:[UIImage imageNamed:@"fwt_ic_delete"] forState:UIControlStateNormal];
        [inputButton setTitle:@"" forState:UIControlStateNormal];
        return inputButton;
    };
    
    return configurationBlock;
}

- (FWTSwipeCellOnButtonCreationBlock)_swipeCellSecondaryButtonConfigurationBlockForRowAtIndexPath:(NSIndexPath*)indexPath
{
    FWTSwipeCellOnButtonCreationBlock configurationBlock = ^UIButton *(UIButton *inputButton){
        NSString *buttonIconName = (indexPath.section == FWTExampleTableViewUnarchivedSection ? @"fwt_ic_archive" : @"fwt_ic_unarchive");
        [inputButton setImage:[UIImage imageNamed:buttonIconName] forState:UIControlStateNormal];
        [inputButton setTitle:@"" forState:UIControlStateNormal];
        return inputButton;
    };
    
    return configurationBlock;
}

@end
