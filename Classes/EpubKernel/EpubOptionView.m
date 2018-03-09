//
//  EpubOptionView.m
//  E-Publishing
//
//  Created by miaopu on 14/12/19.
//
//

#import "EpubOptionView.h"
#import "Catalog.h"
#import "HYToast.h"

#define CONTROL_START_X       15   //内容界面的左侧的起始坐标
#define CONTROL_START_Y       8    //内容界面的上端的起始坐标
#define CONTROL_OFFSET_H      5    //控件之间水平方向的间隔
#define CONTROL_OFFSET_V      15   //控件之间垂直方向的间隔

#define CONTROL_HEIGHT        20
#define CONTROL_INTERVAL      25

#define READBACK_WIDTH        50   //背景的宽度
#define READBACK_HEIGHT       50   //背景的高度

#define BG_TAG_PAGE           1
#define BG_TAG_NIGHT          2

@implementation EpubOptionView

@synthesize largeFontBtn,smallFontBtn,blackBtn,orangeBtn,grayBtn,blueBtn,greenBtn,brownBtn,marginFourBtn,marginThreeBtn,marginTwoBtn,marginDefaultBtn;
@synthesize whiteBtn,lightgrayBtn;
@synthesize nightMode;
@synthesize turnPageMode;
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)setAllControlsEnabled: (BOOL)enabled{
    marginDefaultBtn.enabled = enabled;
    marginTwoBtn.enabled = enabled;
    marginThreeBtn.enabled = enabled;
    marginFourBtn.enabled = enabled;
    
    smallFontBtn.enabled = enabled;
    largeFontBtn.enabled = enabled;
    
    NSDictionary *dic = [Catalog getEpubSetting];
    float fontValue =[dic[@"kEpubFont"] floatValue];
    if (fontValue < 0.61) {
        smallFontBtn.enabled = NO;
    }
    else if(fontValue > 1.39){
        largeFontBtn.enabled = NO;
    }

    // on/off
    turnPageMode.enabled = enabled;
}


-(void)setFontButtonEnabled:(BOOL)enabled{
//    // 字体最大/小时提示
//    BOOL min = !smallFontBtn.enabled;
//    BOOL max = !largeFontBtn.enabled;
//    if (min || max)
//    {
//        UIWindow *wd = [UIApplication sharedApplication].keyWindow;
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:wd animated:true];
//        hud.mode = MBProgressHUDModeText;
//        if (min) {
//            hud.label.text = @"已经到最小字体";
//        }
//        else if(max){
//            hud.label.text = @"已经到最大字体";
//        }
//        [hud hideAnimated:false afterDelay:1];
//    }
}

-(void)defaultSetting{
    NSDictionary *dic = [Catalog getEpubSetting];
    float fontValue =[dic[@"kEpubFont"] floatValue];
    if (fontValue < 0.61) {
        smallFontBtn.enabled = NO;
    }
    else if(fontValue > 1.39){
        largeFontBtn.enabled = NO;
    }
    EPUP_BG_COLOR bgColor = [dic[@"kEpubBgColor"] intValue];
    switch (bgColor) {
        case epub_white:
            [whiteBtn setImage:[UIImage imageNamed:@"epub_white_s"] forState:UIControlStateNormal];
            break;
        case epub_lightgray:
            [lightgrayBtn setImage:[UIImage imageNamed:@"epub_lightgray_s"] forState:UIControlStateNormal];
            break;
        case epub_black:
            [blackBtn setImage:[UIImage imageNamed:@"epub_black_s"] forState:UIControlStateNormal];
            break;
        case epub_gray:
            [grayBtn setImage:[UIImage imageNamed:@"epub_gray_s"] forState:UIControlStateNormal];
            break;
        case epub_orange:
            [orangeBtn setImage:[UIImage imageNamed:@"epub_orange_s"] forState:UIControlStateNormal];
            break;
        case epub_blue:
            [blueBtn setImage:[UIImage imageNamed:@"epub_blue_s"] forState:UIControlStateNormal];
            break;
        case epub_green:
            [greenBtn setImage:[UIImage imageNamed:@"epub_green_s"] forState:UIControlStateNormal];
            break;
        case epub_brown:
            [brownBtn setImage:[UIImage imageNamed:@"epub_brown_s"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    EPUB_MARGIN margin = [dic[@"kEpubMargin"] intValue];
    switch (margin) {
        case epub_margin_default:
            [marginDefaultBtn setImage:[UIImage imageNamed:@"epub_margin_default_s"] forState:UIControlStateNormal];
            break;
        case epub_margin_two:
            [marginTwoBtn setImage:[UIImage imageNamed:@"epub_margin_two_s"] forState:UIControlStateNormal];
            break;
        case epub_margin_three:
            [marginThreeBtn setImage:[UIImage imageNamed:@"epub_margin_three_s"] forState:UIControlStateNormal];
            break;
        case epub_margin_four:
            [marginFourBtn setImage:[UIImage imageNamed:@"epub_margin_four_s"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    int type = [dic[@"kEPubFlipType"] intValue];
    if(type == EPUB_HOR_FLIP)
        [turnPageMode setOn:NO animated:YES];
    else
        [turnPageMode setOn:YES animated:YES];
    
}


-(void)updateEpubFontSize:(id)sender
{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSDictionary *dic = [Catalog getEpubSetting];
    UIButton *btn = sender;
    float fontValue =[dic[@"kEpubFont"] floatValue];
    if (btn.tag == 0) {
        fontValue = fontValue - 0.1;
    }
    else if(btn.tag == 1){
        fontValue = fontValue + 0.1;
    }
	
	if (fontValue < 0.61) {
		smallFontBtn.enabled = NO;
	}
	else if(fontValue > 1.39){
		largeFontBtn.enabled = NO;
	}
	else{
		largeFontBtn.enabled = YES;
		smallFontBtn.enabled = YES;
	}
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mutableDic setObject:@(fontValue) forKey:@"kEpubFont"];
    [Catalog saveEpubSetting:mutableDic];
    [self.delegate updateEpubFontSize:fontValue];
    
	if (!smallFontBtn.enabled) {
		[HYToast showHUDTo:UIApplication.sharedApplication.keyWindow title:@"已经是最小字体" style:HYToastHUDStyleTips delay:1];
	}
	else if (!largeFontBtn.enabled) {
		[HYToast showHUDTo:UIApplication.sharedApplication.keyWindow title:@"已经是最大字体" style:HYToastHUDStyleTips delay:1];
	}
	
    [self setAllControlsEnabled: false];
}

-(void)updateBackgroundColor:(id)sender{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    UIButton *btn = sender;
    [self.delegate setChangeBackMode:(EPUP_BG_COLOR)btn.tag];
    
    NSDictionary *dic = [Catalog getEpubSetting];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mutableDic setObject:@(btn.tag) forKey:@"kEpubBgColor"];
    [Catalog saveEpubSetting:mutableDic];
    
    [lightgrayBtn setImage:[UIImage imageNamed:@"epub_lightgray"] forState:UIControlStateNormal];
    [whiteBtn setImage:[UIImage imageNamed:@"epub_white"] forState:UIControlStateNormal];
    [blackBtn setImage:[UIImage imageNamed:@"epub_black"] forState:UIControlStateNormal];
    [grayBtn setImage:[UIImage imageNamed:@"epub_gray"] forState:UIControlStateNormal];
    [orangeBtn setImage:[UIImage imageNamed:@"epub_orange"] forState:UIControlStateNormal];
    [blueBtn setImage:[UIImage imageNamed:@"epub_blue"] forState:UIControlStateNormal];
    [greenBtn setImage:[UIImage imageNamed:@"epub_green"] forState:UIControlStateNormal];
    [brownBtn setImage:[UIImage imageNamed:@"epub_brown"] forState:UIControlStateNormal];
    
    switch (btn.tag) {
        case epub_white:
            [whiteBtn setImage:[UIImage imageNamed:@"epub_white_s"] forState:UIControlStateNormal];
            break;
        case epub_lightgray:
            [lightgrayBtn setImage:[UIImage imageNamed:@"epub_lightgray_s"] forState:UIControlStateNormal];
            break;
        case epub_black:
            [blackBtn setImage:[UIImage imageNamed:@"epub_black_s"] forState:UIControlStateNormal];
            break;
        case epub_gray:
            [grayBtn setImage:[UIImage imageNamed:@"epub_gray_s"] forState:UIControlStateNormal];
            break;
        case epub_orange:
            [orangeBtn setImage:[UIImage imageNamed:@"epub_orange_s"] forState:UIControlStateNormal];
            break;
        case epub_blue:
            [blueBtn setImage:[UIImage imageNamed:@"epub_blue_s"] forState:UIControlStateNormal];
            break;
        case epub_green:
            [greenBtn setImage:[UIImage imageNamed:@"epub_green_s"] forState:UIControlStateNormal];
            break;
        case epub_brown:
            [brownBtn setImage:[UIImage imageNamed:@"epub_brown_s"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
}

-(void)updateMargin:(id)sender{
    [self setAllControlsEnabled: false];

    UIButton *btn = sender;
    [self.delegate setMarginMode:(EPUB_MARGIN)btn.tag];
    NSDictionary *dic = [Catalog getEpubSetting];
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mutableDic setObject:@(btn.tag) forKey:@"kEpubMargin"];
    [Catalog saveEpubSetting:mutableDic];
    
    [marginDefaultBtn setImage:[UIImage imageNamed:@"epub_margin_default"] forState:UIControlStateNormal];
    [marginTwoBtn setImage:[UIImage imageNamed:@"epub_margin_two"] forState:UIControlStateNormal];
    [marginThreeBtn setImage:[UIImage imageNamed:@"epub_margin_three"] forState:UIControlStateNormal];
    [marginFourBtn setImage:[UIImage imageNamed:@"epub_margin_four"] forState:UIControlStateNormal];
    
    switch (btn.tag) {
        case epub_margin_default:
            [marginDefaultBtn setImage:[UIImage imageNamed:@"epub_margin_default_s"] forState:UIControlStateNormal];
            break;
        case epub_margin_two:
            [marginTwoBtn setImage:[UIImage imageNamed:@"epub_margin_two_s"] forState:UIControlStateNormal];
            break;
        case epub_margin_three:
            [marginThreeBtn setImage:[UIImage imageNamed:@"epub_margin_three_s"] forState:UIControlStateNormal];
            break;
        case epub_margin_four:
            [marginFourBtn setImage:[UIImage imageNamed:@"epub_margin_four_s"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}


#pragma mark - 初始化
-(id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self)
    {
        
        UIColor *contentBgColor = [UIColor clearColor];
        UIColor *lightGrayColor = [UIColor colorWithRed:210 /255.0 green:210 /255.0 blue:210 /255.0 alpha:1.0];
        UIView *fontView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        fontView.backgroundColor = contentBgColor;
        [self addSubview:fontView];
        
        
        
        float leftPadding = 4.0f;
        UILabel *fontLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftPadding,0,44, CGRectGetHeight(fontView.frame))];
        fontLabel.text = @"字体:";
        fontLabel.textAlignment = NSTextAlignmentLeft;
        [fontView addSubview:fontLabel];
        
        //缩小
        smallFontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        smallFontBtn.tag = 0;
        [smallFontBtn setTitle:@"A-" forState:UIControlStateNormal];
        [smallFontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [smallFontBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        smallFontBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [smallFontBtn addTarget:self action:@selector(updateEpubFontSize:) forControlEvents:UIControlEventTouchUpInside];
        [fontView addSubview:smallFontBtn];
        //放大
        largeFontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        largeFontBtn.tag = 1;
        [largeFontBtn setTitle:@"A+" forState:UIControlStateNormal];
        largeFontBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [largeFontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [largeFontBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        [largeFontBtn addTarget:self action:@selector(updateEpubFontSize:) forControlEvents:UIControlEventTouchUpInside];
        [fontView addSubview:largeFontBtn];
        
        //线
        UIView *fontLineView = [[UIView alloc]initWithFrame:CGRectMake(leftPadding,CGRectGetHeight(fontView.frame) -1 ,CGRectGetWidth(fontView.frame) - leftPadding, 1)];
        fontLineView.backgroundColor = lightGrayColor;
        [fontView addSubview:fontLineView];
        
        
        
        float fontBtnWidth =  (CGRectGetWidth(fontView.frame) - 44 )/2;
        smallFontBtn.frame = CGRectMake(44,0, fontBtnWidth, CGRectGetHeight(fontView.frame));
        UIView *middleLineView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(smallFontBtn.frame),0,1, CGRectGetHeight(fontView.frame) -1)];
        middleLineView.backgroundColor = lightGrayColor;
        [fontView addSubview:middleLineView];
        
        largeFontBtn.frame = CGRectMake(CGRectGetMaxX(middleLineView.frame),0,fontBtnWidth, CGRectGetHeight(fontView.frame));
        
        
        float btnWidth = 48.0f;
        float btnHeight = 48.0f;
        float padding =  2.0f;
        float vPadding = 4.0f;
        
        /**********************************************************************
         //设置间距
         **********************************************************************/
        UIView *marginView = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(fontView.frame) + vPadding, frame.size.width, 52)];
        marginView.backgroundColor = contentBgColor;
        [self addSubview:marginView];
        
        
        
        //线
        UIView *marginLineView = [[UIView alloc]initWithFrame:CGRectMake(leftPadding,CGRectGetHeight(marginView.frame) -1 ,CGRectGetWidth(marginView.frame) -leftPadding , 1)];
        marginLineView.backgroundColor = lightGrayColor;
        [marginView addSubview:marginLineView];
        
        
        
        UILabel *marginLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftPadding,0,44,CGRectGetHeight(marginView.frame))];
        marginLabel.text = @"版式:";
        marginLabel.textAlignment = NSTextAlignmentLeft;
        [marginView addSubview:marginLabel];
        
        
        
        marginTwoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        marginTwoBtn.tag = epub_margin_two;
        [marginTwoBtn setImage:[UIImage imageNamed:@"epub_margin_two"] forState:UIControlStateNormal];
        [marginTwoBtn addTarget:self action:@selector(updateMargin:) forControlEvents:UIControlEventTouchUpInside];
        [marginView addSubview:marginTwoBtn];
        
        marginThreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        marginThreeBtn.tag = epub_margin_three;
        [marginThreeBtn setImage:[UIImage imageNamed:@"epub_margin_three"] forState:UIControlStateNormal];
        [marginThreeBtn addTarget:self action:@selector(updateMargin:) forControlEvents:UIControlEventTouchUpInside];
        [marginView addSubview:marginThreeBtn];
        
        marginFourBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        marginFourBtn.tag = epub_margin_four;
        [marginFourBtn setImage:[UIImage imageNamed:@"epub_margin_four"] forState:UIControlStateNormal];
        [marginFourBtn addTarget:self action:@selector(updateMargin:) forControlEvents:UIControlEventTouchUpInside];
        [marginView addSubview:marginFourBtn];
        
        
        marginDefaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        marginDefaultBtn.tag = epub_margin_default;
        [marginDefaultBtn setImage:[UIImage imageNamed:@"epub_margin_default"] forState:UIControlStateNormal];
        [marginDefaultBtn addTarget:self action:@selector(updateMargin:) forControlEvents:UIControlEventTouchUpInside];
        [marginView addSubview:marginDefaultBtn];
        
        
        marginTwoBtn.frame = CGRectMake(CGRectGetMaxX(marginLabel.frame) + padding , CGRectGetHeight(marginView.frame)/2 - btnHeight/2, btnWidth, btnHeight);
        marginThreeBtn.frame = CGRectMake(CGRectGetMaxX(marginTwoBtn.frame) + padding , CGRectGetHeight(marginView.frame)/2 - btnHeight/2, btnWidth, btnHeight);
        marginFourBtn.frame = CGRectMake(CGRectGetMaxX(marginThreeBtn.frame) + padding ,CGRectGetHeight(marginView.frame)/2 - btnHeight/2, btnWidth, btnHeight);
        marginDefaultBtn.frame = CGRectMake(CGRectGetMaxX(marginFourBtn.frame) + padding ,CGRectGetHeight(marginView.frame)/2 - btnHeight/2, btnWidth, btnHeight);
        
        
        
        /**********************************************************************
         //设置主题
         **********************************************************************/
        
        UIView *colorView = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(marginView.frame) + vPadding, frame.size.width, 96)];
        colorView.backgroundColor = contentBgColor;
        [self addSubview:colorView];
        
        
        //线
        UIView *colorLineView = [[UIView alloc]initWithFrame:CGRectMake(leftPadding,CGRectGetHeight(colorView.frame) -1 ,CGRectGetWidth(colorView.frame)- leftPadding, 1)];
        colorLineView.backgroundColor = lightGrayColor;
        [colorView addSubview:colorLineView];
        
        
        
        UILabel *colorLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftPadding,0,44, CGRectGetHeight(fontView.frame))];
        colorLabel.text = @"主题:";
        colorLabel.textAlignment = NSTextAlignmentLeft;
        [colorView addSubview:colorLabel];
        
        
        
        whiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        whiteBtn.tag = epub_white;
        [whiteBtn setImage:[UIImage imageNamed:@"epub_white"] forState:UIControlStateNormal];
        [whiteBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:whiteBtn];
        
        blueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        blueBtn.tag = epub_blue;
        [blueBtn setImage:[UIImage imageNamed:@"epub_blue"] forState:UIControlStateNormal];
        [blueBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:blueBtn];
        
        
        lightgrayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lightgrayBtn.tag = epub_lightgray;
        [lightgrayBtn setImage:[UIImage imageNamed:@"epub_lightgray"] forState:UIControlStateNormal];
        [lightgrayBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:lightgrayBtn];
        
        grayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        grayBtn.tag = epub_gray;
        [grayBtn setImage:[UIImage imageNamed:@"epub_gray"] forState:UIControlStateNormal];
        [grayBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:grayBtn];
        
        
        blackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        blackBtn.tag = epub_black;
        [blackBtn setImage:[UIImage imageNamed:@"epub_black"] forState:UIControlStateNormal];
        [blackBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:blackBtn];
        
        
        orangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        orangeBtn.tag = epub_orange;
        [orangeBtn setImage:[UIImage imageNamed:@"epub_orange"] forState:UIControlStateNormal];
        [orangeBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:orangeBtn];
        
        greenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        greenBtn.tag = epub_green;
        [greenBtn setImage:[UIImage imageNamed:@"epub_green"] forState:UIControlStateNormal];
        [greenBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:greenBtn];
        
        brownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        brownBtn.tag = epub_brown;
        [brownBtn setImage:[UIImage imageNamed:@"epub_brown"] forState:UIControlStateNormal];
        [brownBtn addTarget:self action:@selector(updateBackgroundColor:) forControlEvents:UIControlEventTouchUpInside];
        [colorView addSubview:brownBtn];
        
        float colorBtnPadding = 0.0f;
        
        //上方三个
        whiteBtn.frame = CGRectMake(CGRectGetMaxX(marginLabel.frame) + padding , CGRectGetHeight(colorView.frame)/2 - btnHeight, btnWidth, btnHeight);
        greenBtn.frame = CGRectMake(CGRectGetMaxX(whiteBtn.frame) + colorBtnPadding , CGRectGetHeight(colorView.frame)/2 - btnHeight, btnWidth, btnHeight);
        orangeBtn.frame = CGRectMake(CGRectGetMaxX(greenBtn.frame) + colorBtnPadding ,CGRectGetHeight(colorView.frame)/2 - btnHeight, btnWidth, btnHeight);
        blueBtn.frame = CGRectMake(CGRectGetMaxX(orangeBtn.frame) + colorBtnPadding ,CGRectGetHeight(colorView.frame)/2 - btnHeight, btnWidth, btnHeight);
        
        //下方三个
        brownBtn.frame = CGRectMake(CGRectGetMaxX(marginLabel.frame) + padding , CGRectGetHeight(colorView.frame)/2 , btnWidth, btnHeight);
        lightgrayBtn.frame = CGRectMake(CGRectGetMaxX(brownBtn.frame) + colorBtnPadding ,CGRectGetHeight(colorView.frame)/2, btnWidth, btnHeight);
        grayBtn.frame = CGRectMake(CGRectGetMaxX(lightgrayBtn.frame) + colorBtnPadding ,CGRectGetHeight(colorView.frame)/2, btnWidth, btnHeight);
        blackBtn.frame = CGRectMake(CGRectGetMaxX(grayBtn.frame) + colorBtnPadding ,CGRectGetHeight(colorView.frame)/2, btnWidth, btnHeight);;
        
        /**********************************************************************
         夜间模式
         **********************************************************************/
        /*
         
         UIView *nightModeView = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(colorView.frame) + 10, frame.size.width, 36)];
         nightModeView.backgroundColor = [UIColor whiteColor];
         [self addSubview:nightModeView];
         
         
         UILabel *nightLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftPadding,0,128, CGRectGetHeight(nightModeView.frame))];
         nightLabel.text = @"夜间模式:";
         nightLabel.textAlignment = NSTextAlignmentLeft;
         [nightModeView addSubview:nightLabel];
         
         nightMode = [[UISwitch alloc]initWithFrame:CGRectMake(CGRectGetWidth(nightModeView.frame) - 50,0,50,CGRectGetHeight(nightModeView.frame))];
         [nightMode addTarget:self action:@selector(changeNightMode:) forControlEvents:UIControlEventTouchUpInside];
         [nightModeView addSubview:nightMode];
         
         */
        
        /**********************************************************************
         滚动翻页
         **********************************************************************/
        UIView *turnPageModeView = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(colorView.frame) + vPadding, frame.size.width, 36)];
        turnPageModeView.backgroundColor = contentBgColor;
        [self addSubview:turnPageModeView];
        
        
        
        //        UIView *turnPageLineView = [[UIView alloc]initWithFrame:CGRectMake(leftPadding,CGRectGetHeight(turnPageModeView.frame) -1 ,CGRectGetWidth(colorView.frame)- leftPadding, 1)];
        //        turnPageLineView.ba	kgroundColor = [UIColor lightGrayColor];
        //        [turnPageModeView addSubview:turnPageLineView];
        
        
        
        UILabel *turnPageLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftPadding,0,128, CGRectGetHeight(turnPageModeView.frame))];
        turnPageLabel.text = @"竖屏滚动显示";
        turnPageLabel.textAlignment = NSTextAlignmentLeft;
        [turnPageModeView addSubview:turnPageLabel];
        
        
        turnPageMode = [[UISwitch alloc]initWithFrame:CGRectMake(CGRectGetWidth(turnPageModeView.frame) - 52,0,50,CGRectGetHeight(turnPageModeView.frame))];
        [turnPageMode addTarget:self action:@selector(changeNightMode:) forControlEvents:UIControlEventTouchUpInside];
        [turnPageModeView addSubview:turnPageMode];
        
        [self defaultSetting];
        
    }
    return self;
}


-(void)changeNightMode:(id)sender{
    [self setAllControlsEnabled: false];
    
    
    BOOL value =((UISwitch*)sender).isOn;
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSDictionary *dic = [Catalog getEpubSetting];
    
    NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    if(value)
    {
        [mutableDic setObject:@(EPUB_NOR_FLIP) forKey:@"kEPubFlipType"];
        [Catalog saveEpubSetting:mutableDic];
        [self.delegate updateEpubFlipType:EPUB_NOR_FLIP];
    }
    else
    {
        [mutableDic setObject:@(EPUB_HOR_FLIP) forKey:@"kEPubFlipType"];
        [Catalog saveEpubSetting:mutableDic];
        [self.delegate updateEpubFlipType:EPUB_HOR_FLIP];
        
    }
}

@end
