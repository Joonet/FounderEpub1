//
//  EpubWebView.h
//  E-Publishing
//
//  Created by miaopu on 14-9-19.
//
//

#import <UIKit/UIKit.h>
#import "JSBridgeWebView.h"

@protocol EPUBWebviewProtocal;
@interface EpubWebView :JSBridgeWebView<UIGestureRecognizerDelegate,UIScrollViewDelegate,JSBridgeWebViewDelegate,UIPopoverControllerDelegate>
{
    //页码和标识相关
    //!当前webview的页码
    NSUInteger pageIndex;
    //!此webview的总页码
    NSUInteger pageCount;
    //!此webview在epub中得index
    NSInteger chapterIndex;
    //!自己在展示数组的位置
    NSInteger arrayIndex;
    //!翻转方向
    NSInteger flipType;
    //!横翻标识点击起点的成员
    CGPoint touchBeginPoint;
    //!标识现在主视图webview的高度和宽度
    CGSize  viewSize;
    //!本章节的size
    CGSize chapterSize;
    //!本章节相当于全书的offset
    CGPoint chapterOffset;
    //!表示第一次加载主页面
    BOOL firstLoad;
    //!标识加载的时候是否带着标签加载
    BOOL hasJSMark;
    //!便签的内容
    NSString *mark;
    //!上次点击的时间
    NSDate *lastTapDate;
    
    
    }

@property (nonatomic ,assign) NSUInteger pageIndex;
@property (nonatomic ,assign) NSUInteger pageCount;
@property (nonatomic ,assign) NSInteger chapterIndex;
@property (nonatomic ,assign) NSInteger arrayIndex;
@property (nonatomic ,assign) NSInteger functionFlag;
@property (nonatomic ,assign) NSInteger flipType;
@property (nonatomic ,assign) CGSize chapterSize;
@property (nonatomic ,assign) CGPoint chapterOffset;
@property (nonatomic ,assign) CGPoint touchBeginPoint;
@property (nonatomic ,retain) NSDate *lastTapDate;
@property (nonatomic ,retain) NSString *mark;
@property (nonatomic ,assign) BOOL hasJSMark;
@property (nonatomic ,assign)  BOOL firstLoad;
@property (nonatomic ,assign) CGSize  viewSize;
@property (nonatomic ,weak) id <EPUBWebviewProtocal> mainViewDelegate;
@property(nonatomic, copy)dispatch_block_t singleTapGestureBlock;
@property(nonatomic, copy)dispatch_block_t doubleTapGestureBlock;
-(UIColor *)getColorWithIdenti:(NSString *)colorString;
-(UIColor *)getColorWithColorString:(NSString *)colorString;

@end

