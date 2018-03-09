//
//  NotePoperViewController.h
//  E-Publishing
//
//  Created by tangsl on 15/4/8.
//
//

#import <UIKit/UIKit.h>

@class EpubNoteListObject;
@class EpubWebView;
@interface EpubNotePoperViewController : UIViewController
{
    //输入框对应的textview
    UITextView *textView;
    UILabel    *timeLabel;
    UILabel    *titleLabel;

    
}

@property (nonatomic,retain) UITextView *textView;
@property (nonatomic,retain) UILabel    *timeLabel;
@property (nonatomic,retain) UILabel    *titleLabel;
@property (nonatomic,retain) EpubNoteListObject *noteListObject;
@property(nonatomic, copy)dispatch_block_t exitBlock;
@property(nonatomic, copy)void (^saveNoteString)(NSString *jsonString);

//!初始设置方法
-(void)setNoteWithNoteObject:(EpubNoteListObject *)noteObject;
-(void)sendSaveMethod;

@end
