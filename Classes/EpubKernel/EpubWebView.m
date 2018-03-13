//
//  EpubWebView.m
//  E-Publishing
//
//  Created by miaopu on 14-9-19.
//
//

#import "EpubWebView.h"
#import "EpubStaticDefine.h"
#import "EPubMainViewController.h"
#import "JSON.h"
#import "NSObject+UIPopover_iPhone.h"
#import "EPUBUtils.h"
#import "EpubNoteListObject.h"




@implementation EpubWebView
@synthesize pageIndex;
@synthesize pageCount;
@synthesize chapterIndex;
@synthesize arrayIndex;
@synthesize flipType;
@synthesize viewSize;
@synthesize touchBeginPoint;

@synthesize singleTapGestureBlock;
@synthesize doubleTapGestureBlock;
@synthesize chapterSize;
@synthesize chapterOffset;
@synthesize firstLoad;
@synthesize hasJSMark;
@synthesize functionFlag;
@synthesize mark;
@synthesize lastTapDate;


- (void)item0:(id)sender;
{
    NSString *addnote   = [NSString stringWithFormat:@"(function(){ addNote();return false;})()"];
    
    [self stringByEvaluatingJavaScriptFromString:addnote];
    //    [self showNoteWithDic:nil];
}

- (void)item1:(id)sender;
{
    NSString *addhighLight   = [NSString stringWithFormat:@"(function(){ addHL();return false;})()"];
    [self stringByEvaluatingJavaScriptFromString:addhighLight];
    
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *menuItem0 = [[UIMenuItem alloc] initWithTitle:@"便签" action:@selector(item0:)];
        UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"高亮" action:@selector(item1:)];
        
        self.backgroundColor  =[ UIColor clearColor];
        self.delegate = self;
        
        NSArray *array = [NSArray arrayWithObjects:menuItem0, menuItem1,nil];
        [menuController setMenuItems:array];
        
        
        //初始化章节和页码编号
        pageIndex = 1;
        chapterIndex = 1;
        mark = nil;
        

       
        UITapGestureRecognizer* singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleGesture:)];
        singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
        [self addGestureRecognizer:singleTapOne];
        
    }
    return self;
}

-(void)setPageCount:(NSUInteger)pageCount1
{
    pageCount = pageCount1;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(item0:)||
        action == @selector(item1:)
        )
    {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleSingleGesture:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    
    if (CGRectContainsPoint(CGRectMake(self.bounds.size.width /3, 0, self.bounds.size.width/3, self.bounds.size.height), point    )) {
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
        }
    }
}


#pragma mark - ScrollView Delegate Method

-(void)addJSWithFileName:(NSString *)jsfileName withWebView:(UIWebView *)webview
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *bundlePath = [[NSBundle bundleForClass:[self class]].resourcePath
                                stringByAppendingPathComponent:@"BundleEpbuJS.bundle"];
        NSBundle * resource_bundle  = [NSBundle bundleWithPath:bundlePath];
        
        NSString *path = [resource_bundle pathForResource:@"BundleEpbuJS" ofType:@"bundle"];
        NSString *resourceFilePath = [path stringByAppendingPathComponent:@"Contents/Resources/epubjs"];
        
        
        
        NSString *filePath  = [resourceFilePath stringByAppendingPathComponent:jsfileName];
        NSData *fileData    = [NSData dataWithContentsOfFile:filePath];
        NSString *jsString  = [[NSMutableString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        [webview stringByEvaluatingJavaScriptFromString:jsString];
        
    });
    
    
    
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL result = TRUE;
    NSLog(@"jsbridge url is:%@",[request URL]);
    //获取数据，不执行跳转
    NSString* jsNotId = [self getJSNotificationId:[request URL]];
    if(jsNotId)
    {
        NSLog(@"jsNotId is:%@",jsNotId);
        // Reads the JSON object to be communicated.
        NSString* jsonStr = [webView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"JSBridge_getJsonStringForObjectWithId(%@)", jsNotId]];
        //        NSLog(@"jsonStr is:%@",jsonStr);
        
        SBJSON* jsonObj = [[SBJSON alloc] init];
        NSDictionary* jsonDic = [jsonObj objectWithString:jsonStr];
        NSDictionary* dicTranslated = [self translateDictionary:jsonDic];
        [self webView:webView didReceiveJSNotificationWithDictionary: dicTranslated];
        result = FALSE;
        
        return NO;
    }
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {

    }
    else
    {
        
    }
    return result;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"%s", __func__);
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.mainViewDelegate webviewFailLoad:self];
    NSLog(@"%s加载失败%@", __func__, error);
}

- (void)webView:(UIWebView*) webview didReceiveJSNotificationWithDictionary:(NSDictionary*) dictionary{
    
    
    NSString *type = dictionary[@"type"];
    if ([type isEqualToString:JS_NOTE_FLAGSTR]||[type isEqualToString:JS_PICTURE_FLAGSTR]) {//文本注释
        [self.mainViewDelegate showContentRefWithDIc:dictionary webView:self type:type];
    }
    else if([type isEqualToString:JS_HIGHLIGHTS_FLAGSTR]){
        [self saveHighLightsWithDic:dictionary];
    }
    else if([type isEqualToString:JS_SHOWNOTE_FLAGSTR]){
        [self showNoteWithDic:dictionary];
    }
    else if([type isEqualToString:js_TAP_FLAGSTR])
    {
        [self webViewDidTap:dictionary];
    }
    else if([type isEqualToString:JS_AUCHOR_FLAGSTR])
    {
        [self webviewTriggerAnchor:dictionary];
    }
    else if([type isEqualToString:JS_SHOWURL_FLAGSTR])
    {
        [self turnToUrlWithDic:dictionary];
    }
    
    return;
}
-(void)turnToUrlWithDic:(NSDictionary *)dic
{
    NSLog(@"Url is turned!!!!");
    NSString *founderNotesString = [dic objectForKey:@"content"];
    NSString *wholeString = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"decodeURIComponent('%@')",founderNotesString]];
    
    if([[wholeString substringToIndex:2] isEqualToString:@"ht"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:wholeString]];
    }
    else if([[wholeString substringToIndex:2] isEqualToString:@"fi"])
    {
        NSString *fileName = [wholeString lastPathComponent];
        [self.mainViewDelegate loadPageWithFileName:fileName];
        
        NSLog(@"file name is%@",fileName);
        
    }
}
-(void)webviewTriggerAnchor:(NSDictionary *)dictionary
{
    
    NSLog(@"anchor is turned!!!!");
    NSString *founderNotesString = [dictionary objectForKey:@"content"];
    NSString *wholeString = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"decodeURIComponent('%@')",founderNotesString]];
    NSDictionary *noteDic = wholeString.JSONValue;
    float positonX = ((NSNumber *)[noteDic objectForKey:@"left"]).floatValue;
    float positonY = ((NSNumber *)[noteDic objectForKey:@"top"]).floatValue;
    CGPoint point = CGPointMake(positonX, positonY);
    [self.mainViewDelegate setAnchorPostionWithoffset:point];
}

-(void)webViewDidTap:(NSDictionary *)dictionary
{
    NSLog(@"获取到了的menuVC的状态是%zd",[UIMenuController sharedMenuController].isMenuVisible);
    if ([UIMenuController sharedMenuController].isMenuVisible) {
        return;
    }
    
    NSString *founderNotesString = [dictionary objectForKey:@"content"];
    NSString *wholeString = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"decodeURIComponent('%@')",founderNotesString]];
    NSDictionary *noteDic = wholeString.JSONValue;
    float positonX = ((NSNumber *)[noteDic objectForKey:@"left"]).floatValue;
    float positonY = ((NSNumber *)[noteDic objectForKey:@"top"]).floatValue;
    if (self.flipType == EPUB_HOR_FLIP)
    {
        CGRect viewRect = self.bounds; // View bounds
        
        CGPoint point = CGPointMake(positonX, positonY); // Point
        
        
        CGRect nextPageRect = viewRect;
        CGRect prevPageRect = viewRect;
        if(viewRect.size.width > viewRect.size.height)
        {
//            nextPageRect.size.width = viewRect.size.width / 100 * 4;
//            nextPageRect.origin.x = (viewRect.size.width / 100) * 96;
//            prevPageRect.size.width = viewRect.size.width / 100 * 4;

            nextPageRect.size.width = viewRect.size.width / 3;
            nextPageRect.origin.x = viewRect.size.width / 3.0 *2.0;
            prevPageRect.size.width = viewRect.size.width / 3;
        }
        else
        {
//            nextPageRect.size.width = viewRect.size.width / 100 * 6;
//            nextPageRect.origin.x = (viewRect.size.width / 100) * 94;
//            prevPageRect.size.width = viewRect.size.width / 100 * 6;

            nextPageRect.size.width = viewRect.size.width / 3;
            nextPageRect.origin.x = viewRect.size.width / 3.0 *2.0;
            prevPageRect.size.width = viewRect.size.width / 3;
        }
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self.mainViewDelegate turnToNextPage];
            return;
        }
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self.mainViewDelegate turnToLastPage];
            return;
        }
    }
    if(lastTapDate != nil)
    {
        float timeInterVal = [[NSDate date]timeIntervalSinceDate:lastTapDate];
        if(timeInterVal < 0.6)
        {
            self.doubleTapGestureBlock();
            NSLog(@"double click!");
            self.lastTapDate = nil;
            return;
        }
        
    }
    
    if(![self.mainViewDelegate getNavBarHideState])
    {
        if (self.singleTapGestureBlock) {
            self.singleTapGestureBlock();
            NSLog(@"single click!");
            return;
        }
    }
    
    self.lastTapDate = [NSDate date];

}


-(void)showNoteWithDic:(NSDictionary *)dictionary
{
    NSString *founderNotesString = [dictionary objectForKey:@"content"];
    NSString *wholeString = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"decodeURIComponent('%@')",founderNotesString]];
    NSDictionary *noteDic = wholeString.JSONValue;
    
    float positonX = ((NSNumber *)[noteDic objectForKey:@"left"]).floatValue;
    float positonY = ((NSNumber *)[noteDic objectForKey:@"top"]).floatValue;
    
    EpubNoteListObject *noteObject = [[EpubNoteListObject alloc]init];
    noteObject.noteIndex = ((NSNumber *)[noteDic objectForKey:@"index"]).integerValue;
    noteObject.startWordIndex = ((NSNumber *)[noteDic objectForKey:@"htStartIndex"]).integerValue;
    noteObject.postion =  CGPointMake(positonX, positonY);
    noteObject.date = [NSDate dateWithTimeIntervalSince1970:((NSString*)[noteDic objectForKey:@"createtime"]).doubleValue/1000];
    noteObject.noteColor = [self.mainViewDelegate getColorWithColorString:[noteDic objectForKey:@"cls"]];
    noteObject.modifyNoteType = [noteDic objectForKey:@"modifyNoteType"];
    noteObject.noteSize = CGSizeMake(((NSNumber *)[noteDic objectForKey:@"width"]).integerValue,((NSNumber *)[noteDic objectForKey:@"height"]).integerValue);
    
    NSMutableString *highlightString =  [[noteDic objectForKey:@"htContent"] mutableCopy];
    //    [highlightString replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, highlightString.length)];
    //    [highlightString replaceOccurrencesOfString:@"\t" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, highlightString.length)];
    noteObject.highlightText = highlightString;
    
    
    NSMutableString *partString =  [[noteDic objectForKey:@"htParContent"] mutableCopy];
    //    [partString replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, partString.length)];
    //    [partString replaceOccurrencesOfString:@"\t" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, partString.length)];
    noteObject.partText = partString;
    
    
    noteObject.noteContent = [noteDic objectForKey:@"mark"];
    //    EpubNoteListObject *noteObject = [[EpubNoteListObject alloc]init];
    //    noteObject.postion = CGPointMake(400, 400);
    //
    //    noteObject.partText =@"\n    The book you’re reading is in beta. This means that we update it\n    frequently. This chapter lists the major changes that have been\n    made at each beta release of the book, with the most recent change\n    first.\n  1";
    //    noteObject.noteColor = [UIColor greenColor];
    //    noteObject.startWordIndex = 155;
    //    noteObject.highlightText = @"beta release of the";
    
    
    [self.mainViewDelegate showNoteWithNote:noteObject webView:self];
}

-(void)saveHighLightsWithDic:(NSDictionary*)dictionary
{
    [self.mainViewDelegate saveHighLightsWithDic:dictionary chapterIndex:chapterIndex];
    if(functionFlag == COUNT_PAGE_FLAG)
    {
        [self.mainViewDelegate saveFinished:self];
    }
}



-(void)loadHighlightAndNoteOnWebView
{

    NSString *noteString = [self.mainViewDelegate getNoteStringWithChapterIndex:chapterIndex];
        if(noteString)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"loadHighLightAndNote('%@');",noteString]];
            });
        }
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        [self addJSWithFileName:@"rangy-core.js" withWebView:webView];
        [self addJSWithFileName:@"rangy-textrange.js" withWebView:webView];
        [self addJSWithFileName:@"rangy-cssclassapplier.js" withWebView:webView];
        [self addJSWithFileName:@"rangy-highlighter.js" withWebView:webView];
        [self addJSWithFileName:@"epub-JSBridge.js" withWebView:webView];
        [self addJSWithFileName:@"jquery-2.1.1.js" withWebView:webView];
        [self addJSWithFileName:@"jquery.mobile-1.4.5.js" withWebView:webView];
        [self addJSWithFileName:@"founderEpub.js" withWebView:webView];//能耗最大
        
        [self loadAndSetFontAndBgColor];
        [self loadHighlightAndNoteOnWebView];
     dispatch_async(dispatch_get_main_queue(), ^{
        int totolLengh;
        int singlePageLengh;
       
            NSString *size = [webView stringByEvaluatingJavaScriptFromString:@"getPageSize()"];
       
        
        NSDictionary *dic = size.JSONValue;
        if(flipType == EPUB_NOR_FLIP)
        {
            totolLengh = ((NSNumber *)[dic objectForKey:@"height"]).intValue;;
            singlePageLengh = viewSize.height;
        }
        else
        {
            totolLengh = self.scrollView.contentSize.width;
            //        totolLengh = ((NSNumber *)[dic objectForKey:@"width"]).intValue;;
            singlePageLengh = viewSize.width;
        }
        pageCount = (int)((float)totolLengh/singlePageLengh);
        if(singlePageLengh*pageCount < totolLengh)
        {
            pageCount ++;
        }
        
        if(flipType == EPUB_NOR_FLIP)
        {
            if (self.chapterSize.width==0 &&self.chapterSize.height==0) {
                self.chapterSize = CGSizeMake(viewSize.width, pageCount * singlePageLengh);
            }
            
        }
        else
        {
            if (self.chapterSize.width==0 &&self.chapterSize.height==0) {
                self.chapterSize = CGSizeMake(pageCount * singlePageLengh,viewSize.height);
            }
            
        }
         });
        if(flipType == EPUB_HOR_FLIP)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(viewSize.width > viewSize.height){
                    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setBodyH(%f)",viewSize.height*pageCount*2]];
                }
                else{
                    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setBodyH(%f)",viewSize.height*pageCount]];
                }
            });
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainViewDelegate webviewFinishLoad:self];
        });
        
        
        //    if(chapterSize.height > 0)
        //    {
        //        webView.scrollView.contentSize = chapterSize;
        //    }
        
    });
    
}

-(void)loadAndSetFontAndBgColor
{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSDictionary *dic = [self.mainViewDelegate getEpubSetting];
    float fontValue =[dic[@"kEpubFont"] floatValue];
    NSString *sizeString = [NSString stringWithFormat:@"setFontSize('%f');",fontValue];
    NSLog(@"sizeString is:%@",sizeString);
    
    [self stringByEvaluatingJavaScriptFromString:sizeString];

    NSInteger fontColor =[dic[@"kEpubBgColor"] integerValue];
    NSString *color = [self cssBgColor:(EPUP_BG_COLOR)fontColor];
    NSString *jsString = [NSString stringWithFormat:@"setBgColor('%@');",color];
    [self stringByEvaluatingJavaScriptFromString:jsString];
    NSInteger margin = [dic[@"kEpubMargin"] integerValue];
    [self setMarginMode:(EPUB_MARGIN)(margin)];
        
    });
}



-(UIColor *)getColorWithColorString:(NSString *)colorString
{
    NSArray *colorArray = [colorString componentsSeparatedByString:@" "];
    if(colorArray.count == 2)
    {
        NSString *colorIdenti = [colorArray objectAtIndex:1];
        return [self getColorWithIdenti:colorIdenti];
    }
    else if(colorArray.count == 1)
    {
        NSString *colorIdenti = [colorArray objectAtIndex:0];
        return [self getColorWithIdenti:colorIdenti];
    }
    else
    {
        return [UIColor greenColor];
    }
}

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

-(void)setMarginMode:(EPUB_MARGIN)mode
{
    NSString *margin = @"1";
    switch (mode) {
        case epub_margin_default:
            margin = @"1";
            break;
        case epub_margin_two:
            margin = @"1.8";
            break;
        case epub_margin_three:
            margin = @"1.5";
            break;
        case epub_margin_four:
            margin = @"1.2";
            break;
            
        default:
            break;
    }
    NSString *jsString = [NSString stringWithFormat:@"setLineHeight('%@');",margin];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stringByEvaluatingJavaScriptFromString:jsString];
    });
    
}
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView{
    return nil;
}

-(UIColor *)getColorWithIdenti:(NSString *)colorString
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *rgbColor = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getHTbg('%@')",colorString]];
        
        return [EPUBUtils colorWithRGBHexString:rgbColor];
//    });
}


@end
