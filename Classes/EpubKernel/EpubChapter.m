//
//  EpubChapter.m
//  E-Publishing
//
//  Created by miaopu on 14/12/26.
//
//

#import "EpubChapter.h"
#import "EpubStaticDefine.h"
#import "EPubMainViewController.h"
#import "JSON.h"
#import "EpubMarkObject.h"

#import "Catalog.h"

@implementation EpubChapter
@synthesize  contentSize;
@synthesize offset;
@synthesize pageCount;
@synthesize title;
@synthesize fontSize;
@synthesize chapterUrl;
@synthesize chapterFileName;

@synthesize chapterIndex;
@synthesize searchKey;
@synthesize isUpdateNoteAndMark;



//查找页码执行的方法
- (void) loadChapterWithWindowSize:(CGSize)theWindowSize
{
    [self loadWebViewWithFlag:COUNT_PAGE_FLAG size:theWindowSize];
}
-(NSString *)getFlipTypeAndOren
{
    return [self.epubDelegate getFlipTypeAndOren];
}

-(id)copyWithZone:(NSZone *)zone
{
    EpubChapter *chapter = [[EpubChapter allocWithZone:zone]init];
    chapter.contentSize = contentSize;
    chapter.offset = offset;
    chapter.pageCount = pageCount;
    chapter.title = [title copyWithZone:zone];
    chapter.fontSize = fontSize;
    chapter.chapterUrl = [chapterUrl  copyWithZone:zone];
    chapter.chapterFileName = [chapterFileName  copyWithZone:zone];
    chapter.epubDelegate = self.epubDelegate;
    chapter.chapterIndex = chapterIndex;
    chapter.searchKey = [searchKey  copyWithZone:zone];
    
    return chapter;
}
//搜索执行的方法
- (void)searchChapterWithWindowSize:(CGSize)theWindowSize Key:(NSString *)key
{
    [self loadWebViewWithFlag:SEARCH_FLAG size:theWindowSize];
    self.searchKey = key;
}
-(EpubWebView *)loadWebViewWithFlag:(NSInteger)flag size:(CGSize)theWindowSize
{
    viewWidth = theWindowSize.width;
    viewHeight = theWindowSize.height;
    EpubWebView *tWebView = [[EpubWebView alloc] initWithFrame:CGRectMake(-viewWidth,-viewHeight, viewWidth,viewHeight)];
    
    tWebView.mainViewDelegate = self;
    tWebView.delegate = tWebView;
    tWebView.functionFlag = flag;
    tWebView.chapterIndex = chapterIndex;
    tWebView.pageIndex = 1;
    if([[self.epubDelegate getFlipTypeAndOren] isEqualToString:PORTRAIT_NORFLIP]||[[self.epubDelegate getFlipTypeAndOren] isEqualToString:LANDSCAPE_NORFLIP])
    {
        tWebView.flipType = EPUB_NOR_FLIP;
        tWebView.viewSize = theWindowSize;
        tWebView.paginationMode = UIWebPaginationModeUnpaginated;
        
    }
    else
    {
        tWebView.flipType = EPUB_HOR_FLIP;
        tWebView.paginationMode = UIWebPaginationModeLeftToRight;
        tWebView.viewSize = theWindowSize;
        if(viewWidth > viewHeight  && isPad)
            tWebView.pageLength =viewWidth/2;
        else
            tWebView.pageLength = viewWidth;
    }
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:chapterUrl];
    [self.epubDelegate deCodeHtmlFileWithChapterIndex:chapterIndex];
    [tWebView loadRequest:urlRequest];
    [[self.epubDelegate getMainView] addSubview:tWebView];
    return tWebView;
}

-(void)webviewFinishLoad:(EpubWebView *)webview
{
    if(!self.epubDelegate)
        return;
    [self.epubDelegate enCodeHtmlFileWithChapterIndex:webview.chapterIndex];
    if(webview.functionFlag != SEARCH_FLAG)
    {
        pageCount = webview.pageCount;
        self.contentSize = webview.chapterSize;
    }

    
    if(webview.functionFlag == COUNT_PAGE_FLAG)
    {
        [self getBookMarkPosiWithWebView:webview];
         BOOL result = [self.epubDelegate updateNoteWithWebView:webview];
        if(!result)
        {
            [webview removeFromSuperview];
            
        }
        [self.epubDelegate chapterDidFinishLoad:self];
    }
    
    else if(webview.functionFlag == SEARCH_FLAG)
    {
        NSString *resultString = [webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getResFromSearch('%@')",searchKey]];
        [self.epubDelegate chapterDIdFinishSearch:self lastResult:resultString key:searchKey];
        [webview removeFromSuperview];
        
    }
}
-(void)saveFinished:(EpubWebView *)webView
{
    [webView removeFromSuperview];
    
}
-(void)getBookMarkPosiWithWebView:(EpubWebView *)webView
{
    NSMutableArray *markArray = [self.epubDelegate getBookMarkArray];
    for (int i= 0;i < markArray.count ; i ++) {
        EpubMarkObject *markObject = [markArray objectAtIndex:i];
        if(markObject.chapterIndex == chapterIndex)
        {
            NSString *bookMarkString =  [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getBookmark(%@)",markObject.markJsIndex]];
            NSDictionary *bookMarkDic = bookMarkString.JSONValue;
            
            NSInteger left = ((NSNumber *)[bookMarkDic objectForKey:@"left"]).floatValue;
            NSInteger top =  ((NSNumber *)[bookMarkDic objectForKey:@"top"]).floatValue;
            
           
            NSString *key = [self.epubDelegate getFlipTypeAndOren];
            if([key isEqualToString:PORTRAIT_NORFLIP]||[key isEqualToString:LANDSCAPE_NORFLIP])
            {
                 markObject.pageNum = top/viewHeight+1;
            }
            else
            {
                markObject.pageNum = left/viewWidth+1;

            }
            [markObject.pageNumDic setObject:@(markObject.pageNum) forKey:key];
            [self.epubDelegate updateBookMarkObjcet:markObject];
        }
    }
}

//通知控制器进行保存的方法
-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index
{
    [self.epubDelegate saveHighLightsWithDic:dictionary chapterIndex:index];
}
//读取note
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index
{
    return [self.epubDelegate getNoteStringWithChapterIndex:index];
}
//读取字体信息
-(NSDictionary *)getEpubSetting
{
    return [self.epubDelegate getEpubSetting];
}




@end


