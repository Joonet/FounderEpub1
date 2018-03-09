//
//  EpubWebView.m
//  E-Publishing
//
//  Created by miaopu on 14-8-22.
//
//

#import "EpubMainScrollView.h"
#import "EpubStaticDefine.h"
#import "EpubWebView.h"
#import "EpubChapter.h"
#import "JSON.h"
#import "EpubNoteListObject.h"
#import "EpubMarkObject.h"

@implementation EpubMainScrollView
@synthesize isEnable;
@synthesize epubController;
@synthesize flipType;
@synthesize epubLoaded;
@synthesize mainShowWebView;
@synthesize preLoadNextWebView;
@synthesize preLoadPreWebView;
@synthesize scrolling;
@synthesize viewWidth;
@synthesize viewHeight;

#pragma mark -
#pragma mark ----------------system method-------------------

- (id)initWithFrame:(CGRect)frame flipType:(int)tFlipType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        flipType = tFlipType;
        
        //初始化一些相关的变量
        viewWidth = frame.size.width;
        if(flipType == EPUB_HOR_FLIP)
        {
            viewHeight = frame.size.height-WEBVIEW_TOP_BOTTOM_MARGIN*2;
        }
        else
        {
            viewHeight = frame.size.height;
        }
        
        
        mainShowWebView = nil;
        preLoadPreWebView = nil;
        preLoadNextWebView = nil;
        epubLoaded = NO;
        searchKey = nil;
        scrolling = NO;
        canSetScrollView = YES;
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    viewWidth = frame.size.width;
    
    if(flipType == EPUB_HOR_FLIP)
    {
        viewHeight = frame.size.height-WEBVIEW_TOP_BOTTOM_MARGIN*2;
    }
    else
    {
        viewHeight = frame.size.height;
    }
    [super setFrame:frame];
}


//如果点中的web
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    if([self getLengthWithPoint:mainShowWebView.frame.origin] < [self getLengthWithPoint:point] && [self getLengthWithPoint:mainShowWebView.frame.origin]+[self getLengthWithSize:mainShowWebView.scrollView.contentSize]> [self getLengthWithPoint:point])
    {
        [self bringSubviewToFront:mainShowWebView];
    }
    else if([self getLengthWithPoint:preLoadNextWebView.frame.origin] < [self getLengthWithPoint:point])
    {
        [self bringSubviewToFront:preLoadNextWebView];
    }
    else
    {
        [self bringSubviewToFront:preLoadPreWebView];
    }
    return YES;
}


#pragma mark  ------ scrollViewDelegate-----
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    if (epubLoaded&&canSetScrollView) {
        float offsetLength = [self getLengthWithPoint:offset];
        
        downFlip = YES;
        if([self getLengthWithPoint:lastOffset] > offsetLength)
        {
            downFlip = NO;
        }
        else
        {
            downFlip = YES;
        }
        
        
        NSInteger tempChapterIndex =1;
        NSInteger tempPageIndex = 1;
        
        float perPageLength = [self getPerPageLength];
        
        float mainOffsetLength = [self getLengthWithPoint:mainShowWebView.chapterOffset];
        float preOffsetLength = [self getLengthWithPoint:preLoadPreWebView.chapterOffset];
        float nextOffsetLength = [self getLengthWithPoint:preLoadNextWebView.chapterOffset];
        
        float mainSizeLength = [self getLengthWithSize:mainShowWebView.chapterSize];
        float preSizeLength = [self getLengthWithSize:preLoadPreWebView.chapterSize];
        float nextSizeLength = [self getLengthWithSize:preLoadNextWebView.chapterSize];
//        NSLog(@"原始数据：主展示页面的开始位移%f总长度%f;前展示页面的开始位移%f总长度%f;后展示页面的开始位移%f总长度%f;",mainOffsetLength,mainSizeLength,preOffsetLength,preSizeLength,nextOffsetLength,nextSizeLength);
//        NSLog(@"目前总位移：%f",offsetLength);
        
        lastOffset = offset;
        //如果现在的位移处于mainShowWebView的页面中，不涉及其他webview 那么直接控制mainShowWebView 滚动即可
        if(offsetLength >= mainOffsetLength && offsetLength <= mainOffsetLength + mainSizeLength - perPageLength)
        {
            tempChapterIndex = mainShowWebView.chapterIndex;
            tempPageIndex = (offsetLength - mainOffsetLength)/perPageLength + 1;
            [mainShowWebView.scrollView setContentOffset:[self setPointWithOrigin:offsetLength-mainOffsetLength]];
            [mainShowWebView setFrame:[self setFrameWithOrigin:offsetLength]];
        }
        //如果现在的位移涉及preLoadNextWebView
        else if(offsetLength > mainOffsetLength + mainSizeLength - perPageLength)
        {
            //这里还涉及一种情况 如果这时候preLoadNextWebView 存在但是没有完成加载的情况
            if(preLoadNextWebView)
            {
                //现在页面上同时显示mainShowWebView 和 preLoadNextWebView
                if(offsetLength <= mainOffsetLength + mainSizeLength)
                {
                    //比较两个webview 哪个占的面积大 认为它是主View
                    if(mainOffsetLength + mainSizeLength- offsetLength > perPageLength/2)
                    {
                        tempChapterIndex = mainShowWebView.chapterIndex;
                        tempPageIndex = mainShowWebView.pageCount;
                    }
                    else
                    {
                        tempChapterIndex = preLoadNextWebView.chapterIndex;
                        tempPageIndex = 1;
                    }
                    [mainShowWebView  setFrame:[self setFrameWithOrigin:mainOffsetLength+mainSizeLength-perPageLength]];
                    [preLoadNextWebView setFrame:[self setFrameWithOrigin:mainOffsetLength+mainSizeLength]];
                    [preLoadNextWebView.scrollView setContentOffset:CGPointMake(0, 0)];
                    [mainShowWebView.scrollView setContentOffset:[self setPointWithOrigin:mainSizeLength-perPageLength]];
                }
                //现在页面上只显示preLoadNextWebView 直接控制preLoadNextWebView 滚动即可
                else if(offsetLength > nextOffsetLength && offsetLength <=nextOffsetLength + nextSizeLength - perPageLength)
                {
                    tempChapterIndex = preLoadNextWebView.chapterIndex;
                    tempPageIndex = (offsetLength - nextOffsetLength)/perPageLength +1;
                    [preLoadNextWebView.scrollView setContentOffset:[self setPointWithOrigin:offsetLength-nextOffsetLength]];
                    [preLoadNextWebView setFrame:[self setFrameWithOrigin:offsetLength]];
                }
                //如果到最下面 而且下面没有新的一页  那么保持现在的章节和页码
                else if(offsetLength > nextOffsetLength + nextSizeLength - perPageLength && offsetLength < nextOffsetLength + nextSizeLength)
                {
                    tempChapterIndex = preLoadNextWebView.chapterIndex;
                    tempPageIndex = preLoadNextWebView.pageCount;
                }
                //如果现在向下滑动且现在滑动到preLoadNextWebView大小的将近一半位置 那么就加在下一章
                if(downFlip)
                {
                    if (offsetLength > nextOffsetLength +nextSizeLength/2-perPageLength) {
                        [self preloadNextChapter];
                    }
                }
            }
            //如果预加载的下一章 并不存在 那么现在的章节和页码 应该和主显示视图一致
            else
            {
                tempChapterIndex = mainShowWebView.chapterIndex;
                tempPageIndex = mainShowWebView.pageCount;
            }
        }
        else if (offsetLength < mainOffsetLength)
        {
            if(preLoadPreWebView)
            {
                if(offsetLength > mainOffsetLength - perPageLength)
                {
                    if(mainOffsetLength - offsetLength > perPageLength/2)
                    {
                        tempChapterIndex = preLoadPreWebView.chapterIndex;
                        tempPageIndex = preLoadPreWebView.pageCount;
                    }
                    else
                    {
                        tempChapterIndex = mainShowWebView.chapterIndex;
                        tempPageIndex = 1;
                    }
                    
                    [mainShowWebView  setFrame:[self setFrameWithOrigin:mainOffsetLength]];
                    [mainShowWebView.scrollView setContentOffset:CGPointMake(0, 0)];
                    [preLoadPreWebView setFrame:[self setFrameWithOrigin:mainOffsetLength-perPageLength]];
                    [preLoadPreWebView.scrollView setContentOffset:[self setPointWithOrigin:preSizeLength-perPageLength]];
                }
                else if(offsetLength >preOffsetLength && offsetLength <=preOffsetLength +preSizeLength - perPageLength)
                {
                    tempChapterIndex = preLoadPreWebView.chapterIndex;
                    tempPageIndex = (offsetLength - preOffsetLength)/perPageLength+1;
                    
                    [preLoadPreWebView.scrollView setContentOffset:[self setPointWithOrigin:offsetLength-preOffsetLength]];
                    [preLoadPreWebView setFrame:[self setFrameWithOrigin:offsetLength]];
                }
                if(!downFlip||offsetLength <= 0 )
                {
                    if(offsetLength <= preOffsetLength +preLoadPreWebView.chapterSize.height/2)
                    {
                        [self preloadPreChapter];
                    }
                }
            }
        }
//        NSLog(@"目前数据：主展示页面的开始位移%f总长度%f;前展示页面的开始位移%f总长度%f;后展示页面的开始位移%f总长度%f;",mainShowWebView.scrollView.contentOffset.x,mainShowWebView.scrollView.contentSize.width,preLoadPreWebView.scrollView.contentOffset.x,preLoadPreWebView.scrollView.contentSize.width,preLoadNextWebView.scrollView.contentOffset.x,preLoadNextWebView.scrollView.contentSize.width);
        [epubController setNowChapterIndex:tempChapterIndex pageIndex:tempPageIndex];
        
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //暂时禁止平滑滚动
    //    if(!decelerate)
    //    {
    //        [self handleScorllToCorrectPosi];
    //    }
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    scrolling = YES;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    scrolling = NO;
    //    [self handleScorllToCorrectPosi];
}
-(void)handleScorllToCorrectPosi
{
    if(EPUB_HOR_FLIP)
    {
        //暂时禁止平滑滚动
        //        canSetScrollView = NO;
        //        NSInteger pageCount = (NSInteger)(self.contentOffset.x/viewWidth);
        //        if((int)self.contentOffset.x % (int)viewWidth < viewWidth/2)
        //        {
        //            [self setContentOffset:CGPointMake(pageCount * viewWidth,0) animated:YES];
        //        }
        //        else
        //        {
        //            [self setContentOffset:CGPointMake((pageCount +1) * viewWidth,0) animated:YES];
        //        }
        //        canSetScrollView = YES;
        canSetScrollView = NO;
        NSInteger pageCount = (NSInteger)(self.contentOffset.x/viewWidth);
        if(downFlip)
        {
            if((int)self.contentOffset.x % (int)viewWidth < viewWidth/4)
            {
                [self setContentOffset:CGPointMake(pageCount * viewWidth,0) animated:NO];
            }
            else
            {
                [self setContentOffset:CGPointMake((pageCount +1) * viewWidth,0) animated:NO];
            }
        }
        else
        {
            if((int)self.contentOffset.x % (int)viewWidth < viewWidth/4*3)
            {
                [self setContentOffset:CGPointMake(pageCount * viewWidth,0) animated:NO];
            }
            else
            {
                [self setContentOffset:CGPointMake((pageCount +1) * viewWidth,0) animated:NO];
            }
        }
        canSetScrollView = YES;
        
    }
}

#pragma mark -
#pragma mark ----------------WEBVIEW INIT OR LOAD RES METHOD-------------------

#pragma mark ----------------INIT METHOD-------------------

-(EpubWebView *)webViewWithchapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex mark:(NSString *)mark
{
    
    EpubChapter *chapter = [epubController getChapterWithIndex:chapterIndex];
    if(chapter == nil)
    {
        if(mainShowWebView.chapterIndex ==  chapterIndex)
        {
            epubLoaded = YES;
        }
        return nil;
    }
    
    CGPoint origin;
    if(flipType == EPUB_NOR_FLIP)
    {
        origin = CGPointMake(chapter.offset.x, chapter.offset.y + (pageIndex - 1)*viewHeight);
    }
    else
    {
        origin = CGPointMake(chapter.offset.x + (pageIndex - 1) * viewWidth, chapter.offset.y+WEBVIEW_TOP_BOTTOM_MARGIN);
    }
    
    EpubWebView *tempWebView = [[EpubWebView alloc]initWithFrame:CGRectMake(origin.x,origin.y, viewWidth, viewHeight)];
    tempWebView.mainViewDelegate = self;
    tempWebView.chapterIndex = chapter.chapterIndex;
    tempWebView.pageIndex = pageIndex;
    tempWebView.viewSize = CGSizeMake(viewWidth, viewHeight);
    tempWebView.pageCount = chapter.pageCount;
    tempWebView.chapterSize = chapter.contentSize;
    tempWebView.chapterOffset = chapter.offset;
    tempWebView.scrollView.scrollEnabled = NO;
    tempWebView.backgroundColor = [UIColor clearColor];
    tempWebView.scrollView.backgroundColor = [UIColor clearColor];
    tempWebView.scrollView.scrollsToTop = NO;
    tempWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    if(flipType == EPUB_HOR_FLIP)
    {
        tempWebView.paginationMode = UIWebPaginationModeLeftToRight;
        if(viewWidth > viewHeight && isPad)
            tempWebView.pageLength = viewWidth/2;
        else
            tempWebView.pageLength = viewWidth;
    }
    
    
    tempWebView.flipType = flipType;
    __block EpubMainScrollView *curView = self;
    tempWebView.doubleTapGestureBlock = ^{
//        [curView changeNavigationBarVisible];
    };
    tempWebView.singleTapGestureBlock = ^{
        [curView hideNavigateBar];
        curView.getNavBarHideState? [curView changeNavigationBarVisible] : [curView hideNavigateBar];
    };
    [epubController deCodeHtmlFileWithChapterIndex:chapterIndex];
    if(mark)
    {
        tempWebView.hasJSMark = YES;
        tempWebView.mark = mark;
        NSString *loacalUrlString = chapter.chapterUrl.absoluteString;
        NSString *markUrlString = [loacalUrlString stringByAppendingString:[NSString stringWithFormat:@"#%@",mark]];
        [tempWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:markUrlString]]];
        
    }
    else
    {
        [tempWebView loadRequest:[NSURLRequest requestWithURL:chapter.chapterUrl]];
    }
    
    
    [self addSubview:tempWebView];
    tempWebView.hidden = YES;
    
    return tempWebView;
}



-(void)reloadWebView:(EpubWebView *)webView chapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex mark:(NSString *)mark
{
    if(!webView)
        return;
    EpubChapter *chapter = [epubController getChapterWithIndex:chapterIndex];
    if(chapter == nil)
    {
        if(mainShowWebView.chapterIndex ==  chapterIndex)
        {
            epubLoaded = YES;
        }
        [self releaseWebviewWithChapterIndex:chapterIndex];
        return;
    }
    //为了避免新的web展示前 能看到旧web
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML='';"];
    CGPoint origin;
    if(flipType == EPUB_NOR_FLIP)
    {
        origin = CGPointMake(chapter.offset.x, chapter.offset.y + (pageIndex - 1)*viewHeight);
        webView.paginationMode = UIWebPaginationModeUnpaginated;
    }
    else
    {
        origin = CGPointMake(chapter.offset.x + (pageIndex - 1) * viewWidth, chapter.offset.y+WEBVIEW_TOP_BOTTOM_MARGIN);
        webView.paginationMode = UIWebPaginationModeLeftToRight;
        if(viewWidth > viewHeight && isPad)
        {
            webView.pageLength =viewWidth/2;
        }
        else
        {
            webView.pageLength =viewWidth;
        }
    }
    
    [webView setFrame:CGRectMake(origin.x, origin.y, viewWidth, viewHeight)];
    webView.flipType = flipType;
    webView.chapterIndex = chapterIndex;
    webView.pageIndex = pageIndex;
    webView.viewSize = CGSizeMake(viewWidth, viewHeight);
    webView.pageCount = chapter.pageCount;
    webView.chapterSize = chapter.contentSize;
    webView.chapterOffset = chapter.offset;
    [epubController deCodeHtmlFileWithChapterIndex:chapterIndex];
    
    if(mark)
    {
        webView.hasJSMark = YES;
        webView.mark = mark;
        NSString *loacalUrlString = chapter.chapterUrl.absoluteString;
        NSString *markUrlString = [loacalUrlString stringByAppendingString:[NSString stringWithFormat:@"#%@",mark]];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:markUrlString]]];
    }
    else
    {
        webView.hasJSMark = NO;
        webView.mark = nil;
        [webView loadRequest:[NSURLRequest requestWithURL:chapter.chapterUrl]];
    }
    
    [self addSubview:webView];
    webView.hidden = YES;
}

-(void)initWebview:(NSInteger)loadChapterIndex pageIndex:(NSInteger)pageIndex flipType:(NSInteger)ftype mark:(NSString *)mark
{
    flipType = ftype;
    //当没有计算页码时 初始化的函数
    epubLoaded = NO;
    //初始化主显示视图
    
    self.mainShowWebView = [self webViewWithchapterIndex:loadChapterIndex pageIndex:pageIndex mark:mark];
    mainShowWebView.firstLoad = YES;
    
    self.preLoadNextWebView = [self webViewWithchapterIndex:loadChapterIndex+1 pageIndex:1 mark:mark];
    
    if(preLoadNextWebView)
        self.preLoadNextWebView.frame = CGRectMake(0, -viewHeight, viewWidth, viewHeight) ;
    
    self.preLoadPreWebView = [self webViewWithchapterIndex:loadChapterIndex-1 pageIndex:1 mark:mark];
    
    if(preLoadPreWebView)
        self.preLoadPreWebView.frame = CGRectMake(0, -viewHeight, viewWidth, viewHeight) ;
    [epubController showLoadHud];
    
}


#pragma mark ----------------LOAD METHOD-------------------
//预加载下一章
-(void)preloadNextChapter
{
    if(mainShowWebView.chapterIndex < [epubController getChapterCount] - 2)
    {
        EpubWebView *tempWebView = preLoadPreWebView;
        preLoadPreWebView = mainShowWebView;
        mainShowWebView = preLoadNextWebView;
        preLoadNextWebView = tempWebView;
        if(preLoadNextWebView)
        {
            
            [self reloadWebView:preLoadNextWebView chapterIndex:mainShowWebView.chapterIndex+1 pageIndex:1 mark:nil];
        }
        else
        {
            self.preLoadNextWebView = [self webViewWithchapterIndex:mainShowWebView.chapterIndex+1 pageIndex:1 mark:nil];
        }
        if([epubController getPaginateState])
        {
            preLoadNextWebView.chapterSize = CGSizeMake(0, 0);
            preLoadNextWebView.chapterOffset = CGPointMake(0, 0);
        }
    }
    
}
//预加载上一章
-(void)preloadPreChapter
{
    if(mainShowWebView.chapterIndex > 2)
    {
        if([epubController getPaginateState]&&preLoadPreWebView.chapterSize.height==0)
        {
            return;
        }
        EpubWebView *tempWebView = preLoadNextWebView;
        preLoadNextWebView = mainShowWebView;
        mainShowWebView = preLoadPreWebView;
        preLoadPreWebView = tempWebView;
        
        if(preLoadPreWebView)
        {
            [self reloadWebView:preLoadPreWebView chapterIndex:mainShowWebView.chapterIndex-1 pageIndex:1 mark:nil];
        }
        else
        {
            self.preLoadPreWebView = [self webViewWithchapterIndex:mainShowWebView.chapterIndex-1 pageIndex:1 mark:nil];
        }
        if([epubController getPaginateState])
        {
            preLoadPreWebView.chapterSize = CGSizeMake(0, 0);
            preLoadPreWebView.chapterOffset = CGPointMake(0, 0);
        }
    }
}
-(void)turnToNextPage
{
    if([self getLengthWithPoint:self.contentOffset] + [self getPerPageLength] < [self getLengthWithSize:self.contentSize]){
        CGPoint point =[self setPointWithOrigin:[self getLengthWithPoint:self.contentOffset] + [self getPerPageLength]] ;
        [self setContentOffset:point animated:NO];
    }
    
}
-(void)turnToLastPage
{
    if([self getLengthWithPoint:self.contentOffset] - [self getPerPageLength] >= 0)
        [self setContentOffset:[self setPointWithOrigin:[self getLengthWithPoint:self.contentOffset] - [self getPerPageLength]] animated:NO];
}

-(void)turnTOChapter:(NSInteger)ChapterIndex page:(NSInteger)pageIndex mark:(NSString *)mark
{
    epubLoaded = NO;
    if(mainShowWebView && !mark)
    {
        [self reloadWebView:mainShowWebView chapterIndex:ChapterIndex pageIndex:pageIndex mark:mark];
    }
    else
    {
        if(mark)
        {
            if(mainShowWebView)
            {
                [mainShowWebView removeFromSuperview];
                mainShowWebView = nil;
            }
        }
        self.mainShowWebView = [self webViewWithchapterIndex:ChapterIndex pageIndex:pageIndex mark:mark];
        
    }
    
    if(preLoadNextWebView)
    {
        preLoadNextWebView.chapterIndex = ChapterIndex +1;
        [self reloadWebView:preLoadNextWebView chapterIndex:ChapterIndex+1 pageIndex:1 mark:nil];
    }
    else
    {
        self.preLoadNextWebView =[ self webViewWithchapterIndex:ChapterIndex+1 pageIndex:1 mark:nil];
    }
    
    if(preLoadPreWebView)
    {
        preLoadPreWebView.chapterIndex = ChapterIndex-1;
        [self reloadWebView:preLoadPreWebView chapterIndex:ChapterIndex-1 pageIndex:1 mark:nil];
    }
    else
    {
        self.preLoadPreWebView  = [self webViewWithchapterIndex:ChapterIndex-1 pageIndex:1 mark:nil];
    }
    
    if(!mark)
        [self setContentOffset:[self setPointWithOrigin:[self getLengthWithPoint:mainShowWebView.chapterOffset ]+[self getPerPageLength]*(pageIndex - 1)]];
    
}








#pragma mark -
#pragma mark ----------------委托控制器进行完成的方法-------------------
-(void)changeNavigationBarVisible
{
    [epubController changeNavigationBarVisible];
}
-(void)hideNavigateBar
{
    [epubController hideNavigateBar];
}


#pragma mark -
#pragma mark ----------------delegate method-------------------
-(void)webviewFailLoad:(EpubWebView *)webview
{
    if(webview.chapterIndex == mainShowWebView.chapterIndex)
    {
        epubLoaded = YES;
    }
}
-(void)webviewFinishLoad:(EpubWebView *)webview
{
    webview.backgroundColor = [UIColor clearColor];
    webview.scrollView.backgroundColor = [UIColor clearColor];
    [epubController enCodeHtmlFileWithChapterIndex:webview.chapterIndex];
    if(mainShowWebView.firstLoad == YES||[epubController getPaginateState])
    {
        [self setEpubwebView:webview];
    }
    
    if(webview.chapterIndex == mainShowWebView.chapterIndex)
    {
        //        epubLoaded = YES;
        if(webview.firstLoad == YES)
        {
            
            webview.firstLoad = NO;
            epubLoaded = YES;
            [self delayLoadPageWithWebview:webview];
            [epubController updatePagination];
        }
        else
        {
            if(!mainShowWebView.hasJSMark)
            {
                if(webview.pageIndex != 1 && webview.pageIndex != 0)
                {
                    [self delayLoadPageWithWebview:webview];
                }
                else
                {
                    [self finishLoadWebView:webview];
                }
                
                
            }
            else
            {
                //                if(webview.mark.length > 0)
                //                {
                ////                    [self resetMainWebViewPostion];
                //                }
                mainShowWebView.hasJSMark = NO;
                [self finishLoadWebView:webview];
                
            }
            
            if(searchKey)
            {
                [self showSearchResultWithkey:searchKey position:searchPosi];
                searchKey = nil;
            }
            
        }
        
        
    }
    else
    {
        webview.hidden = NO;
    }
    
    
}
-(void)delayLoadPageWithWebview:(EpubWebView *)webView
{
    // 延迟2秒执行：
    double delayInSeconds = 1;
    __block EpubWebView* blockWebview = webView;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // code to be executed on the main queue after delay
        [self resetMainWebViewPostionWithOffset:[self getPerPageLength]*(blockWebview.pageIndex-1)];
        [self finishLoadWebView:blockWebview];
        
    });
}

-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index
{
    [epubController saveHighLightsWithDic:dictionary chapterIndex:index];
}
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index
{
    return [epubController getNoteStringWithChapterIndex:index];
}
-(NSDictionary *)getEpubSetting
{
    return [epubController getEpubSetting];
}
-(void)loadPageWithFileName:(NSString *)fileName
{
    [epubController loadPageWithFileName:fileName];
}

-(void)showContentRefWithDIc:(NSDictionary *)dic webView:(EpubWebView*)webview type:(NSString *)type
{
    NSString *contentString = [self.mainShowWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"decodeURIComponent(\"%@\")",[dic objectForKey:@"content"]]] ;
    NSMutableDictionary*contentDic = ((NSDictionary*)contentString.JSONValue).mutableCopy ;
    NSNumber *topNumber = [contentDic objectForKey:@"top"];
    NSNumber *leftNumber = [contentDic objectForKey:@"left"];
    if(flipType == EPUB_NOR_FLIP)
        [contentDic setObject:[NSNumber numberWithInteger:topNumber.integerValue+webview.chapterOffset.y-self.contentOffset.y] forKey:@"top"];
    else
    {
        [contentDic setObject:[NSNumber numberWithInteger:leftNumber.integerValue + webview.chapterOffset.x-self.contentOffset.x] forKeyedSubscript:@"left"];
        [contentDic setObject:[NSNumber numberWithInteger:topNumber.integerValue + WEBVIEW_TOP_BOTTOM_MARGIN] forKeyedSubscript:@"top"];
    }
    
    if([type isEqualToString:JS_NOTE_FLAGSTR])
    {
        [epubController showNoteRefWithDic:contentDic webView:webview];
    }
    else if([type isEqualToString:JS_PICTURE_FLAGSTR])
    {
        [epubController showPicWithDic:contentDic webView:webview];
    }
}

-(NSString *)getFlipTypeAndOren
{
    return [epubController getFlipTypeAndOren];
}

-(void)setAnchorPostionWithoffset:(CGPoint)offset
{
    [self renewMainViewPositionWithOffset:offset];
}

#pragma mark -
#pragma mark ----------------business method-------------------
-(void)allWebViewLoadJsString:(NSString *)jsString
{
    [mainShowWebView stringByEvaluatingJavaScriptFromString:jsString];
    [preLoadNextWebView stringByEvaluatingJavaScriptFromString:jsString];
    [preLoadPreWebView stringByEvaluatingJavaScriptFromString:jsString];
}

//改变字体大小和行间距调用的刷新方法
-(void)reloadLoadedWebView
{
    epubLoaded = NO;
    [[epubController getPagenatingChapterArray] removeAllObjects];
    mainShowWebView.firstLoad = YES;
    [self hideNowLoadedWebView];
    [mainShowWebView reload];
    [preLoadNextWebView reload];
    [preLoadPreWebView reload];
}

-(void)hideNowLoadedWebView
{
    mainShowWebView.hidden = YES;
    preLoadNextWebView.hidden = YES;
    preLoadPreWebView.hidden = YES;
}
-(void)refreshLoadedWebView
{
    [self refreshWebViewWithWebView:mainShowWebView];
    [self refreshWebViewWithWebView:preLoadNextWebView];
    [self refreshWebViewWithWebView:preLoadPreWebView];
}

-(void)refreshWebViewWithWebView:(EpubWebView *)webview
{
    EpubChapter *chapter = [epubController getChapterWithIndex:webview.chapterIndex];
    webview.chapterOffset = chapter.offset;
    webview.chapterSize = chapter.contentSize;
    webview.pageCount = chapter.pageCount;
}

-(void)releaseAllWebView
{
    if(mainShowWebView)
    {
        [mainShowWebView removeFromSuperview];
        mainShowWebView = nil;
    }
    if(preLoadPreWebView)
    {
        [preLoadPreWebView removeFromSuperview];
        preLoadPreWebView = nil;
    }
    if(preLoadNextWebView)
    {
        [preLoadNextWebView removeFromSuperview];
        preLoadNextWebView = nil;
    }
}

//暂时屏蔽键盘弹出控制

//-(void)keyBoradWillShow:(float)keyBoardHeight
//{
//    if(mainShowWebView.frame.origin.y < pointPositionY && mainShowWebView.frame.origin.y+viewHeight>pointPositionY)
//    {
//        tempKeyboardFlagView = mainShowWebView;
//    }
//    else if(preLoadNextWebView.frame.origin.y < pointPositionY)
//    {
//        tempKeyboardFlagView = preLoadNextWebView;
//    }
//    else
//    {
//        tempKeyboardFlagView = preLoadPreWebView;
//    }
//
//    //    if(tempView.frame.origin.y >= self.contentOffset.y&& tempView.frame.origin.y <= self.contentOffset.y+viewHeight)
//    //    {
//    NSInteger marginValue = tempKeyboardFlagView.scrollView.contentOffset.y;
//    NSInteger top = pointPositionY - self.contentOffset.y;
//    NSInteger topToWeb = pointPositionY - tempKeyboardFlagView.frame.origin.y;
//    NSInteger moveDistance = top +250 -viewHeight +keyBoardHeight;
//
//    if (marginValue+topToWeb+250 > tempKeyboardFlagView.scrollView.contentSize.height) {
//        moveDistance = moveDistance - marginValue-topToWeb-250 +tempKeyboardFlagView.scrollView.contentSize.height;
//        //        moveDistance = tempKeyboardFlagView.scrollView.contentSize.height-tempKeyboardFlagView.scrollView.contentOffset.y-self.contentOffset.y + tempKeyboardFlagView.frame.origin.x+keyBoardHeight-viewHeight;
//    }
//
//
//
//    if(moveDistance >0)
//    {
//        canSetScrollView = NO;
//
//        if (top - topToWeb >3) {
//            if(top - topToWeb > moveDistance)
//            {
//                [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + top -topToWeb) animated:NO];
//                NSLog(@"keyboard log top - topToWeb > moveDistance %ld",(long)(top -topToWeb - moveDistance));
//            }
//            else
//            {
//                [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + top -topToWeb)];
//                [tempKeyboardFlagView.scrollView setContentOffset:CGPointMake(tempKeyboardFlagView.scrollView.contentOffset.x,marginValue +moveDistance-top + topToWeb)];
//            }
//        }
//        else
//        {
//            if (marginValue + moveDistance < tempKeyboardFlagView.chapterSize.height - viewHeight) {
//                [tempKeyboardFlagView.scrollView setContentOffset:CGPointMake(tempKeyboardFlagView.scrollView.contentOffset.x,marginValue + moveDistance) animated:NO];
//                NSLog(@"keyboard log %ld",(long)moveDistance);
//            }
//            else
//            {
//                [self setContentOffset:CGPointMake(self.contentOffset.x,self.contentOffset.y + marginValue + moveDistance - tempKeyboardFlagView.chapterSize.height + viewHeight)];
//                [tempKeyboardFlagView.scrollView setContentOffset:CGPointMake(tempKeyboardFlagView.scrollView.contentOffset.x,tempKeyboardFlagView.chapterSize.height - viewHeight)];
//
//            }
//
//        }
//
//
//
//        lastSavedPositionY = pointPositionY;
//        canSetScrollView = YES;
//    }
//    //    }
//}
//-(void)keyBoradWillHide
//{
//    NSInteger selftempOffset = tempKeyboardFlagView.chapterOffset.y+self.contentOffset.y - tempKeyboardFlagView.frame.origin.y+ tempKeyboardFlagView.scrollView.contentOffset.y;
//    NSInteger viewTempOriginX = tempKeyboardFlagView.chapterOffset.y + tempKeyboardFlagView.scrollView.contentOffset.y;
//
//    [self setContentOffset:CGPointMake(0,selftempOffset)];
//    [tempKeyboardFlagView setFrame:CGRectMake(0,viewTempOriginX, viewWidth, viewHeight)];
//}

-(void)resetMainWebViewPostion
{
    [self resetMainWebViewPostionWithOffset:[self getLengthWithPoint:mainShowWebView.scrollView.contentOffset]];
}
//不重新设置webview的contentoffset 而是通过当前offset 计算页码调整webview在scorllview上的位置
-(void)resetMainWebViewPostionWithOffset:(float)offsetLenght
{
    if(mainShowWebView)
    {
        
        canSetScrollView = NO;
        if(offsetLenght != [self getLengthWithPoint:mainShowWebView.scrollView.contentOffset])
            [mainShowWebView.scrollView setContentOffset:[self setPointWithOrigin:offsetLenght]];
        [mainShowWebView setFrame:[self setFrameWithOrigin:[self getLengthWithPoint:mainShowWebView.chapterOffset]+offsetLenght]];
        [self setContentOffset:[self setPointWithOrigin:[self getLengthWithPoint:mainShowWebView.chapterOffset]+offsetLenght]];
        [ epubController setNowChapterIndex:mainShowWebView.chapterIndex pageIndex:offsetLenght/[self getPerPageLength]+1];
        canSetScrollView = YES;
    }
    //    else
    //    {
    //        [self turnTOChapter:nowChapterIndex page:nowPageIndex];
    //    }
    
}

-(void)setScrollToMark:(NSString *)mark
{
    if(mark)
    {
        NSString*pos = [mainShowWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getAnchorPos('#%@')",mark]];
        NSDictionary *dic = [pos JSONValue];
        CGPoint Point = CGPointMake(((NSNumber*)[dic objectForKey:@"left"]).floatValue, ((NSNumber*)[dic objectForKey:@"top"]).floatValue);
        
        [self renewMainViewPositionWithOffset:Point];
    }
}
-(void)renewMainViewPositionWithOffset:(CGPoint)aimOffset
{
    float webOffsetLength;
    float mainScrollSetLength;
    int page =  [self getLengthWithPoint:aimOffset]/[self getPerPageLength];
    if(flipType == EPUB_HOR_FLIP&&[self getLengthWithPoint:aimOffset] != page *[self getPerPageLength])
    {
        webOffsetLength =page * [self getPerPageLength];
        mainScrollSetLength = [self getLengthWithPoint:mainShowWebView.chapterOffset]+webOffsetLength;
        
    }
    else
    {
        webOffsetLength = [self getLengthWithPoint:mainShowWebView.scrollView.contentOffset];
        mainScrollSetLength = [self getLengthWithPoint:mainShowWebView.chapterOffset]+webOffsetLength;
    }
    
    [self resetMainWebViewPostionWithOffset:webOffsetLength];
}
-(BOOL)formartWebViewContent:(NSInteger)nowChapterIndex
{
    if(mainShowWebView.chapterIndex == nowChapterIndex)
    {
        return YES;
    }
    else if(preLoadNextWebView.chapterIndex == nowChapterIndex)
    {
        if(mainShowWebView.chapterIndex < [epubController getChapterCount] - 2)
            [self preloadNextChapter];
        else
        {
            preLoadPreWebView = mainShowWebView;
            mainShowWebView = preLoadNextWebView;
            preLoadNextWebView = nil;
        }
    }
    else if(preLoadPreWebView.chapterIndex == nowChapterIndex)
    {
        if(mainShowWebView.chapterIndex > 2)
            [self preloadPreChapter];
        else
        {
            preLoadNextWebView = mainShowWebView;
            mainShowWebView = preLoadPreWebView;
            preLoadPreWebView = nil;
            
            
        }
    }
    else
    {
        return NO;
    }
    return YES;
}
-(UIColor *)getColorWithColorString:(NSString *)colorString
{
    return [mainShowWebView getColorWithColorString:colorString];
}
-(void)showNoteWithNote:(EpubNoteListObject *)noteObject webView:(EpubWebView *)webView
{
    //不算webview的滚动偏移  现在距离webview顶部的距离
    NSInteger nowWebViewPosiLength = [self getLengthWithPoint:noteObject.postion]-[self getLengthWithPoint:webView.scrollView.contentOffset];
    //现在屏幕上得物理位置
    NSInteger nowViewpositonLength = [self getLengthWithPoint:webView.frame.origin]+nowWebViewPosiLength - [self getLengthWithPoint:self.contentOffset];
    if(flipType == EPUB_HOR_FLIP)
        noteObject.postion = CGPointMake(nowViewpositonLength, noteObject.postion.y + WEBVIEW_TOP_BOTTOM_MARGIN);
    else
        noteObject.postion = CGPointMake(noteObject.postion.x, nowViewpositonLength);
    
    [epubController poperNoteWithNoteObject:noteObject webView:webView];
    
}
-(BOOL)getNavBarHideState
{
    return [epubController getNavBarHideState];
}

-(void)showSearchResultWithkey:(NSString *)key position:(CGPoint)positon
{
    [mainShowWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getResFromSearch('%@')",key]];
    //在开始的时候就计算好 而不是在这里进行跳转
    //    [mainShowWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"toPosAndHt(%f,%f)",positon.x,positon.y]];
}
-(void)willShowSearchResultWithkey:(NSString *)key position:(CGPoint)positon
{
    searchKey = [key mutableCopy];
    searchPosi = positon;
}
-(void)releaseWebviewWithChapterIndex:(NSInteger)index
{
    if(mainShowWebView.chapterIndex == index)
    {
        [mainShowWebView removeFromSuperview];
        mainShowWebView = nil;
    }
    if(preLoadNextWebView.chapterIndex == index)
    {
        [preLoadNextWebView removeFromSuperview];
        preLoadNextWebView = nil;
    }
    if(preLoadPreWebView.chapterIndex == index)
    {
        [preLoadPreWebView removeFromSuperview];
        preLoadPreWebView = nil;
    }
}

-(EpubWebView *)getWebViewWithChapterIndex:(NSInteger)index
{
    if(mainShowWebView.chapterIndex == index)
    {
        return mainShowWebView;
    }
    else if(preLoadNextWebView.chapterIndex == index)
    {
        return preLoadNextWebView;
    }
    else if(preLoadPreWebView.chapterIndex == index)
    {
        return preLoadPreWebView;
    }
    else
    {
        return mainShowWebView;
    }
    return nil;
}

-(void)resetLoadedWebview
{
    if(flipType == EPUB_HOR_FLIP)
    {
        mainShowWebView.paginationMode = UIWebPaginationModeLeftToRight;
        preLoadNextWebView.paginationMode = UIWebPaginationModeLeftToRight;
        preLoadPreWebView.paginationMode = UIWebPaginationModeLeftToRight;
        if(viewWidth > viewHeight && isPad)
        {
            mainShowWebView.pageLength =viewWidth/2;
            preLoadNextWebView.pageLength =viewWidth/2;
            preLoadPreWebView.pageLength =viewWidth/2;
        }
        else
        {
            mainShowWebView.pageLength =viewWidth;
            preLoadNextWebView.pageLength =viewWidth;
            preLoadPreWebView.pageLength =viewWidth;
        }
        
    }
    else
    {
        mainShowWebView.paginationMode = UIWebPaginationModeUnpaginated;
        preLoadNextWebView.paginationMode = UIWebPaginationModeUnpaginated;
        preLoadPreWebView.paginationMode = UIWebPaginationModeUnpaginated;
    }
    mainShowWebView.flipType = flipType;
    preLoadPreWebView.flipType = flipType;
    preLoadNextWebView.flipType = flipType;
    [mainShowWebView reload];
    [preLoadPreWebView reload];
    [preLoadNextWebView reload];
}

-(void)finishLoadWebView:(EpubWebView *)webview
{
    webview.hidden = NO;
    epubLoaded = YES;
    
    // 发通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EpubMainScrollViewDidReloadContent" object:nil];
}

#pragma mark -
#pragma mark ----------------书签相关-------------------

-(EpubMarkObject *)addBookMarkWithChapterIndex:(NSInteger)chapterIndex
{
    EpubWebView *webView = [self getWebViewWithChapterIndex:chapterIndex];
    NSString *bookMarkString = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setBookmark(%zd)",flipType]];
    NSDictionary *bookMarkDic = bookMarkString.JSONValue;
    if(bookMarkDic.allKeys.count == 0)
    {
        return nil;
    }
    
    NSInteger left = ((NSNumber *)[bookMarkDic objectForKey:@"left"]).floatValue;
    NSInteger top =  ((NSNumber *)[bookMarkDic objectForKey:@"top"]).floatValue;
    
    EpubMarkObject *markObject = [[EpubMarkObject alloc]init];
    markObject.chapterIndex = chapterIndex;
    markObject.markJsIndex = [bookMarkDic objectForKey:@"index"];
    markObject.content = [bookMarkDic objectForKey:@"content"];
    markObject.date = [NSDate date];
    
    if(flipType == EPUB_NOR_FLIP)
    {
        markObject.pageNum = top/viewHeight+1;
    }
    else
    {
        markObject.pageNum = left/viewWidth+1;
    }
    
    [self setEpubMarkObjectPageNumWithEpubMarkObject:markObject left:left top:top];
    
    return markObject;
}
-(void)setEpubMarkObjectPageNumWithEpubMarkObject:(EpubMarkObject *)markObject left:(NSInteger)left top:(NSInteger)top
{
    if(flipType == EPUB_NOR_FLIP)
    {
        if(viewWidth > viewHeight)
        {
            [markObject.pageNumDic setObject:@(top/viewHeight+1) forKey:LANDSCAPE_NORFLIP];
        }
        else
        {
            [markObject.pageNumDic setObject:@(top/viewHeight+1) forKey:PORTRAIT_NORFLIP];
        }
    }
    else
    {
        if(viewWidth > viewHeight)
        {
            [markObject.pageNumDic setObject:@(left/viewWidth+1) forKey:LANDSCAPE_HORFLIP];
        }
        else
        {
            [markObject.pageNumDic setObject:@(left/viewWidth+1) forKey:PORTRAIT_HORFLIP];
        }
    }
}
#pragma mark -
#pragma mark ----------------function method-------------------


-(CGSize)addSizeWithSize:(CGSize)size margin:(float)margin
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return CGSizeMake(size.width, size.height + margin);
    }
    else
    {
        return CGSizeMake(size.width + margin, size.height);
    }
}
-(CGPoint)addPointWithPoint:(CGPoint)point margin:(float)margin
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return CGPointMake(point.x, point.y+margin);
    }
    else
    {
        return CGPointMake(point.x + margin, point.y);
    }
}

-(CGRect)addFrameWithPoint:(CGRect)rect margin:(float)margin
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return CGRectMake(rect.origin.x, rect.origin.y+margin, viewWidth, viewHeight);
    }
    else
    {
        return CGRectMake(rect.origin.x + margin, rect.origin.y, viewWidth, viewHeight);
    }
}

-(CGSize)setSizeWithlength:(float)length
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return CGSizeMake(viewWidth, length);
    }
    else
    {
        return CGSizeMake(length, viewHeight);
    }
}
-(CGPoint)setPointWithOrigin:(float)origin
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return CGPointMake(0, origin);
    }
    else
    {
        return CGPointMake(origin, 0);
    }
}
-(CGRect)setFrameWithOrigin:(float)origin
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return CGRectMake(0, origin, viewWidth, viewHeight);
    }
    else
    {
        return CGRectMake(origin, WEBVIEW_TOP_BOTTOM_MARGIN, viewWidth, viewHeight);
    }
}
-(float)getLengthWithPoint:(CGPoint)point
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return point.y;
    }
    else
    {
        return point.x;
    }
}
-(float)getLengthWithFrame:(CGRect)rect
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return rect.origin.y;
    }
    else
    {
        return rect.origin.x;
    }
}

-(float)getLengthWithSize:(CGSize)size
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return size.height;
    }
    else
    {
        return size.width;
    }
}

-(float)getPerPageLength
{
    if(flipType == EPUB_NOR_FLIP)
    {
        return viewHeight;
    }
    else
    {
        return viewWidth;
    }
}


#pragma mark -
#pragma mark ----------------scroll noblock method-------------------

-(void)pagenatedScrollViewWithOffset:(CGPoint)offset
{
    
}

-(void)setEpubwebView:(EpubWebView *)webView
{
    //此时如果本页有笔记 那么把笔记位置进行更新
    [epubController updateNoteWithWebView:webView];
    
    NSMutableArray *pagenatingChapterArray = [epubController getPagenatingChapterArray];
    if (pagenatingChapterArray.count == 0) {
        [self setContentOffset:CGPointMake(0, 0)];
        [self setContentSize:CGSizeMake(0, 0)];
    }
    //must adjust protocal copy
    EpubChapter *aimChapter = [[epubController getChapterWithIndex:webView.chapterIndex]copy];
    aimChapter.contentSize = webView.chapterSize;
    aimChapter.pageCount = webView.pageCount;
    
    NSInteger tempFlagChapter = 0;
    NSInteger marginLengh;
    if(flipType == EPUB_NOR_FLIP)
    {
        marginLengh = aimChapter.contentSize.height;
    }
    else
    {
        marginLengh = aimChapter.contentSize.width;
    }
    for (NSInteger i = 0; i < pagenatingChapterArray.count; i++) {
        EpubChapter *tempChapter = [pagenatingChapterArray objectAtIndex:i];
        if(tempChapter.chapterIndex > aimChapter.chapterIndex)
        {
            if(tempFlagChapter == 0)
            {
                tempFlagChapter = aimChapter.chapterIndex;
                aimChapter.offset = tempChapter.offset;
                [pagenatingChapterArray insertObject:aimChapter atIndex:i];
                i++;
                if(self.contentOffset.y >= aimChapter.offset.y )
                {
                    canSetScrollView = NO;
                    [self setContentOffset:[self addPointWithPoint:self.contentOffset margin:marginLengh]];
                    canSetScrollView = YES;
                }
                
            }
            tempChapter.offset = [self addPointWithPoint:tempChapter.offset margin:marginLengh];
        }
        else if (tempChapter.chapterIndex == aimChapter.chapterIndex)
        {
            aimChapter.offset =  tempChapter.offset;
            tempFlagChapter = -1;
            break;
        }
    }
    
    //object is last object or first
    if(tempFlagChapter == 0)
    {
        NSInteger lastOffsetLengh;
        if(pagenatingChapterArray.count > 0)
        {
            EpubChapter *tempChapter = [pagenatingChapterArray objectAtIndex:pagenatingChapterArray.count-1];
            if(flipType == EPUB_NOR_FLIP)
                lastOffsetLengh =tempChapter.offset.y+tempChapter.contentSize.height;
            else
                lastOffsetLengh = tempChapter.offset.x+tempChapter.contentSize.width;
        }
        else
        {
            lastOffsetLengh = 0;
        }
        aimChapter.offset = [self setPointWithOrigin:lastOffsetLengh];
        [pagenatingChapterArray addObject:aimChapter];
    }
    
    webView.chapterOffset = aimChapter.offset;
    
    //if new object added > 0 add marin to contentsize
    if(tempFlagChapter >= 0)
    {
        [self setContentSize:[self addSizeWithSize:self.contentSize margin:marginLengh]];
    }
    
    [webView setFrame:CGRectMake(webView.chapterOffset.x, webView.chapterOffset.y, viewWidth, viewHeight)];
    
    
    if(tempFlagChapter > 0)
        [self resetAllOtherViewWithMargin:marginLengh chapterFlag:webView.chapterIndex];
    
    if(webView.firstLoad == YES)
    {
        [self setContentOffset:webView.chapterOffset];
    }
    
    
    
}

-(void)resetAllOtherViewWithMargin:(NSInteger)margin chapterFlag:(NSInteger)flagIndex
{
    if(mainShowWebView.chapterIndex > flagIndex)
    {
        mainShowWebView.chapterOffset = [self addPointWithPoint:mainShowWebView.chapterOffset margin:margin];
        [mainShowWebView setFrame:[self addFrameWithPoint:mainShowWebView.frame margin:margin]];
    }
    if(preLoadNextWebView.chapterIndex > flagIndex)
    {
        preLoadNextWebView.chapterOffset = [self addPointWithPoint:preLoadNextWebView.chapterOffset margin:margin];
        [preLoadNextWebView setFrame:[self addFrameWithPoint:preLoadNextWebView.frame margin:margin]];
    }
    if(preLoadPreWebView.chapterIndex > flagIndex)
    {
        preLoadPreWebView.chapterOffset = [self addPointWithPoint:preLoadPreWebView.chapterOffset margin:margin];
        [preLoadPreWebView setFrame:[self addFrameWithPoint:preLoadPreWebView.frame margin:margin]];
    }
}
@end
