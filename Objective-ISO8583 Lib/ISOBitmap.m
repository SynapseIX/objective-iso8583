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

- (id)initWithGivenDataElements:(NSArray *)dataElements configFileName:(NSString *)configFileName {
    self = [super init];

    if (self) {
        _isBinary = YES;
        NSString *pathToConfigFile = !configFileName ? [[NSBundle mainBundle] pathForResource:@"isoconfig" ofType:@"plist"] : [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
        NSDictionary *dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
        NSMutableArray *bitmapTemplate = [[ISOHelper stringToArray:@"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"] mutableCopy];

        for (id dataElement in dataElements) {
            if ([dataElement isEqualToString:@"DE01"]) {
                NSLog(@"You cannot add DE01 explicitly, its value is automatically inferred.");
                self = nil;
                return nil;
            }

            if (![dataElementsScheme objectForKey:dataElement]) {
                NSLog(@"Cannot add %@ because it is not a valid data element defined in the ISO8583 standard or in the isoconfig.plist file or in your custom config file. Please visit http://en.wikipedia.org/wiki/ISO_8583#Data_elements to learn more about data elements.", dataElement);
                self = nil;
                return nil;
            } else {
                // mark the data element on the bitmap
                int indexToUpdate = [[dataElement substringFromIndex:2] intValue] - 1;
                [bitmapTemplate replaceObjectAtIndex:indexToUpdate withObject:@"1"];
            }
        }

        // Check if it has a secondary bitmap (contains DE65...DE128)
        for (id dataElement in dataElements) {
            int index = [[dataElement substringFromIndex:2] intValue] - 1;

            if (index > 63) {
                [bitmapTemplate replaceObjectAtIndex:0 withObject:@"1"];
                _hasSecondaryBitmap = YES;
                break;
            }
        }

        if (_hasSecondaryBitmap) {
            _rawValue = [ISOHelper arrayToString:bitmapTemplate];
            _binaryBitmap = bitmapTemplate;
        } else {
            _rawValue =[[ISOHelper arrayToString:bitmapTemplate] substringToIndex:64];
            _binaryBitmap = [ISOHelper stringToArray:_rawValue];
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

- (NSArray *)dataElementsInBitmap:(NSString *)customConfigFileName {
    NSString *pathToConfigFile = !customConfigFileName ? [[NSBundle mainBundle] pathForResource:@"isoconfig" ofType:@"plist"] : [[NSBundle mainBundle] pathForResource:customConfigFileName ofType:@"plist"];
    NSDictionary *dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
    NSMutableArray *dataElements = [[NSMutableArray alloc] initWithCapacity:_binaryBitmap.count];
    
    for (int i=0; i < _binaryBitmap.count; i++) {
        NSString *bit  = [NSString stringWithFormat:@"%@", _binaryBitmap[i]];
        
        if ([bit isEqualToString:@"1"]) {
            NSString *index = [NSString stringWithFormat:@"%d", i];
            NSString *key = nil;
            
            if (!customConfigFileName) {
                key = index.length == 1 ? [NSString stringWithFormat:@"DE0%d", i + 1] : [NSString stringWithFormat:@"DE%d", i + 1];
            } else {
                NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES comparator:^(id obj1, id obj2) { return [obj1 compare:obj2 options:NSNumericSearch]; }];
                NSArray *sortedKeys = [dataElementsScheme.allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
                key = sortedKeys[i];
            }
            
            
            if ([dataElementsScheme objectForKey:key]) {
                [dataElements addObject:key];
            }
        }
    }
    
    return dataElements;
}

@end
