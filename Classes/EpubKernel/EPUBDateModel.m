//
//  EPUBDateModel.m
//  E-Publishing
//
//  Created by tangsl on 15/4/3.
//
//

#import "EPUBDateModel.h"
#import "EpubChapter.h"
#import "JSON.h"
#import "Catalog.h"
#import "UserInfo.h"
#import "UserState.h"
#import "EpubStaticDefine.h"
#import "StatisticsManager.h"
#import "TeaRecord.h"

#import "EPUBUtils.h"
#import "SearchResultObject.h"
#import "EpubListObject.h"
#import "EpubMarkObject.h"
#import "EpubNoteListObject.h"


@implementation EPUBDateModel

@synthesize chapterArray;
@synthesize listArray;
@synthesize markArray;
@synthesize pagenatingChapterArray;
@synthesize isSearch;
@synthesize pagenatingChapterIndexArray;

//extern BOOL isEncrypt;
extern UserInfo *userInfo;

-(id)init
{
    

    self = [super init];
    if(self)
    {
        pagenatingChapterArray = [[NSMutableArray alloc]init];
        pagenatingChapterIndexArray = [[NSMutableArray alloc]init];
    }
    return self;
}







#pragma mark  EpubChapterProtocol
- (void) chapterDidFinishLoad:(EpubChapter *)tempChapter
{
    if(stopPageing)
    {
        return;
    }
    if(tempChapter.isUpdateNoteAndMark)
    {
        [self noteAndMarkChapterDidFinishLoad:tempChapter];
        return;
    }
    if(tempChapter.chapterIndex > lastCountPageIndex)
    {
        if(tempChapter.chapterIndex > lastCountPageIndex +1)
        {
            return;
        }
        lastCountPageIndex = tempChapter.chapterIndex;
    }
    
    if(tempChapter.chapterIndex + 1 < [chapterArray count]){
        [self.epubDelegate setPagenatingProcessView:((float)tempChapter.chapterIndex)/(float)chapterArray.count];
//        EpubChapter *loadedChapter = [self getChapterFormLoadedArray:tempChapter.chapterIndex+1];
        EpubChapter *chapter =  [chapterArray objectAtIndex:tempChapter.chapterIndex+1];
        
        if ([self.epubDelegate canNotContinueUpdate]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                while ([self.epubDelegate canNotContinueUpdate]) {
                    sleep(0.5);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self chapterDidFinishLoad:tempChapter];
                });
            });
            return;
        }
//        暂时先不去已经load的网页去读取大小
//        if(loadedChapter)
//        {
//            chapter.contentSize = loadedChapter.contentSize;
//            chapter.pageCount = loadedChapter.pageCount;
//            chapter.self.epubDelegate = self;
//            [self chapterDidFinishLoad:chapter];
//            return;
//        }
        
        chapter.epubDelegate = self;
        [chapter loadChapterWithWindowSize:CGSizeMake([self.epubDelegate getViewwidth], [self.epubDelegate getViewHeight])];
    }
    else {
        lastCountPageIndex = 0;
        [self.epubDelegate finishUpdateChapterArray];
        
    }
}
- (void) chapterDIdFinishSearch:(EpubChapter *)tchapter lastResult:(NSString*)result key:(NSString *)sKey
{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSDictionary *resultDic = [result JSONValue];
    
    NSArray*keyArray =  resultDic.allKeys;
    
    for (NSInteger i = 0; i < keyArray.count; i++) {
        NSDictionary *resultObjectDic = [resultDic objectForKey:[keyArray objectAtIndex:i]];
        
        SearchResultObject*searchObject = [[SearchResultObject alloc]init];
        searchObject.text = [resultObjectDic objectForKey:@"text"];
        searchObject.left = ((NSString *)[resultObjectDic objectForKey:@"left"]).floatValue;
        searchObject.top  = ((NSString *)[resultObjectDic objectForKey:@"top"]).floatValue;
        searchObject.startIndex = ((NSString *)[resultObjectDic objectForKey:@"startIndex"]).intValue;
        searchObject.chapterIndex = tchapter.chapterIndex;
        if([[self.epubDelegate getFlipTypeAndOren] isEqualToString:LANDSCAPE_NORFLIP] || [[self.epubDelegate getFlipTypeAndOren] isEqualToString:PORTRAIT_NORFLIP])
            searchObject.pageNum = [self getPageCountWithChapterIndex:tchapter.chapterIndex pageindex:searchObject.top/[self.epubDelegate getViewHeight]+1];
        else
            searchObject.pageNum = [self getPageCountWithChapterIndex:tchapter.chapterIndex pageindex:searchObject.left/[self.epubDelegate getViewwidth]+1];
        
        
        //NSLog(@"result object is%@",resultObjectDic);
        [resultArray addObject:searchObject];
        
    }
    
    if(resultArray.count > 0)
    {
        NSArray *sortArray = [resultArray sortedArrayUsingSelector:@selector(compare:)];
        [self.epubDelegate addResultsObject:sortArray key:sKey];
        if(!result)
        {
            
            return;
        }
    }
    
    
    //继续搜索下一章的内容
    if(chapterArray.count > tchapter.chapterIndex+1 && isSearch)
    {
        EpubChapter *chapter = [chapterArray objectAtIndex:tchapter.chapterIndex+1];
        chapter.epubDelegate = self;
        
        [chapter searchChapterWithWindowSize:CGSizeMake([self.epubDelegate getViewwidth], [self.epubDelegate getViewHeight]) Key:tchapter.searchKey];
    }
    else
    {
        isSearch = NO;
        [self.epubDelegate showResultAlert];
    }
}



-(NSString *)getFlipTypeAndOren
{
    return [self.epubDelegate getFlipTypeAndOren];
}

-(UIView *)getMainView
{
    return [self.epubDelegate getMainView];
}
-(BOOL)updateNoteWithWebView:(EpubWebView *)webView
{
    NSDictionary *recordInfoDic = [[StatisticsManager sharedStatisticsManager]getCurPageBookRecordWithType:ReadingEpubNote page:webView.chapterIndex];
    if(recordInfoDic)
    {
        [webView stringByEvaluatingJavaScriptFromString:@"sendNotes()"];
        return YES;
    }
    return NO;
}

#pragma mark  EpubSearchProtocal

- (void)searchEpubWithKey:(NSString *)keys
{
    if(chapterArray.count > 1)
    {
        isSearch = YES;
        [self.epubDelegate showSearchHud];
        EpubChapter *chapter = [chapterArray objectAtIndex:1];
        chapter.epubDelegate = self;
        
        [chapter searchChapterWithWindowSize:CGSizeMake([self.epubDelegate getViewwidth], [self.epubDelegate getViewHeight]) Key:keys];
    }
    
    
}
-(void)showSearchWithTotalPage:(NSInteger)pageNum key:(NSString *)key position:(CGPoint)positon
{
    isSearch = NO;
    [self.epubDelegate showSearchWithTotalPage:pageNum key:key position:positon];
}


#pragma mark  删除数据相关代码
-(void)deleteOtherOrientationInfo
{
    NSDictionary *epubInfodic = [Catalog getReadingInfo];
    NSMutableDictionary *epubDic = epubInfodic[userInfo.userState.textbookID];
    if (!epubDic) {
        epubDic = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    [epubDic removeObjectForKey:LANDSCAPE_HORFLIP];
    [epubDic removeObjectForKey:LANDSCAPE_NORFLIP];
    [epubDic removeObjectForKey:PORTRAIT_HORFLIP];
    [epubDic removeObjectForKey:PORTRAIT_NORFLIP];
    [Catalog saveReadingInfo:epubDic withKey:userInfo.userState.textbookID];
    [Catalog deleteReadingInfoWithKey:userInfo.userState.textbookID];
    
}
-(void)deleteBookMarkWithID:(NSString *)recordID
{
    [[StatisticsManager sharedStatisticsManager]deleteReadingReocrdWithID:recordID withType:ReadingPageBookmark];
}

#pragma mark  整理数据相关代码
//根据总页码 得到总页码对应的chapterindex 和pageindex
-(NSArray *)getChapterIndexAndPageindexWithPageNum:(NSInteger)pageNum
{
    NSInteger pageIndex = 0;
    NSInteger chapterIndex = 0;
    NSInteger tempPage = 0;
    for (NSInteger i = 1; i < chapterArray.count; i++) {
        EpubChapter *chapter = [chapterArray objectAtIndex:i];
        tempPage+=chapter.pageCount;
        if(tempPage >= pageNum)
        {
            chapterIndex = i;
            break;
        }
    }
    if(chapterIndex != 0)
    {
        EpubChapter *nowChapter = [chapterArray objectAtIndex:chapterIndex];
        pageIndex = nowChapter.pageCount+pageNum-tempPage;
    }
    if(chapterIndex <= 0)
    {
        chapterIndex = 1;
    }
    if(pageIndex<=0)
    {
        pageIndex = 1;
    }
    return @[@(chapterIndex),@(pageIndex)];
}
//根据chapterindex 获取title
-(NSString*)getTitleWithChapterIndex:(NSInteger)chapterIndex
{
    NSString *title = nil;
    for (NSInteger  i = 0; i < listArray.count; i++) {
        EpubListObject *listObject = [listArray objectAtIndex:i];
        if(listObject.chapterIndex == chapterIndex)
        {
            title = listObject.listName;
            break;
        }
    }
    
    return title;
}
//设置Offset 并计算总页码
-(NSInteger)generateChapterPositonAndGetTotolCount
{
    NSInteger totalPageCount = 0;
    float offset = 0;
    for (NSInteger i = 1; i < chapterArray.count; i++) {
        EpubChapter *epubChapter = [chapterArray objectAtIndex:i];
        epubChapter.offset = [self.epubDelegate setPointWithOrigin:offset];
        offset+=epubChapter.pageCount*[self.epubDelegate getPerPageLength];
        totalPageCount+=epubChapter.pageCount;
    }
    
    return totalPageCount;
}
//根据chapterindex 和pageindex 获取当前页对应的总页码
-(NSInteger)getPageCountWithChapterIndex:(NSInteger)chapterIndex pageindex:(NSInteger)pageIndex
{
    NSInteger pageCount = 0;
    //获取前些章节的每章的页数 并且累加 章节从1开始计数
    for(NSInteger i=1; i<chapterIndex; i++){
        pageCount+= [[chapterArray objectAtIndex:i] pageCount];
    }
    //获取当前章的当前页  当前页从1开始计数 还不是0
    pageCount+=pageIndex;
    return pageCount;
}
//从已经加载完成的数组里面查找是否有已经计算好的页码的
-(EpubChapter*)getChapterFormLoadedArray:(NSInteger)index
{
    for (NSInteger i = 0; i < pagenatingChapterArray.count; i++) {
        EpubChapter *chapter = [pagenatingChapterArray objectAtIndex:i];
        if(chapter.chapterIndex == index)
        {
            return chapter;
        }
    }
    
    return nil;
}
//根据文件名称 获取对应的chapterindex
-(NSInteger)getChapterIndexWithFileName:(NSString *)fileName
{
    NSInteger chapterIndex = 0;
    for (NSInteger i = 0; i < chapterArray.count; i++) {
        EpubChapter *chapter = [chapterArray objectAtIndex:i];
        if([chapter.chapterFileName.lastPathComponent isEqualToString:fileName])
        {
            chapterIndex = i;
        }
    }
    return chapterIndex;
}

//更新chapterarray的成员内容
-(void)updateChapterArray
{
    lastCountPageIndex = 0;
    EpubChapter *chapter =[chapterArray objectAtIndex:1];
    chapter.epubDelegate = self;
    [chapter loadChapterWithWindowSize:CGSizeMake([self.epubDelegate getViewwidth],[self.epubDelegate getViewHeight])];
}

-(void)updateNoteAndMarkChangedChapter
{
    BOOL searchResult = [self searchNeedUpdateChapter];
    if(searchResult)
    {
        noteAndMarkLastCountIndex = 0;
        EpubChapter *chapter =[chapterArray objectAtIndex:[[pagenatingChapterIndexArray objectAtIndex:0] integerValue]];
        chapter.epubDelegate = self;
        chapter.isUpdateNoteAndMark = YES;
        [chapter loadChapterWithWindowSize:CGSizeMake([self.epubDelegate getViewwidth],[self.epubDelegate getViewHeight])];
    }
}

-(BOOL)searchNeedUpdateChapter
{
    [pagenatingChapterIndexArray removeAllObjects];
    for (int i = 0; i < markArray.count; i++) {
        EpubMarkObject *bookMarkObject = [markArray objectAtIndex:i];
        if(![bookMarkObject.pageNumDic objectForKey:[self.epubDelegate getFlipTypeAndOren]])
        {
            [pagenatingChapterIndexArray addObject:@(bookMarkObject.chapterIndex)];
        }
        
    }
    NSArray *noteArray = [self getNoteListArray];
    for (int i = 0; i < noteArray.count; i++) {
        EpubNoteListObject *noteObject = [noteArray objectAtIndex:i];
        if(![noteObject.positionDic objectForKey:[self.epubDelegate getFlipTypeAndOren]])
        {
            for (int j = 0; j < pagenatingChapterIndexArray.count; j++) {
                NSNumber *number = [pagenatingChapterIndexArray objectAtIndex:j];
                if([number integerValue] == noteObject.chapterIndex)
                {
                    continue;
                }
            }
            
            [pagenatingChapterIndexArray addObject:@(noteObject.chapterIndex)];
        }
    }
    [pagenatingChapterIndexArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSComparisonResult result = [obj1 compare:obj2];
        
        return result == NSOrderedDescending;
        
    }];
    
    if(pagenatingChapterIndexArray.count == 0)
        return NO;
    
    return YES;
}

//根据index 获取制定epubchapter
-(EpubChapter *)getChapterWithIndex:(NSInteger)chapterIndex
{
    if(chapterIndex<chapterArray.count && chapterIndex>0)
    {
        return [chapterArray objectAtIndex:chapterIndex];
    }
    else
    {
        return nil;
    }
}

- (void) noteAndMarkChapterDidFinishLoad:(EpubChapter *)tempChapter
{
    if ([self.epubDelegate canNotContinueUpdate]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while ([self.epubDelegate canNotContinueUpdate]) {
                sleep(0.5);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self noteAndMarkChapterDidFinishLoad:tempChapter];
            });
        });
        return;
    }
    tempChapter.isUpdateNoteAndMark = NO;
    
    if(pagenatingChapterIndexArray.count <=noteAndMarkLastCountIndex || tempChapter.chapterIndex != [[pagenatingChapterIndexArray objectAtIndex:noteAndMarkLastCountIndex] integerValue])
    {
        
        return;
    }
    
    if(noteAndMarkLastCountIndex+1 < pagenatingChapterIndexArray.count){
        
        
        
        
        noteAndMarkLastCountIndex++;
        EpubChapter *chapter =  [chapterArray objectAtIndex:[[pagenatingChapterIndexArray objectAtIndex:noteAndMarkLastCountIndex] integerValue]];
        
        chapter.epubDelegate = self;
        chapter.isUpdateNoteAndMark = YES;
        [chapter loadChapterWithWindowSize:CGSizeMake([self.epubDelegate getViewwidth], [self.epubDelegate getViewHeight])];
    }
    else {
        noteAndMarkLastCountIndex = 0;
        
    }
}
- (void) cancelCountPage
{
    lastCountPageIndex = 0;
}


#pragma mark  保存数据相关代码
//保存页码信息
-(void)savePageingInfo
{
    NSMutableArray *chapterPosArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1; i < chapterArray.count; i++) {
        EpubChapter *chapter = [chapterArray objectAtIndex:i];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        [tempArray addObject:[NSNumber numberWithFloat:[self.epubDelegate getLengthWithPoint:chapter.offset]]];
        [tempArray addObject:[NSNumber numberWithFloat:[self.epubDelegate getLengthWithSize:chapter.contentSize]]];
        [tempArray addObject:[NSNumber numberWithInteger:chapter.pageCount]];
        [chapterPosArray addObject:tempArray];
        
    }
    SBJSON *jsonPara = [[SBJSON alloc]init];
    
    NSString *metaString = [jsonPara stringWithObject:chapterPosArray];
    
    
    
    NSDictionary *settingDic = [Catalog getEpubSetting];
    NSDictionary *epubInfodic = [Catalog getReadingInfo];
    NSMutableDictionary *epubDic = epubInfodic[userInfo.userState.textbookID];
    if (!epubDic) {
        epubDic = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    NSDictionary *infoDic = @{@"array":metaString,@"font":settingDic[@"kEpubFont"],@"margin":settingDic[@"kEpubMargin"]};
    if([self.epubDelegate getViewHeight] >[self.epubDelegate getViewwidth])
    {
        [epubDic setObject:infoDic forKey:[self getFlipTypeAndOren]];
    }
    else
    {
        [epubDic setObject:infoDic forKey:[self getFlipTypeAndOren]];
        
    }
    [Catalog saveReadingInfo:epubDic withKey:userInfo.userState.textbookID];
}

-(void)setUserInfoPageNum:(NSInteger)pageNum
{
    userInfo.userState.pageNum = pageNum;
}
//保存阅读进度
-(BOOL)saveReadingInfo:(NSDictionary *)info
{
    
//    NSDictionary *dic = [Catalog getReadingInfo];
//    NSMutableDictionary *epubDic = dic[userInfo.userState.textbookID];
//    if (!epubDic) {
//        epubDic = [NSMutableDictionary dictionaryWithCapacity:10];
//    }
//    [epubDic setObject:info[@"page"] forKey:@"page"];
//    [epubDic setObject:info[@"chapter"] forKey:@"chapter"];
//    [epubDic setObject:info[@"readprocess"] forKey:@"readprocess"];
//    return [Catalog saveReadingInfo:epubDic withKey:userInfo.userState.textbookID];
    
    NSDictionary *readingDic = @{@"readprocess":info[@"readprocess"],@"chapter":info[@"chapter"],@"page":info[@"page"]};
    
    return [[StatisticsManager sharedStatisticsManager]saveProcessInfoWithDic:readingDic bookId:userInfo.userState.textbookID];
}

//保存书签
-(void)saveBookMarkWithMarkObject:(EpubMarkObject *)bookMarkObject;
{
    NSDictionary *recordInfoDic = [[StatisticsManager sharedStatisticsManager]getRecordInfoWithType:ReadingPageBookmark];
    
    NSString *title = nil;
    for (NSInteger  i = 0; i < listArray.count; i++) {
        EpubListObject *listObject = [listArray objectAtIndex:i];
        if(listObject.chapterIndex == bookMarkObject.chapterIndex)
        {
            title = listObject.listName;
            break;
        }
    }
    
    if(!title)
    {
        title = @"";
    }
    
    bookMarkObject.title = title;
    NSString *name = [NSString stringWithFormat:@"%@",title];
    NSString *recordID = [recordInfoDic objectForKey:@"recordID"];
    bookMarkObject.markId = recordID;
    bookMarkObject.bookPageNum = [self getPageCountWithChapterIndex:bookMarkObject.chapterIndex pageindex:bookMarkObject.pageNum];
    NSDictionary *readingDic = @{@"recordID":recordID,@"type":[NSNumber numberWithInteger:ReadingPageBookmark],@"name":name,@"meta":@{@"pageNumDic":bookMarkObject.pageNumDic,@"markJsIndex":bookMarkObject.markJsIndex,@"content":bookMarkObject.content}};
    [[StatisticsManager sharedStatisticsManager]saveReadingRecord:readingDic pagenum:bookMarkObject.chapterIndex];
    [markArray addObject:bookMarkObject];
    
}
//保存高亮
-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index
{
    NSString *founderNotesString = [dictionary objectForKey:@"content"];
    NSDictionary *recordInfoDic = [[StatisticsManager sharedStatisticsManager]getCurPageBookRecordWithType:ReadingEpubNote page:index];
    if(recordInfoDic == nil)
    {
        recordInfoDic =[[StatisticsManager sharedStatisticsManager]getRecordInfoWithType:ReadingEpubNote];
    }
    
    NSString *name = [NSString stringWithFormat:@"第%ld页",(long)index];
    
    NSString *recordID = [recordInfoDic objectForKey:@"recordID"];
    NSDictionary *readingDic = @{@"recordID":recordID,@"type":[NSNumber numberWithInteger:ReadingEpubNote],@"name":name};
    [[StatisticsManager sharedStatisticsManager]saveReadingRecord:readingDic pagenum:index];
    NSDictionary *pathInfo = [[StatisticsManager sharedStatisticsManager]getRecordInfoWithRecordID:recordID withReadingType:ReadingEpubNote];
    
    NSString *folderPath = [pathInfo objectForKey:@"filePath"];
    if(founderNotesString)
    {
        NSString * filepath = [folderPath stringByAppendingPathComponent:EPUB_NOTE];
        [founderNotesString writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    
    [self saveHighLightWithString:founderNotesString folderPath:folderPath recordid:recordID];
    

}
-(void)saveHighLightWithString:(NSString *)highLightString folderPath:(NSString *)folderPath recordid:(NSString *)recordID
{
    EpubWebView *tempWebView = [[EpubWebView alloc]init];
    NSString *wholeString = [tempWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"decodeURIComponent('%@')",highLightString]];
    NSDictionary *wholeDic = wholeString.JSONValue;
    NSString *noteStringPre = [wholeDic objectForKey:@"founderNotes"];
    NSString *noteString = [tempWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"decodeURIComponent('%@')",noteStringPre]];
    
    
    NSDictionary *pageNoteDic = [noteString JSONValue];
    if(pageNoteDic.count == 0)
    {
        [[StatisticsManager sharedStatisticsManager]deleteReadingReocrdWithID:recordID withType:ReadingEpubNote];
        return;
    }
    NSMutableArray *preNoteArray = [[NSMutableArray alloc]init];
    NSMutableArray *noteArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < pageNoteDic.allKeys.count; i++) {
        NSDictionary *noteDic = [pageNoteDic objectForKey:[pageNoteDic.allKeys objectAtIndex:i]];
        float positonX = ((NSNumber *)[noteDic objectForKey:@"left"]).floatValue;
        float positonY = ((NSNumber *)[noteDic objectForKey:@"top"]).floatValue;
        
        EpubNoteListObject *noteObject = [[EpubNoteListObject alloc]init];
        noteObject.noteIndex = ((NSNumber *)[noteDic objectForKey:@"index"]).integerValue;
        noteObject.startWordIndex = ((NSNumber *)[noteDic objectForKey:@"htStartIndex"]).integerValue;
        noteObject.postion =  CGPointMake(positonX, positonY);
        noteObject.date = [NSDate dateWithTimeIntervalSince1970:((NSString*)[noteDic objectForKey:@"createtime"]).doubleValue/1000];
        noteObject.noteColor = [self getColorWithColorString:[noteDic objectForKey:@"cls"]];
        
        NSMutableString *highlightString =  [[noteDic objectForKey:@"htContent"] mutableCopy];
        noteObject.highlightText = highlightString;
        
        
        NSMutableString *partString =  [[noteDic objectForKey:@"htParContent"] mutableCopy];
        noteObject.partText = partString;
        
        
        noteObject.noteContent = [noteDic objectForKey:@"mark"];
        //        noteObject.pageNum = [self getPageCountWithChapterIndex:record.pageNum pageindex:positonY/[epubDelegate getViewHeight]+1];
        [preNoteArray addObject:noteObject];
        
    }
    NSArray *newArray = [preNoteArray sortedArrayUsingSelector:@selector(compare:)];
    EpubNoteListObject *tempObject = nil;
    for (NSInteger i = 0 ; i < newArray.count; i++) {
        EpubNoteListObject *noteObject = [newArray objectAtIndex:i];
        if(i == 0)
        {
            tempObject = noteObject;
        }
        else
        {
            if([tempObject.date isEqualToDate:noteObject.date])
            {
                NSInteger length = tempObject.highlightText.length + noteObject.highlightText.length;
                if(tempObject.startWordIndex+length > tempObject.partText.length)
                {
                    length = tempObject.partText.length - tempObject.startWordIndex;
                }
                tempObject.highlightText = [tempObject.partText substringWithRange:NSMakeRange(tempObject.startWordIndex, length)];
                if(noteObject.noteContent)
                {
                    tempObject.noteContent = noteObject.noteContent;
                }
            }
            else
            {
                [noteArray addObject:tempObject];
                tempObject = noteObject;
            }
        }
        if(i == newArray.count-1)
        {
            [noteArray addObject:tempObject];
        }
    }
    
    NSString *lastDataString = [NSString stringWithContentsOfFile:[folderPath stringByAppendingPathComponent:EPUB_NOTE_DETAIL] encoding:NSUTF8StringEncoding error:nil];
    NSArray *lastNoteDicArray = lastDataString.JSONValue;
    NSMutableArray *lasetNoteArray = [[NSMutableArray alloc]init];
    for(int i = 0;i < lastNoteDicArray.count ;i++)
    {
        NSDictionary *noteDic = [lastNoteDicArray objectAtIndex:i];
        
        EpubNoteListObject *noteObject = [[EpubNoteListObject alloc]init];
        [noteObject setNoteWithDic:noteDic];
        [lasetNoteArray addObject:noteObject];
        
    }
    
    NSMutableArray *finalSaveArray = [[NSMutableArray alloc]init];
    for(int i = 0; i < noteArray.count ;i++)
    {
        EpubNoteListObject *noteOBject = [noteArray objectAtIndex:i];
        for (int j = 0; j < lasetNoteArray.count; j++) {
            EpubNoteListObject *lastNoteObject = [lasetNoteArray objectAtIndex:j];
            if((int)[noteOBject.date timeIntervalSince1970]== (int)[lastNoteObject.date timeIntervalSince1970])
            {
                noteOBject.positionDic = [lastNoteObject.positionDic mutableCopy];
                
            }
        }
        [noteOBject.positionDic setObject:@{@"left":@(noteOBject.postion.x),@"top":@(noteOBject.postion.y)} forKey:[self getFlipTypeAndOren]];
        [finalSaveArray addObject:[noteOBject serializeToDic]];
    }
    //noteContent
    SBJSON *jsonPara = [[SBJSON alloc]init];
    NSString *saveString = [jsonPara stringWithObject:finalSaveArray];
    [saveString writeToFile:[folderPath stringByAppendingPathComponent:EPUB_NOTE_DETAIL] atomically:YES encoding:NSUTF8StringEncoding error:nil];
  
}

-(void)updateBookMarkObjcet:(EpubMarkObject *)bookMarkObject;
{
    bookMarkObject.bookPageNum = [self getPageCountWithChapterIndex:bookMarkObject.chapterIndex pageindex:bookMarkObject.pageNum];
    NSDictionary *readingDic = @{@"recordID":bookMarkObject.markId,@"type":[NSNumber numberWithInteger:ReadingPageBookmark],@"name":bookMarkObject.title,@"meta":@{@"pageNumDic":bookMarkObject.pageNumDic,@"markJsIndex":bookMarkObject.markJsIndex,@"content":bookMarkObject.content}};
    [[StatisticsManager sharedStatisticsManager]saveReadingRecord:readingDic pagenum:bookMarkObject.chapterIndex];
}

#pragma mark  读取数据相关代码
//得到笔记
-(NSArray *)getNoteListArray
{
    NSMutableArray *noteArray = [[NSMutableArray alloc]init];
    NSArray *bookRecordArray = [[StatisticsManager sharedStatisticsManager]getCurBookRecordArrayWithType:ReadingEpubNote];
    if(bookRecordArray.count >0)
    {
        
        for (NSInteger i = 0; i < bookRecordArray.count; i++) {
            TeaRecord *record = [bookRecordArray objectAtIndex:i];
            NSString *recordID = record.ID;
            NSDictionary *pathInfo = [[StatisticsManager sharedStatisticsManager]getRecordInfoWithRecordID:recordID withReadingType:ReadingEpubNote];
            NSString *folderPath = [pathInfo objectForKey:@"filePath"];
            NSString *notePath = [folderPath stringByAppendingPathComponent:EPUB_NOTE_DETAIL];
            NSString *wholeStringPre = [NSString stringWithContentsOfFile:notePath encoding:NSUTF8StringEncoding error:nil];
            NSArray *lastNoteDicArray = wholeStringPre.JSONValue;
            for(int i = 0;i < lastNoteDicArray.count ;i++)
            {
                NSDictionary *noteDic = [lastNoteDicArray objectAtIndex:i];
                
                EpubNoteListObject *noteObject = [[EpubNoteListObject alloc]init];
                [noteObject setNoteWithDic:noteDic];
                NSDictionary *dic = [noteObject.positionDic objectForKey:[self.epubDelegate getFlipTypeAndOren]];
                noteObject.postion = CGPointMake([[dic objectForKey:@"left"] floatValue], [[dic objectForKey:@"top"] floatValue]);
                noteObject.pageNum = [self getPageCountWithChapterIndex:record.pageNum pageindex:[self.epubDelegate getLengthWithPoint:noteObject.postion]/[self.epubDelegate getPerPageLength]+1];
                noteObject.chapterIndex = record.pageNum;
                [noteArray addObject:noteObject];
                
            }
            
            
        }
    }
    return noteArray;
    
}
//得到所有的书签
-(void)getAllBookMarkWithPagedState:(BOOL)pagedState
{
    if(markArray)
    {
        
        markArray = nil;
    }
    NSArray* recordArray =  [[StatisticsManager sharedStatisticsManager]getCurBookRecordArrayWithType:ReadingPageBookmark];
    markArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < recordArray.count; i++) {
        TeaRecord *record = [recordArray objectAtIndex:i];
        NSDictionary *metaDic = record.meta.JSONValue;
        EpubMarkObject *markObject = [[EpubMarkObject alloc]init];
        markObject.markId = record.ID;
        markObject.chapterIndex = record.pageNum;
        markObject.pageNumDic = [metaDic objectForKey:@"pageNumDic"];
        markObject.title = record.name;
        markObject.date = record.timeCreated;
        markObject.markJsIndex = [metaDic objectForKey:@"markJsIndex"];
        markObject.content = [metaDic objectForKey:@"content"];
        markObject.pageNum = ((NSNumber*)[markObject.pageNumDic objectForKey:[self.epubDelegate getFlipTypeAndOren]]).integerValue;
        if(pagedState)
            markObject.bookPageNum = [self getPageCountWithChapterIndex:markObject.chapterIndex pageindex:markObject.pageNum];
        [markArray addObject:markObject];
        
        
    }
    if(markArray.count == 0)
    {
        markArray = [[NSMutableArray alloc]init];
    }
}
//获取设置相关信息
-(NSDictionary *)getEpubSetting
{
    return [Catalog getEpubSetting];
}
//读取页码信息
-(BOOL)getPageInfoAndLoadPagePosition
{
    NSString *orinFlag = [self getFlipTypeAndOren];
    NSDictionary *paginginfoDic  = [Catalog getReadingInfo][userInfo.userState.textbookID][orinFlag];
    
    if(paginginfoDic)
    {
        NSDictionary *dic = [self getEpubSetting];
        float fontValue =[dic[@"kEpubFont"] floatValue];
        EPUB_MARGIN margin = [dic[@"kEpubMargin"] intValue];
        
        if(((NSNumber*)[paginginfoDic objectForKey:@"font"]).floatValue == fontValue && ((NSNumber*)[paginginfoDic objectForKey:@"margin"]).floatValue == margin )
        {
            NSArray *positionArray = ((NSString *)[paginginfoDic objectForKey:@"array"]).JSONValue;
            for (NSInteger i= 0; i < positionArray.count; i++) {
                EpubChapter* chapter = [chapterArray objectAtIndex:i+1];
                NSArray *tempArray = [positionArray objectAtIndex:i];
                chapter.offset = [self.epubDelegate setPointWithOrigin:((NSNumber *)[tempArray objectAtIndex:0]).floatValue];
                chapter.contentSize =  [self.epubDelegate setSizeWithlength:((NSNumber *)[tempArray objectAtIndex:1]).floatValue];
                chapter.pageCount = ((NSNumber *)[tempArray objectAtIndex:2]).integerValue;
            }
            
            [self.epubDelegate setViewPositionAndPageCount];
            
            return YES;
            
        }
        else
        {
            [self deleteOtherOrientationInfo];
            return NO;
        }
        
    }
    else
    {
        return NO;
    }
}
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index
{
    NSDictionary *recordInfoDic = [[StatisticsManager sharedStatisticsManager]getCurPageBookRecordWithType:ReadingEpubNote page:index];
    if(recordInfoDic != nil)
    {
        NSString *recordID = [recordInfoDic objectForKey:@"recordID"];
        NSDictionary *pathInfo = [[StatisticsManager sharedStatisticsManager]getRecordInfoWithRecordID:recordID withReadingType:ReadingEpubNote];
        NSString *folderPath = [pathInfo objectForKey:@"filePath"];
        NSString *notePath = [folderPath stringByAppendingPathComponent:EPUB_NOTE];
        
        NSString *noteString = [NSString stringWithContentsOfFile:notePath encoding:NSUTF8StringEncoding error:nil];
        return noteString;
    }
    
    return nil;
}
//获取上次阅读位置的信息
-(NSArray *)getReadingInfo
{
    NSInteger chapterIndex = 0;
    NSInteger pageIndex = 0;
    
//    NSDictionary *readinginfoDic  = [Catalog getReadingInfo][userInfo.userState.textbookID];
//    if(readinginfoDic)
//    {
//        chapterIndex = ((NSNumber*)[readinginfoDic objectForKey:@"chapter"]).integerValue;
//        EpubChapter *chapter = [chapterArray objectAtIndex:chapterIndex];
//        
//        pageIndex = [self changeFloatPagenumToInt:((NSNumber*)[readinginfoDic objectForKey:@"page"]).floatValue * (float)chapter.pageCount];
//    }
    NSDictionary *metadic = [[StatisticsManager sharedStatisticsManager]getPrecessInfoDicWithBookid:userInfo.userState.textbookID];
    if (metadic != nil)
    {
            chapterIndex = ((NSNumber*)[metadic objectForKey:@"chapter"]).integerValue;
            EpubChapter *chapter = [chapterArray objectAtIndex:chapterIndex];
            pageIndex = [self changeFloatPagenumToInt:((NSNumber*)[metadic objectForKey:@"page"]).floatValue * (float)chapter.pageCount];
        }
    
    if(chapterIndex == 0 || pageIndex == 0)
    {
        chapterIndex = 1;
        pageIndex = 1;
    }
    
    return @[@(chapterIndex),@(pageIndex)];
}
-(NSMutableArray *)getBookMarkArray
{
    return markArray;
}
#pragma mark  加密解密相关代码
-(void)enCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex
{
//    if(isEncrypt)
//    {
//        EpubChapter *chapter = [chapterArray objectAtIndex:chapterIndex];
        //[EncodeDecode PublishingContentEncript:chapter.chapterUrl.path];
        //[EncodeDecode htmlFileEncode:chapter.chapterUrl.path];
//    }
    
}
-(void)deCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex
{
//    if(isEncrypt)
//    {
//        EpubChapter *chapter = [chapterArray objectAtIndex:chapterIndex];
        //[EncodeDecode PublishingContentDecript:chapter.chapterUrl.path];
        //[EncodeDecode htmlFileDecode:chapter.chapterUrl.path];
//    }
}

#pragma mark  功能性代码
-(NSInteger)changeFloatPagenumToInt:(float)pagenum
{
    NSInteger returnPageNum = pagenum;
    if(pagenum > returnPageNum + 0.5)
    {
        returnPageNum++;
    }
    if(returnPageNum<=0)
    {
        returnPageNum = 1;
    }
    return returnPageNum;
}
-(void)stopPaging
{
    stopPageing = YES;
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
-(UIColor *)getColorWithIdenti:(NSString *)colorString
{
    EpubWebView *tempWebView = [[EpubWebView alloc]init];
    NSString *rgbColor = [tempWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"getHTbg('%@')",colorString]];
    
    return [EPUBUtils colorWithRGBHexString:rgbColor];
}

@end
