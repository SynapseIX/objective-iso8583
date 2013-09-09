//
//  ISOMessage.h
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 8/29/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISOBitmap.h"

@interface ISOMessage : NSObject

@property (readonly) NSString *mti;
@property (strong, nonatomic) ISOBitmap *bitmap;
@property (readonly) BOOL hasSecondaryBitmap;
@property NSMutableDictionary *dataElements;

- (id)init;
- (id)initWithIsoMessage:(NSString *)isoMessage;
- (id)initWithIsoMessageAndHeader:(NSString *)isoMessage;

- (BOOL)setMTI:(NSString *)mti;
- (BOOL)addDataElement:(NSString *)elementName withValue:(NSString *)value;
- (NSString *)getHexBitmap1;
- (NSString *)getBinaryBitmap1;
- (NSString *)getHexBitmap2;
- (NSString *)getBinaryBitmap2;
- (NSString *)buildIsoMessage;
- (NSString *)buildIsoMessageWithISOHeader;

@end
