//
//  EpubOptionView.h
//  E-Publishing
//
//  Created by miaopu on 14/12/19.
//
//

#import <UIKit/UIKit.h>
#import "EpubStaticDefine.h"
#import <MBProgressHUD/MBProgressHUD.h>



@protocol EpubOptionViewDelegate <NSObject>

@required
-(void)updateEpubFontSize:(float)value;
//-(void)setChangePagingType:(NSInteger)type;
-(void)setChangeBackMode:(EPUP_BG_COLOR)mode;
-(void)setMarginMode:(EPUB_MARGIN)mode;
-(void)updateEpubFlipType:(int)tflipType;
@end

@interface EpubOptionView : UIView{
    NSMutableArray *bgArray;
    
    //字体设置
    UIButton *largeFontBtn;
    UIButton *smallFontBtn;
    //背景色设置
    UIButton *whiteBtn;
    UIButton *lightgrayBtn;
    UIButton *blackBtn;
    UIButton *orangeBtn;
    UIButton *grayBtn;
    UIButton *blueBtn;
    UIButton *greenBtn;
    UIButton *brownBtn;
    
    //行间距设置
    UIButton *marginTwoBtn;
    UIButton *marginThreeBtn;
    UIButton *marginFourBtn;
    UIButton *marginDefaultBtn;
    
    UISwitch *nightMode;
    UISwitch *turnPageMode;
}
//字体设置
@property(nonatomic, retain) UIButton *largeFontBtn;
@property(nonatomic, retain) UIButton *smallFontBtn;
//背景色设置
@property(nonatomic, retain) UIButton *whiteBtn;
@property(nonatomic, retain) UIButton *lightgrayBtn;
@property(nonatomic, retain) UIButton *blackBtn;
@property(nonatomic, retain) UIButton *orangeBtn;
@property(nonatomic, retain) UIButton *grayBtn;
@property(nonatomic, retain) UIButton *blueBtn;
@property(nonatomic, retain) UIButton *greenBtn;
@property(nonatomic, retain) UIButton *brownBtn;

//行间距设置
@property(nonatomic, retain) UIButton *marginTwoBtn;
@property(nonatomic, retain) UIButton *marginThreeBtn;
@property(nonatomic, retain) UIButton *marginFourBtn;
@property(nonatomic, retain) UIButton *marginDefaultBtn;


@property(nonatomic, retain)UISwitch *nightMode;
@property(nonatomic, retain)UISwitch *turnPageMode;

@property (nonatomic,weak)id<EpubOptionViewDelegate> delegate;

-(void)updateEpubFontSize:(id)sender;

// 按钮可点击
-(void)setAllControlsEnabled: (BOOL)enabled;


@end
