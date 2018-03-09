//
//  ChapterListViewController.h
//  epubAnalysis
//
//  Created by tang shoulin on 3/20/14.
//
//  类描述：章节列表的tableView
//

#import <UIKit/UIKit.h>
#import "EPubMainViewController.h"
#import "EpubChapter.h"


#define EPUB_DIRECTORY_FLAG 0
#define EPUB_BOOKMARK_FLAG 1
#define EPUB_NOTE_FLAG 2

@interface EPUBChapterListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    //! 章节数组
    NSArray *chaperArray;
    //! 书签数组
    NSArray *bookMarkArray;
    //！ 高亮和笔记数组
    NSArray *noteListArray;
    //! 用于展示数据的tableview
    UITableView *listTableView;
    //! 导航控件
    UISegmentedControl *segMentControl;
    //! 标识展示是何种内容的标识
    NSInteger tableFlag;
    //！ 是否已经高亮目标章节
    BOOL alreadyHighlightChapter;
}
//! 章节数组
@property (nonatomic,retain) NSArray *chaperArray;
//! 书签数组
@property (nonatomic,retain) NSArray *bookMarkArray;
//！ 高亮和笔记数组
@property (nonatomic,retain) NSArray *noteListArray;
//! 代理
@property (nonatomic,weak)id<listViewProtocol> delegate;
//! 用于展示数据的tableview
@property (retain,nonatomic) UITableView *listTableView;
//! 初始化所有的subview
-(void)setAllSubView;
//! 根据标识重新刷新展示内容
-(void)resetContent;

@end
