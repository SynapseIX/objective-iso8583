Objective-ISO8583
=================

Objective-C library for iOS and Mac OS X that implements the ISO-8583 financial transaction protocol. Build and parse ISO-8583 messages using a friendly and easy to use interface.

Currently supports protocol version ISO 8583-1:1987.

To use the library, clone or download the archive. Drag or copy/paste the "Objective-ISO8583 Lib" directory to your Xcode project.
Be sure to select the following options when adding:

- Copy items into destination group's folder (if needed)
- Add to targets "Your Target Name"
- Import the necessary classes in your code i.e. #import "ISOMessage.h"

Be sure to contact me for help using the library, and of course, report any issues/bugs you find.
Now you can build your own custom ISO8583-formatted messages, include your custom config and MTIs plist files and you're good to go. Sample custom files and usage examples are also included.

Example of usage 1
--------------

	ISOMessage *isoMessage1 = [[ISOMessage alloc] init];
	[isoMessage1 setMTI:@"0200"];
	// Declares the presence of a secondary bitmap and data elements: 3, 4, 7, 11, 44, 105
	isoMessage1.bitmap = [[ISOBitmap alloc] initWithGivenDataElements:@[@"DE03", "DE04", "DE07", "DE11", "DE44", "DE105"] configFileName:nil];
	
	[isoMessage1 addDataElement:@"DE03" withValue:@"123" configFileName:nil];
	[isoMessage1 addDataElement:@"DE04" withValue:@"123" configFileName:nil];
	[isoMessage1 addDataElement:@"DE07" withValue:@"123" configFileName:nil];
	[isoMessage1 addDataElement:@"DE11" withValue:@"123" configFileName:nil];
	[isoMessage1 addDataElement:@"DE44" withValue:@"Value for DE44" configFileName:nil];
	[isoMessage1 addDataElement:@"DE105" withValue:@"This is the value for DE105" configFileName:nil];
	
	NSString *theBuiltMessage = [isoMessage1 buildIsoMessage:nil];
	NSLog(@"Built message:\n%@", theBuiltMessage);
	
Example of usage 2
--------------

	ISOMessage *isoMessage2 = [[ISOMessage alloc] initWithIsoMessage:@"0200B2200000001000000000000000800000000123000000000123000000012300012314Value for DE44027This is the value for DE105"];
	
	for (id elementName in isoMessage2.dataElements) {
		if ([elementName isEqualToString:@"DE01"]) {
			continue;
		}
		
		NSLog(@"%@:%@", elementName, ((ISODataElement *)[isoMessage2.dataElements objectForKey:elementName]).value);
	}

More examples of usage are included in the code. To build and parse standard ISO-8583 messages, pass 'nil' as argument value for methods that accept 'customConfig' parameters.
