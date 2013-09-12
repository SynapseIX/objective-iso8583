//
//  ISODataElement.m
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 9/3/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import "ISODataElement.h"
#import "ISOHelper.h"

@implementation ISODataElement

- (id)initWithName:(NSString *)name value:(NSString *)value dataType:(NSString *)dataType length:(NSString *)length customConfigFileName:(NSString *)customConfigFileName {
    self = [super init];
    
    if (self) {
        if (!name) {
            NSLog(@"The name cannot be nil");
            self = nil;
            return nil;
        }
        
        if ([name isEqualToString:@"DE01"]) {
            NSLog(@"DE01 is reserved for the bitmap and cannot be added through this method.");
            self = nil;
            return nil;
        }
        
        if (![self isValidDataType:dataType]) {
            NSLog(@"The data type \"%@\" is invalid. Please visit http://en.wikipedia.org/wiki/ISO_8583#Data_elements to learn more about data types.", dataType);
            self = nil;
            return nil;
        }
        
        NSString *pathToConfigFile = !customConfigFileName ? [[NSBundle mainBundle] pathForResource:@"isoconfig" ofType:@"plist"] : [[NSBundle mainBundle] pathForResource:customConfigFileName ofType:@"plist"];
        NSDictionary *dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
        
        if ([dataElementsScheme objectForKey:name]) {
            NSString *length = [dataElementsScheme valueForKeyPath:[NSString stringWithFormat:@"%@.Length", name]];
            
            // validate value with data type
            if (![self isValue:value compliantWithDataType:dataType]) {
                NSLog(@"The value \"%@\" is not compliant with data type \"%@\"", value, dataType);
                self = nil;
                return nil;
            }
            
            _name = name;
            _dataType = dataType;
            _length = length;
            
            // set value according to length and data type
            if (([dataType isEqualToString:@"an"] || [dataType isEqualToString:@"ans"]) && [length rangeOfString:@"."].location == NSNotFound) {
                _value = [ISOHelper fillStringWithBlankSpaces:value fieldLength:length];
            } else if ([dataType isEqualToString:@"n"] && [length rangeOfString:@"."].location == NSNotFound) {
                _value = [ISOHelper fillStringWithZeroes:value fieldLength:length];
            } else {
                // value has variable length
                if ([length rangeOfString:@"."].location != NSNotFound) {
                    int maxLength = -1;
                    int numberOfLengthDigits = -1;
                    NSString *trueLength = nil;
                    
                    if (length.length == 2) {
                        maxLength = [[length substringFromIndex:1] intValue];
                        numberOfLengthDigits = 1;
                    } else if (length.length == 4) {
                        maxLength = [[length substringFromIndex:2] intValue];
                        numberOfLengthDigits = 2;
                    } else if (length.length == 6) {
                        maxLength = [[length substringFromIndex:3] intValue];
                        numberOfLengthDigits = 3;
                    }
                    
                    // validate length of value
                    if (value.length > maxLength) {
                        NSLog(@"The value length \"%d\" is greater to the provided length \"%@\".", value.length, length);
                        self = nil;
                        return nil;
                    }
                    
                    // fill with zeroes if needed
                    if (numberOfLengthDigits == 1) {
                        trueLength = [NSString stringWithFormat:@"%d", value.length];
                    }
                    
                    if (numberOfLengthDigits == 2 && value.length < 10) {
                        trueLength = [NSString stringWithFormat:@"0%d", value.length];
                    } else {
                        trueLength = [NSString stringWithFormat:@"%d", value.length];
                    }
                    
                    if (numberOfLengthDigits == 3 && value.length < 10) {
                        trueLength = [NSString stringWithFormat:@"00%d", value.length];
                    } else if (numberOfLengthDigits == 3 && value.length >= 10 && value.length < 100) {
                        trueLength = [NSString stringWithFormat:@"0%d", value.length];
                    } else if (numberOfLengthDigits == 3 && value.length >= 100 && value.length < 1000) {
                        trueLength = [NSString stringWithFormat:@"%d", value.length];
                    }
                    
                    _value = [NSString stringWithFormat:@"%@%@", trueLength, value];
                } else {
                    // has no variable value
                    if (value.length == [length intValue]) {
                        _value = value;
                    } else {
                        NSLog(@"The value \"%@\" length is not equal to the provided length \"%@\".", value, length);
                        self = nil;
                        return nil;
                    }
                }
            }
            
            return self;
        } else {
            NSLog(@"Cannot add %@ because it is not a valid data element defined in the ISO8583 standard or in the isoconfig.plist file or in your custom config file. Please visit http://en.wikipedia.org/wiki/ISO_8583#Data_elements to learn more about data elements.", name);
            return nil;
        }
    }
    
    return nil;
}

- (BOOL) isValidDataType:(NSString *)dataType {
    NSString *pathToDataTypeConfigFile = [[NSBundle mainBundle] pathForResource:@"isodatatypes" ofType:@"plist"];
    NSArray *validDataTypes = [NSArray arrayWithContentsOfFile:pathToDataTypeConfigFile];
    int index = [validDataTypes indexOfObject:dataType];
    
    return index > -1;
}

- (BOOL)isValue:(NSString *)value compliantWithDataType:(NSString *)dataType {
    if ([dataType isEqualToString:@"a"]) {
        NSString *regExPattern = @"[A-Za-z\\s]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"n"]) {
        NSString *regExPattern = @"[0-9]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"a"]) {
        NSString *regExPattern = @"[A-Za-z\\s]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"s"]) {
        NSString *regExPattern = @"[^A-Za-z0-9\\s]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"an"]) {
        NSString *regExPattern = @"[A-Za-z0-9\\s]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"as"]) {
        NSString *regExPattern = @"[A-Za-z0-9\\s\\W]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"ns"]) {
        NSString *regExPattern = @"[0-9\\W]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"ans"]) {
        NSString *regExPattern = @"[A-Za-z0-9\\s\\W]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    if ([dataType isEqualToString:@"b"]) {
        NSString *regExPattern = @"[0-9A-F]";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:value options:0 range:NSMakeRange(0, value.length)];
        
        if (regExMatches != value.length) {
            return NO;
        } else {
            return YES;
        }
    }
    
    #warning TODO: correctly validate type z
    if ([dataType isEqualToString:@"z"]) {
        return YES;
    }
    
    return NO;
}

@end
