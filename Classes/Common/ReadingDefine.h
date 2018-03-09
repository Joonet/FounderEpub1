//
//  Header.h
//  E-Publishing
//
//  Created by 李 雷川 on 13-12-12.
//
//

#ifndef E_Publishing_Header_h
#define E_Publishing_Header_h

#define NOTE_TEXT @"notetext.txt"

#define ENDORSE_SHAPES @"endorse.vg"
#define ENDORSE_BITMAPE @"preview.png"
#define ENDORSE_TRANSIMG @"endorse.png"

#define RECORD_ICON @"recordIcon.png"

#define CAPTURE_BITMAPE @"preview.png"
#define TEXTFRAME_FILE @"textframe.txt"
#define BOOKMARK_IMG @"bookmark.png"

#define STATIC_SHAPES 10000
#define DYNAMIC_SHAPES 20000
#define MANAGE_STRING 30000
#define IMG_BITMAP @"preview.png"
#define UNDO_FILE @"undo"
#define RECORD_AUDIO_FILENAME @"record.mp3"


#define EPUB_HIGH_LIGHT @"epubHighlight.txt"
#define EPUB_NOTE @"epubNote.txt"
#define EPUB_NOTE_DETAIL @"epubNoteDetail.txt"

typedef enum {
    ReadingNote             = 99,  //便签
    ReadingBookmark         = 1,  //书签
    ReadingCapture          = 2,  //截屏
    ReadingEndorse          = 3,  //批注
    ReadingRecordEndorse    = 4,  //录屏
    ReadingResource         = 5,  //添加资源
    ReadingRecorder         = 21, //录音 
    ReadingKeyboard         = 6,  //键盘文本框
    ReadingPageBookmark     = 7,  //页面书签
    ReadingEpubNote         = 8,  //epub笔记
    ReadingProcess          = 9,  //阅读进度
    ReadingHand             = 22, //手写文本框
} ReadingRecordType;

#endif
