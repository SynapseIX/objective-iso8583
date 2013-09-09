//
//  ISODataElement.h
//  Objective-ISO8583
//
//  For more information about ISO8583 formats, go to http://en.wikipedia.org/wiki/ISO_8583
//
//  Created by Jorge Tapia on 9/3/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISODataElement : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *value;
@property (readonly) NSString *dataType;
@property (readonly) NSString *length;

- (id)initWithName:(NSString *)name value:(NSString *)value dataType:(NSString *)dataType length:(NSString *)length;

@end
