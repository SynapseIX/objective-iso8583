//
//  ISOBitmap.m
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 9/3/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import "ISOBitmap.h"
#import "ISOHelper.h"

@implementation ISOBitmap

- (id)initWithBinaryString:(NSString *)binaryString {
    self = [super init];
    
    if (self) {
        // Validate if it's a binary number
        NSString *regExPattern = @"[0-1]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:binaryString options:0 range:NSMakeRange(0, binaryString.length)];
        if (regExMatches != binaryString.length) {
            NSLog(@"Parameter %@ is an invalid binary number.", binaryString);
            self = nil;
            return nil;
        }
        
         _hasSecondaryBitmap = [[binaryString substringToIndex:1] isEqualToString:@"1"];
        
        if (_hasSecondaryBitmap && binaryString.length != 128) {
            NSLog(@"Invalid bitmap. Bitmap length must be 128 if the first bit is 1.");
            return nil;
        } else if (!_hasSecondaryBitmap && binaryString.length != 64) {
            NSLog(@"Invalid bitmap. Bitmap length must be 64 if the first bit is 0.");
            return nil;
        } else {
            _rawValue = binaryString;
            _isBinary = YES;
            _binaryBitmap = [ISOHelper stringToArray:binaryString];
        }
    }
    
    return self;
}

- (id)initWithHexString:(NSString *)hexString {
    self = [super init];
    
    if (self) {
        // Validate if it's a hexadecimal number
        NSString *regExPattern = @"[0-9A-F]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:hexString options:0 range:NSMakeRange(0, hexString.length)];
        if (regExMatches != hexString.length) {
            NSLog(@"Parameter %@ is an invalid hexadecimal number.", hexString);
            self = nil;
            return nil;
        }
        
        _hasSecondaryBitmap = [[hexString substringToIndex:1] isEqualToString:@"8"] || [[hexString substringToIndex:1] isEqualToString:@"9"] || [[hexString substringToIndex:1] isEqualToString:@"A"] || [[hexString substringToIndex:1] isEqualToString:@"B"] || [[hexString substringToIndex:1] isEqualToString:@"C"] || [[hexString substringToIndex:1] isEqualToString:@"D"] || [[hexString substringToIndex:1] isEqualToString:@"E"] | [[hexString substringToIndex:1] isEqualToString:@"F"];
        
        if (_hasSecondaryBitmap && hexString.length != 32) {
            NSLog(@"Invalid bitmap. Hexadecimal bitmap length must be 32 if the first byte is not 0.");
            self = nil;
            return nil;
        } else if (!_hasSecondaryBitmap && hexString.length != 16) {
            NSLog(@"Invalid bitmap. Bitmap length must be 16 if the first byte is 0.");
            self = nil;
            return nil;
        } else {
            _rawValue = hexString;
            _isBinary = NO;
            _binaryBitmap = [ISOHelper stringToArray:[ISOHelper hexToBinaryAsString:hexString]];
        }
    }
    
    return self;
}

- (NSString *)bitmapAsBinaryString {
    return _isBinary ? _rawValue : [ISOHelper hexToBinaryAsString:_rawValue];
}

- (NSString *)bitmapAsHexString {
    return !_isBinary ? _rawValue : [ISOHelper binaryToHexAsString:_rawValue];
}

- (NSArray *)dataElementsInBitmap {
    NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"isoconfig" ofType:@"plist"];
    NSDictionary *dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
    NSMutableArray *dataElements = [[NSMutableArray alloc] initWithCapacity:_binaryBitmap.count];
    
    for (int i=0; i < _binaryBitmap.count; i++) {
        NSString *bit  = [NSString stringWithFormat:@"%@", _binaryBitmap[i]];
        if ([bit isEqualToString:@"1"]) {
            NSString *index = [NSString stringWithFormat:@"%d", i];
            NSString *key = index.length == 1 ? [NSString stringWithFormat:@"DE0%d", i + 1] : [NSString stringWithFormat:@"DE%d", i + 1];
            if ([dataElementsScheme objectForKey:key]) {
                [dataElements addObject:key];
            }
        }
    }
    
    return dataElements;
}

@end
