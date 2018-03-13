//
//  EPubMainViewController.m
//  E-Publishing
//
//  Created by miaopu on 14/12/26.
//
//

#import "EPubMainViewController.h"
#import "EpubStaticDefine.h"
#import "EpubNavigationBar.h"
#import "EPUBChapterListViewController.h"
#import "EpubChapter.h"
#import "EpubWebView.h"
#import "JSON.h"
#import "TeaRecord.h"
#import "EpubSearchViewController.h"
#import "ENoteRefViewController.h"
#import "EImageView.h"
#import "EPUBDateModel.h"
#import "EPUBUtils.h"
#import "EpubNoteListObject.h"
#import "EpubMarkObject.h"
#import "PaperImageBrowserController.h"


@interface EPubMainViewController ()

@end

@implementation EPubMainViewController
@synthesize exitEpubBlock;;


#pragma mark -
#pragma mark -----------------INT OR LOAD METHOD-------------------

//初始化epubbook 和相关的视图
- (id)initWithDirPath:(NSString *)dirPath
{
    self = [super init];
    if (self) {
        //初始化epub相关的EPUB相关的
        epubController = [[HYEpubController alloc] initWithDestinationFolder:[NSURL fileURLWithPath:dirPath]];
        epubController.delegate = self;
        
        //初始化页码信息 从第一项开始加载 第0项为描述文件
        nowChapterIndex = 1;
        nowPageIndex = 1;
        
        epubDataModel = [[EPUBDateModel alloc]init];
        epubDataModel.epubDelegate = self;
        
        //标识epub主页面是否已经加载
        
        bookMarkIndex = -1;
       
        searchKey = nil;
        
        NSDictionary *dic = [epubDataModel getEpubSetting];
        int fontColor =[dic[@"kEpubBgColor"] intValue];
        NSString *webviewBGColor = [EPUBUtils webviewBgColor:fontColor];
        UIColor* bgColor =[EPUBUtils colorWithRGBHexString:webviewBGColor];
        flipType = [dic[@"kEPubFlipType"] intValue];
        self.view.backgroundColor = bgColor;
        

    }
    return self;
}

- (BOOL)shouldAutorotate
{
    if(pagenating)
        return NO;
    else
        return YES;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    epubMainView = [[EpubMainView alloc]initWithFrame:self.view.frame];
    self.view = epubMainView;
    epubMainView.epubMainViewDelegate = self;
    
    [self setViewBoundWithOrientation:self.interfaceOrientation];
    
    //初始化主滚动视图
    mainScrollView = [[EpubMainScrollView alloc]initWithFrame:CGRectMake(0, 0, webWidth, viewHeight) flipType:flipType];
    mainScrollView.epubController = self;
    mainScrollView.delegate = mainScrollView;
    mainScrollView.contentSize = CGSizeMake(viewWidth, viewHeight);
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.scrollsToTop = NO;
    if(flipType == EPUB_HOR_FLIP)
        mainScrollView.pagingEnabled = YES;
    else
        mainScrollView.pagingEnabled = NO;
    [self.view addSubview:mainScrollView];
    
    [epubMainView addEpubFunctionViews];
    
    float btnWidth;
    if(viewWidth > viewHeight && isPad)
    {
        btnWidth = viewWidth * 4 /100;
    }
    else
    {
        btnWidth = viewWidth *8 / 100;
    }
    
    
    NSDictionary *dic = [self getEpubSetting];
    int fontColor =[dic[@"kEpubBgColor"] intValue];
    NSString *webviewBGColor = [EPUBUtils webviewBgColor:fontColor];
    UIColor* bgColor =[EPUBUtils colorWithRGBHexString:webviewBGColor];
    mainScrollView.backgroundColor = [UIColor clearColor];
    [epubMainView setBgColor:bgColor];

    self.automaticallyAdjustsScrollViewInsets = NO;
    //回调进入epub方法
    [epubController epubExtractorDidFinishExtracting];
    

    [self setNeedsStatusBarAppearanceUpdate];
}
-(void)lastPage
{
    [mainScrollView turnToLastPage];
}
-(void)nextPage
{
    [mainScrollView turnToNextPage];
}



-(void)viewDidAppear:(BOOL)animated{
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return  [epubMainView getNaviBarState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    if(pagenating)
    {
        [epubDataModel stopPaging];
    }
 
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self removeChapterListView];
    [self releaseSearchPoper];
    [self setViewBoundWithOrientation:toInterfaceOrientation];
    
    [mainScrollView setFrame:CGRectMake(0, 0, webWidth, viewHeight)];
    [epubMainView setPrecessSliderFrame];
    if(pagenating)
    {
        
    }
    BOOL loadFlag = [self getInfoAndLoadPagePostion];
    if(!loadFlag)
    {
        
        [mainScrollView releaseAllWebView];
        [epubDataModel.pagenatingChapterArray removeAllObjects];
        [mainScrollView initWebview:nowChapterIndex pageIndex:nowPageIndex flipType:flipType mark:nil];
    }
    else
    {
        if(pagenating)
        {
            [self removeCountrelatedView];
            [epubDataModel cancelCountPage];
        }
        //tips查找书签是否有没有更新的内容
        //        if(flipType == EPUB_HOR_FLIP)
        //        {
        //这种情况容易混乱 暂时不用
        //            [mainScrollView resetLoadedWebview];
        [self turnTOChapter:nowChapterIndex page:nowPageIndex];
        //        }
        [epubDataModel updateNoteAndMarkChangedChapter];
        [self resetBookMark];
    }
    
    if(flipType == EPUB_HOR_FLIP)
    {
        float btnWidth;
        if(viewWidth > viewHeight && isPad)
        {
            btnWidth = viewWidth * 4 /100;
        }
        else
        {
            btnWidth = viewWidth *8 / 100;
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self turnTOChapter:nowChapterIndex page:nowPageIndex];
    //        }
    [epubDataModel updateNoteAndMarkChangedChapter];
    [self resetBookMark];
}

-(void)setViewBoundWithOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    float longSideLength;
    float shortSideLength;
    if(self.view.frame.size.height > self.view.frame.size.width)
    {
        longSideLength = self.view.frame.size.height;
        shortSideLength = self.view.frame.size.width;
    }
    else
    {
        longSideLength = self.view.frame.size.width;
        shortSideLength = self.view.frame.size.height;
    }
    
    if(toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        self.view.frame = CGRectMake(0, 0, shortSideLength, longSideLength);
        
    }
    else
    {
        self.view.frame = CGRectMake(0, 0, longSideLength, shortSideLength);
        
    }
    viewHeight = self.view.frame.size.height;
    viewWidth  = self.view.frame.size.width;
    
    if(flipType == EPUB_HOR_FLIP)
    {
        if(((int)(viewWidth)) % 2 != 0)
        {
            webWidth = viewWidth-1;
        }
        else
        {
            webWidth = viewWidth;
        }
        webHeight = viewHeight-WEBVIEW_TOP_BOTTOM_MARGIN*2;
    }
    else
    {
        webWidth = viewWidth;
        webHeight = viewHeight;
    }
    
}

#pragma mark -
#pragma mark -----------------DELEGATE METHOD-------------------
#pragma mark HYEpubControllerDelegate

//书架上点书本的回调方法
- (void)epubController:(HYEpubController *)controller didOpenEpub:(HYEpubContentModel *)contentModelt
{
    epubDataModel.chapterArray = [epubController getBookChapterFileArray];
    epubDataModel.listArray = [epubController getChapterListArrayWithChapterArray:epubDataModel.chapterArray];
    contentModel  = contentModelt;
    
    BOOL loadFlag = [self getInfoAndLoadPagePostion];
//    loadFlag = NO;
    if(!loadFlag)
    {
//        [self getAllBookMarkWithPagedState:NO];
        [mainScrollView initWebview:nowChapterIndex pageIndex:nowPageIndex flipType:flipType mark:nil];
    }
    else
    {
        NSArray *chapterAndPageArray = [self getReadingInfo];
        nowPageIndex = ((NSNumber *)[chapterAndPageArray objectAtIndex:1]).integerValue;
        nowChapterIndex = ((NSNumber *)[chapterAndPageArray objectAtIndex:0]).integerValue;
        [epubDataModel  setUserInfoPageNum:10000*((float)[self getGlobalPageCount]/(float)totalPageCount)];
        [self turnTOChapter:nowChapterIndex page:nowPageIndex];
        [self getAllBookMarkWithPagedState:YES];
        //tips查找书签是否有没有更新的内容
        [self changeBookMarkState];
    }
    
    
    
    
}

- (void)epubController:(HYEpubController *)controller didFailWithError:(NSError *)error
{
    
}

#pragma mark listViewProtocol
//翻转到目标章节的目标页码
- (void)showPageWithChapter:(NSInteger)cindex page:(NSInteger)pIndex jsMark:(NSString *)mark
{
    EpubChapter *chapter = [epubDataModel.chapterArray objectAtIndexedSubscript:cindex];
    if(chapter.pageCount < pIndex)
    {
        pIndex = chapter.pageCount;
    }
    if(pIndex <=0)
    {
        pIndex = 1;
    }
    
    [self setNowChapterIndex:cindex pageIndex:pIndex];
    
    if(!pagenating)
    {
        //为了防止跳转不准确 暂时注释 已经存在的页面不重新加载的逻辑
        if(cindex >= mainScrollView.mainShowWebView.chapterIndex -1 && cindex <= mainScrollView.mainShowWebView.chapterIndex +1)
        {
            [mainScrollView formartWebViewContent:nowChapterIndex];
          
            if(mark)
                [mainScrollView setScrollToMark:mark];
            else
                [mainScrollView resetMainWebViewPostionWithOffset:[self getPerPageLength]*(nowPageIndex-1)];
            
            
            
        }
        else
        {
            [self turnTOChapter:cindex page:pIndex mark:mark];
            
        }
    }
    else
    {
        [epubDataModel.pagenatingChapterArray removeAllObjects];
        [mainScrollView releaseAllWebView];
        [mainScrollView initWebview:nowChapterIndex pageIndex:nowPageIndex flipType:flipType mark:mark];
    }
    
    
    
    [self removeChapterListView];
}
-(NSArray *)getBookMarkArray
{
    return epubDataModel.markArray;
}
-(NSArray *)getChapterListArray
{
    return epubDataModel.listArray;
}
-(void)showTotalPage:(NSInteger)pageNum
{
    [self turnToTotalPage:pageNum];
    [self removeChapterListView];
    [self changeBookMarkState];
}
#pragma mark EpubMainScrollViewProtocol
-(void)setNowChapterIndex:(NSInteger)tempChapterIndex pageIndex:(NSInteger)tempPageIndex
{
    if(tempPageIndex != nowPageIndex || tempChapterIndex != nowChapterIndex)
    {
        if(tempChapterIndex != 0 && tempPageIndex != 0)
        {
            nowChapterIndex = tempChapterIndex;
            nowPageIndex = tempPageIndex;
            if(!pagenating)
            {
                [self countNowPageAndSetSlider];
                [epubDataModel setUserInfoPageNum:10000*((float)[self getGlobalPageCount]/(float)totalPageCount)];
            }
            
            [self changeBookMarkState];
            [epubMainView setNavigateBarHidden:YES];
            
        }
        
    }
}
-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index
{
    [epubDataModel saveHighLightsWithDic:dictionary chapterIndex:index];
}
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index;
{
    return [epubDataModel getNoteStringWithChapterIndex:index];
}
-(NSDictionary *)getEpubSetting
{
    return [epubDataModel getEpubSetting];
}
-(UIColor *)getColorWithColorString:(NSString *)colorString
{
    return [mainScrollView getColorWithColorString:colorString];
}
-(EpubChapter *)getChapterWithIndex:(NSInteger)chapterIndex
{
    return [epubDataModel getChapterWithIndex:chapterIndex];
}
//显示隐藏导航栏
-(void)changeNavigationBarVisible
{
    [self setNavigationBarHiddenState:![epubMainView getNaviBarState]];
    
}
-(BOOL)getPaginateState;
{
    return pagenating;
}
-(void)showLoadHud
{
    [epubMainView showLoadHud];
}
-(void)showSearchHud
{
    [epubMainView showSearchHud];
}

-(NSInteger)getChapterCount
{
    return epubDataModel.chapterArray.count;
}

-(void)enCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex
{
    [epubDataModel enCodeHtmlFileWithChapterIndex:chapterIndex];
}


-(void)deCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex
{
    [epubDataModel deCodeHtmlFileWithChapterIndex:chapterIndex];
}

#pragma mark JSBridgeWebViewDelegate
- (void)webView:(UIWebView*) webview didReceiveJSNotificationWithDictionary:(NSDictionary*) dictionary
{
    
}

#pragma mark EpubCoverDelegate
//移除章节列表
-(void)removeChapterListView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5];
    
    
    if(chapterList)
    {
        [chapterList.view setFrame:CGRectMake(-viewWidth*2, 0, viewWidth, self.view.frame.size.height)];
    }
    
    [self setViewX:0 view:mainScrollView];
    
    [UIView commitAnimations];
    
}

#pragma mark EPUBWebviewProtocal
//传递点击位置的坐标



-(void)webviewFinishLoad:(EpubWebView *)webview
{
    
}
-(void)loadPageWithFileName:(NSString *)fileNameCom
{
    NSArray *fileArray = [fileNameCom componentsSeparatedByString:@"#"];
    NSString *fileName = nil;
    NSString *jsMark = nil;
    if(fileArray.count == 2)
    {
        jsMark = [fileArray objectAtIndex:1];
        fileName = [fileArray objectAtIndex:0];
    }
    else
    {
        fileName = fileNameCom;
    }
    
    
    NSInteger chapterIndex = [epubDataModel getChapterIndexWithFileName:fileName];
    
    
    if(chapterIndex>0)
    {
        [self showPageWithChapter:chapterIndex page:1 jsMark:jsMark];
    }
}

-(void)showNoteRefWithDic:(NSDictionary *)dic webView:(EpubWebView*)webview
{
    NSString *content = [dic objectForKey:@"html"];
    NSInteger top = ((NSNumber*)[dic objectForKey:@"top"]).integerValue;
    NSInteger left = ((NSNumber*)[dic objectForKey:@"left"]).integerValue;
    NSInteger width = ((NSNumber*)[dic objectForKey:@"width"]).integerValue;
    NSInteger height = ((NSNumber*)[dic objectForKey:@"height"]).integerValue;
    ENoteRefViewController *noteRefViewController = [[ENoteRefViewController alloc]initWithHtmlString:content];
    /*应国开要求,iPhone 和 iPad 均采用 popView 模式
     *时间:2018.1.11
     *修订人:郝瑞文
     */
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:noteRefViewController];
    popoverController.delegate = self;
    [popoverController presentPopoverFromRect:CGRectMake(left, top, width, height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
}
-(void)showPicWithDic:(NSDictionary *)dic webView:(EpubWebView *)webview
{
    NSString *filePathCom = [dic objectForKey:@"src"];
    NSURL *pathPre = [webview.request.URL URLByDeletingLastPathComponent];
    if(filePathCom)
    {
        while ([[filePathCom substringToIndex:2] isEqualToString: @".."]) {
            filePathCom = [filePathCom substringFromIndex:3];
            pathPre = [pathPre URLByDeletingLastPathComponent];
        }
    }
    else
    {
        return;
    }
    NSURL *imageUrl = [pathPre URLByAppendingPathComponent:filePathCom];
    
    NSString *pathString = [[imageUrl path]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSInteger top = ((NSNumber*)[dic objectForKey:@"top"]).integerValue;
    NSInteger left = ((NSNumber*)[dic objectForKey:@"left"]).integerValue;
    NSInteger width = ((NSNumber*)[dic objectForKey:@"width"]).integerValue;
    NSInteger height = ((NSNumber*)[dic objectForKey:@"height"]).integerValue;
    
    NSData *imageData = [NSData dataWithContentsOfFile:pathString];
    UIImage *image = [UIImage imageWithData:imageData];
    
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, width, height)];
    iv.image = image;
    [self.view addSubview:iv];
    
    PaperImageBrowserController *vc = [[PaperImageBrowserController alloc] initWithPlaceImageView:iv];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:false completion:^{
        [vc showWithAnimation];
    }];
    

    
    return;

    
    /*
    旧代码 - 图片查看
    EImageView *picView = [[EImageView alloc]init];
    picView.imageView.image = image;
    [self.view addSubview:picView];
    
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(picView);
    NSDictionary *metrics = @{@"left":@(left),@"top":@(top),@"width":@(width),@"height":@(height)};
    picView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray* fullScreenContstraints = [NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|[picView]|"
                                       options:0
                                       metrics:nil
                                       views:viewsDictionary];
    fullScreenContstraints = [fullScreenContstraints arrayByAddingObjectsFromArray:
                              [NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[picView]|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    
    NSArray *defaultScreenContstraints = [NSLayoutConstraint
                                          constraintsWithVisualFormat:@"H:|-left-[picView(width)]"
                                          options:0
                                          metrics:metrics
                                          views:viewsDictionary];
    defaultScreenContstraints = [defaultScreenContstraints arrayByAddingObjectsFromArray:
                                 [NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:|-top-[picView(height)]"
                                  options:0
                                  metrics:metrics
                                  views:viewsDictionary]];
    [self.view addConstraints:defaultScreenContstraints];
    [picView layoutIfNeeded];
    
    
    picView.exitBlock = ^{
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationCurveEaseIn
                         animations:^{
                             picView.backgroundColor = [UIColor clearColor];
                             [self.view removeConstraints:fullScreenContstraints];
                             picView.translatesAutoresizingMaskIntoConstraints = NO;
                             [picView reloadConstraints];
                             [self.view addConstraints:defaultScreenContstraints];
                             [self.view layoutIfNeeded];
                         }
         
                         completion:^(BOOL finished){
                             if (finished){
                                 [picView removeFromSuperview];
                             }
                             
                         }];
    };
    
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationCurveEaseIn
                     animations:^{
                         picView.backgroundColor = [UIColor blackColor];
                         [self.view removeConstraints:defaultScreenContstraints];
                         picView.translatesAutoresizingMaskIntoConstraints = NO;
                         [picView reloadConstraints];
                         [self.view addConstraints:fullScreenContstraints];
                         [self.view layoutIfNeeded];
                     }
     
                     completion:^(BOOL finished){
                         if (finished){
                             
                         }
                         
                     }
     ];
     */
}
-(NSMutableArray *)getPagenatingChapterArray
{
    return epubDataModel.pagenatingChapterArray;
}
#pragma mark PositonDataHandleProtocal
-(CGSize)addSizeWithSize:(CGSize)size margin:(float)margin
{
    return [mainScrollView addSizeWithSize:size margin:margin];
}
-(CGPoint)addPointWithPoint:(CGPoint)point margin:(float)margin
{
    return [mainScrollView addPointWithPoint:point margin:margin];
}
-(CGRect)addFrameWithPoint:(CGRect)rect margin:(float)margin
{
    return [mainScrollView addFrameWithPoint:rect margin:margin];
}
-(CGSize)setSizeWithlength:(float)length
{
    return [mainScrollView setSizeWithlength:length];
}
-(CGPoint)setPointWithOrigin:(float)origin
{
    return [mainScrollView setPointWithOrigin:origin];
}
-(CGRect)setFrameWithOrigin:(float)origin
{
    return [mainScrollView setFrameWithOrigin:origin];
}
-(float)getLengthWithPoint:(CGPoint)point
{
    return [mainScrollView getLengthWithPoint:point];
}
-(float)getLengthWithFrame:(CGRect)rect
{
    return [mainScrollView getLengthWithFrame:rect];
}
-(float)getLengthWithSize:(CGSize)size
{
    return [mainScrollView getLengthWithSize:size];
}
-(float)getPerPageLength
{
    return [mainScrollView getPerPageLength];
}
#pragma mark EpubOptionViewDelegate
//更新主界面的字体大小
-(void)updateEpubFontSize:(float)fSize
{
    [epubDataModel.pagenatingChapterArray removeAllObjects];
    [mainScrollView releaseAllWebView];
    [mainScrollView initWebview:nowChapterIndex pageIndex:nowPageIndex flipType:flipType mark:nil];
    [self deleteOtherOrientationInfo];
    [self showLoadHud];
    //    [mainScrollView reloadLoadedWebView];
    //    [self deleteOtherOrientationInfo];
    
}



//更新背景颜色
-(void)setChangeBackMode:(EPUP_BG_COLOR)mode
{
    NSString *color = [self cssBgColor:mode];
    NSString *webviewBGColor = [EPUBUtils webviewBgColor:mode];
    UIColor *curColor =[EPUBUtils colorWithRGBHexString:webviewBGColor];
    
    NSString *jsString = [NSString stringWithFormat:@"setBgColor('%@');",color];
    [mainScrollView allWebViewLoadJsString:jsString];
    [epubMainView setBgColor:curColor];
    mainScrollView.backgroundColor = curColor;

}
-(void)setMarginMode:(EPUB_MARGIN)mode
{
    [epubDataModel.pagenatingChapterArray removeAllObjects];
    [mainScrollView releaseAllWebView];
    [mainScrollView initWebview:nowChapterIndex pageIndex:nowPageIndex flipType:flipType mark:nil];
    [self deleteOtherOrientationInfo];
    [self showLoadHud];
}
-(void)updateEpubFlipType:(int)tflipType
{
    NSInteger aimPageIndex = nowPageIndex;
    mainScrollView.flipType = tflipType;
    flipType = tflipType;
    [self releaseSearchPoper];
    [self resetWebHeightAndWidth];
    BOOL loadFlag = [self getInfoAndLoadPagePostion];
    
    if (!loadFlag) {
        
        [mainScrollView releaseAllWebView];
        [epubDataModel.pagenatingChapterArray removeAllObjects];
        [mainScrollView initWebview:nowChapterIndex pageIndex:aimPageIndex flipType:flipType mark:nil];
    }
    else
    {
        if(pagenating)
        {
            [self removeCountrelatedView];
            [epubDataModel cancelCountPage];
        }
        //        [mainScrollView resetLoadedWebview];
        [self turnTOChapter:nowChapterIndex page:aimPageIndex];
        [epubDataModel updateNoteAndMarkChangedChapter];
        [self resetBookMark];
    }
    [epubMainView setPrecessSliderFrame];
    
}



#pragma mark  EpubChapterProtocol



#pragma mark PopoverViewDelegate


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    epubDataModel.isSearch = NO;
    //    if(epubSearchController)
    //    {
    
    //        epubSearchController = nil;
    //    }
    if(searchpoper)
    {
        
        searchpoper = nil;
    }
    if(notePoper)
    {
        
        notePoper = nil;
    }
    if(notePoperViewController)
    {
        [notePoperViewController sendSaveMethod];
        
        notePoperViewController = nil;
    }
}
#pragma mark HYEpubControllerDelegate
-(void)backToBookshelf
{
    [self saveReadingInfo];
    if(chapterList)
    {
        [chapterList.view removeFromSuperview];
        
        chapterList = nil;
    }
    if (self.exitEpubBlock) {
        self.exitEpubBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark EpubMainViewProtocol
-(BOOL)getEpubFlipType
{
    return flipType;
}
-(BOOL)getEpubLoadedState
{
    return mainScrollView.epubLoaded;
}

#pragma mark  EpubDataModelProtocal
-(float)getViewwidth
{
    return webWidth;
}
-(float)getViewHeight
{
    return webHeight;
}
-(NSInteger)getToltalPageCount
{
    return totalPageCount;
}
-(BOOL)canNotContinueUpdate
{
    return mainScrollView.scrolling;
}
//完成计算页码
-(void)finishUpdateChapterArray
{
    if(pagenating)
    {
        [self removeCountrelatedView];
        //计算完成以后保存章节信息
        [epubDataModel savePageingInfo];
        NSLog(@"Pagination Ended!");
    }
    
    [self setViewPositionAndPageCount];
    
}
-(void)removeCountrelatedView
{
    pagenating = NO;
    [epubMainView removeProcessView];
    [epubDataModel.pagenatingChapterArray removeAllObjects];
}
-(void)setViewPositionAndPageCount
{
    [self generateChapterPositon];
    [mainScrollView setContentSize:[self setSizeWithlength:[self getPerPageLength]*totalPageCount]];
    [self setNowLoadViewPosi];
    [self countNowPageAndSetSlider];
    [epubDataModel setUserInfoPageNum:10000*((float)[self getGlobalPageCount]/(float)totalPageCount)];
    //书签列表更新
    [self getAllBookMarkWithPagedState:YES];
    [self setNavigationBarHiddenState:NO];
}
-(void)showResultAlert
{
    epubMainView.showHub = NO;
    if(epubSearchController.resultsArray.count == 0 && searchpoper)
    {
        [searchpoper dismissPopoverAnimated:YES];
        // If no occurences of string, show alert message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无结果!"
                                                        message:[NSString stringWithFormat:@"没有搜索到对应的数据"]
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
        if(epubSearchController)
        {
            
            epubSearchController = nil;
        }
        
    }
}
-(BOOL)addResultsObject:(NSArray*)array key:(NSString *)sKey
{
    epubMainView.showHub = NO;
    BOOL result =[epubSearchController addResultsObject:array key:sKey];
    return result;
}

#pragma mark -
#pragma mark -----------------BAR BTN CLICK METHOD-------------------


-(void)setSearchPoperSize:(CGSize)size
{
    //    [searchpoper setPopoverContentSize:size animated:YES];
}
-(void)showSearchWithTotalPage:(NSInteger)pageNum key:(NSString *)key position:(CGPoint)positon;
{
    searchKey = [key mutableCopy];
    searchPosi = positon;
    //    if(epubSearchController)
    //    {
    
    //        epubSearchController = nil;
    //    }
    if(searchpoper)
    {
        [searchpoper dismissPopoverAnimated:NO];
        
        searchpoper = nil;
    }
    else
    {
        [epubSearchController dismissViewControllerAnimated:NO completion:nil];
    }
    [self turnToTotalPage:pageNum];
    [self changeBookMarkState];
}

-(void)showChapterListView
{
    if(pagenating){
        return;
    }
    NSInteger leftMargin = 0;
    leftMargin = viewWidth;
    if(!chapterList)
    {
        chapterList = [[EPUBChapterListViewController alloc]init];
        chapterList.delegate = self;
        chapterList.chaperArray = epubDataModel.listArray;
        chapterList.view.backgroundColor = self.view.backgroundColor;
        [chapterList.view setFrame:CGRectMake(-leftMargin, 0, leftMargin, self.view.frame.size.height)];
        [chapterList setAllSubView];
    }
    else
    {
        [chapterList.view setFrame:CGRectMake(-leftMargin, 0, leftMargin, self.view.frame.size.height)];
        [chapterList resetContent];
    }
    
    [self.view addSubview:chapterList.view];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5];
    
    [chapterList.view setFrame:CGRectMake(0, 0, leftMargin, self.view.frame.size.height)];
    
    [self setViewX:leftMargin view:mainScrollView];
    
    
    [UIView commitAnimations];
}

-(void)setViewX:(float)originX view:(UIView *)tempview
{
    [tempview setFrame:CGRectMake(originX, tempview.frame.origin.y, tempview.frame.size.width, tempview.frame.size.height)];
}


-(void)showSerchTextView
{
    if(pagenating){
        return;
    }
    if(searchpoper)
    {
        [searchpoper dismissPopoverAnimated:YES];
    }
    
    if (!epubSearchController) {
        epubSearchController  = [[EpubSearchViewController alloc]init];
        epubSearchController.epubControlerDelegate = epubDataModel;
    }
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:epubSearchController];
    if (isPad) {
        searchpoper = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        searchpoper.delegate = self;
        [searchpoper presentPopoverFromRect:[epubMainView.navigateBar.searchButton frame] inView:epubMainView.navigateBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [epubSearchController resetPreferredSize];
        
    }
    else {
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    
}
-(void)fontChangeClickMethod
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       dispatch_async(dispatch_get_main_queue(), ^{
           [epubMainView showOptionView];
       });
    });
    
}

#pragma mark -
#pragma mark -----------------NAVAGATION RES METHOD-------------------



-(void)setNavigationBarHiddenState:(BOOL)hidden
{
    if(!pagenating)
    {
        [epubMainView setNavigateBarHidden:hidden];
    }
    else
    {
        [epubMainView setNavigateBarHidden:YES];
    }
    epubMainView.navigateBar.hidden = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}
//隐藏导航栏
-(void)hideNavigateBar
{
    [self setNavigationBarHiddenState:YES];
}
-(BOOL)getNavBarHideState
{
    return epubMainView.navigateBar.hidden;
}








#pragma mark -
#pragma mark ----------------EPUB BUSI RES METHOD-------------------
//更新页码
- (void) updatePagination{
    
    if(mainScrollView.epubLoaded){
        [self releaseSearchPoper];
        
        pagenating = YES;
        [self setNavigationBarHiddenState:epubMainView.navigateBar.hidden];
        totalPageCount=0;
        
        [epubDataModel updateChapterArray];
        [epubMainView.pageNumLable setText:@""];
        [epubMainView.bottomPageNumLable setText:@""];

        
        NSLog(@"Pagination Started!");
    }
}
-(void)releaseSearchPoper
{
    if(epubSearchController)
    {
        
        epubSearchController = nil;
    }
    if(searchpoper)
    {
        [searchpoper dismissPopoverAnimated:YES];
        
        searchpoper = nil;
    }
}
-(void)setPagenatingProcessView:(float)process
{
    [epubMainView setPagenatingProcessView:process];
}
-(void)updatePaginationTask
{
    
    while (pagenating) {
        sleep(0.5);
    }
}
//获得现在的页码数
- (NSInteger) getGlobalPageCount{
    return [epubDataModel getPageCountWithChapterIndex:nowChapterIndex pageindex:nowPageIndex];
}

-(IBAction)updateEpubprocess:(id)sender
{
    [epubMainView releaseTitleView];
    UISlider *slider = (UISlider*)sender;
    [self turnToProcess:slider.value];
    
}
-(IBAction)epubProcessSliderChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;

    [epubMainView showTitleView];
    
    NSInteger pageNum = [EPUBUtils changeFloatPagenumToInt:(float)totalPageCount*(slider.value/(float)10000)];
    
    
    NSString *title = [self getTilteWithPageNum:pageNum];
    epubMainView.chapterLable.text = [NSString stringWithFormat:@"%@",title];
    epubMainView.topChapterTitleLable.text = [NSString stringWithFormat:@"%@",title];
    epubMainView.pageLable.text = [NSString stringWithFormat:@"%ld页",(long)pageNum];
    
    
    
    
    
}
-(NSString *)getTilteWithPageNum:(NSInteger)pnum{
    NSArray *chapterAndPageArray = [epubDataModel getChapterIndexAndPageindexWithPageNum:pnum];
    NSInteger chapterIndex = ((NSNumber *)[chapterAndPageArray objectAtIndex:0]).integerValue;
    
    if(chapterIndex<=0)
    {
        chapterIndex = 1;
    }
    
    NSString *title = [epubDataModel getTitleWithChapterIndex:chapterIndex];
    if(!title)
    {
        title = @"";
    }
    return title;
}

//设置当前已经加载的网页的offset和contentsize 并滚动到相应位置
-(void)setNowLoadViewPosi
{
    //    EpubChapter *chapter = [chapterArray objectAtIndex:nowChapterIndex];
    
    //    //如果不是第一次加在 那么重新计算当前的页码 根据百分比算出本章节现在的页码
    //    if(nowPageProcess!=0)
    //    {
    //        nowPageIndex = [self changeFloatPagenumToInt:(float)chapter.pageCount * nowPageProcess];
    //    }
    //    if(nowPageIndex <= 0)
    //    {
    //        nowPageIndex = 1;
    //    }
    [mainScrollView formartWebViewContent:nowChapterIndex];
    [mainScrollView refreshLoadedWebView];
    [mainScrollView resetMainWebViewPostion];
    
}
-(void)countNowPageAndSetSlider
{
    [epubMainView.pageNumLable setText:[NSString stringWithFormat:@"%ld/%ld",(long)[self getGlobalPageCount], (long)totalPageCount]];
    [epubMainView.bottomPageNumLable setText:[NSString stringWithFormat:@"%ld/%ld",(long)[self getGlobalPageCount], (long)totalPageCount]];
    [epubMainView.prePageNumLable setText:[NSString stringWithFormat:@"本章已阅读%ld页",(long)nowPageIndex]];
    [epubMainView.leftPageNumLable setText:[NSString stringWithFormat:@"本章还剩%ld页",(long)((EpubChapter*)[epubDataModel.chapterArray objectAtIndex:nowChapterIndex]).pageCount-nowPageIndex]];
    NSString *title = [self getTilteWithPageNum:[self getGlobalPageCount]];
    epubMainView.topChapterTitleLable.text = [NSString stringWithFormat:@"%@",title];
    
    [epubMainView.epubSlier setValue:(float)10000*(float)[self getGlobalPageCount]/(float)totalPageCount animated:YES];
}
//计算每个chapter的起始位置和size
-(void)generateChapterPositon
{
    totalPageCount = [epubDataModel generateChapterPositonAndGetTotolCount];
}
-(void)setWebViewPosiWithWebView:(EpubWebView *)webView
{
    EpubChapter *chapter = [epubDataModel.chapterArray objectAtIndex:webView.chapterIndex];
    webView.chapterOffset = chapter.offset;
    webView.chapterSize = chapter.contentSize;
    webView.pageCount = chapter.pageCount;
}



-(void)poperNoteWithNoteObject:(EpubNoteListObject *)noteObject webView:(EpubWebView *)webView;
{
    if (!notePoperViewController) {
        notePoperViewController  = [[EpubNotePoperViewController alloc]init];
        [notePoperViewController setNoteWithNoteObject:noteObject];
        __block EpubWebView *view = webView;
        notePoperViewController.saveNoteString = ^(NSString *str){
            [view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setNoteToCurrentHL(%@)",str]];
        };
        
    }
    if(isPad)
    {
        if(notePoper)
        {
            [notePoper dismissPopoverAnimated:YES];
        }
        notePoper = [[UIPopoverController alloc] initWithContentViewController:notePoperViewController];
        notePoper.delegate = self;
        notePoper.backgroundColor = noteObject.noteColor;
        [notePoper setPopoverContentSize:CGSizeMake(280,200)];
        [notePoper presentPopoverFromRect:CGRectMake(noteObject.postion.x, noteObject.postion.y, noteObject.noteSize.width,noteObject.noteSize.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:notePoperViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
        
        
        __block UINavigationController *controller  = navigationController;
        notePoperViewController.exitBlock = ^{
            [controller dismissViewControllerAnimated:YES completion:nil];
            notePoperViewController = nil;
        };
        
    }
}
-(void)resetWebHeightAndWidth
{
    if(flipType == EPUB_HOR_FLIP)
    {
        webHeight = viewHeight - WEBVIEW_TOP_BOTTOM_MARGIN*2;
        mainScrollView.viewHeight = webHeight;
        mainScrollView.pagingEnabled = YES;
        if(((int)viewWidth) %2 != 0)
        {
            webWidth = viewWidth-1;
            mainScrollView.viewWidth = webWidth;
        }
        else
        {
            webWidth = viewWidth;
            mainScrollView.viewWidth = webWidth;
        }
    }
    else
    {
        webHeight = viewHeight;
        mainScrollView.viewHeight = webHeight;
        mainScrollView.pagingEnabled = NO;
        webWidth = viewWidth;
        mainScrollView.viewWidth = webWidth;
    }
    
    [mainScrollView setFrame:CGRectMake(0, 0, webWidth, viewHeight)];
}


#pragma mark -
#pragma mark ----------------MODEL SAVE LOAD RES METHOD-------------------
//退出时保存阅读的详细信息 字体 背景 页码
-(void)saveReadingInfo{
    EpubChapter *nowChapter = [epubDataModel.chapterArray objectAtIndex:nowChapterIndex];
    
    
    [epubDataModel saveReadingInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:nowChapterIndex],@"chapter",[NSNumber numberWithFloat:((float)nowPageIndex)/((float)nowChapter.pageCount)],@"page",[NSNumber numberWithFloat:(float)100*(float)[self getGlobalPageCount]/(float)totalPageCount],@"readprocess", nil]];
}

-(void)deleteOtherOrientationInfo
{
    [epubDataModel deleteOtherOrientationInfo];
}
-(NSArray *)getReadingInfo
{
    return [epubDataModel getReadingInfo];
}

-(BOOL)getInfoAndLoadPagePostion
{
    return [epubDataModel getPageInfoAndLoadPagePosition];
}

-(NSArray *)getNoteListArray
{
    return [epubDataModel getNoteListArray];
}
//得到目前的章节index
-(NSInteger)getNowChapterIndex{
    return nowChapterIndex;
}


#pragma mark -
#pragma mark ----------------BOOK MARK RES METHOD-------------------
-(void)changeBookMarkState
{
    for (NSInteger i = 0; i < epubDataModel.markArray.count; i++) {
        EpubMarkObject *markObject = [epubDataModel.markArray objectAtIndex:i];
        if(markObject.chapterIndex == nowChapterIndex && markObject.pageNum == nowPageIndex)
        {
            bookMarkIndex = i;
            [epubMainView.navigateBar.bookMarkButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_bookmark_add"] forState:UIControlStateNormal];
            return;
        }
    }
    
    bookMarkIndex = -1;
    
    [epubMainView.navigateBar.bookMarkButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_bookmark"] forState:UIControlStateNormal];
}

-(NSString *)getFlipTypeAndOren
{
    if(viewWidth > viewHeight)
    {
        
        if(flipType == EPUB_NOR_FLIP)
        {
            return LANDSCAPE_NORFLIP;
        }
        if(flipType == EPUB_HOR_FLIP)
        {
            return LANDSCAPE_HORFLIP;
        }
    }
    else
    {
        if(flipType == EPUB_NOR_FLIP)
        {
            return PORTRAIT_NORFLIP;
        }
        if(flipType == EPUB_HOR_FLIP)
        {
            return PORTRAIT_HORFLIP;
        }
    }
    return ORI_UNKNOW;
}

-(BOOL)updateNoteWithWebView:(EpubWebView *)webView
{
    return [epubDataModel updateNoteWithWebView:webView];
}
-(UIView *)getMainView
{
    return self.view;
}

//高亮 非高亮书签按钮点击触发的方法
-(void)changeBookMarkBtnState:(id)sender
{
    if(pagenating){
        return;
    }
    //把书签变为选中或者非选中状态
    
    if(bookMarkIndex == -1)
    {
        //        float saveoffset = 0;
        //        EpubChapter *chapter = [epubDataModel.chapterArray objectAtIndex:nowChapterIndex];
        //        saveoffset = nowPageIndex/chapter.pageCount;
        [epubMainView.navigateBar.bookMarkButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_bookmark_add"] forState:UIControlStateNormal];
        EpubMarkObject* bookmark =  [mainScrollView addBookMarkWithChapterIndex:nowChapterIndex];
        if(bookmark)
        {
            [epubDataModel saveBookMarkWithMarkObject:bookmark];
            
            bookMarkIndex = epubDataModel.markArray.count-1;
        }
        
    }
    else
    {
        EpubMarkObject *markObject = [epubDataModel.markArray objectAtIndex:bookMarkIndex];
        [epubMainView.navigateBar.bookMarkButton setImage:[UIImage loadImageClass:[self class] ImageName:@"kernel_bookmark"] forState:UIControlStateNormal];
        [epubDataModel deleteBookMarkWithID:markObject.markId];
        
        [epubDataModel.markArray removeObjectAtIndex:bookMarkIndex];
        bookMarkIndex = -1;
    }
}

-(void)resetBookMark
{
    NSArray *array = epubDataModel.markArray;
    for(int i = 0; i < array.count;i++)
    {
        EpubMarkObject *markObject = [array objectAtIndex:i];
        NSNumber *pageNumNumber = [markObject.pageNumDic objectForKey:[self getFlipTypeAndOren]];
        if(pageNumNumber)
        {
            markObject.pageNum = pageNumNumber.integerValue;
        }
    }
}

-(void)getAllBookMarkWithPagedState:(BOOL)pagedState
{
    //暂时
    [epubDataModel getAllBookMarkWithPagedState:pagedState];
}
#pragma mark -
#pragma mark ----------------WEBVIEW INIT OR LOAD RES METHOD-------------------

#pragma mark ----------------INIT METHOD-------------------

-(void)initHorFlipview
{
    
}

#pragma mark ----------------LOAD METHOD-------------------
//预加载下一章


-(void)turnToProcess:(float)precess
{
    [self turnToTotalPage:[EPUBUtils changeFloatPagenumToInt:(float)totalPageCount*(precess/(float)10000)]];
}
-(void)turnToTotalPage:(NSInteger)pageNum
{
    NSArray *chapterAndPageArray = [epubDataModel getChapterIndexAndPageindexWithPageNum:pageNum];
    NSInteger chapterIndex = ((NSNumber *)[chapterAndPageArray objectAtIndex:0]).integerValue;
    NSInteger pageIndex = ((NSNumber *)[chapterAndPageArray objectAtIndex:1]).integerValue;
    
    
    EpubChapter *chapter = [epubDataModel.chapterArray objectAtIndexedSubscript:chapterIndex];
    if(chapter.pageCount < pageIndex)
    {
        pageIndex = chapter.pageCount;
    }
    if(pageIndex <=0)
    {
        pageIndex = 1;
    }
    
    if(chapterIndex >= mainScrollView.mainShowWebView.chapterIndex -1 && chapterIndex <= mainScrollView.mainShowWebView.chapterIndex +1)
    {
        nowChapterIndex = chapterIndex;
        nowPageIndex = pageIndex;
        [mainScrollView formartWebViewContent:nowChapterIndex];
        
        [mainScrollView resetMainWebViewPostionWithOffset:[self getPerPageLength]*(pageIndex-1)];
        if(searchKey)
        {
            [mainScrollView showSearchResultWithkey:searchKey position:searchPosi];
            
            searchKey = nil;
        }
        [self countNowPageAndSetSlider];
    }
    else
    {
        [self turnTOChapter:chapterIndex page:pageIndex];
        if(searchKey)
        {
            [mainScrollView willShowSearchResultWithkey:searchKey position:searchPosi];
            
            searchKey = nil;
        }
    }
    
}
-(void)turnTOChapter:(NSInteger)ChapterIndex page:(NSInteger)pageIndex mark:(NSString *)mark
{
    [mainScrollView turnTOChapter:ChapterIndex page:pageIndex mark:mark];
    if(!pagenating)
        [self countNowPageAndSetSlider];
    [self showLoadHud];
}
-(void)turnTOChapter:(NSInteger)ChapterIndex page:(NSInteger)pageIndex
{
    nowChapterIndex = ChapterIndex;
    nowPageIndex = pageIndex;
    [mainScrollView turnTOChapter:ChapterIndex page:pageIndex mark:nil];
    [self countNowPageAndSetSlider];
    [self showLoadHud];
}

#pragma mark -
#pragma mark ----------------OTHER FUN METHOD-------------------





-(NSString *)cssBgColor:(EPUP_BG_COLOR)mode{
    NSString *color = @"black";
    switch (mode) {
        case epub_white:
            color = @"white";
            break;
        case epub_lightgray:
            color = @"lightgray";
            break;
        case epub_black:
            color = @"black";
            break;
        case epub_gray:
            color = @"gray";
            break;
        case epub_orange:
            color = @"orange";
            break;
        case epub_blue:
            color = @"blue";
            break;
        case epub_green:
            color = @"green";
            break;
        case epub_brown:
            color = @"brown";
            break;
        default:
            break;
    }
    return color;
}



@end
