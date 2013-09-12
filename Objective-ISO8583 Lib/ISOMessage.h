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
@property (readonly) BOOL usesCustomConfiguration;
@property NSMutableDictionary *dataElements;

- (id)init;
- (id)initWithIsoMessage:(NSString *)isoMessage;
- (id)initWithIsoMessageAndHeader:(NSString *)isoMessage;
- (id)initWithCustomIsoMessage:(NSString *)customIsoMessage configFileName:(NSString *)configFileName customMTIFileName:(NSString *)customMTIFileName;
- (id)initWithCustomIsoMessageAndHeader:(NSString *)customIsoMessage configFileName:(NSString *)configFileName customMTIFileName:(NSString *)customMTIFileName;

- (BOOL)useCustomConfigurationFile:(NSString *)customConfigurationFileName andCustomMTIFileName:(NSString *)customMTIFileName;

- (BOOL)setMTI:(NSString *)mti;
- (BOOL)addDataElement:(NSString *)elementName withValue:(NSString *)value configFileName:(NSString *)configFileName;
- (NSString *)getHexBitmap1;
- (NSString *)getBinaryBitmap1;
- (NSString *)getHexBitmap2;
- (NSString *)getBinaryBitmap2;
- (NSString *)buildIsoMessage:(NSString *)customConfigFileName;
- (NSString *)buildIsoMessageWithISOHeader:(NSString *)customConfigFileName;

@end
