//
//  ISOBitmap.h
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 9/3/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISOBitmap : NSObject

@property (readonly) NSArray *binaryBitmap;
@property (readonly) BOOL hasSecondaryBitmap;
@property (readonly) NSString *rawValue;
@property (readonly) BOOL isBinary;

- (id)initWithBinaryString:(NSString *)binaryString;
- (id)initWithHexString:(NSString *)hexString;
- (NSString *)bitmapAsBinaryString;
- (NSString *)bitmapAsHexString;
- (NSArray *)dataElementsInBitmap:(NSString *)customConfigFileName;

@end
