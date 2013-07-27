#import "SKPGSQLStorageDriver.h"

static OFTLSKey* connectionMappingKey;

@implementation SKPGSQLStorageDriver
@synthesize connectionParameters;
+ storageDriverWithConnectionParameters: (OFDictionary*)connectionParameters
{
	if (connectionMappingKey == nil)
	{
		connectionMappingKey = [OFTLSKey TLSKey];
	}

	if ([OFThread objectForTLSKey: connectionMappingKey] == nil)
	{
		[OFThread setObject: [OFMutableDictionary dictionary] 
				  forTLSKey: connectionMappingKey];
	}

	SKPGSQLStorageDriver* obj = [self new];

	[obj setConnectionParameters: connectionParameters];

	return obj;
}

- (PGConnection*)session
{
	// dict with Connection Parameters -> TLSKey mapping
	OFMutableDictionary* mappings = 
		[OFThread objectForTLSKey: connectionMappingKey];

	OFTLSKey* key;

	// No TLSKey for connection Parameters
	if ((key = [mappings objectForKey: connectionParameters]) == nil)
	{
		key = [OFTLSKey TLSKey];
	}

	if ([OFThread objectForTLSKey: key] == nil)
	{
		// No Session for that Key found
		[mappings setObject: connectionParameters forKey: key];
		PGConnection* con = [PGConnection new];
		[con setParameters: connectionParameters];
		[con connect];
		[OFThread setObject: con forTLSKey: key];
		return con;
	}
	else
	{
		// Session found
		return [OFThread objectForTLSKey: key];
	}
}

- (id)getObjectForId: (uint32_t)id andClass: (Class)class
{

	return nil;
}

- (void)deleteObject: (SKObject*)object
{
	OFString* queryString = [OFString stringWithFormat: @"DELETE FROM \"%@\" WHERE "
		@"\"ID\" = %d;", [self escapeString: [object className]], [object ID]];

	[[self session] executeCommand: (OFConstantString*)queryString];
}

- (void)saveObject: (SKObject*)object
{
	OFConstantString* format = @"INSERT INTO \"%@\"(%@) VALUES(%@) RETURNING ID;";
	OFMutableString* propertyNames = [OFMutableString string];
	OFMutableString* propertyValues = [OFMutableString string];

	OFDictionary* properties = object._sk_properties;
	OFArray* keys = [object._sk_properties allKeys];

	for (OFString* key in keys)
	{
		OFString* seperator = [keys lastObject] == key ? @"" : @", ";

    	[propertyNames appendString: 
    		[OFString stringWithFormat: @"\"%@\"%@", 
    									[self escapeString: key], 
    									seperator]];

    	OFString* value = [self escapeString: 
    		[[properties objectForKey: key] description]];

    	[propertyValues appendString: 
    		[OFString stringWithFormat: @"\"%@\"%@", 
    									value, 
    									seperator]];
	}

	OFConstantString* queryString = [OFConstantString stringWithFormat: format, 
		[self escapeString: [object className]], propertyNames, propertyValues];

	PGResult* result = [[self session] executeCommand: queryString];

	object.ID = [[[result objectAtIndex: 0] objectAtIndex: 0] uInt32Value];
}

- (void)updateObject: (SKObject*)object
{
	OFConstantString* format = @"UPDATE \"%@\" SET %@ WHERE \"ID\"=%d;";

	OFMutableString* data = [OFMutableString string];

	OFDictionary* properties = object._sk_properties;
	OFArray* keys = [object._sk_properties allKeys];

	for (OFString* key in keys)
	{
		OFString* seperator = [keys lastObject] == key ? @"" : @", ";

    	OFString* value = [self escapeString: 
    		[[properties objectForKey: key] description]];

    	[data appendString: 
    		[OFString stringWithFormat: @"\"%@\"='%@'%@",
    									[self escapeString: key],
    									value, 
    									seperator]];
	}

	OFConstantString* queryString = [OFConstantString stringWithFormat: format, 
		[self escapeString: [object className]], data, [object ID]];

	[[self session] executeCommand: queryString];
}

- (id)objectInstanceFrom: (Class)class andData: (OFDictionary*)data
{
	OFObject* instance = [class new];

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

- (id)getFirstItemForQuery: (SKQuery*)query
{
	return nil;
}

- (OFList*)getAllItemsForQuery: (SKQuery*)query
{
	return nil;
}

- (int)countItemsForQuery: (SKQuery*)query
{
	return 0;
}

- (OFString*)buildStringForCondition: (SKQueryCondition*)condition
{
	OFString* selectorName = [self escapeString:
		[OFString stringWithUTF8String: sel_getName(condition.selector)]];

	OFString* binding = condition.binding == Where ? @" where "
	                  : condition.binding == And   ? @" and "
	                  : @" or ";

	OFString* operator = condition.operator == IsEqual       ? @" = " 
	                   : condition.operator == IsNotEqual    ? @" <> "
	                   : condition.operator == IsGreaterThen ? @" > "
	                   : condition.operator == IsLowerThen   ? @" < "
	                   : @" LIKE ";

	// in case we re comparing null objects we use null operators
	if (condition.value == nil)
	{
		operator = condition.operator == IsEqual ? @" ISNULL" : @" NOTNULL";

		return [OFString stringWithFormat: @" %@ %@", selectorName, operator];
	}

	id value = condition.value;

	// In case we compare with an SKObject, we want to compare the ids
	if ([condition.value isKindOfClass: [SKObject class]])
	{
		// TODO check if local instance is dirty and compare properties?
		value = [OFNumber numberWithUInt32: [condition.value ID]];
	}

	// TODO handle SKQuery as value

	return [OFString stringWithFormat: @" %@ %@ %@ %@", 
		binding, selectorName, operator, [self escapeString: [value description]]];
}

- (OFString*)escapeString: (OFString*)string;
{
	char* cString = PQescapeLiteral([[self session] PG_connection], 
		[string UTF8String], [string length]);

	return [OFString stringWithUTF8String: cString];
}
@end