//
//  EpubStaticDefine.h
//  E-Publishing
//
//  Created by miaopu on 14-8-19.
//
//

#ifndef E_Publishing_EpubStaticDefine_h
#define E_Publishing_EpubStaticDefine_h

#define EPUB_CHAPTER_TITLE @"title"
#define EPUB_CHAPTER_INDEX @"index"
#define EPUB_CHAPTER_SRC @"src"
#define EPUB_CHAPTER_LAYER @"layer"

#define EPUB_CHAPTER_FILENAME @"chapter.txt"

#define EPUB_HOR_FLIP 0
#define EPUB_NOR_FLIP 1
#define EPUB_NOR_FLIP_CHAPTER 2
#define EPUB_NOR_FLIP_PAGE 3


#define SHOW_FLAG 0
#define COUNT_PAGE_FLAG 1
#define SEARCH_FLAG 2


#define DEFLAUT_MARGIN 50



#define LAST_CHAPTER_FLAG 2
#define LAST_PAGE_FLAG 1
#define NOT_LAST_PAGE_FLAG 0
#define ERROR_FLAG -1


#define NAVIGATION_BTN_WIDTH 100
#define NAVIGATION_BTN_HEIGHT 33
#define NAVIGATION_BTNTOTOP   40
#define NAVIGATION_LEFT_MARGIN 560
#define NAVIGATION_BTN_BTW 24

#define DIRECTORY_BTN_HEIGHT 29
#define DIRECTORY_LEFT_MARGIN 100
#define DIRECTORY_WHOLE_WIDTH 510
#define DIRECTORY_WHOLE_HEIGHT 80
#define DIRECTORY_SEGMENT_WIDTH 3
#define DIRECTORY_TITLE_HEIGHT 40
#define DIRECTORY_NEXT_TITLE_HEIGHT 27
#define DIRECTORY_TITLE_ICON_WIDTH 22
#define DIRECTORY_NEXT_TITLE_ICON_WIDTH 17
#define DIRECTORY_TITLE_MARGIN_LEFT 23
#define DIRECTORY_WORD_MARGIN_LEGT 70
//web view 的上下间距
#define WEBVIEW_TOP_BOTTOM_MARGIN 40


//load type
#define FIRST_LOAD 0
#define FIRST_CSS_LOAD 1

#define LANDSCAPE_NORFLIP @"0"
#define PORTRAIT_NORFLIP @"1"
#define LANDSCAPE_HORFLIP @"2"
#define PORTRAIT_HORFLIP @"3"
#define ORI_UNKNOW @"4"

//#define 


#define JS_HIGHLIGHTS_FLAGSTR @"highLightsref"
#define JS_NOTE_FLAGSTR @"noteref"
#define JS_PICTURE_FLAGSTR @"pictureref"
#define JS_SHOWNOTE_FLAGSTR @"showNoteRef"
#define js_TAP_FLAGSTR @"tapWebRef"
#define JS_AUCHOR_FLAGSTR @"anchorRef"
#define JS_SHOWURL_FLAGSTR @"turntourl"

typedef enum{
    epub_white  = 0,
    epub_blue   =1,
    epub_green  = 2,
    epub_orange = 3,
    epub_brown  = 4,
    epub_lightgray =5,
    epub_gray   = 6,
    epub_black   = 7
    
}EPUP_BG_COLOR;

typedef enum{
    epub_margin_default=0,
    epub_margin_two = 1,
    epub_margin_three = 2,
    epub_margin_four=3,
    
}EPUB_MARGIN;

#endif
