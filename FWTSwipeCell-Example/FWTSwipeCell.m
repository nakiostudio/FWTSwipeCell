//
//  FWTSwipeCell.m
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 04/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import "FWTSwipeCell.h"

CGFloat const kOptionsWidth                             =       180.f;
CGFloat const kLabelsLateralMargins                     =       15.f;
CGFloat const kTitleTopMargin                           =       10.f;
CGFloat const kLabelMinHeight                           =       24.f;

NSString *const kPrimaryActionButtonDefaultLabel        =       @"Delete";
NSString *const kSecondaryActionButtonDefaultLabel      =       @"Archive";



@interface FWTSwipeCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollViewButtonView;

@property (nonatomic, strong) UIButton *primaryActionButton;
@property (nonatomic, strong) UIButton *secondaryActionButton;

@property (nonatomic, strong) FWTSwipeCellOnButtonCreationBlock primaryButtonCreationBlock;
@property (nonatomic, strong) FWTSwipeCellOnButtonCreationBlock secondaryButtonCreationBlock;

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
    
    self.secondaryActionButton.frame = CGRectMake(0, 0, kOptionsWidth*0.5f, self.frame.size.height);
    self.primaryActionButton.frame = CGRectMake(kOptionsWidth*0.5f, 0, kOptionsWidth*0.5f, self.frame.size.height);
    
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
-(void)_primaryActionButtonTapped:(id)sender
{
    if (self.primaryActionBlock){
        self.primaryActionBlock(self);
    }
    else{
        NSLog(@"FWTSwipeCellPrimaryActionBlock must be set");
    }
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)_secondaryActionButtonTapped:(id)sender
{
    if (self.secondaryActionBlock){
        self.secondaryActionBlock(self);
    }
    else{
        NSLog(@"FWTSwipeCellSecondaryActionBlock must be set");
    }
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)_contentTapped:(id)sender
{
    if (self.selectionBlock){
        self.selectionBlock(self);
    }
    else{
        NSLog(@"FWTSwipeCellSelectionBlock must be set");
    }
}

#pragma mark - Public methods

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    if (self.delegate != nil){
        [self.delegate swipeCellWillBeginDragging:self];
    }
    else{
        NSLog(@"FWTSwipeCellDelegate must be set");
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
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_contentTapped:)];
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
        
        UIButton *secondaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondaryButton.backgroundColor = [UIColor lightGrayColor];
        secondaryButton.frame = CGRectMake(0, 0, kOptionsWidth*0.5f, self.frame.size.height);
        secondaryButton.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
        [secondaryButton setTitle:kSecondaryActionButtonDefaultLabel forState:UIControlStateNormal];
        [secondaryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [secondaryButton addTarget:self action:@selector(_secondaryActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self->_scrollViewButtonView addSubview:secondaryButton];
        self->_secondaryActionButton = secondaryButton;
        
        UIButton *primaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        primaryButton.backgroundColor = [UIColor redColor];
        primaryButton.frame = CGRectMake(kOptionsWidth*0.5f, 0, kOptionsWidth*0.5f, self.frame.size.height);
        primaryButton.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
        [primaryButton setTitle:kPrimaryActionButtonDefaultLabel forState:UIControlStateNormal];
        [primaryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [primaryButton addTarget:self action:@selector(_primaryActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self->_scrollViewButtonView addSubview:primaryButton];
        self->_primaryActionButton = primaryButton;
    }
    
    if (self->_scrollViewButtonView.superview == nil){
        [self.scrollView insertSubview:self->_scrollViewButtonView belowSubview:self.contentView];
    }
    
    return self->_scrollViewButtonView;
}

@end
