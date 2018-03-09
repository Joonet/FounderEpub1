//
//  BHButton.m
//  E-Publishing
//
//  Created by 李 雷川 on 13-7-12.
//
//

#import "BHButton.h"
@implementation BHButton
@synthesize hasClickState,clickState;

- (id)init{
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
      
    }
    return self;
}
- (void)click:(id)sender{
    switch (_bhButtonType) {
        case BHSearchButton:
        case BHCatalogButton:
        case BHThumbNavButton:
        case BHRecordButton:
        case BHBookmarkButton:
            break;
        default:
               [[NSNotificationCenter defaultCenter]postNotificationName:@"HideNavigationBar" object:nil];
            break;
    }
 
    if (clickState == YES) {
        clickState = NO;
        return;
    }
    if (hasClickState) {
        clickState = YES ;
    }
    //这个地方暂时注释 // 
//    [[StatisticsManager sharedStatisticsManager]addActivityButton:_bhButtonType];

}

 

@end
