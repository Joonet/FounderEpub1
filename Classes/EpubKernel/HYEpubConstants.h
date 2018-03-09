//  HYEpubConstants.h
//  E-Publishing
//
//  Created by tangsl on 14-7-31.
//
//

#import <Foundation/Foundation.h>


extern NSString *const HYEpubKitErrorDomain;


typedef NS_ENUM(NSUInteger, HYEpubKitBookType)
{
    HYEpubKitBookTypeUnknown,
    HYEpubKitBookTypeEpub2,
    HYEpubKitBookTypeEpub3,
    HYEpubKitBookTypeiBook
};


typedef NS_ENUM(NSUInteger, HYEpubKitBookEncryption)
{
    HYEpubKitBookEnryptionNone,
    HYEpubKitBookEnryptionFairplay
};


@interface HYEpubConstants : NSObject

@end
