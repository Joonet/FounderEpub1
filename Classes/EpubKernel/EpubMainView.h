//
//  EpubMainView.h
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import <UIKit/UIKit.h>
#import "EpubOptionView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PopoverView.h"

@protocol EPubMainViewProtocol;
@class EpubNavigationBar;
@class EpubChapterCoverView;
@class PopoverView;
@class MBProgressHUD;
@class EpubOptionView;

@interface EpubMainView : UIView <MBProgressHUDDelegate,PopoverViewDelegate>
{
    //! 导航栏view
    EpubNavigationBar *navigateBar;
    //! 章节列表弹出的时候 临时的view
    EpubChapterCoverView *chaperCoverView;
    //! 设置界面
    EpubOptionView *epubOptionView;
    //! poper
    PopoverView *epubPopoverView;
    //! 页码进度条
    MBProgressHUD *HUD;
    //! 页码进度条
    MBProgressHUD *searchHUD;
    //! 滚动条
    UISlider *epubSlier;
    //! 页码lable
    UILabel *pageNumLable;
    //! 页码lable
    UILabel *prePageNumLable;
    //! 页码lable
    UILabel *leftPageNumLable;
    //! 底栏的页码视图
    UIToolbar *bottomBar;
    //! 滑动滚动条展示的章节信息视图
    UIView *titleShowView;
    //! 滑动滚动条展示的章节信息视图 章节信息
    UILabel *chapterLable;
    //! 滑动滚动条展示的章节信息视图  页码信息
    UILabel *pageLable;
    //! 计算的进程条
    UIView* pagenatingProcessView;
    //! 页面下方的页码lable
    UILabel *bottomPageNumLable;
    //! 页面上方的章节名称
    UILabel *topChapterTitleLable;
    
    
    //其他变量相关
    //! 导航栏的约束
    NSLayoutConstraint *topBarConstraint;
    //! 显示hub
    BOOL showHub;
}

@property (nonatomic,assign) BOOL showHub;
@property (nonatomic,retain) EpubNavigationBar *navigateBar;
@property (nonatomic,assign) id<EPubMainViewProtocol,EpubOptionViewDelegate> epubMainViewDelegate;
//! 页码lable
@property (nonatomic,retain) UILabel *pageNumLable;
//! 滚动条
@property (nonatomic,retain) UISlider *epubSlier;
//! 页码lable
@property (nonatomic,retain) UILabel *prePageNumLable;
//! 页码lable
@property (nonatomic,retain) UILabel *leftPageNumLable;
//! 滑动滚动条展示的章节信息视图  页码信息
@property (nonatomic,retain) UILabel *pageLable;
//! 滑动滚动条展示的章节信息视图 章节信息
@property (nonatomic,retain) UILabel *chapterLable;
//! 页面下方的页码lable
@property (nonatomic,retain) UILabel *bottomPageNumLable;
//! 页面上方的章节名称
@property (nonatomic,retain) UILabel *topChapterTitleLable;

-(void)setBgColor:(UIColor*)bgColor;
-(void)addEpubFunctionViews;
-(BOOL)getNaviBarState;
-(void)setPrecessSliderFrame;
-(void)showLoadHud;
-(void)showSearchHud;
-(void)removeProcessView;
-(void)showOptionView;
-(void)setNavigateBarHidden:(BOOL)hidden;
-(void)setPagenatingProcessView:(float)process;
-(void)showTitleView;
-(void)releaseTitleView;


@end
