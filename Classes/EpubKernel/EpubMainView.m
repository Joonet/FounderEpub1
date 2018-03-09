//
//  EpubMainView.m
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import "EpubMainView.h"
#import "EpubStaticDefine.h"
#import "EpubProtocal.h"
#import "EPUBUtils.h"
#import "EpubNavigationBar.h"
#import "EpubOptionView.h"



#define viewWidth self.frame.size.width
#define viewHeight self.frame.size.height

@implementation EpubMainView
@synthesize showHub;
@synthesize navigateBar;
@synthesize epubMainViewDelegate;
@synthesize pageNumLable;
@synthesize leftPageNumLable;
@synthesize prePageNumLable;
@synthesize epubSlier;
@synthesize pageLable;
@synthesize chapterLable;
@synthesize bottomPageNumLable;
@synthesize topChapterTitleLable;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)addEpubFunctionViews
{
    //初始化滚动条
    epubSlier = [[UISlider alloc]init];
    
    epubSlier.minimumValue =0;
    epubSlier.maximumValue =9999.99;
    
    
    UIImage *minTrackImage = [EPUBUtils createImageWithColor:[UIColor colorWithRed:22.0/255 green:108.0/255 blue:211.0/255 alpha:1.0] withSize:CGSizeMake(2,2) isCircle:NO];
    UIImage *maxTrackImage = [EPUBUtils createImageWithColor:[UIColor grayColor]withSize:CGSizeMake(2, 2) isCircle:NO];
    UIImage *thumbImage = [EPUBUtils createImageWithColor: [UIColor colorWithRed:22.0/255 green:108.0/255 blue:211.0/255 alpha:1.0]withSize:CGSizeMake(8,8) isCircle:YES];
    
    [epubSlier setMinimumTrackImage:minTrackImage forState:UIControlStateNormal];
    [epubSlier setMaximumTrackImage:maxTrackImage forState:UIControlStateNormal];
    [epubSlier setThumbImage:thumbImage forState:UIControlStateNormal];
    [epubSlier setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [epubSlier addTarget:epubMainViewDelegate action:@selector(updateEpubprocess:) forControlEvents:UIControlEventTouchUpInside];
    [epubSlier addTarget:epubMainViewDelegate action:@selector(updateEpubprocess:) forControlEvents:UIControlEventTouchDragExit];
    [epubSlier addTarget:epubMainViewDelegate action:@selector(updateEpubprocess:) forControlEvents:UIControlEventTouchUpOutside];
    [epubSlier addTarget:epubMainViewDelegate action:@selector(epubProcessSliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    float fontSize = 13;
    bottomBar = [[UIToolbar alloc]init];
    [self addSubview:bottomBar];
    
   //初始化页面页码信息
    bottomPageNumLable = [[UILabel alloc]initWithFrame:CGRectMake(viewWidth/2-35, 0, 70, 30)];
    bottomPageNumLable.textAlignment = NSTextAlignmentCenter;
    bottomPageNumLable.text = @"";
    bottomPageNumLable.textColor = [UIColor darkGrayColor];
    bottomPageNumLable.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:bottomPageNumLable];
    
    topChapterTitleLable = [[UILabel alloc]initWithFrame:CGRectMake(viewWidth/2-35, 0, 70, 30)];
    topChapterTitleLable.textAlignment = NSTextAlignmentCenter;
    topChapterTitleLable.text = @"";
    topChapterTitleLable.textColor = [UIColor darkGrayColor];
    topChapterTitleLable.font = [UIFont systemFontOfSize:fontSize];
    [self addSubview:topChapterTitleLable];
    
    NSDictionary *viewsDictionary1 = NSDictionaryOfVariableBindings(bottomPageNumLable,topChapterTitleLable);
    NSDictionary *metrics1 = @{@"hPadding" :@20,@"vPadding" :@15,@"vheight":@30,@"vWidth":@400};
    bottomPageNumLable.translatesAutoresizingMaskIntoConstraints = NO;
    topChapterTitleLable.translatesAutoresizingMaskIntoConstraints = NO;
    
    
     NSArray *constraints1 = [NSLayoutConstraint
     constraintsWithVisualFormat:@"V:|-vPadding-[topChapterTitleLable]"
     options:0
     metrics:metrics1
     views:viewsDictionary1];
    
    constraints1 = [constraints1 arrayByAddingObject:
                             [NSLayoutConstraint constraintWithItem:bottomPageNumLable attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];;
    constraints1 = [constraints1 arrayByAddingObject:
                    [NSLayoutConstraint constraintWithItem:topChapterTitleLable attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:[bottomPageNumLable]-vPadding-|"
                     options:0
                     metrics:metrics1
                     views:viewsDictionary1]];
    if(!isPad){
        constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"H:[topChapterTitleLable(vWidth)]"
                     options:0
                     metrics:metrics1
                     views:viewsDictionary1]];
    }
    
    [self addConstraints:constraints1];
    
    
    //初始化页码信息
    pageNumLable = [[UILabel alloc]initWithFrame:CGRectMake(viewWidth/2-35, 0, 70, 30)];
    pageNumLable.textAlignment = NSTextAlignmentCenter;
    pageNumLable.text = @"";
    pageNumLable.textColor = [UIColor darkGrayColor];
    pageNumLable.font = [UIFont systemFontOfSize:fontSize];
    
    
    prePageNumLable = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 140, 30)];
    prePageNumLable.textAlignment = NSTextAlignmentCenter;
    prePageNumLable.text = @"本章已阅读0页";
    prePageNumLable.font = [UIFont systemFontOfSize:fontSize];
    prePageNumLable.hidden = YES;
    
    leftPageNumLable = [[UILabel alloc]initWithFrame:CGRectMake(viewWidth - 170, 0, 120, 30)];
    leftPageNumLable.textAlignment = NSTextAlignmentCenter;
    leftPageNumLable.text = @"本章还剩0页";
    leftPageNumLable.font = [UIFont systemFontOfSize:fontSize];
    leftPageNumLable.hidden = YES;
    
    UIBarButtonItem *one = [[UIBarButtonItem alloc] initWithCustomView:prePageNumLable];
    UIBarButtonItem *two = [[UIBarButtonItem alloc] initWithCustomView:pageNumLable];
    UIBarButtonItem *three = [[UIBarButtonItem alloc] initWithCustomView:leftPageNumLable];
    UIBarButtonItem *flexItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];;
    [bottomBar setItems:@[one,flexItem1,two,flexItem2,three]];
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(bottomBar);
    NSDictionary *metrics = @{@"hPadding" :@50,@"vPadding" :@8,@"vheight":@44,@"vWidth":@150};
    bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[bottomBar]|"
                            options:0
                            metrics:metrics
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[bottomBar(vheight)]|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    [self addConstraints:constraints];
    //[self constraintPageLable];
    
    //加载导航栏
    [self addBarUtility];
    [self addSubview:navigateBar];
    [self constraintTopBarView];
    [self constraintTopBarSubViews];
    [self addSubview:epubSlier];
    [self setPrecessSliderFrame];

}
#pragma mark -
#pragma mark -----------------HUD DELEGATE METHOD-------------------
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
}
#pragma mark -
#pragma mark -----------------HUD DELEGATE METHOD-------------------

- (void)popoverViewDidDismiss:(PopoverView *)popoverView
{
    if (epubOptionView) {
        
        epubOptionView = nil;
    }
}
#pragma mark -
#pragma mark -----------------FUNCTION METHOD-------------------
-(void)showLoadHud
{
    if(![epubMainViewDelegate getEpubLoadedState])
    {
        HUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:HUD];
        HUD.delegate = self;
        HUD.label.text = @"页面加载中";
        [HUD showWhileExecuting:@selector(startLoad) onTarget:self withObject:nil animated:YES];
    }
}
-(void)startLoad
{
    while(![epubMainViewDelegate getEpubLoadedState])
    {
        usleep(500);
    }
    usleep(800);
    
}
-(BOOL)getNaviBarState
{
    return  navigateBar.hidden;
}
-(void)setPrecessSliderFrame
{
    if([epubMainViewDelegate getEpubFlipType] == EPUB_NOR_FLIP)
    {
        epubSlier.transform =  CGAffineTransformIdentity;
        [epubSlier setFrame:CGRectMake(0,0,viewHeight-165,24)];
        //变为竖的slider
        epubSlier.transform = CGAffineTransformMakeRotation(1.57079633);
        [epubSlier setCenter:CGPointMake(viewWidth-15, viewHeight/2+15)];
    }
    else
    {
        epubSlier.transform =  CGAffineTransformIdentity;
        [epubSlier setFrame:CGRectMake(50, viewHeight-56, viewWidth-50*2, 24)];
        
    }
}
-(void)showSearchHud
{
    showHub = YES;
    if(showHub)
    {
        searchHUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:searchHUD];
        searchHUD.delegate = self;
        searchHUD.label.text = @"搜索中";
        [searchHUD showWhileExecuting:@selector(startSearch) onTarget:self withObject:nil animated:YES];
    }
}
-(void)releaseTitleView
{
    if(titleShowView)
    {
        [titleShowView removeFromSuperview];
        
        titleShowView = nil;
    }
}
-(void)showTitleView
{
    int titileViewWidth;
    if(isPad)
    {
        titileViewWidth = 400;
    }
    else
    {
        titileViewWidth = 300;
    }
    
    if(!titleShowView)
    {
        titleShowView = [[UIView alloc]initWithFrame:CGRectMake((viewWidth-titileViewWidth)/2,viewHeight-124, titileViewWidth, 50)];
        titleShowView.backgroundColor = [UIColor blackColor];
        [self addSubview:titleShowView];
        
        chapterLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titileViewWidth, 30)];
        chapterLable.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        
        chapterLable.textColor = [UIColor whiteColor];
        chapterLable.textAlignment = NSTextAlignmentCenter;
        [titleShowView addSubview:chapterLable];
        
        pageLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, titileViewWidth, 20)];
        pageLable.font = [UIFont systemFontOfSize:12];
        
        pageLable.textColor = [UIColor whiteColor];
        pageLable.textAlignment = NSTextAlignmentCenter;
        [titleShowView addSubview:pageLable];
    }
}
-(void)showOptionView
{
    if(!epubOptionView)
    {
        epubOptionView = [[EpubOptionView alloc]initWithFrame:CGRectMake(0, 0, 244, 236)];
        epubOptionView.delegate = epubMainViewDelegate;
        
    }
    CGPoint point = CGPointMake(navigateBar.optionButton.center.x,CGRectGetMaxY(navigateBar.optionButton.frame) );
    epubPopoverView = [PopoverView showPopoverAtPoint:point inView:self  withContentView:epubOptionView  delegate:self];
}
-(void)setPagenatingProcessView:(float)process
{
    if(!pagenatingProcessView)
    {
        pagenatingProcessView = [[UIView alloc]init];
        pagenatingProcessView.backgroundColor = [UIColor grayColor];
        [self addSubview:pagenatingProcessView];
        
    }
    if([epubMainViewDelegate getEpubFlipType] == EPUB_NOR_FLIP)
    [pagenatingProcessView setFrame:CGRectMake(viewWidth-17, 80, 2, (viewHeight-160)*process)];
    else
    [pagenatingProcessView setFrame:CGRectMake(50, viewHeight-WEBVIEW_TOP_BOTTOM_MARGIN+5, (viewWidth-100)*process,2 )];
}
-(void)setNavigateBarHidden:(BOOL)hidden
{
    epubSlier.hidden = hidden;
    bottomBar.hidden = hidden;
    navigateBar.hidden = hidden;
    if(hidden == NO){
        [self bringSubviewToFront:bottomBar];
        [self bringSubviewToFront:epubSlier];
    }
}

-(void)removeProcessView
{
if(pagenatingProcessView)
{
    [pagenatingProcessView removeFromSuperview];
    pagenatingProcessView = nil;
}
}

-(void)constraintPageLable{
    bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
    pageNumLable.translatesAutoresizingMaskIntoConstraints = NO;
    leftPageNumLable.translatesAutoresizingMaskIntoConstraints = NO;
    prePageNumLable.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(bottomBar,pageNumLable,leftPageNumLable,prePageNumLable);
    NSDictionary *metrics = @{@"hPadding" :@50,@"vPadding" :@8,@"vheight":@30,@"vWidth":@150};
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[buttomView]|"
                            options:0
                            metrics:metrics
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[buttomView(vheight)]|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    [self addConstraints:constraints];
    
    NSArray *constraints1 = [NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|-hPadding-[prePageNumLable(vWidth)]"
                             options:0
                             metrics:metrics
                             views:viewsDictionary];
    constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"H:[leftPageNumLable(vWidth)]-hPadding-|"
                     options:0
                     metrics:metrics
                     views:viewsDictionary]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pageNumLable attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bottomBar attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|[leftPageNumLable]|"
                     options:0
                     metrics:metrics
                     views:viewsDictionary]];
    constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|[prePageNumLable]|"
                     options:0
                     metrics:metrics
                     views:viewsDictionary]];
    constraints1 = [constraints1 arrayByAddingObjectsFromArray:
                    [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|[pageNumLable]|"
                     options:0
                     metrics:metrics
                     views:viewsDictionary]];
    [bottomBar addConstraints:constraints1];
    
}
-(void)startSearch
{
    while(showHub)
    {
        sleep(0.5);
    }
    
    
}
-(void)setBgColor:(UIColor*)bgColor
{
    self.backgroundColor = bgColor;
     bottomBar.barTintColor = bgColor;
}

//导航栏上的按钮增加点击方法
-(void)addBarUtility{
    navigateBar = [[EpubNavigationBar alloc]init];
    [navigateBar.backToViewButton addTarget:epubMainViewDelegate action:@selector(backToBookshelf) forControlEvents:UIControlEventTouchUpInside];
    [navigateBar.searchButton addTarget:epubMainViewDelegate action:@selector(showSerchTextView) forControlEvents:UIControlEventTouchUpInside];
    [navigateBar.optionButton addTarget:epubMainViewDelegate action:@selector(fontChangeClickMethod) forControlEvents:UIControlEventTouchUpInside];
    [navigateBar.bookMarkButton addTarget:epubMainViewDelegate action:@selector(changeBookMarkBtnState:) forControlEvents:UIControlEventTouchUpInside];
    [navigateBar.directoryButton addTarget:epubMainViewDelegate action:@selector(showChapterListView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showSerchTextView{
    NSLog(@"点击了搜索按钮");
}

#pragma mark -
#pragma mark -----------------Constraint METHOD-------------------
-(void)constraintTopBarView{
    [self removeConstraint:topBarConstraint];
    navigateBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(navigateBar);
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[navigateBar]|"
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    topBarConstraint =[NSLayoutConstraint constraintWithItem:navigateBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    [self addConstraints:constraints];
    [self addConstraint:topBarConstraint];
    
}
-(void)constraintTopBarSubViews{
    UIButton *returnButton   = navigateBar.backToViewButton;
    UIButton *searchButton   = navigateBar.searchButton;
    UIButton *optionButton   = navigateBar.optionButton;
    UIButton *bookmarkButton = navigateBar.bookMarkButton;
    UIButton *contentsButton = navigateBar.directoryButton;
    
    
    returnButton.translatesAutoresizingMaskIntoConstraints = NO;
    searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    contentsButton.translatesAutoresizingMaskIntoConstraints = NO;
    optionButton.translatesAutoresizingMaskIntoConstraints = NO;
    bookmarkButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(returnButton,bookmarkButton,optionButton,contentsButton,searchButton);
    NSDictionary *metrics = @{@"hPadding" :@12,@"vPadding" :@8};
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|-hPadding-[returnButton]"
                            options:0
                            metrics:metrics
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                                              constraintsWithVisualFormat:@"H:[searchButton]-hPadding-[contentsButton]-hPadding-[optionButton]-hPadding-[bookmarkButton]-hPadding-|"
                                                              options:0
                                                              metrics:metrics
                                                              views:viewsDictionary]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[returnButton]-vPadding-|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[searchButton]-vPadding-|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[contentsButton]-vPadding-|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[optionButton]-vPadding-|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    constraints = [constraints arrayByAddingObjectsFromArray:
                   [NSLayoutConstraint
                    constraintsWithVisualFormat:@"V:[bookmarkButton]-vPadding-|"
                    options:0
                    metrics:metrics
                    views:viewsDictionary]];
    [navigateBar addConstraints:constraints];
}
#pragma mark -
#pragma mark -----------------SYSTEM METHOD-------------------

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        titleShowView = nil;
        
        // 字体改变引起的web内容重新加载完成
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(epubMainScrollViewDidReloadContent) name:@"EpubMainScrollViewDidReloadContent" object:nil];
    }
    return self;
    
}

-(void)epubMainScrollViewDidReloadContent{
    [epubOptionView setAllControlsEnabled:true];
}

-(void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
