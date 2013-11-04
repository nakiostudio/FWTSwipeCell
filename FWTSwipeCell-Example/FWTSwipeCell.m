//
//  FWTSwipeCell.m
//  FWTSwipeCell-Example
//
//  Created by Carlos Vidal Pallín on 04/11/2013.
//  Copyright (c) 2013 Future Workshops Ltd. All rights reserved.
//

#import "FWTSwipeCell.h"

@implementation FWTSwipeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
