//  HYEpubController.h
//  E-Publishing
//
//  Created by tangsl on 14-7-31.
//
//

#import <Foundation/Foundation.h>


@class HYEpubController;
@class HYEpubContentModel;


@protocol HYEpubControllerDelegate <NSObject>


- (void)epubController:(HYEpubController *)controller didOpenEpub:(HYEpubContentModel *)contentModel;

- (void)epubController:(HYEpubController *)controller didFailWithError:(NSError *)error;

@optional

- (void)epubController:(HYEpubController *)controller willOpenEpub:(NSURL *)epubURL;


@end


@interface HYEpubController : NSObject


@property (nonatomic, assign) id<HYEpubControllerDelegate> delegate;


@property (nonatomic, readonly, strong) NSURL *epubURL;

@property (nonatomic, readonly, strong) NSURL *destinationURL;

@property (nonatomic, readonly, strong) NSURL *epubContentBaseURL;

@property (nonatomic, readonly, strong) HYEpubContentModel *contentModel;


+(NSArray *)getEncodeFilePathArrayDestinationFolder:(NSString *)destinationPath;



- (instancetype)initWithDestinationFolder:(NSURL *)destinationURLP;

- (void)epubExtractorDidFinishExtracting;

-(NSURL *)getCoverImgPath;
-(NSArray *)getBookChapterFileArray;
-(NSArray *)getChapterListArrayWithChapterArray:(NSArray *)chapterArray;

+(BOOL)encodeEpub:(NSString *)epubPath;
+(BOOL)decodeEpub:(NSString *)epubPath;
@end
