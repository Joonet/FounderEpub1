//
//  EpubNavigationBar.h
//  E-Publishing
//
//  Created by miaopu on 14-10-9.
//
//

#import <UIKit/UIKit.h>

@class  BHButton;
@interface EpubNavigationBar : UIImageView
{
    BHButton *backToViewButton;
    BHButton *searchButton;
    BHButton *optionButton;
    BHButton *bookMarkButton;
    BHButton *directoryButton;
}

@property(nonatomic,assign)   int   bookType;
@property (nonatomic,strong)UIButton *backToViewButton;
@property (nonatomic,strong)UIButton *searchButton;
@property (nonatomic,strong)UIButton *optionButton;
@property (nonatomic,strong)UIButton *bookMarkButton;
@property (nonatomic,strong)UIButton *directoryButton;

@end
