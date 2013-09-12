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
    @property (strong, nonatomic) NSArray *validMTIs;
@end

@implementation ISOMessage

- (id)init {
    self = [super init];
    
    if (self) {
        NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:@"isoconfig" ofType:@"plist"];
        _dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
        _dataElements = [NSMutableDictionary dictionaryWithCapacity:[_dataElementsScheme count]];
        
        NSString *pathToMTIConfigFile = [[NSBundle mainBundle] pathForResource:@"isoMTI" ofType:@"plist"];
        _validMTIs = [NSDictionary dictionaryWithContentsOfFile:pathToMTIConfigFile];
        
        _usesCustomConfiguration = NO;
    }
    
    return self;
}

- (id)initWithIsoMessage:(NSString *)isoMessage {
    if (!isoMessage) {
        NSLog(@"The isoMessage cannot be nil.");
        return nil;
    }
    
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
        NSArray *theValues = [self extractDataElementValuesFromIsoString:dataElementValues withDataElements:[_bitmap dataElementsInBitmap:nil]];
        
        NSLog(@"MTI:%@", _mti);
        NSLog(@"Bitmap:%@", _bitmap.rawValue);
        for (int i = 1; i < [_bitmap dataElementsInBitmap:nil].count; i++) {
            [self addDataElement:[_bitmap dataElementsInBitmap:nil][i] withValue:theValues[i - 1] configFileName:nil];
        }
        
        _usesCustomConfiguration = NO;
    }
    
    return self;
}

- (id)initWithIsoMessageAndHeader:(NSString *)isoMessage {
    if (!isoMessage) {
        NSLog(@"The isoMessage cannot be nil.");
        return nil;
    }
    
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
        NSArray *theValues = [self extractDataElementValuesFromIsoString:dataElementValues withDataElements:[_bitmap dataElementsInBitmap:nil]];
        
        NSLog(@"MTI:%@", _mti);
        NSLog(@"Bitmap:%@", _bitmap.rawValue);
        for (int i = 1; i < [_bitmap dataElementsInBitmap:nil].count; i++) {
            [self addDataElement:[_bitmap dataElementsInBitmap:nil][i] withValue:theValues[i - 1] configFileName:nil];
        }
        
        _usesCustomConfiguration = NO;
    }
    
    return self;
}

- (id)initWithCustomIsoMessage:(NSString *)customIsoMessage configFileName:(NSString *)configFileName customMTIFileName:(NSString *)customMTIFileName {
    if (!customIsoMessage) {
        NSLog(@"The customIsoMessage cannot be nil.");
        return nil;
    }
    
    if (!configFileName) {
        NSLog(@"The custom configuration file name must be provided and part of the application bundle.");
        return nil;
    }
    
    if ([[customIsoMessage substringToIndex:3] isEqualToString:@"ISO"]) {
        NSLog(@"The ISO header is present. Please use the 'initWithCustomIsoMessageAndHeader' method to build the ISOMessage.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _dataElementsScheme = nil;
        _dataElements = nil;
        _validMTIs = nil;
        
        NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
        _dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
        _dataElements = [NSMutableDictionary dictionaryWithCapacity:[_dataElementsScheme count]];
        
        if (!customMTIFileName) {
            NSString *pathToMTIConfigFile = [[NSBundle mainBundle] pathForResource:@"isoMTI" ofType:@"plist"];
            _validMTIs = [NSDictionary dictionaryWithContentsOfFile:pathToMTIConfigFile];
        } else {
            NSString *pathToMTIConfigFile = [[NSBundle mainBundle] pathForResource:customMTIFileName ofType:@"plist"];
            _validMTIs = [NSDictionary dictionaryWithContentsOfFile:pathToMTIConfigFile];
        }
        
        [self setMTI:[customIsoMessage substringToIndex:4]];
        _hasSecondaryBitmap = NO;
        
        _bitmap = [[ISOBitmap alloc] initWithHexString:[[customIsoMessage substringFromIndex:4] substringToIndex:16]];
        
        NSString *dataElementValues = [customIsoMessage substringFromIndex:20];
        NSArray *theValues = [self extractDataElementValuesFromIsoString:dataElementValues withDataElements:[_bitmap dataElementsInBitmap:configFileName]];
        
        NSLog(@"MTI:%@", _mti);
        NSLog(@"Bitmap:%@", _bitmap.rawValue);
        for (int i = 0; i < [_bitmap dataElementsInBitmap:configFileName].count; i++) {
            [self addDataElement:[_bitmap dataElementsInBitmap:configFileName][i] withValue:theValues[i] configFileName:configFileName];
        }
        
        _usesCustomConfiguration = YES;
    }
    
    return self;
}

- (id)initWithCustomIsoMessageAndHeader:(NSString *)customIsoMessage configFileName:(NSString *)configFileName customMTIFileName:(NSString *)customMTIFileName {
    if (!customIsoMessage) {
        NSLog(@"The customIsoMessage cannot be nil.");
        return nil;
    }
    
    if (!configFileName) {
        NSLog(@"The custom configuration file name must be provided and part of the application bundle.");
        return nil;
    }
    
    if (![[customIsoMessage substringToIndex:3] isEqualToString:@"ISO"]) {
        NSLog(@"The ISO header is missing. Please use the 'initWithCustomIsoMessage' method to build the ISOMessage.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _dataElementsScheme = nil;
        _dataElements = nil;
        _validMTIs = nil;
        
        NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
        _dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
        _dataElements = [NSMutableDictionary dictionaryWithCapacity:[_dataElementsScheme count]];
        
        if (!customMTIFileName) {
            NSString *pathToMTIConfigFile = [[NSBundle mainBundle] pathForResource:@"isoMTI" ofType:@"plist"];
            _validMTIs = [NSDictionary dictionaryWithContentsOfFile:pathToMTIConfigFile];
        } else {
            NSString *pathToMTIConfigFile = [[NSBundle mainBundle] pathForResource:customMTIFileName ofType:@"plist"];
            _validMTIs = [NSDictionary dictionaryWithContentsOfFile:pathToMTIConfigFile];
        }
        
        [self setMTI:[[customIsoMessage substringFromIndex:3] substringToIndex:4]];
        _hasSecondaryBitmap = NO;
        
        _bitmap = [[ISOBitmap alloc] initWithHexString:[[customIsoMessage substringFromIndex:7] substringToIndex:16]];
        
        NSString *dataElementValues = [customIsoMessage substringFromIndex:23];
        NSArray *theValues = [self extractDataElementValuesFromIsoString:dataElementValues withDataElements:[_bitmap dataElementsInBitmap:configFileName]];
        
        NSLog(@"MTI:%@", _mti);
        NSLog(@"Bitmap:%@", _bitmap.rawValue);
        for (int i = 0; i < [_bitmap dataElementsInBitmap:configFileName].count; i++) {
            [self addDataElement:[_bitmap dataElementsInBitmap:configFileName][i] withValue:theValues[i] configFileName:configFileName];
        }
        
        _usesCustomConfiguration = YES;
    }
    
    return self;
}

- (BOOL)useCustomConfigurationFile:(NSString *)customConfigurationFileName andCustomMTIFileName:(NSString *)customMTIFileName {
    if (!customConfigurationFileName) {
        NSLog(@"The customConfigurationFileName cannot be nil.");
        return NO;
    }
    
    if (!customMTIFileName) {
        NSLog(@"The customMTIFileName cannot be nil.");
        return NO;
    }
    
    _dataElementsScheme = nil;
    _dataElements = nil;
    _validMTIs = nil;
    
    NSString *pathToConfigFile = [[NSBundle mainBundle] pathForResource:customConfigurationFileName ofType:@"plist"];
    _dataElementsScheme = [NSDictionary dictionaryWithContentsOfFile:pathToConfigFile];
    _dataElements = [NSMutableDictionary dictionaryWithCapacity:[_dataElementsScheme count]];
    _usesCustomConfiguration = YES;
    
    NSString *pathToMTIConfigFile = [[NSBundle mainBundle] pathForResource:customMTIFileName ofType:@"plist"];
    _validMTIs = [NSDictionary dictionaryWithContentsOfFile:pathToMTIConfigFile];
    
    return YES;
}

- (BOOL)setMTI:(NSString *)mti {
    if ([self isMTIValid:mti]) {
        _mti = mti;
        return YES;
    } else {
        NSLog(@"The MTI is not valid. Please set a valid MTI like the ones described in the isoMTI.plist or your custom MTI configuration file.");
        return NO;
    }
}

- (BOOL)addDataElement:(NSString *)elementName withValue:(NSString *)value configFileName:(NSString *)configFileName {
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
    
    if (!configFileName) {
        if (elementName.length == 4 && [[elementName substringToIndex:1] isEqualToString:@"0"]) {
            dataElementNumber = [elementName substringFromIndex:3];
        } else if (elementName.length == 4 && ![[elementName substringToIndex:1] isEqualToString:@"0"]) {
            dataElementNumber = [elementName substringFromIndex:2];
        } else if (elementName.length == 5) {
            dataElementNumber = [elementName substringFromIndex:2];
        }
    } else {
        // Intermediate
        dataElementNumber = [elementName substringFromIndex:[elementName rangeOfString:@"_"].location + 1];
    }
    
    int dataElementIndex = [dataElementNumber intValue] - 1;
    
    
    if (![binaryBitmap[dataElementIndex] isEqualToString:@"1"]) {
        NSLog(@"Cannot add %@ because it is not declared in the bitmap.", elementName);
        return NO;
    }
    
    NSString *type = [_dataElementsScheme valueForKeyPath:[NSString stringWithFormat:@"%@.Type", elementName]];
    NSString *length = [_dataElementsScheme valueForKeyPath:[NSString stringWithFormat:@"%@.Length", elementName]];
    
    ISODataElement *dataElement = [[ISODataElement alloc] initWithName:elementName value:value dataType:type length:length customConfigFileName:configFileName];
    
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

- (NSString *)buildIsoMessage:(NSString *)customConfigFileName {
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
    
    for (id dataElement in [_bitmap dataElementsInBitmap:customConfigFileName]) {
        if ([dataElement isEqualToString:@"DE01"]) {
            continue;
        }
        
        [isoMessage appendString:((ISODataElement *)[_dataElements objectForKey:dataElement]).value];
    }
    
    return isoMessage;
}

- (NSString *)buildIsoMessageWithISOHeader:(NSString *)customConfigFileName {
    NSMutableString *isoMessage = [NSMutableString string];
    [isoMessage appendString:@"ISO"];
    [isoMessage appendString:[self buildIsoMessage:customConfigFileName]];
    
    return isoMessage;
}

- (BOOL)isMTIValid:(NSString *)mti {
    int index = [_validMTIs indexOfObject:mti];
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
