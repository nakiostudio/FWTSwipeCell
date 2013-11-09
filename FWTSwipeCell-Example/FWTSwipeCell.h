//
//  FWTSwipeCell.h
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 04/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FWTSwipeCell;

@protocol FWTSwipeCellDelegate;

typedef void (^FWTSwipeCellSelectionBlock)(FWTSwipeCell *cell);
typedef void (^FWTSwipeCellPrimaryActionBlock)(FWTSwipeCell *cell);
typedef void (^FWTSwipeCellSecondaryActionBlock)(FWTSwipeCell *cell);

typedef UIButton * (^FWTSwipeCellOnButtonCreationBlock)(UIButton *inputButton);

@interface FWTSwipeCell : UITableViewCell

@property (nonatomic, strong) FWTSwipeCellSelectionBlock selectionBlock;
@property (nonatomic, strong) FWTSwipeCellPrimaryActionBlock primaryActionBlock;
@property (nonatomic, strong) FWTSwipeCellSecondaryActionBlock secondaryActionBlock;

@property (nonatomic, weak) id<FWTSwipeCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
      creationBlock:(FWTSwipeCellOnButtonCreationBlock)primaryButtonCreationBlock
secondaryCreationBlock:(FWTSwipeCellOnButtonCreationBlock)secondaryButtonCreationBlock;

- (void)restoreScroll;

@end

@protocol FWTSwipeCellDelegate

- (void)swipeCellWillBeginDragging:(FWTSwipeCell*)cell;

@end
