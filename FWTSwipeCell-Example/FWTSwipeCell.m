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

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
priButtonCreationBlock:(FWTSwipeCellOnButtonCreationBlock)primaryButtonCreationBlock
secButtonCreationBlock:(FWTSwipeCellOnButtonCreationBlock)secondaryButtonCreationBlock
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

#pragma mark - Public methods
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

-(void)restoreContentScrollViewOffset
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)configureButtonWithCustomizationBlock:(FWTSwipeCellOnButtonCreationBlock)customizationBlock
                        isPrimaryActionButton:(BOOL)configurePrimaryActionButton
{
    if (customizationBlock != nil){
        UIButton *button = (configurePrimaryActionButton ? self.primaryActionButton : self.secondaryActionButton);
        SEL buttonSelector = (configurePrimaryActionButton ? @selector(_primaryActionButtonTapped:) : @selector(_secondaryActionButtonTapped:));
        
        button = customizationBlock(button);
        [button addTarget:self action:buttonSelector forControlEvents:UIControlEventTouchUpInside];
        
        [self setNeedsDisplay];
    }
    else{
        NSLog(@"FWTSwipeCellOnButtonCreationBlock argument cannot be nil");
    }
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
    
    [self restoreContentScrollViewOffset];
}

-(void)_secondaryActionButtonTapped:(id)sender
{
    if (self.secondaryActionBlock){
        self.secondaryActionBlock(self);
    }
    else{
        NSLog(@"FWTSwipeCellSecondaryActionBlock must be set");
    }
    
    [self restoreContentScrollViewOffset];
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
    }
    
    if (self->_scrollViewButtonView.superview == nil){
        [self.scrollView insertSubview:self->_scrollViewButtonView belowSubview:self.contentView];
    }
    
    return self->_scrollViewButtonView;
}

- (UIButton*)primaryActionButton
{
    if (self->_primaryActionButton == nil && self.primaryButtonCreationBlock == nil){
        self->_primaryActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self->_primaryActionButton.backgroundColor = [UIColor redColor];
        self->_primaryActionButton.frame = CGRectMake(kOptionsWidth*0.5f, 0, kOptionsWidth*0.5f, self.frame.size.height);
        self->_primaryActionButton.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
        [self->_primaryActionButton setTitle:kPrimaryActionButtonDefaultLabel forState:UIControlStateNormal];
        [self->_primaryActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self->_primaryActionButton addTarget:self action:@selector(_primaryActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (self->_primaryActionButton == nil && self.primaryButtonCreationBlock != nil){
        self->_primaryActionButton = self.primaryButtonCreationBlock(nil);
        [self->_primaryActionButton addTarget:self action:@selector(_primaryActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self->_primaryActionButton.superview == nil){
        [self.scrollViewButtonView addSubview:self->_primaryActionButton];
    }

    return self->_primaryActionButton;
}

- (UIButton*)secondaryActionButton
{
    if (self->_secondaryActionButton == nil){
        self->_secondaryActionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self->_secondaryActionButton.backgroundColor = [UIColor lightGrayColor];
        self->_secondaryActionButton.frame = CGRectMake(0, 0, kOptionsWidth*0.5f, self.frame.size.height);
        self->_secondaryActionButton.autoresizesSubviews = UIViewAutoresizingFlexibleHeight;
        [self->_secondaryActionButton setTitle:kSecondaryActionButtonDefaultLabel forState:UIControlStateNormal];
        [self->_secondaryActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self->_secondaryActionButton addTarget:self action:@selector(_secondaryActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (self->_secondaryActionButton == nil && self.secondaryButtonCreationBlock != nil){
        self->_secondaryActionButton = self.secondaryButtonCreationBlock(nil);
        [self->_secondaryActionButton addTarget:self action:@selector(_secondaryActionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self->_secondaryActionButton.superview == nil){
        [self.scrollViewButtonView addSubview:self->_secondaryActionButton];
    }
    
    return self->_secondaryActionButton;
}

@end
