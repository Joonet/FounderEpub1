//
//  EpubChapterCoverView.m
//  E-Publishing
//
//  Created by miaopu on 14-10-13.
//
//

#import "EpubChapterCoverView.h"

@implementation EpubChapterCoverView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //  Initialization code 
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    [self.delegate removeChapterListView];
    return YES;
}


@end
