//
//  EpubChapterCoverView.h
//  E-Publishing
//
//  Created by miaopu on 14-10-13.
//
//

#import <UIKit/UIKit.h>
@protocol EpubCoverDelegate <NSObject>
//移除章节列表
-(void)removeChapterListView;
@end

@interface EpubChapterCoverView : UIView

@property (nonatomic,weak)id <EpubCoverDelegate>delegate;

@end
