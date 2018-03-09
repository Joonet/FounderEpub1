//
//  Behavior.h
//  E-Publishing
//
//  Created by 李 雷川 on 13-8-2.
//
//

#ifndef E_Publishing_Behavior_h
#define E_Publishing_Behavior_h


typedef enum {
    BehaviorTypeActivityUser    = 0,
    BehaviorTypeDpubReading     = 1,
    BehaviorTypePageReading     = 2,
    BehaviorTypeExfcUsed        = 3,
    BehaviorTypeEmailShare      = 4,
    BehaviorTypeActivityButton  = 5,
    BehaviorTypeException       = 6,
    BehaviorTypeEpubReading     = 7,  //新增 epub 
} BehaviorType;

typedef enum {
    DurationTypeLaunching        = 0,
    DurationTypeResignActive     = 1,
    DurationTypeBecomeActive     = 2,
    DurationTypeTerminate        = 3,
} DurationType;


typedef enum {
    BehaviorPlayModeAutoPlay  	= 0,
    BehaviorPlayModeHandPlay    = 1,
}BehaviorPlayMode;

typedef enum {
    BehaviorTouchModeNone        = -1,
    BehaviorTouchModeTap         = 0,    //点击
    BehaviorTouchModeDoubleTap   = 1,    //点击
    BehaviorTouchModePinch       = 2,    //捏合
    BehaviorTouchModeRotation    = 3,    //旋转
    BehaviorTouchModeSwipe       = 4,    //滑动
    BehaviorTouchModePan         = 5,    //拖动
    BehaviorTouchModeLongPress   = 6,    //长按
}BehaviorTouchMode;

typedef enum {
    BehaviorFunctionPlay          = 0,        //播放
    BehaviorFunctionPause         = 1,        //暂停
    BehaviorFunctionStop          = 2,        //停止
    BehaviorFunctionRecord        = 3,        //录音
    BehaviorFunctionBackplay      = 4,        //回话
    BehaviorFunctionSwitch        = 5,        //切换
    BehaviorFunctionRepeate       = 6,        //复读
    BehaviorFunctionCancelRepeate = 7,        //取消复读
    BehaviorFunctionBookmark      = 8,        //书签
    BehaviorFunctionClickPlay     = 9,        //点播
    BehaviorFunctionSlider        = 10,       //滑动slider调整播放
    BehaviorFunctionPercussion    = 11,       //点击乐器
    BehaviorFunctionReset         = 12,       //复位
}BehaviorFunction;

typedef enum {
    BehaviorOrientationPre  	= 0,
    BehaviorOrientationNext    = 1,
}BehaviorOrientation;


typedef enum {
    StatsStyleHistogram	 = 0,
    StatsStyleRound      = 1,
    StatsStyleLine       =2
}StatsStyle;
#endif
