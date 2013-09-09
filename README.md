Objective-ISO8583
=================

Objective-C library for iOS and Mac OS X that implements the ISO-8583 financial transaction protocol. Build and parse ISO-8583 messages using a friendly and easy to use interface.

Currently supports protocol version ISO 8583-1:1987.

To use the library, clone or download the archive. Drag or copy/paste the "Objective-ISO8583 Lib" directory to your Xcode project.
Be sure to select the following options when adding:

- Copy items into destination group's folder (if needed)
- Add to targets "Your Target Name"
- Import the necessary classes in your code i.e. #import "ISOMessage.h"

Be sure to contact me for help using the library

Example of usage 1
--------------

	ISOMessage *isoMessage = [[ISOMessage alloc] init];
	[isoMessage setMTI:@"0200"];
	isoMessage.bitmap = [[ISOBitmap alloc] initWithHexString:@"B2200000001000000000000000800000"];
	
	[isoMessage addDataElement:@"DE03" withValue:@"123"];
	[isoMessage addDataElement:@"DE04" withValue:@"123"];
	[isoMessage addDataElement:@"DE07" withValue:@"123"];
	[isoMessage addDataElement:@"DE11" withValue:@"123"];
	[isoMessage addDataElement:@"DE44" withValue:@"123"];
	[isoMessage addDataElement:@"DE105" withValue:@"This is a varible length value for DE105"];
	
	NSString *builtMessage = [isoMessage buildIsoMessage];
	NSLog(@"Message: %@", builtMessage);
	
Example of usage 2
--------------

	ISOMessage *isoMessage = [[ISOMessage alloc] initWithIsoMessage:
		@"0200B2200000001000000000000000800000000123000000000123000000012300012303123040This is a varible length value for DE105"];
	
	for (id dataElement in isoMessage.dataElements) {
		NSLog(@"%@:%@", dataElement, ((ISODataElement *)[isoMessage.dataElements objectForKey:dataElement]).value);
	}
