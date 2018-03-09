//
//  EpubProtocal.h
//  E-Publishing
//
//  Created by tangsl on 15/1/29.
//
//

#ifndef E_Publishing_EpubProtocal_h
#define E_Publishing_EpubProtocal_h

@class EpubChapter;
@class EpubWebView;
@class EpubNoteListObject;
@class EpubMarkObject;

#import <UIKit/UIKit.h>
@protocol listViewProtocol <NSObject>
//翻转到目标章节的目标页码
- (void)showPageWithChapter:(NSInteger)cindex page:(NSInteger)pIndex jsMark:(NSString *)mark;
//获得书签数组
-(NSArray *)getBookMarkArray;
//得到目录数组
-(NSArray *)getChapterListArray;
//跳转到目标页码(当前总页码，而不是章节内页码)
-(void)showTotalPage:(NSInteger)pageNum;
//得到note数组
-(NSArray *)getNoteListArray;
//移除章节列表
-(void)removeChapterListView;
//得到目前的章节index
-(NSInteger)getNowChapterIndex;
@end


@protocol EpubChapterProtocol <NSObject>
//传递点击位置的坐标
- (void) chapterDidFinishLoad:(EpubChapter *)chapter;
- (void) chapterDIdFinishSearch:(EpubChapter *)tchapter lastResult:(NSString*)result key:(NSString *)sKey;
-(void)enCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex;
-(void)deCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex;
-(NSMutableArray *)getBookMarkArray;
-(void)updateBookMarkObjcet:(EpubMarkObject *)bookMarkObject;;
-(NSString *)getFlipTypeAndOren;
-(UIView *)getMainView;
-(BOOL)updateNoteWithWebView:(EpubWebView *)webView;
//通知控制器进行保存的方法
-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index;
//读取note
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index;
//读取字体信息
-(NSDictionary *)getEpubSetting;
@end

@protocol EPUBWebviewProtocal <NSObject>
//完成网页加载的回调方法
-(void)webviewFinishLoad:(EpubWebView *)webview;
@optional
-(void)webviewFailLoad:(EpubWebView *)webview;
-(void)saveFinished:(EpubWebView *)webView;
//根据文件名加载目标网页
-(void)loadPageWithFileName:(NSString *)fileName;
//根据type加载对应的相关内容
-(void)showContentRefWithDIc:(NSDictionary *)dic webView:(EpubWebView*)webview type:(NSString *)type;
-(UIColor *)getColorWithColorString:(NSString *)colorString;
-(void)showNoteWithNote:(EpubNoteListObject *)noteObject webView:(EpubWebView *)webView;
-(NSString *)getFlipTypeAndOren;
-(void)turnToNextPage;
-(void)turnToLastPage;
-(BOOL)getNavBarHideState;
-(void)setAnchorPostionWithoffset:(CGPoint)offset;

//通知控制器进行保存的方法
-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index;
//读取note
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index;
//读取字体信息
-(NSDictionary *)getEpubSetting;
@end

@protocol EPubMainViewProtocol <NSObject>

-(BOOL)getEpubFlipType;
-(NSDictionary *)getEpubSetting;
-(void)backToBookshelf;
-(void)showSerchTextView;
-(void)fontChangeClickMethod;
-(void)changeBookMarkBtnState;
-(void)showChapterListView;
-(BOOL)getEpubLoadedState;

@end


@protocol EpubMainScrollViewProtocol <NSObject>
//显示隐藏导航栏
-(void)changeNavigationBarVisible;
//得到是否正在计算页码
-(BOOL)getPaginateState;
//设置视图控制器中现在展示的页码
-(void)setNowChapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex;
- (void) updatePagination;
-(EpubChapter *)getChapterWithIndex:(NSInteger)chapterIndex;
-(void)showLoadHud;
-(NSInteger)getChapterCount;
-(void)loadPageWithFileName:(NSString *)fileName;
-(void)showNoteRefWithDic:(NSDictionary *)dic webView:(EpubWebView*)webview;
//根据dic 显示图片
-(void)showPicWithDic:(NSDictionary *)dic webView:(EpubWebView *)webview;
-(NSMutableArray *)getPagenatingChapterArray;
-(void)poperNoteWithNoteObject:(EpubNoteListObject *)noteObject webView:(EpubWebView *)webView;
-(void)enCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex;
-(void)deCodeHtmlFileWithChapterIndex:(NSInteger)chapterIndex;
-(NSString *)getFlipTypeAndOren;
-(BOOL)updateNoteWithWebView:(EpubWebView *)webView;
-(void)hideNavigateBar;
-(BOOL)getNavBarHideState;

-(void)saveHighLightsWithDic:(NSDictionary*)dictionary chapterIndex:(NSInteger)index;
-(NSString *)getNoteStringWithChapterIndex:(NSInteger)index;
-(NSDictionary *)getEpubSetting;

@end

@protocol EpubSearchProtocal <NSObject>
- (void)searchEpubWithKey:(NSString *)keys;
-(void)showSearchWithTotalPage:(NSInteger)pageNum key:(NSString *)key position:(CGPoint)positon;
@end

@protocol EpubDataModelProtocal <NSObject>
-(float)getViewwidth;
-(float)getViewHeight;
-(NSInteger)getToltalPageCount;
-(void)setPagenatingProcessView:(float)process;
-(BOOL)canNotContinueUpdate;
-(void)finishUpdateChapterArray;
-(void)removeCountrelatedView;
-(void)setViewPositionAndPageCount;
-(void)showSearchHud;
-(void)showResultAlert;
-(BOOL)addResultsObject:(NSArray*)array key:(NSString *)sKey;
-(void)showSearchWithTotalPage:(NSInteger)pageNum key:(NSString *)key position:(CGPoint)positon;
-(void)setNowChapterIndex:(NSInteger)tempChapterIndex pageIndex:(NSInteger)tempPageIndex;
-(UIColor *)getColorWithColorString:(NSString *)colorString;
-(NSString *)getFlipTypeAndOren;
-(UIView *)getMainView;
@end

@protocol PositonDataHandleProtocal <NSObject>
-(CGSize)addSizeWithSize:(CGSize)size margin:(float)margin;
-(CGPoint)addPointWithPoint:(CGPoint)point margin:(float)margin;
-(CGRect)addFrameWithPoint:(CGRect)rect margin:(float)margin;
-(CGSize)setSizeWithlength:(float)length;
-(CGPoint)setPointWithOrigin:(float)origin;
-(CGRect)setFrameWithOrigin:(float)origin;
-(float)getLengthWithPoint:(CGPoint)point;
-(float)getLengthWithFrame:(CGRect)rect;
-(float)getLengthWithSize:(CGSize)size;
-(float)getPerPageLength;
@end
#endif
