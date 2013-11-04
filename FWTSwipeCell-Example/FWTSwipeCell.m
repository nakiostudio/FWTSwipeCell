//
//  FWTSwipeCell.m
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 04/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import "FWTSwipeCell.h"

CGFloat kOptionsWidth                       =       180.f;
CGFloat kLabelsLateralMargins               =       15.f;
CGFloat kTitleTopMargin                     =       10.f;
CGFloat kLabelMinHeight                     =       24.f;

NSString *kDeleteButtonLabel                =       @"Delete";
NSString *kAdditionalActionButtonLabel      =       @"Archive";

@interface FWTSwipeCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollViewButtonView;

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation FWTSwipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width + kOptionsWidth, self.frame.size.height - 1.0f);
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 1.0f);
    self.scrollViewButtonView.frame = CGRectMake(self.frame.size.width - kOptionsWidth, 0, kOptionsWidth, self.frame.size.height - 1.0f);
    
    self.additionalButton.frame = CGRectMake(0, 0, kOptionsWidth*0.5f, self.frame.size.height);
    self.deleteButton.frame = CGRectMake(kOptionsWidth*0.5f, 0, kOptionsWidth*0.5f, self.frame.size.height);
    
    self.backgroundView = [UIView new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected && !self.editing){
        self.scrollViewButtonView.alpha = 0.f;
    }
    else if (!selected && !self.editing){
        self.scrollViewButtonView.alpha = 1.f;
    }
    
    void (^changes)(void) = ^void(void) {
        if (selected && !self.editing){
            self.scrollViewButtonView.backgroundColor = [UIColor lightGrayColor];
            self.scrollView.scrollEnabled = NO;
        }
        else if (selected && self.editing){
            self.scrollViewButtonView.backgroundColor = [UIColor lightGrayColor];
            self.scrollView.scrollEnabled = NO;
        }
        else if (!selected && self.editing){
            self.scrollViewButtonView.backgroundColor = [UIColor whiteColor];
            self.scrollView.scrollEnabled = NO;
        }
        else{
            self.scrollViewButtonView.backgroundColor = [UIColor whiteColor];
            self.scrollView.scrollEnabled = YES;
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3f animations:changes];
    } else {
        changes();
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    self.scrollView.scrollEnabled = !self.editing;
    self.scrollViewButtonView.hidden = editing;
}

-(void)restoreScroll
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Private Methods
-(void)_userPressedDeleteButton:(id)sender
{
    if (self.actionBlock != nil){
        self.actionBlock(self, FWTSwipeCellActionDeleteRow);
    }
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)_userPressedArchiveButton:(id)sender
{
    if (self.actionBlock != nil){
        self.actionBlock(self, FWTSwipeCellActionAdditionalRow);
    }
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)_userPressedContent:(id)sender
{
    if (self.selected && !self.editing)
        return;
    
    if (self.actionBlock != nil){
        self.actionBlock(self, FWTSwipeCellActionSelectRow);
    }
}

#pragma mark - Public methods

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    if (self.actionBlock){
        self.actionBlock(self, FWTSwipeCellActionWillBeginDragging);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView.contentOffset.x > kOptionsWidth) {
        targetContentOffset->x = kOptionsWidth;
    }
    else {
        *targetContentOffset = CGPointZero;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setContentOffset:CGPointZero animated:YES];
        });
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointZero;
    }
    
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x + (self.frame.size.width - kOptionsWidth), 0.0f, kOptionsWidth, self.frame.size.height);
}

#pragma mark - Lazy loading
- (UIScrollView*)scrollView
{
    if (self->_scrollView == nil){
        self->_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 1.0f)];
        self->_scrollView.contentSize = CGSizeMake(self.frame.size.width + kOptionsWidth, self.frame.size.height - 1.0f);
        self->_scrollView.delegate = self;
        self->_scrollView.showsHorizontalScrollIndicator = NO;
    }
    
    if (self->_scrollView.superview == nil){
        
        [self.contentView removeFromSuperview];
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_userPressedContent:)];
        [self.contentView addGestureRecognizer:tapGestureRecognizer];
        
        
        [self->_scrollView addSubview:self.contentView];
        
        [self addSubview:self->_scrollView];
    }
    
    return self->_scrollView;
}

- (UIView*)scrollViewButtonView
{
    if (self->_scrollViewButtonView == nil){
        self->_scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - kOptionsWidth, 0, kOptionsWidth, self.frame.size.height)];
        
        UIButton *additionalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        additionalButton.backgroundColor = [UIColor lightGrayColor];
        additionalButton.frame = CGRectMake(0, 0, kOptionsWidth*0.5f, self.frame.size.height);
        additionalButton.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
        [additionalButton setTitle:kAdditionalActionButtonLabel forState:UIControlStateNormal];
        [additionalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [additionalButton addTarget:self action:@selector(_userPressedArchiveButton:) forControlEvents:UIControlEventTouchUpInside];
        [self->_scrollViewButtonView addSubview:additionalButton];
        self->_additionalButton = additionalButton;
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.backgroundColor = [UIColor redColor];
        deleteButton.frame = CGRectMake(kOptionsWidth*0.5f, 0, kOptionsWidth*0.5f, self.frame.size.height);
        deleteButton.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
        [deleteButton setTitle:kDeleteButtonLabel forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(_userPressedDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self->_scrollViewButtonView addSubview:deleteButton];
        self->_deleteButton = deleteButton;
    }
    
    if (self->_scrollViewButtonView.superview == nil){
        [self.scrollView insertSubview:self->_scrollViewButtonView belowSubview:self.contentView];
    }
    
    return self->_scrollViewButtonView;
}

@end
