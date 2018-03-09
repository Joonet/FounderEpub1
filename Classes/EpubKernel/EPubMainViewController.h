//
//  EPubMainViewController.h
//  E-Publishing
//
//  Created by miaopu on 14/12/26.
//
//

#import <UIKit/UIKit.h>
#import "HYEpubController.h"
#import "HYEpubContentModel.h"
#import "EpubNavigationBar.h"
#import "EpubMainScrollView.h"
#import "JSBridgeWebView.h"
#import "EpubChapterCoverView.h"
#import "EpubOptionView.h"
#import "PopoverView.h"
#import "EpubChapter.h"
#import "PopoverView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "EpubProtocal.h"
#import "EpubNotePoperViewController.h"
#import "EpubMainView.h"

@class EpubMainScrollView;
@class EpubWebView;
@class EPUBChapterListViewController;
@class EpubSearchViewController;
@class EPUBDateModel;
@class EpubMainView;

@interface EPubMainViewController : UIViewController<HYEpubControllerDelegate,listViewProtocol,EpubMainScrollViewProtocol,JSBridgeWebViewDelegate,EpubCoverDelegate,EPUBWebviewProtocal,EpubOptionViewDelegate,PopoverViewDelegate,MBProgressHUDDelegate,UIPopoverControllerDelegate,EpubDataModelProtocal,PositonDataHandleProtocal,EPubMainViewProtocol>
{
    //--------------页码和标识相关-------------
    //! epub 总页码
    NSInteger totalPageCount;
    //! 是否正在生成页码
    BOOL pagenating;
    //! 翻页方式（横屏翻页还是竖屏翻页）
    int flipType;
    //! epub 屏幕的方向
    BOOL orientation;
    //! 主webview是否初次加载
    BOOL firstLoad;
    //! 现在的页码(相当于章节的页码) 从1开始计数
    NSInteger nowPageIndex;
    //! 现在的章节码 从1开始计数
    NSInteger nowChapterIndex;
    //! 在本章节现在页码所在的百分比
    float nowPageProcess;
    //! 现在书签在书签数组的位置 如果此页没加书签 那么值为-1
    NSInteger bookMarkIndex;


    //! 如果此项有值说明 搜索完成以后需要跳转
    NSString *searchKey;
    CGPoint searchPosi;
    //! 键盘消失以后需要变更页面位置的表示
    BOOL keyBoardMissChangeFlag;

    
    // ------------epub特有标识-----------------
    NSString   *cbookId;
    NSString   *cbookPATH;

    //! --------------视图大小和位置相关--------------
    //! 初次加载的位移
    float firstOffset;
    //! 主视图宽度
    float viewWidth;
    //! 主视图高度
    float viewHeight;
    //! 用户点击的位置Y
    float pointPositionY;

    //! web视图高度
    float webWidth;
    //! web视图宽度
    float webHeight;
    
    //--------------控制器相关--------------
    //! 解析相关的控制器
    HYEpubController *epubController;
    HYEpubContentModel *contentModel;
    //! 章节列表控制器
    EPUBChapterListViewController *chapterList;
    //! 搜索列表控制器
    EpubSearchViewController *epubSearchController;
    //! datamodel
    EPUBDateModel *epubDataModel;
    
    
    
    //--------------其他视图相关--------------
    //! 主滚动视图，计算epub总的翻阅offset
    EpubMainScrollView *mainScrollView;
    //! 这个viewcontroller对应的主view
    EpubMainView *epubMainView;
    //! 搜索视图的poper
    UIPopoverController *searchpoper;
    //! 弹出笔记的poper
    UIPopoverController *notePoper;
    //! 笔记弹出视图对应的视图控制器
    EpubNotePoperViewController *notePoperViewController;

}
@property (nonatomic ,copy)dispatch_block_t exitEpubBlock;

//初始化方法
- (id)initWithDirPath:(NSString *)dirPath;


//delegate mothod


@end
