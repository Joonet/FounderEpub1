//  HYEpubContentModel.h
//  E-Publishing
//
//  Created by tangsl on 14-7-31.
//
//

#import <Foundation/Foundation.h>
#import "HYEpubConstants.h"

@interface HYEpubContentModel : NSObject


@property (nonatomic) HYEpubKitBookType bookType;
@property (nonatomic) HYEpubKitBookEncryption bookEncryption;

@property (nonatomic, strong) NSDictionary *metaData;
@property (nonatomic, strong) NSString *coverPath;
@property (nonatomic, strong) NSDictionary *manifest;
@property (nonatomic, strong) NSArray *spine;
@property (nonatomic, strong) NSArray *guide;


@end
