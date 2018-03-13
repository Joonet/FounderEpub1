//
//  EpubNavigationBar.m
//  E-Publishing
//
//  Created by miaopu on 14-10-9.
//
//

#import "EpubNavigationBar.h"
#import "BHButton.h"
#import "EpubStaticDefine.h"

@implementation EpubNavigationBar
@synthesize backToViewButton;
@synthesize bookMarkButton;
@synthesize directoryButton;
@synthesize optionButton;
@synthesize searchButton;
@synthesize bookType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        UIImage *barBGImage = [UIImage loadImageClass:[self class] ImageName:@"kernel_bar_bg_v"];
        [self setImage:barBGImage];
        
        [self addUtilityViews];
        //        [self setUtilityFrames];
    }
    return self;
}

-(void)addUtilityViews
{
    backToViewButton = [BHButton buttonWithType:UIButtonTypeCustom];
    backToViewButton.bhButtonType=BHRecordButton;
    [backToViewButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_back_bookshelf"] forState:UIControlStateNormal];
    [backToViewButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_back_bookshelf_s"] forState:UIControlStateHighlighted];
    [self addSubview:backToViewButton];
    
    searchButton = [BHButton buttonWithType:UIButtonTypeCustom];
    searchButton.bhButtonType=BHRecordButton;
    [searchButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_search"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_search_s"] forState:UIControlStateHighlighted];
    [self addSubview:searchButton];
    
    optionButton = [BHButton buttonWithType:UIButtonTypeCustom];
    optionButton.bhButtonType=BHRecordButton;
    [optionButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_setting"] forState:UIControlStateNormal];
    [optionButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_setting_s"] forState:UIControlStateHighlighted];
    [self addSubview:optionButton];
    
    bookMarkButton = [BHButton buttonWithType:UIButtonTypeCustom];
    bookMarkButton.bhButtonType=BHRecordButton;
    [bookMarkButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_bookmark"] forState:UIControlStateNormal];
    [bookMarkButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_bookmark_s"] forState:UIControlStateHighlighted];
    [self addSubview:bookMarkButton];
    
    directoryButton = [BHButton buttonWithType:UIButtonTypeCustom];
    directoryButton.bhButtonType=BHRecordButton;
    [directoryButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_catalog"] forState:UIControlStateNormal];
    [directoryButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_catalog"] forState:UIControlStateHighlighted];
    [self addSubview:directoryButton];
    
    
}
//
//-(void)setUtilityFrames
//{
//     [backToViewButton setFrame:CGRectMake(23,NAVIGATION_BTNTOTOP,NAVIGATION_BTN_WIDTH, NAVIGATION_BTN_HEIGHT)];
//     [searchButton setFrame:CGRectMake(NAVIGATION_LEFT_MARGIN,NAVIGATION_BTNTOTOP,NAVIGATION_BTN_WIDTH, NAVIGATION_BTN_HEIGHT)];
//     [optionButton setFrame:CGRectMake(NAVIGATION_LEFT_MARGIN+NAVIGATION_BTN_BTW+NAVIGATION_BTN_WIDTH,NAVIGATION_BTNTOTOP,NAVIGATION_BTN_WIDTH, NAVIGATION_BTN_HEIGHT)];
//    [directoryButton setFrame:CGRectMake(NAVIGATION_LEFT_MARGIN+NAVIGATION_BTN_BTW*2+NAVIGATION_BTN_WIDTH*2,NAVIGATION_BTNTOTOP,NAVIGATION_BTN_WIDTH, NAVIGATION_BTN_HEIGHT)];
//     [bookMarkButton setFrame:CGRectMake(NAVIGATION_LEFT_MARGIN+NAVIGATION_BTN_BTW*3+NAVIGATION_BTN_WIDTH*3,NAVIGATION_BTNTOTOP+5,23, 23)];
//
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
