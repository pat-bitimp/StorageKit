#import "SKIntrospection.h"

// TODO make cross plattform.

@implementation SKIntrospection
+ (OFArray*)propertyNamesForClass: (Class)class
{
	OFIntrospection* introspection = [OFIntrospection introspectionWithClass: class];
	OFArray* methods = [introspection instanceMethods];

	OFMutableArray* returnArr = [OFMutableArray array];
	
	for (int i = 0; i < [methods count]; ++i)
	{
		OFString* name = [methods[i] name];

		if ([name hasPrefix: SKPropertyPrefix])
		{
			[returnArr addObject: name];
		}
	}

	return returnArr;
}

+ (OFDictionary*)propertiesForObject: (OFObject*)object
{
	OFIntrospection* introspection = [OFIntrospection introspectionWithClass: [object class]];
	OFArray* methods = [introspection instanceMethods];

	OFMutableDictionary* returnDict = [OFMutableDictionary dictionary];
	
	for (OFMethod* method in methods)
	{
		if ([[method name] hasPrefix: SKPropertyPrefix])
		{
			SEL selector = sel_registerName([[method name] UTF8String]);

			id (*getValue)(id, SEL) = (id(*)(id, SEL))[object methodForSelector: selector];
			id value = getValue(object, selector);

			[returnDict setObject: value forKey: [method name]];
		}
	}

	return returnDict;
}

+ (SKObject*)objectInstanceFor: (Class)class data: (OFDictionary*)data
{
	SKObject* instance = [class new];

	OFArray* keys = [data allKeys];

	for (OFString* key in keys)
	{
		OFString* selectorName = 
			[OFString stringWithFormat: @"set%@:", [key capitalizedString]];

		SEL selector = sel_registerName([selectorName UTF8String]);

		void (*setValue)(id, SEL, id) = 
			(void(*)(id, SEL, id))[instance methodForSelector: selector];

		setValue(instance, selector, [data objectForKey: key]);
	}

	return instance;
} 
@end