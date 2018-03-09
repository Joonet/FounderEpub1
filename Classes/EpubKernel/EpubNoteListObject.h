//
//  EpubNoteListObject.h
//  E-Publishing
//
//  Created by tangsl on 15/7/9.
//
//

#import <UIKit/UIKit.h>


@interface EpubNoteListObject : NSObject

//!标识index 也是js索引
@property (nonatomic,assign) NSInteger noteIndex;
//!高亮文本距离段落开头的位置
@property (nonatomic,assign) NSInteger startWordIndex;
//!笔记所在的页码
@property (nonatomic,assign) NSInteger pageNum;
//!高亮的坐标
@property (nonatomic,assign) CGPoint postion;
//!创建时间
@property (nonatomic,retain) NSDate *date;
//!高亮的颜色
@property (nonatomic,retain) UIColor *noteColor;
//!高亮的文本
@property (nonatomic,retain) NSString *highlightText;
//!段落的文本
@property (nonatomic,retain) NSString *partText;
//!笔记内容
@property (nonatomic,retain) NSString *noteContent;
//!增加还是修改笔记的标识
@property (nonatomic,retain)NSString *modifyNoteType;
//!矩形框的size
@property (nonatomic,assign) CGSize noteSize;
//!包含各个方向的位置信息
@property (nonatomic,strong) NSMutableDictionary *positionDic;
//!包含这个笔记的章节INDEX
@property (nonatomic,assign) NSInteger chapterIndex;

-(NSDictionary *)serializeToDic;
-(void)setNoteWithDic:(NSDictionary *)dic;


@end

