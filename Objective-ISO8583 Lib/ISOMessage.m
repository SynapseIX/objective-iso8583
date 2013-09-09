//
//  ISOMessage.m
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 8/29/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import "ISOMessage.h"
#import "ISODataElement.h"
#import "ISOHelper.h"

@interface ISOMessage()
    @property (strong, nonatomic) NSDictionary *dataElementsScheme;
@end

@implementation ISOMessage

- (id)init {
    self = [super init];
    
    if (self) {
        NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"isoconfig" ofType:@"plist"];
        _dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
        _dataElements = [NSMutableDictionary dictionaryWithCapacity:[_dataElementsScheme count]];
    }
    
    return self;
}

- (id)initWithIsoMessage:(NSString *)isoMessage {
    if ([[isoMessage substringToIndex:3] isEqualToString:@"ISO"]) {
        NSLog(@"The ISO header is present. Please use the 'initWithIsoMessageAndHeader' method to build the ISOMessage.");
        return nil;
    }
    
    self = [self init];
    
    if (self) {
        [self setMTI:[isoMessage substringToIndex:4]];
        NSString *bitmapFirstBit = [[isoMessage substringFromIndex:4] substringToIndex:1];
        
        _hasSecondaryBitmap = [bitmapFirstBit isEqualToString:@"8"] || [bitmapFirstBit isEqualToString:@"9"] || [bitmapFirstBit isEqualToString:@"A"] || [bitmapFirstBit isEqualToString:@"B"] || [bitmapFirstBit isEqualToString:@"C"] || [bitmapFirstBit isEqualToString:@"D"] || [bitmapFirstBit isEqualToString:@"E"] || [bitmapFirstBit isEqualToString:@"F"];
        
        
        _bitmap = _hasSecondaryBitmap ? [[ISOBitmap alloc] initWithHexString:[[isoMessage substringFromIndex:4] substringToIndex:32]] : [[ISOBitmap alloc] initWithHexString:[[isoMessage substringFromIndex:4] substringToIndex:16]];
        
        NSString *dataElementValues = _hasSecondaryBitmap ? [isoMessage substringFromIndex:36] : [isoMessage substringFromIndex:20];
        NSArray *theValues = [self extractDataElementValuesFromIsoString:dataElementValues withDataElements:[_bitmap dataElementsInBitmap]];
        
        NSLog(@"MTI:%@", _mti);
        NSLog(@"Bitmap:%@", _bitmap.rawValue);
        for (int i = 1; i < [_bitmap dataElementsInBitmap].count; i++) {
            [self addDataElement:_bitmap.dataElementsInBitmap[i] withValue:theValues[i - 1]];
        }
    }
    
    return self;
}

- (id)initWithIsoMessageAndHeader:(NSString *)isoMessage {
    if (![[isoMessage substringToIndex:3] isEqualToString:@"ISO"]) {
        NSLog(@"The ISO header is missing. Please use the 'initWithIsoMessage' method to build the ISOMessage.");
        return nil;
    }
    
    self = [self init];
    
    if (self) {
        [self setMTI:[[isoMessage substringFromIndex:3] substringToIndex:4]];
        NSString *bitmapFirstBit = [[isoMessage substringFromIndex:7] substringToIndex:1];
        
        _hasSecondaryBitmap = [bitmapFirstBit isEqualToString:@"8"] || [bitmapFirstBit isEqualToString:@"9"] || [bitmapFirstBit isEqualToString:@"A"] || [bitmapFirstBit isEqualToString:@"B"] || [bitmapFirstBit isEqualToString:@"C"] || [bitmapFirstBit isEqualToString:@"D"] || [bitmapFirstBit isEqualToString:@"E"] || [bitmapFirstBit isEqualToString:@"F"];
        
        
        _bitmap = _hasSecondaryBitmap ? [[ISOBitmap alloc] initWithHexString:[[isoMessage substringFromIndex:7] substringToIndex:32]] : [[ISOBitmap alloc] initWithHexString:[[isoMessage substringFromIndex:7] substringToIndex:16]];
        
        NSString *dataElementValues = _hasSecondaryBitmap ? [isoMessage substringFromIndex:39] : [isoMessage substringFromIndex:23];
        NSArray *theValues = [self extractDataElementValuesFromIsoString:dataElementValues withDataElements:[_bitmap dataElementsInBitmap]];
        
        NSLog(@"MTI:%@", _mti);
        NSLog(@"Bitmap:%@", _bitmap.rawValue);
        for (int i = 1; i < [_bitmap dataElementsInBitmap].count; i++) {
            [self addDataElement:_bitmap.dataElementsInBitmap[i] withValue:theValues[i - 1]];
        }
    }
    
    return self;
}

- (BOOL)setMTI:(NSString *)mti {
    if ([self isMTIValid:mti]) {
        _mti = mti;
        return YES;
    } else {
        NSLog(@"The MTI is not valid. Please set a valid MTI like the ones described in the isoMTI.plist file.");
        return NO;
    }
}

- (BOOL)addDataElement:(NSString *)elementName withValue:(NSString *)value  {
    if (!_bitmap) {
        NSLog(@"Cannot add data elements without setting the bitmap before.");
        return NO;
    }
    
    if (!elementName) {
        NSLog(@"Cannot add data elements with a nil name.");
        return NO;
    }
    
    if (!value) {
        NSLog(@"Cannot add data elements with a nil value.");
        return NO;
    }
    
    NSArray *binaryBitmap = [_bitmap binaryBitmap];
    NSString *dataElementNumber;
    
    if (elementName.length == 4 && [[elementName substringToIndex:1] isEqualToString:@"0"]) {
        dataElementNumber = [elementName substringFromIndex:3];
    } else if (elementName.length == 4 && ![[elementName substringToIndex:1] isEqualToString:@"0"]) {
        dataElementNumber = [elementName substringFromIndex:2];
    } else if (elementName.length == 5) {
        dataElementNumber = [elementName substringFromIndex:2];
    }
    
    int dataElementIndex = [dataElementNumber intValue] - 1;
    
    
    if (![binaryBitmap[dataElementIndex] isEqualToString:@"1"]) {
        NSLog(@"Cannot add %@ because it is not declared in the bitmap.", elementName);
        return NO;
    }
    
    NSString *type = [_dataElementsScheme valueForKeyPath:[NSString stringWithFormat:@"%@.Type", elementName]];
    NSString *length = [_dataElementsScheme valueForKeyPath:[NSString stringWithFormat:@"%@.Length", elementName]];
    
    ISODataElement *dataElement = [[ISODataElement alloc] initWithName:elementName value:value dataType:type length:length];
    
    if (dataElement) {
        [_dataElements setObject:dataElement forKey:elementName];
        return YES;
    }
    
    return NO;
}

- (NSString *)getHexBitmap1 {
    return [[_bitmap bitmapAsHexString] substringToIndex:16];
}

- (NSString *)getBinaryBitmap1 {
    return [[_bitmap bitmapAsBinaryString] substringToIndex:64];
}

- (NSString *)getHexBitmap2 {
    if (_bitmap.isBinary && _bitmap.rawValue.length != 128) {
        NSLog(@"This bitmap does not have a secondary bitmap.");
        return nil;
    } else if (!_bitmap.isBinary && _bitmap.rawValue.length != 32) {
        NSLog(@"This bitmap does not have a secondary bitmap.");
        return nil;
    } else if (_bitmap.isBinary && _bitmap.rawValue.length == 128) {
        return [ISOHelper binaryToHexAsString:[_bitmap.rawValue substringFromIndex:64]];
    } else if (!_bitmap.isBinary && _bitmap.rawValue.length == 32) {
        return [_bitmap.rawValue substringFromIndex:16];
    }
    
    return nil;
}

- (NSString *)getBinaryBitmap2 {
    if (_bitmap.isBinary && _bitmap.rawValue.length != 128) {
        NSLog(@"This bitmap does not have a secondary bitmap.");
        return nil;
    } else if (!_bitmap.isBinary && _bitmap.rawValue.length != 32) {
        NSLog(@"This bitmap does not have a secondary bitmap.");
        return nil;
    } else if (_bitmap.isBinary && _bitmap.rawValue.length == 128) {
        return [_bitmap.rawValue substringFromIndex:64];
    } else if (!_bitmap.isBinary && _bitmap.rawValue.length == 32) {
        return [ISOHelper hexToBinaryAsString:[_bitmap.rawValue substringFromIndex:16]];
    }
    
    return nil;
}

- (NSString *)buildIsoMessage {
    if (!_bitmap) {
        NSLog(@"The bitmap does not exist.");
        return nil;
    }
    
    if (_dataElements.count == 0) {
        NSLog(@"There are no data elements.");
        return nil;
    }
    
    if (!_mti) {
        NSLog(@"The MTI does not exist.");
        return nil;
    }
    
    NSMutableString *isoMessage = [NSMutableString string];
    [isoMessage appendString:_mti];
    [isoMessage appendString:[_bitmap bitmapAsHexString]];
    
    for (id dataElement in [_bitmap dataElementsInBitmap]) {
        if ([dataElement isEqualToString:@"DE01"]) {
            continue;
        }
        
        [isoMessage appendString:((ISODataElement *)[_dataElements objectForKey:dataElement]).value];
    }
    
    return isoMessage;
}

- (NSString *)buildIsoMessageWithISOHeader {
    NSMutableString *isoMessage = [NSMutableString string];
    [isoMessage appendString:@"ISO"];
    [isoMessage appendString:[self buildIsoMessage]];
    
    return isoMessage;
}

- (BOOL)isMTIValid:(NSString *)mti {
    NSString *pathToMtiConfigFile = [[NSBundle mainBundle] pathForResource:@"isoMTI" ofType:@"plist"];
    NSArray *validMTIs = [NSArray arrayWithContentsOfFile:pathToMtiConfigFile];
    int index = [validMTIs indexOfObject:mti];
    return index > -1;
}

- (NSArray *)extractDataElementValuesFromIsoString:(NSString *)isoMessageDataElementValues withDataElements:(NSArray *)dataElements {
    int dataElementCount = 0;
    int fromIndex = -1;
    int toIndex = -1;
    NSMutableArray *values = [NSMutableArray array];
    
    for (id dataElement in dataElements) {
        if ( [dataElement isEqualToString:@"DE01"]) {
            continue;
        }
        
        NSString *length = [_dataElementsScheme valueForKeyPath:[NSString stringWithFormat:@"%@.Length", dataElement]];
        
        // fixed length values
        if ([length rangeOfString:@"."].location == NSNotFound) {
            int trueLength = [length intValue];
            if (dataElementCount == 0) {
                fromIndex = 0;
                toIndex = trueLength;
                NSString *value = [[isoMessageDataElementValues substringFromIndex:fromIndex] substringToIndex:toIndex];
                [values addObject:value];
                fromIndex = trueLength;
            } else {
                toIndex = trueLength;
                NSString *value = [[isoMessageDataElementValues substringFromIndex:fromIndex] substringToIndex:toIndex];
                [values addObject:value];
                fromIndex += trueLength;
            }
        }
        
        // variable length values
        if ([length rangeOfString:@"."].location != NSNotFound) {
            int trueLength = -1;
            int numberOfLengthDigits = 0;
            
            if (length.length == 2) {
                numberOfLengthDigits = 1;
            } else if (length.length == 4) {
                numberOfLengthDigits = 2;
            } else if (length.length == 6) {
                numberOfLengthDigits = 3;
            }
            
            if (dataElementCount == 0) {
                trueLength = [[isoMessageDataElementValues substringToIndex:numberOfLengthDigits] intValue] + numberOfLengthDigits;
                fromIndex = 0 + numberOfLengthDigits;
                toIndex = trueLength - numberOfLengthDigits;
                NSString *value = [[isoMessageDataElementValues substringFromIndex:fromIndex] substringToIndex:toIndex];
                [values addObject:value];
                fromIndex = trueLength;
            } else {
                trueLength = [[[isoMessageDataElementValues substringFromIndex:fromIndex] substringToIndex:numberOfLengthDigits] intValue] + numberOfLengthDigits;
                toIndex = trueLength;
                NSString *value = [[isoMessageDataElementValues substringFromIndex:fromIndex + numberOfLengthDigits] substringToIndex:toIndex - numberOfLengthDigits];
                [values addObject:value];
                fromIndex += trueLength;
            }
        }
        
        dataElementCount++;
    }
    
    return values;
}

@end
