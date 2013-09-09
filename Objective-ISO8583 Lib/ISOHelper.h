//
//  ISOHelper.h
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 8/29/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISOHelper : NSObject

+ (NSArray *)stringToArray:(NSString *)string;
+ (NSString *)arrayToString:(NSArray *)array;
+ (NSString *)hexToBinaryAsString:(NSString *)hexString;
+ (NSString *)binaryToHexAsString:(NSString *)binaryString;
+ (NSString *)fillStringWithZeroes:(NSString *)string fieldLength:(NSString *)length;
+ (NSString *)fillStringWithBlankSpaces:(NSString *)string fieldLength:(NSString *)length;
+ (NSString *)limitStringWithQuotes:(NSString *)string;

@end
