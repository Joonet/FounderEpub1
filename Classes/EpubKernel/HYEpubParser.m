//  HYEpubParser.m
//  E-Publishing
//
//  Created by tangsl on 14-7-31.
//
//

#import "HYEpubParser.h"
#import "EpubStaticDefine.h"

@interface HYEpubParser ()


@property (strong) NSXMLParser *parser;
@property (strong) NSString *rootPath;
@property (strong) NSMutableDictionary *items;
@property (strong) NSMutableArray *spinearray;


@end


#define kMimeTypeEpub @"application/epub+zip"
#define kMimeTypeiBooks @"application/x-ibooks+zip"


@implementation HYEpubParser


- (HYEpubKitBookType)bookTypeForBaseURL:(NSURL *)baseURL
{
    NSError *error = nil;
    HYEpubKitBookType bookType = HYEpubKitBookTypeUnknown;
    
    NSURL *mimetypeURL = [baseURL URLByAppendingPathComponent:@"mimetype"];
    NSString *mimetype = [[NSString alloc] initWithContentsOfURL:mimetypeURL encoding:NSASCIIStringEncoding error:&error];
    
    if (error)
    {
        return bookType;
    }
    
    NSRange mimeRange = [mimetype rangeOfString:kMimeTypeEpub];
    
    if (mimeRange.location == 0 && mimeRange.length == 20)
    {
        bookType = HYEpubKitBookTypeEpub2;
    }
    else if ([mimetype isEqualToString:kMimeTypeiBooks])
    {
        bookType = HYEpubKitBookTypeiBook;
    }
    
    return bookType;
}


- (HYEpubKitBookEncryption)contentEncryptionForBaseURL:(NSURL *)baseURL
{
    NSURL *containerURL = [[baseURL URLByAppendingPathComponent:@"META-INF"] URLByAppendingPathComponent:@"sinf.xml"];
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&error];
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
    
    if (error)
    {
        return HYEpubKitBookEnryptionNone;
    }
    NSArray *sinfNodes = [document.rootElement nodesForXPath:@"//fairplay:sinf" error:&error];
    if (sinfNodes == nil || sinfNodes.count == 0)
    {
        return HYEpubKitBookEnryptionNone;
    }
    else
    {
        return HYEpubKitBookEnryptionFairplay;
    }
}


- (NSURL *)rootFileForBaseURL:(NSURL *)baseURL
{
    NSError *error = nil;
    NSURL *containerURL = [[baseURL URLByAppendingPathComponent:@"META-INF"] URLByAppendingPathComponent:@"container.xml"];
    
    NSString *content = [NSString stringWithContentsOfURL:containerURL encoding:NSUTF8StringEncoding error:&error];
    DDXMLDocument *document = [[DDXMLDocument alloc] initWithXMLString:content options:kNilOptions error:&error];
    DDXMLElement *root  = [document rootElement];
    
    DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
    defaultNamespace.name = @"default";
    NSArray* objectElements = [root nodesForXPath:@"//default:container/default:rootfiles/default:rootfile" error:&error];
    
    NSUInteger count = 0;
    NSString *value = nil;
    for (DDXMLElement* xmlElement in objectElements)
    {
        value = [[xmlElement attributeForName:@"full-path"] stringValue];
        count++;
    }
    
    if (count == 1 && value)
    {
        return [baseURL URLByAppendingPathComponent:value];
    }
    else if (count == 0)
    {
        NSLog(@"no root file found.");
    }
    else
    {
        NSLog(@"there are more than one root files. this is odd.");
    }
    return nil;
}

- (NSURL *)tocFileForBaseURL:(NSURL *)baseURL
{
    NSURL *containerURL = [baseURL URLByAppendingPathComponent:@"toc.ncx"];
    return containerURL;
}



- (NSString *)coverPathComponentFromDocument:(DDXMLDocument *)document
{
    NSString *coverPath = nil;
    DDXMLElement *root  = [document rootElement];
    DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
    defaultNamespace.name = @"default";
    NSArray *metaNodes = nil;
    
    
    if (!coverPath)
    {
        NSString *coverItemId = nil;
        
        DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
        defaultNamespace.name = @"default";
        metaNodes = [root nodesForXPath:@"//default:package/default:metadata/default:meta" error:nil];
        for (DDXMLElement *xmlElement in metaNodes)
        {
            if ([[xmlElement attributeForName:@"name"].stringValue compare:@"cover" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                if(!coverItemId)
                    coverItemId = [xmlElement attributeForName:@"content"].stringValue;
            }
        }
        
        if(!coverItemId)
        {
            coverItemId = @"cover-image";
        }
        metaNodes = [root nodesForXPath:[NSString stringWithFormat:@"//default:package/default:manifest/default:item[@id='%@']",coverItemId] error:nil];
        
        if (metaNodes)
        {
            coverPath = [[metaNodes.lastObject attributeForName:@"href"] stringValue];
        }
        
    }
    return coverPath;
}



- (NSDictionary *)metaDataFromDocument:(DDXMLDocument *)document
{
    NSMutableDictionary *metaData = [NSMutableDictionary new];
    DDXMLElement *root  = [document rootElement];
    DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
    defaultNamespace.name = @"default";
    NSArray *metaNodes = [root nodesForXPath:@"//default:package/default:metadata" error:nil];
    
    if (metaNodes.count == 1)
    {
        DDXMLElement *metaNode = metaNodes[0];
        NSArray *metaElements = metaNode.children;
        
        for (DDXMLElement* xmlElement in metaElements)
        {
            if ([self isValidNode:xmlElement])
            {
                if (![metaData objectForKey:xmlElement.localName]) {
                    metaData[xmlElement.localName] = xmlElement.stringValue;
                }else{
                    NSString * attributeString = [[[xmlElement attributes] firstObject] stringValue];
                    NSString * metaDataKeyString = [NSString stringWithFormat:@"%@-%@", xmlElement.localName, attributeString];
                    metaData[metaDataKeyString] = xmlElement.stringValue;
                }
            }
        }
    }
    else
    {
        NSLog(@"meta data invalid");
        return nil;
    }
    return metaData;
}

- (NSArray *)getBookChapterListDic:(DDXMLDocument *)document
{
    //最后返回的数组，数组最外层是章节数组，内层数组是章节分多少主题，主题包含dic name and src
    NSMutableArray *spine = [NSMutableArray new];
    DDXMLElement *root = [document rootElement];
    DDXMLNode *defaultNameSpace = [root namespaceForPrefix:@""];
    defaultNameSpace.name = @"default";
    int index = 1;
    NSArray *spineNodes = [root nodesForXPath:@"//default:ncx/default:navMap" error:nil];
    if (spineNodes.count == 1)
    {
        DDXMLElement *metaNode = spineNodes[0];
        NSArray *metaElements = metaNode.children;
        for (DDXMLElement* chapterElement in metaElements) {
            
            NSArray *titleArray = [chapterElement children];
//            NSMutableArray *oneChapterArray = [[NSMutableArray alloc]init];
            if(titleArray.count > 1)
            {
                index ++;
                NSDictionary *firstDic = [self turnChapterName:[titleArray objectAtIndex:0] src:[titleArray objectAtIndex:1] layer:1];
                [spine addObject:firstDic];
                
            }
            if(titleArray.count > 2)
            {
                for (int i = 2; i < chapterElement.childCount; i++)
                {
                    DDXMLNode* chapterElement1 = [chapterElement childAtIndex:i];
                    NSArray *titleArray1 = [chapterElement1 children];
                    if(titleArray1.count >1)
                    {
                        DDXMLNode *title = [titleArray1 objectAtIndex:0];
                        DDXMLElement *src = [titleArray1 objectAtIndex:1];
                        
                        index ++;
                        NSDictionary *secondDic = [self turnChapterName:title src:src layer:2];
                        [spine addObject:secondDic];
                    }if(titleArray1.count > 2)
                    {
                        
                        
                        for (int j =2; j < titleArray1.count; j++) {
                            DDXMLNode* chapterElement2 = [titleArray1 objectAtIndex:j];
                            NSArray *titleArray2 = [chapterElement2 children];
                            if(titleArray2.count >1)
                            {
                                DDXMLNode *title = [titleArray2 objectAtIndex:0];
                                DDXMLElement *src = [titleArray2 objectAtIndex:1];
                                
                                index ++;
                                NSDictionary *secondDic1 = [self turnChapterName:title src:src layer:3];
                                [spine addObject:secondDic1];
                            }
                            if (titleArray2.count > 2)
                            {
                                
                                
                                for (int k =2; k < titleArray2.count; k++) {
                                    DDXMLNode* chapterElement3 = [titleArray2 objectAtIndex:k];
                                    NSArray *titleArray3 = [chapterElement3 children];
                                    if(titleArray3.count >1)
                                    {
                                        DDXMLNode *title = [titleArray3 objectAtIndex:0];
                                        DDXMLElement *src = [titleArray3 objectAtIndex:1];
                                        
                                        index ++;
                                        NSDictionary *secondDic2 = [self turnChapterName:title src:src layer:4];
                                        [spine addObject:secondDic2];
                                    }
                                }
                                
                                
                            }
                        }
                        

                    }
                    
                    
                }
            }
//            [spine addObject:oneChapterArray];
        }
    }
    else
    {
        NSLog(@"title data invalid");
        return nil;
    }
    
    return spine;
}


-(NSDictionary *)turnChapterName:(DDXMLNode *)nameNode src:(DDXMLElement *)src layer:(NSInteger)layer
{
    NSMutableDictionary *reDic = [[NSMutableDictionary alloc]init];
    NSString *titleSr = nil;
    DDXMLNode *nameNodePre = [nameNode childAtIndex:0];
    if(nameNodePre.childCount >  0)
    {
        titleSr = [[nameNodePre childAtIndex:0]stringValue];
        
    }
    else
    {
        //如果<default:text></default:text> 那么返回空
        titleSr = @"默认章节";
        
    }
    
    NSString *srcstr = [[src attributeForName:EPUB_CHAPTER_SRC] stringValue];
    
    [reDic setObject:srcstr  forKey:EPUB_CHAPTER_SRC];
    [reDic setObject:titleSr forKey:EPUB_CHAPTER_TITLE];
    [reDic setObject:[NSNumber numberWithInteger:layer] forKey:EPUB_CHAPTER_LAYER];
    
    return reDic;
}


- (NSArray *)spineFromDocument:(DDXMLDocument *)document
{
    NSMutableArray *spine = [NSMutableArray new];
    DDXMLElement *root  = [document rootElement];
    DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
    defaultNamespace.name = @"default";
    NSArray *spineNodes = [root nodesForXPath:@"//default:package/default:spine" error:nil];
    
    if (spineNodes.count == 1)
    {
        DDXMLElement *spineElement = spineNodes[0];
        
        NSString *toc = [[spineElement attributeForName:@"toc"] stringValue];
        if (toc)
        {
            [spine addObject:toc];
        }
        else
        {
            [spine addObject:@""];
        }
        NSArray *spineElements = spineElement.children;
        for (DDXMLElement* xmlElement in spineElements)
        {
            if ([self isValidNode:xmlElement])
            {
                [spine addObject:[[xmlElement attributeForName:@"idref"] stringValue]];
            }
        }
    }
    else
    {
        NSLog(@"spine data invalid");
        return nil;
    }
    return spine;
}


- (NSDictionary *)manifestFromDocument:(DDXMLDocument *)document
{
    NSMutableDictionary *manifest = [NSMutableDictionary new];
    DDXMLElement *root  = [document rootElement];
    DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
    defaultNamespace.name = @"default";
    NSArray *manifestNodes = [root nodesForXPath:@"//default:package/default:manifest" error:nil];
    
    if (manifestNodes.count == 1)
    {
        NSArray *itemElements = ((DDXMLElement *)manifestNodes[0]).children;
        for (DDXMLElement* xmlElement in itemElements)
        {
            if ([self isValidNode:xmlElement] && xmlElement.attributes)
            {
                NSString *href = [[xmlElement attributeForName:@"href"] stringValue];
                NSString *itemId = [[xmlElement attributeForName:@"id"] stringValue];
                NSString *mediaType = [[xmlElement attributeForName:@"media-type"] stringValue];
                
                if (itemId)
                {
                    NSMutableDictionary *items = [NSMutableDictionary new];
                    if (href)
                    {
                        items[@"href"] = href;
                    }
                    if (mediaType)
                    {
                        items[@"media"] = mediaType;
                    }
                    manifest[itemId] = items;
                }
            }
        }
    }
    else
    {
        NSLog(@"manifest data invalid");
        return nil;
    }
    return manifest;
}


- (NSArray *)guideFromDocument:(DDXMLDocument *)document
{
    NSMutableArray *guide = [NSMutableArray new];
    DDXMLElement *root  = [document rootElement];
    
    DDXMLNode *defaultNamespace = [root namespaceForPrefix:@""];
    defaultNamespace.name = @"default";
    NSArray *guideNodes = [root nodesForXPath:@"//default:package/default:guide" error:nil];
    
    if (guideNodes.count == 1)
    {
        DDXMLElement *guideElement = guideNodes[0];
        NSArray *referenceElements = guideElement.children;
        
        for (DDXMLElement* xmlElement in referenceElements)
        {
            if ([self isValidNode:xmlElement])
            {
                NSString *type = [[xmlElement attributeForName:@"type"] stringValue];
                NSString *href = [[xmlElement attributeForName:@"href"] stringValue];
                NSString *title = [[xmlElement attributeForName:@"title"] stringValue];
                
                NSMutableDictionary *reference = [NSMutableDictionary new];
                if (type)
                {
                    reference[type] = type;
                }
                if (href)
                {
                    reference[@"href"] = href;
                }
                if (title)
                {
                    reference[@"title"] = title;
                }
                [guide addObject:reference];
            }
        }
    }
    else
    {
        NSLog(@"guide data invalid");
        return nil;
    }
    
    return guide;
}


- (BOOL)isValidNode:(DDXMLElement *)node
{
    return node.kind != DDXMLCommentKind;
    
}


@end
