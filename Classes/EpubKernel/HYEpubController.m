//  HYEpubController.m
//  E-Publishing
//
//  Created by tangsl on 14-7-31.
//
//

#import "HYEpubController.h"
#import "HYEpubConstants.h"
#import "HYEpubParser.h"
#import "HYEpubContentModel.h"
#import "EpubStaticDefine.h"
#import "EpubChapter.h"
#import "EpubListObject.h"

@interface HYEpubController ()

@property (nonatomic, strong) HYEpubParser *parser;


@end


@implementation HYEpubController


- (instancetype)initWithDestinationFolder:(NSURL *)destinationURL
{
    self = [super init];
    if (self)
    {
        _destinationURL = destinationURL;
    }
    return self;
}

+(BOOL)encodeEpub:(NSString *)epubPath{
    BOOL success = YES;
    NSArray *filelist = [[self class]getEncodeFilePathArrayDestinationFolder:epubPath];
    for (NSString *filePath in filelist) {
        if ([filePath hasSuffix:@"ncf"] == NO) {
//            success = [EncodeDecode htmlFileEncode:filePath];
            success = YES;
            if (success == NO) {
                break;
            }
        }
    }
    
    return success;
}
+(BOOL)decodeEpub:(NSString *)epubPath{
    BOOL success = NO;
    NSArray *filelist = [[self class]getEncodeFilePathArrayDestinationFolder:epubPath];
    for (NSString *filePath in filelist) {
        if ([filePath hasSuffix:@"ncf"] == NO) {
//            success = [EncodeDecode htmlFileDecode:filePath];
            success = YES;
            if (success == NO) {
                break;
            }
        }
    }
    
    return success;
}

//- (void)openAsynchronous:(BOOL)asynchronous
//{
//    self.extractor = [[HYEpubExtractor alloc] initWithEpubURL:self.epubURL andDestinationURL:self.destinationURL];
//    self.extractor.delegate = self;
//    [self.extractor start:asynchronous];
//}


#pragma mark HYEpubExtractorDelegate Methods


//- (void)epubExtractorDidStartExtracting:(HYEpubExtractor *)epubExtractor
//{
//    if ([self.delegate respondsToSelector:@selector(epubController:willOpenEpub:)])
//    {
//        [self.delegate epubController:self willOpenEpub:self.epubURL];
//    }
//}


- (void)epubExtractorDidFinishExtracting
{
    self.parser = [HYEpubParser new];
    NSURL *rootFile = [self.parser rootFileForBaseURL:_destinationURL];
    _epubContentBaseURL = [rootFile URLByDeletingLastPathComponent];
    
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:rootFile encoding:NSUTF8StringEncoding error:&error];
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
    if (document)
    {
        _contentModel = [HYEpubContentModel new];
        
        self.contentModel.bookType = [self.parser bookTypeForBaseURL:_destinationURL];
        self.contentModel.bookEncryption = [self.parser contentEncryptionForBaseURL:_destinationURL];
        self.contentModel.metaData = [self.parser metaDataFromDocument:document];
        self.contentModel.coverPath = [self.parser coverPathComponentFromDocument:document];
        
        if (!self.contentModel.metaData)
        {
            NSError *error = [NSError errorWithDomain:HYEpubKitErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"No meta data found"}];
            [self.delegate epubController:self didFailWithError:error];
        }
        else
        {
            self.contentModel.manifest = [self.parser manifestFromDocument:document];
            self.contentModel.spine    = [self.parser spineFromDocument:document];
            self.contentModel.guide    = [self.parser guideFromDocument:document];
            
            if (self.delegate)
            {
                [self.delegate epubController:self didOpenEpub:self.contentModel];
            }
        }
    }
    
}
+(NSArray *)getEncodeFilePathArrayDestinationFolder:(NSString *)destinationPath
{
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    NSMutableArray *encodeArray = [[NSMutableArray alloc]init];
    HYEpubParser *parser = [HYEpubParser new];
    NSURL *rootFile = [parser rootFileForBaseURL:destinationURL];
    NSURL* epubContentBaseURL = [rootFile URLByDeletingLastPathComponent];
    
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:rootFile encoding:NSUTF8StringEncoding error:&error];
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
    
    NSDictionary* manifest = [parser manifestFromDocument:document];
    NSArray* spine    = [parser spineFromDocument:document];
    
    for (int i = 0;i < spine.count;i++) {
        NSString *title = [spine objectAtIndex:i];
        NSString *contentFilePath = manifest[title][@"href"];
        NSString *chapterFileName = [contentFilePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *chapterUrl =[epubContentBaseURL URLByAppendingPathComponent:chapterFileName];
        NSString *filePath = chapterUrl.path;
        [encodeArray addObject:filePath];
        
    }
    
    
    return encodeArray;
}
-(NSURL *)getCoverImgPath
{
    self.parser = [HYEpubParser new];
    NSString *imgPath;
    NSURL *rootFile = [self.parser rootFileForBaseURL:self.destinationURL];
    _epubContentBaseURL = [rootFile URLByDeletingLastPathComponent];
    
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:rootFile encoding:NSUTF8StringEncoding error:&error];
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
    if (document)
    {
        imgPath = [self.parser coverPathComponentFromDocument:document];
        imgPath = [imgPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSURL *coverUrl;
    imgPath ?(coverUrl = [_epubContentBaseURL URLByAppendingPathComponent:imgPath]):(coverUrl = _epubContentBaseURL);
    return coverUrl;
}
-(NSArray *)getBookChapterFileArray
{
    NSMutableArray *chapterArray = [[NSMutableArray alloc]init];
    
    NSArray *spineArray = self.contentModel.spine;
    
    NSURL *htmlFolderUrl = nil;
    
    for (int i = 0;i < spineArray.count;i++) {
        NSString *title = [spineArray objectAtIndex:i];
        EpubChapter *epubChapter = [[EpubChapter alloc]init];
        epubChapter.title = title;
        NSString *contentFilePath = self.contentModel.manifest[title][@"href"];
        epubChapter.chapterFileName = [contentFilePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        epubChapter.chapterUrl =[self.epubContentBaseURL URLByAppendingPathComponent:epubChapter.chapterFileName];
        epubChapter.chapterIndex = i;
        if(i == spineArray.count-1)
        {
            htmlFolderUrl = [epubChapter.chapterUrl URLByDeletingLastPathComponent];
        }
        
        [chapterArray addObject:epubChapter];
        
        
    }
    
    NSString *folderPath = nil;
    
    NSString *filePathPre =[htmlFolderUrl absoluteString];
    if(filePathPre.length >8)
    {
        
        folderPath = [filePathPre substringFromIndex:7];
    }
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:folderPath isDirectory:nil]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"BundleEpbuJS" ofType:@"bundle"];
        NSString *resourceFilePath = [path stringByAppendingPathComponent:@"Contents/Resources/epubjs"];
        
        NSString *cssfilePath  = [resourceFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"founderEpub.css"]];
        NSString *founderEpubPath = [folderPath stringByAppendingPathComponent:@"founderEpub.css"];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:founderEpubPath]){
            [[NSFileManager defaultManager]copyItemAtPath:cssfilePath toPath:founderEpubPath error:nil];
        }
        
        NSString *EpubImgPath =[folderPath stringByAppendingPathComponent:@"epubimg"];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:EpubImgPath]) {
            
         [[NSFileManager defaultManager]copyItemAtPath:[resourceFilePath stringByAppendingPathComponent:@"epubimg"] toPath:EpubImgPath error:nil];
        }
       
    }
    
    return chapterArray;
}

-(NSArray *)getChapterListArrayWithChapterArray:(NSArray *)chapterArray
{
    if(chapterArray.count < 1)
    {
        return nil;
    }
    NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
    NSArray *preChapterListArray = [self getPreChapterListArrayWithNcxFileName:((EpubChapter *)[chapterArray objectAtIndex:0]).chapterFileName];
    int i = 0;
    for (NSDictionary *listDic in preChapterListArray) {
        EpubListObject *listObject = [[EpubListObject alloc]init];
        listObject.listName = [listDic objectForKey:EPUB_CHAPTER_TITLE];
        listObject.layer =((NSNumber *)[listDic objectForKey:EPUB_CHAPTER_LAYER]).intValue;
        NSString *listFileSrc = [listDic objectForKey:EPUB_CHAPTER_SRC];
        NSArray *listFileArray = [listFileSrc componentsSeparatedByString:@"#"];
        NSString *listFileName = nil;
        if(listFileArray.count > 1)
        {
            listFileName = [listFileArray objectAtIndex:0];
            listObject.listMark = [listFileArray objectAtIndex:1];
        }
        else
        {
            listFileName = listFileSrc;
        }
        for (; i < chapterArray.count; i++) {
            EpubChapter *epubChapter = [chapterArray objectAtIndex:i];
            if( [listFileName isEqualToString:epubChapter.chapterFileName])
            {
                listObject.chapterIndex = i;
                break;
            }
        }
        [mutableArray addObject:listObject];
    }
    
    return mutableArray;
    
}
-(NSArray *)getPreChapterListArrayWithNcxFileName:(NSString*)fileName
{
    self.parser = [HYEpubParser new];
    
    
    NSURL *tempRootFile = [self.parser rootFileForBaseURL:self.destinationURL];
    _epubContentBaseURL = [tempRootFile URLByDeletingLastPathComponent];
    
    NSURL *rootFile = [_epubContentBaseURL URLByAppendingPathComponent:fileName];
    
    if(!rootFile)
        return nil;
    
    _epubContentBaseURL = [rootFile URLByDeletingLastPathComponent];
    
    NSError *error = nil;
    NSString *contentPre = [NSString stringWithContentsOfURL:rootFile encoding:NSUTF8StringEncoding error:&error];
    if (contentPre == nil) {
        NSURL *containerURL = [_epubContentBaseURL URLByAppendingPathComponent:@"toc.ncx"];
        contentPre = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&error];
//        if (error) {//目录文件为非NSUTF8StringEncoding，现在只考虑中文编码 cuihongbao 20170510 mark
//            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
//            contentPre = [NSString stringWithContentsOfURL:containerURL encoding:enc error:&error];
//        }
    }
    NSString *content = [contentPre stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//对字符串进行UTF-8编码：输出str字符串的UTF-8格式  cuihongbao 20170510 mark
    content = [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//解码：把str字符串以UTF-8规则进行解码
    DDXMLDocument *document = [[DDXMLDocument alloc]initWithXMLString:content options:kNilOptions error:&error];
    if(document)
    {
        return [self.parser getBookChapterListDic:document];
    }
    
    
    return nil;
}
-(NSArray *)turnSpinArrayToChapterArray
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSURL *rootFile = [self.parser rootFileForBaseURL:_destinationURL];
    NSString *content = [NSString stringWithContentsOfURL:rootFile encoding:NSUTF8StringEncoding error:nil];
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:nil];
    if (document)
    {
        NSArray *array =  [self.parser spineFromDocument:document];
        for (int i = 1; i < array.count; i++) {
            NSMutableDictionary *reDic = [[NSMutableDictionary alloc]init];
            [reDic setObject:[array objectAtIndex:i] forKey:EPUB_CHAPTER_TITLE];
            [reDic setObject:[NSNumber numberWithInteger:i] forKey:EPUB_CHAPTER_INDEX];
            NSArray *pageArray = [NSArray arrayWithObjects:reDic, nil];
            [tempArray addObject:pageArray];
        }
    }
    
    return tempArray;
}



//- (void)epubExtractor:(HYEpubExtractor *)epubExtractor didFailWithError:(NSError *)error
//{
//    if (self.delegate)
//    {
//        [self.delegate epubController:self didFailWithError:error];
//    }
//}


@end
