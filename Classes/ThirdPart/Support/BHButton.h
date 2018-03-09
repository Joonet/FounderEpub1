//
//  BHButton.h
//  E-Publishing
//
//  Created by 李 雷川 on 13-7-12.
//
//

#import <UIKit/UIKit.h>
//#import "DurAnalysis.h"
//#import "Statistic/StatisticsManager.h"


typedef enum {
//17个学习工具按钮+1个设置按钮
    GeneralBtn_pen = 0,                     //激光笔
    GeneralBtn_draft = 1,                   //草稿
    GeneralBtn_screen = 2,                  //截屏
    GeneralBtn_camera = 3,                  //拍照
    GeneralBtn_set = 4,                     //设置
    GeneralBtn_lock = 5,                    //锁屏
    GeneralBtn_notes = 6,                   //批注
    GeneralBtn_piano = 7,                   //钢琴
    GeneralBtn_monitor = 8,                 //监控
    GeneralBtn_printscreen = 9,             //截图
    GeneralBtn_black = 10,                  //黑屏
    GeneralBtn_metronome = 11,              //节拍器
    GeneralBtn_noSound = 12,                //静音
    GeneralBtn_noSoundMonitor = 13,         //静音录屏
    GeneralBtn_note = 14,                   //便签
    GeneralBtn_ScreenRecording = 15,        //录屏
    GeneralBtn_curtain = 16,                //幕布
    GeneralBtn_spot = 17,                   //聚光灯

//   导航条上方的五个按钮：    
    BHSearchButton = 18,                            //18 搜索
    BHCatalogButton = 19,                           //19目录
    BHThumbNavButton = 20,                          //20、缩略图
    BHRecordButton = 21,                            //21衍生数据
    BHBookmarkButton = 22,                          //22书签
    
    
    GeneralBtn_projection = 23,             //投屏
//    GeneralBtn_amplification = 24,          //放大
    GeneralBtn_broadcast = 25,              //广播
//    GeneralBtn_whiteBoard = 26,          //白板
    GeneralBtn_browser = 27,              //浏览器
    GeneralBtn_quiz = 28,              //测验
    GeneralBtn_homework = 29,              //zuoye
    
    

} BHButtonType;
@interface BHButton : UIButton

{
//    BHButtonType _bhButtonType;   //按钮类型，暂时有23中类型：18个按钮+5个菜单栏按钮

    BOOL clickState;//选中状态，记录按钮的选中状态 ，不是所有按钮都需要这个属性，默认是NO；
    BOOL hasClickState;//是否有选中状态，记录按钮是否存在选中状态的属性，默认是NO；
}


//- (id)initWithButtonType:(BHButtonType)_type ;



@property (nonatomic ,assign) BHButtonType bhButtonType;
@property (nonatomic ,assign) BOOL clickState;//选中状态，记录按钮的选中状态 ，不是所有按钮都需要这个属性，默认是NO；
@property (nonatomic ,assign) BOOL hasClickState;//是否有选中状态，记录按钮是否存在选中状态的属性 ，默认是NO；
@end
