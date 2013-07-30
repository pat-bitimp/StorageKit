#import "SKObject.h"

@implementation SKObject
@synthesize ID;
- (void)save
{
	id <SKStorageDriver> driver = 
		[SKManager getStorageDriverForClass: [self class]];

	if (driver == nil)
		@throw [SKNoDriverFoundException new];

	if ([self ID] == 0)
		[driver saveObject: self];
	else
		[driver updateObject: self];
}

- (void)delete
{
	id <SKStorageDriver> driver = 
		[SKManager getStorageDriverForClass: [self class]];

	if (driver == nil)
		@throw [SKNoDriverFoundException new];

	if ([self ID] > 0)
	{
		[driver deleteObject: self];
	}
}

- (OFString*)description
{
	return [OFString stringWithFormat: @"%d", [self ID]];
}
@end