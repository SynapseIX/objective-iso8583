//
//  ISOHelper.m
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 8/29/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import "ISOHelper.h"

@implementation ISOHelper

+ (NSArray *)stringToArray:(NSString *)string {
    if (!string) {
        return nil;
    }
    
    NSMutableArray *chars = [[NSMutableArray alloc] initWithCapacity:string.length];
    
    for (int i=0; i < string.length; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%C", [string characterAtIndex:i]];
        [chars addObject:ichar];
    }
    
    return chars;
}

+ (NSString *)arrayToString:(NSArray *)array {
    if (!array) {
        return nil;
    }
    
    NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i < array.count; i++) {
        [string appendString:array[i]];
    }
    
    return string;
}

+ (NSString *)hexToBinaryAsString:(NSString *)hexString {
    if (!hexString) {
        return nil;
    }
    
    // Validate if it's a hexadecimal number
    NSString *regExPattern = @"[0-9A-F]";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:hexString options:0 range:NSMakeRange(0, hexString.length)];
    if (regExMatches != hexString.length) {
        NSLog(@"Parameter %@ is an invalid hexadecimal number.", hexString);
        return nil;
    }
    
    NSDictionary *conversionTable = [[NSDictionary alloc] initWithObjectsAndKeys:@"0000", @"0", @"0001", @"1", @"0010", @"2", @"0011", @"3", @"0100", @"4", @"0101", @"5", @"0110", @"6", @"0111", @"7", @"1000", @"8", @"1001", @"9", @"1010", @"A", @"1011", @"B", @"1100", @"C", @"1101", @"D", @"1110", @"E", @"1111", @"F", nil];
    
    NSArray *hexArray = [self stringToArray:hexString];
    NSMutableString *result = [NSMutableString string];
    
    for (NSString *hexNumber in hexArray) {
        [result appendString:[conversionTable objectForKey:hexNumber]];
    }
    
    return result;
}

+ (NSString *)binaryToHexAsString:(NSString *)binaryString {
    if (!binaryString) {
        return nil;
    }
    
    // Validate if it's a binary number
    NSString *regExPattern = @"[0-1]";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:binaryString options:0 range:NSMakeRange(0, binaryString.length)];
    if (regExMatches != binaryString.length) {
        NSLog(@"Parameter %@ is an invalid binary number.", binaryString);
        return nil;
    }
    
    // Validate that length is correct (multiple of 4)
    if (binaryString.length % 4 != 0) {
        NSLog(@"Invalid binary string length (%d). It must be multiple of 4.", binaryString.length);
        return nil;
    }
    
    NSDictionary *conversionTable = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"0000", @"1", @"0001", @"2", @"0010", @"3", @"0011", @"4", @"0100", @"5", @"0101", @"6", @"0110", @"7", @"0111", @"8", @"1000", @"9", @"1001", @"A", @"1010", @"B", @"1011", @"C", @"1100", @"D", @"1101", @"E", @"1110", @"F", @"1111", nil];
    
    NSMutableArray *binArray = [[NSMutableArray alloc] initWithCapacity:binaryString.length / 4];
    NSMutableString *result = [NSMutableString string];
    
    for (int i = 0; i < binaryString.length; i += 4) {
        [binArray addObject:[[binaryString substringFromIndex:i] substringToIndex:4]];
        [result appendString:[conversionTable objectForKey:[binArray objectAtIndex:i / 4]]];
    }
    
    return result;
}

+ (NSString *)fillStringWithZeroes:(NSString *)string fieldLength:(NSString *)length {
    if (!string) {
        return nil;
    }
    
    if (!length) {
        return nil;
    }
    
    if ([length rangeOfString:@"."].location != NSNotFound) {
        NSLog(@"The length format is not correct.");
        return string;
    }
    
    int trueLength = [length intValue];
    NSString *regExPattern = @"[0-9]";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    if (regExMatches != string.length) {
        NSLog(@"The string provided \"%@\" is not a numeric string and cannot be filled with zeroes (0).", string);
        return string;
    }
    
    if (string.length >= trueLength) {
        return string;
    }
    
    int zeroesNeeded = trueLength - string.length;
    NSMutableString *result = [NSMutableString string];
    
    for (int i = 0; i < zeroesNeeded; i++) {
        [result appendString:@"0"];
    }
    
    [result appendString:string];
    
    return result;
}

+ (NSString *)fillStringWithBlankSpaces:(NSString *)string fieldLength:(NSString *)length {
    if (!string) {
        return nil;
    }
    
    if (!length) {
        return nil;
    }
    
    if ([length rangeOfString:@"."].location != NSNotFound) {
        NSLog(@"The length format is not correct.");
        return string;
    }
    
    int trueLength = [length intValue];
    NSString *regExPattern = @"[A-Za-z0-9\\s]";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:0 error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    if (regExMatches != string.length) {
        NSLog(@"The string provided \"%@\" is not an alphanumeric string and cannot be filled with blank spaces.", string);
        return string;
    }
    
    if (string.length >= trueLength) {
        return string;
    }
    
    int spacesNeeded = trueLength - string.length;
    NSMutableString *blankSpaces = [NSMutableString string];
    
    for (int i = 0; i < spacesNeeded; i++) {
        [blankSpaces appendString:@" "];
    }
    
    return [NSString stringWithFormat:@"%@%@", string, blankSpaces];
}

+ (NSString *)limitStringWithQuotes:(NSString *)string {
    if (!string) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"\"%@\"", string];
}

+ (NSString *)trimString:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


@end
