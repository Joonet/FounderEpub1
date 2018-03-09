//
//  EpubWebView.h
//  E-Publishing
//
//  Created by miaopu on 14-8-22.
//
//

#import <UIKit/UIKit.h>
#import "EpubProtocal.h"
@class EpubWebView;
@class EpubChapter;
@class EpubMarkObject;

@interface EpubMainScrollView : UIScrollView<UIScrollViewDelegate,EPUBWebviewProtocal>
{

    
     //--------------上层传递过来的标识-------------
    //翻转方式
    NSInteger flipType;
    CGFloat viewWidth;
    CGFloat viewHeight;
    
    
     //--------------视图相关的变量-------------
    //主显示视图
    EpubWebView *mainShowWebView;
    //预加载前一个webview
    EpubWebView *preLoadPreWebView;
    //预加载后一个webview
    EpubWebView *preLoadNextWebView;
    
    //--------------页码和标识相关-------------
    //是否已经开始加载epub 的html
    BOOL epubLoaded;
    //上次通知的位移
    CGPoint lastOffset;
    //现在点击的位置
    float pointPositionY;
    BOOL isEnable;
    BOOL canSetScrollView;
    BOOL downFlip;
    
    //键盘滚动和消失相关
    float lastSavedPositionY;
    EpubWebView *tempKeyboardFlagView;
    
    //如果此项有值说明 搜索完成以后需要跳转
    NSString *searchKey;
    CGPoint searchPosi;
    
    //标识现在view是否正在滚动
    BOOL scrolling;
    
    }

@property (nonatomic,assign) id <EpubMainScrollViewProtocol> epubController;
@property (nonatomic,assign) BOOL isEnable;
@property (nonatomic,assign) NSInteger flipType;
@property (nonatomic,assign) BOOL epubLoaded;
@property (nonatomic,assign) BOOL scrolling;
@property (nonatomic,assign) CGFloat viewWidth;
@property (nonatomic,assign) CGFloat viewHeight;

//!主显示视图
@property (nonatomic,retain) EpubWebView *mainShowWebView;
//!预加载前一个webview
@property (nonatomic,retain) EpubWebView *preLoadPreWebView;
//!预加载后一个webview
@property (nonatomic,retain) EpubWebView *preLoadNextWebView;


-(void)initWebview:(NSInteger)loadChapterIndex pageIndex:(NSInteger)pageIndex flipType:(NSInteger)ftype mark:(NSString *)mark;
-(EpubWebView *)webViewWithchapterIndex:(NSInteger)chapterIndex pageIndex:(NSInteger)pageIndex mark:(NSString *)mark;
-(void)allWebViewLoadJsString:(NSString *)jsString;
-(void)reloadLoadedWebView;
-(void)resetMainWebViewPostionWithOffset:(float)offset;
-(void)resetMainWebViewPostion;
-(void)refreshLoadedWebView;
-(void)turnTOChapter:(NSInteger)ChapterIndex page:(NSInteger)pageIndex mark:(NSString *)mark;
-(BOOL)formartWebViewContent:(NSInteger)nowChapterIndex;
//-(void)keyBoradWillShow:(float)keyBoardHeight;
//-(void)keyBoradWillHide;
-(void)setScrollToMark:(NSString *)mark;
-(UIColor *)getColorWithColorString:(NSString *)colorString;
-(void)showSearchResultWithkey:(NSString *)key position:(CGPoint)positon;
-(void)willShowSearchResultWithkey:(NSString *)key position:(CGPoint)positon;
-(void)releaseAllWebView;
-(EpubMarkObject *)addBookMarkWithChapterIndex:(NSInteger)chapterIndex;
-(CGSize)addSizeWithSize:(CGSize)size margin:(float)margin;
-(CGPoint)addPointWithPoint:(CGPoint)point margin:(float)margin;
-(CGRect)addFrameWithPoint:(CGRect)rect margin:(float)margin;
-(CGSize)setSizeWithlength:(float)length;
-(CGPoint)setPointWithOrigin:(float)origin;
-(CGRect)setFrameWithOrigin:(float)origin;
-(void)hideNowLoadedWebView;
-(float)getLengthWithPoint:(CGPoint)point;
-(float)getLengthWithFrame:(CGRect)rect;
-(float)getLengthWithSize:(CGSize)size;
-(float)getPerPageLength;
- (id)initWithFrame:(CGRect)frame flipType:(int)tFlipType;
-(void)resetLoadedWebview;
-(void)turnToNextPage;
-(void)turnToLastPage;
@end
