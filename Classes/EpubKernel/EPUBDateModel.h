//
//  EPUBDateModel.h
//  E-Publishing
//
//  Created by tangsl on 15/4/3.
//
//

#import <Foundation/Foundation.h>
#import "EpubProtocal.h"

@class EpubChapter;
@class EpubMarkObject;
@interface EPUBDateModel : NSObject<EpubChapterProtocol,EpubSearchProtocal>
{
    //计算页码上次计算的index
    NSInteger lastCountPageIndex;
    //书签和笔记上次计算的index
    NSInteger noteAndMarkLastCountIndex;
    //是否正在执行搜索
    BOOL isSearch;
    BOOL stopPageing;
}


@property (nonatomic,weak) id<EpubDataModelProtocal,PositonDataHandleProtocal> epubDelegate;
//!存储信息的数组
@property (nonatomic,retain) NSArray *chapterArray;
//!存储书签的数组
@property (nonatomic,retain) NSMutableArray *markArray;
//!包含目录数组
@property (nonatomic,retain) NSArray *listArray;
//!包含临时滚动数组
@property (nonatomic,retain) NSMutableArray *pagenatingChapterArray;
//!包含计算章节描述数组
@property (nonatomic,retain) NSMutableArray *pagenatingChapterIndexArray;
//!如果现在正在搜索  那么终止搜索
@property (nonatomic,assign) BOOL isSearch;

#pragma mark  EpubChapterProtocol
- (void) chapterDidFinishLoad:(EpubChapter *)tempChapter;
- (void) chapterDIdFinishSearch:(EpubChapter *)tchapter lastResult:(NSString*)result key:(NSString *)sKey;

#pragma mark  EpubSearchProtocal
- (void)searchEpubWithKey:(NSString *)keys;
-(void)showSearchWithTotalPage:(NSInteger)pageNum key:(NSString *)key position:(CGPoint)positon;

#pragma mark  删除数据相关代码
-(void)deleteOtherOrientationInfo;
-(void)deleteBookMarkWithID:(NSString *)recordID;

#pragma mark  整理数据相关代码
//!根据总页码 得到总页码对应的chapterindex 和pageindex
-(NSArray *)getChapterIndexAndPageindexWithPageNum:(NSInteger)pageNum;
//!更具chapterindex 获取title
-(NSString*)getTitleWithChapterIndex:(NSInteger)chapterIndex;
//!设置Offset 并计算总页码
-(NSInteger)generateChapterPositonAndGetTotolCount;
//!根据chapterindex 和pageindex 获取当前页对应的总页码
-(NSInteger)getPageCountWithChapterIndex:(NSInteger)chapterIndex pageindex:(NSInteger)pageIndex;
//!从已经加载完成的数组里面查找是否有已经计算好的页码的
-(EpubChapter*)getChapterFormLoadedArray:(NSInteger)index;
//!根据文件名称 获取对应的chapterindex
-(NSInteger)getChapterIndexWithFileName:(NSString *)fileName;
//!更新chapterarray的成员内容
-(void)updateChapterArray;
//!根据index 获取制定epubchapter
-(EpubChapter *)getChapterWithIndex:(NSInteger)chapterIndex;
-(BOOL)updateNoteWithWebView:(EpubWebView *)webView;
-(void)updateNoteAndMarkChangedChapter;

#pragma mark  保存数据相关代码
//!保存页码信息
-(void)savePageingInfo;
-(void)setUserInfoPageNum:(NSInteger)pageNum;
//!保存阅读进度
-(BOOL)saveReadingInfo:(NSDictionary *)info;
//!保存书签
-(void)saveBookMarkWithMarkObject:(EpubMarkObject *)bookMarkObject;
//!保存高亮
-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index;

#pragma mark  读取数据相关代码
//!得到笔记
-(NSArray *)getNoteListArray;
//!得到所有的书签
-(void)getAllBookMarkWithPagedState:(BOOL)pagedState;
//!获取设置相关信息
-(NSDictionary *)getEpubSetting;
//!读取页码信息
-(BOOL)getPageInfoAndLoadPagePosition;
//!读取note信息
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index;

//!获取上次阅读位置的信息
-(NSArray *)getReadingInfo;

#pragma mark  功能性代码
-(NSInteger)changeFloatPagenumToInt:(float)pagenum;
-(void)stopPaging;

#pragma mark  加密解密相关代码
-(void)enCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex;
-(void)deCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex;

- (void) cancelCountPage;
@end
