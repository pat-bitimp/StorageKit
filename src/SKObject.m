#import "SKObject.h"

@implementation SKObject
@synthesize id;
- (void)save
{
	id <SKStorageDriver> driver = 
		[SKManager getStorageDriverForClass: [self class]];

	if (driver == nil)
		@throw [SKNoDriverFoundException new];

	if (id == 0)
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

	if (id > 0)
	{
		[driver deleteObject: self];
	}
}
@end