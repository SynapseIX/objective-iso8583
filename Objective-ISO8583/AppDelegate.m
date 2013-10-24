//
//  AppDelegate.m
//  Objective-ISO8583
//
//  Created by Jorge Tapia on 8/29/13.
//  Copyright (c) 2013 Mindshake Interactive. All rights reserved.
//

#import "AppDelegate.h"
#import "ISOMessage.h"
#import "ISODataElement.h"
#import "ISOBitmap.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Example of usage #1
    NSLog(@"***EXAMPLE OF USAGE #1***");
    
    ISOMessage *isoMessage1 = [[ISOMessage alloc] init];
    [isoMessage1 setMTI:@"0200"];
    // Declares the presence of a secondary bitmap and data elements: 3, 4, 7, 11, 44, 105
    isoMessage1.bitmap = [[ISOBitmap alloc] initWithHexString:@"B2200000001000000000000000800000"];
    
    [isoMessage1 addDataElement:@"DE03" withValue:@"123" configFileName:nil];
    [isoMessage1 addDataElement:@"DE04" withValue:@"123" configFileName:nil];
    [isoMessage1 addDataElement:@"DE07" withValue:@"123" configFileName:nil];
    [isoMessage1 addDataElement:@"DE11" withValue:@"123" configFileName:nil];
    [isoMessage1 addDataElement:@"DE44" withValue:@"Value for DE44" configFileName:nil];
    [isoMessage1 addDataElement:@"DE105" withValue:@"This is the value for DE105" configFileName:nil];
    
    NSString *theBuiltMessage = [isoMessage1 buildIsoMessage:nil];
    NSLog(@"Built message:\n%@", theBuiltMessage);

    // Example of usage #2
    NSLog(@"***EXAMPLE OF USAGE #2***");

    ISOMessage *isoMessage2 = [[ISOMessage alloc] init];
    [isoMessage2 setMTI:@"0200"];
    // Initializes the bitmap with given data elements
    isoMessage2.bitmap = [[ISOBitmap alloc] initWithGivenDataElements:@[@"DE03", @"DE04", @"DE07", @"DE11", @"DE44", @"DE105"] customConfigFileName:nil];

    [isoMessage2 addDataElement:@"DE03" withValue:@"123" configFileName:nil];
    [isoMessage2 addDataElement:@"DE04" withValue:@"123" configFileName:nil];
    [isoMessage2 addDataElement:@"DE07" withValue:@"123" configFileName:nil];
    [isoMessage2 addDataElement:@"DE11" withValue:@"123" configFileName:nil];
    [isoMessage2 addDataElement:@"DE44" withValue:@"Value for DE44" configFileName:nil];
    [isoMessage2 addDataElement:@"DE105" withValue:@"This is the value for DE105" configFileName:nil];

    NSString *theBuiltMessage2 = [isoMessage2 buildIsoMessage:nil];
    NSLog(@"Built message:\n%@", theBuiltMessage2);

    // Example of usage #3
    NSLog(@"***EXAMPLE OF USAGE #3***");
    
    ISOMessage *isoMessage3 = [[ISOMessage alloc] initWithIsoMessage:@"0200B2200000001000000000000000800000000123000000000123000000012300012314Value for DE44027This is the value for DE105"];
    
    for (id elementName in isoMessage3.dataElements) {
        if ([elementName isEqualToString:@"DE01"]) {
            continue;
        }
        
        NSLog(@"%@:%@", elementName, ((ISODataElement *)[isoMessage3.dataElements objectForKey:elementName]).value);
    }
    
    // Example of usage #4
    NSLog(@"***EXAMPLE OF USAGE #4***");
    
    ISOMessage *isoMessage4 = [[ISOMessage alloc] initWithIsoMessageAndHeader:@"ISO0200B2200000001000000000000000800000000123000000000123000000012300012314Value for DE44027This is the value for DE105"];
    
    for (id elementName in isoMessage4.dataElements) {
        if ([elementName isEqualToString:@"DE01"]) {
            continue;
        }
        
        NSLog(@"%@:%@", elementName, ((ISODataElement *)[isoMessage4.dataElements objectForKey:elementName]).value);
    }
    
    // Example of usage #5
    NSLog(@"***EXAMPLE OF USAGE #5 CUSTOM ISO MESSAGES***");
    
    ISOMessage *isoMessage5 = [[ISOMessage alloc] init];
    [isoMessage5 useCustomConfigurationFile:@"customisoconfig" andCustomMTIFileName:@"customisoMTI"];
    [isoMessage5 setMTI:@"0127"];
    isoMessage5.bitmap = [[ISOBitmap alloc] initWithBinaryString:@"0000001100000000000010000000000000000000000000000000000000000000"];
    
    [isoMessage5 addDataElement:@"DE127_7" withValue:@"501" configFileName:@"customisoconfig"];
    [isoMessage5 addDataElement:@"DE127_8" withValue:@"1" configFileName:@"customisoconfig"];
    [isoMessage5 addDataElement:@"DE127_21" withValue:@"1" configFileName:@"customisoconfig"];
    
    NSString *theBuiltMessage5 = [isoMessage5 buildIsoMessage:@"customisoconfig"];
    NSString *theBuiltMessageWithHeader5 = [isoMessage5 buildIsoMessageWithISOHeader:@"customisoconfig"];
    NSLog(@"Built message:\n%@", theBuiltMessage5);
    NSLog(@"Built message with ISO header:\n%@", theBuiltMessageWithHeader5);
    
    // Example of usage #6
    NSLog(@"***EXAMPLE OF USAGE #6 CUSTOM ISO MESSAGES***");
    
    ISOMessage *isoMessage6 = [[ISOMessage alloc] initWithCustomIsoMessage:@"012703000800000000000501000000000000001000001" configFileName:@"customisoconfig" customMTIFileName:@"customisoMTI"];
    
    for (id elementName in isoMessage6.dataElements) {
        NSLog(@"%@:%@", elementName, ((ISODataElement *)[isoMessage6.dataElements objectForKey:elementName]).value);
    }
    
    // Example of usage #7
    NSLog(@"***EXAMPLE OF USAGE #7 CUSTOM ISO MESSAGES***");
    
    ISOMessage *isoMessage7 = [[ISOMessage alloc] initWithCustomIsoMessageAndHeader:@"ISO012703000800000000000501000000000000001000001" configFileName:@"customisoconfig" customMTIFileName:@"customisoMTI"];
    
    for (id elementName in isoMessage7.dataElements) {
        NSLog(@"%@:%@", elementName, ((ISODataElement *)[isoMessage7.dataElements objectForKey:elementName]).value);
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
