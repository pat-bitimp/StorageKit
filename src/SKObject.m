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

- (OFDictionary*)_sk_properties
{
	uint* propertiesCount = NULL;
	objc_property_t* properties = class_copyPropertyList([self class], propertiesCount);
	OFMutableDictionary* returnDict = [OFMutableDictionary dictionary];
	
	for (int i = 0; i < *propertiesCount; ++i)
	{
		objc_property_t property = properties[i];
		
		//const char* attributes = property_getAttributes(property);

		OFString* name = [OFString stringWithUTF8String: property_getName(property)];

		if (![name hasPrefix: @"__sk__dbproperty__"])
		{
			continue;
		}

		SEL selector = sel_registerName([name UTF8String]);

		id (*getValue)(id, SEL) = (id(*)(id, SEL))[self methodForSelector: selector];
		id value = getValue(self, selector);

		//id value = [self performSelector: selector];
		[returnDict setObject: value forKey: name];
	}

	return returnDict;
}

- (OFString*)description
{
	return [OFString stringWithFormat: @"%d", [self ID]];
}
@end