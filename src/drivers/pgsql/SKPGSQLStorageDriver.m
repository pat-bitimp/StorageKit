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

- (SKObject*)objectForID: (uint32_t)ID class: (Class)_class
{
	OFArray* propertyNames = [SKIntrospection propertyNamesForClass: _class];

	OFConstantString* format = @"SELECT %@ FROM \"%@\";";

	OFMutableString* propertyString = [OFMutableString string];

	for (OFString* propertyName in propertyNames)
	{
		OFString* seperator = 
			[propertyNames lastObject] == propertyName ? @"" : @", ";

		[propertyString appendString: [OFString stringWithFormat: @"\"%@\"%@", 
			[self escapeString: propertyName], seperator]];
	}

	OFString* className = [self escapeString: 
		[OFString stringWithUTF8String: class_getName(_class)]];

	OFString* queryString = [OFString stringWithFormat: format, propertyString, 
		className];

	PGResult* result = 
		[[self session] executeCommand: (OFConstantString*)queryString];

	if ([result count] == 0)
	{
		return nil;
	}

	PGResultRow* row = [result objectAtIndex: 0];
	OFMutableDictionary* data = [OFMutableDictionary dictionary];

	for (OFString *propertyName in propertyNames)
	{
		id value = [row objectForKey: propertyName];
		[data setObject: value forKey: propertyName];
	}

	return [SKIntrospection objectInstanceFor: _class data: data];
}

- (void)deleteObject: (SKObject*)object
{
	OFString* queryString = 
		[OFString stringWithFormat: @"DELETE FROM \"%@\" WHERE "
		@"\"ID\" = %d;", [self escapeString: [object className]], [object ID]];

	[[self session] executeCommand: (OFConstantString*)queryString];
}

- (void)saveObject: (SKObject*)object
{
	OFConstantString* format = 
		@"INSERT INTO \"%@\"(%@) VALUES(%@) RETURNING ID;";

	OFMutableString* propertyNames = [OFMutableString string];
	OFMutableString* propertyValues = [OFMutableString string];

	OFDictionary* properties = [SKIntrospection propertiesForObject: object];
	OFArray* keys = [properties allKeys];

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

	OFString* queryString = [OFString stringWithFormat: format, 
		[self escapeString: [object className]], propertyNames, propertyValues];

	PGResult* result = 
		[[self session] executeCommand: (OFConstantString*)queryString];

	object.ID = [[[result objectAtIndex: 0] objectAtIndex: 0] uInt32Value];
}

- (void)updateObject: (SKObject*)object
{
	OFConstantString* format = @"UPDATE \"%@\" SET %@ WHERE \"ID\"=%d;";

	OFMutableString* data = [OFMutableString string];

	OFDictionary* properties = [SKIntrospection propertiesForObject: object];
	OFArray* keys = [properties allKeys];

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

	OFString* queryString = [OFString stringWithFormat: format, 
		[self escapeString: [object className]], data, [object ID]];

	[[self session] executeCommand: (OFConstantString*)queryString];
}

- (SKObject*)getFirstItemForQuery: (SKQuery*)query
{
	OFConstantString* format = @"SELECT * FROM \"%@\" %@ %@ %@ %@ ;";

	OFMutableString* conditionString = [OFMutableString string];

	for (SKQueryCondition* condition in query.conditions)
	{
		[conditionString appendString: 
			[self buildStringForCondition: condition]];
	}

	OFString* orderString = [self buildOrderStringForQuery: query];

	OFString* limit = @" LIMIT 1 ";

	OFString* offset = [OFString stringWithFormat: @" OFFSET %d ", query.offset];

	OFString* className = [self escapeString: 
		[OFString stringWithUTF8String: class_getName(query.queryingClass)]];

	OFString* queryString = [OFString stringWithFormat: format, 
		className, conditionString, orderString, limit, offset];

	PGResult* result = 
		[[self session] executeCommand: (OFConstantString*)queryString];

	if ([result count] == 0)
	{
		return nil;
	}

	OFArray* propertyNames = 
		[SKIntrospection propertyNamesForClass: query.queryingClass];

	OFMutableDictionary* data = [OFMutableDictionary dictionary];

	for (OFString *propertyName in propertyNames)
	{
		id value = [result[0] objectForKey: propertyName];
		[data setObject: value forKey: propertyName];
	}

	return [SKIntrospection objectInstanceFor: query.queryingClass 
									     data: data];
}

- (OFArray*)getAllItemsForQuery: (SKQuery*)query
{
	OFConstantString* format = @"SELECT * FROM \"%@\" %@ %@ %@ %@ ;";

	OFMutableString* conditionString = [OFMutableString string];

	for (SKQueryCondition* condition in query.conditions)
	{
		[conditionString appendString: 
			[self buildStringForCondition: condition]];
	}

	OFString* orderString = [self buildOrderStringForQuery: query];

	OFString* limit = query.limit == 0 ? 
		@"" : [OFString stringWithFormat: @" LIMIT %d ", query.limit];

	OFString* offset = [OFString stringWithFormat: @" OFFSET %d ", query.offset];

	OFString* className = [self escapeString: 
		[OFString stringWithUTF8String: class_getName(query.queryingClass)]];

	OFString* queryString = [OFString stringWithFormat: format, 
		className, conditionString, orderString, limit, offset];

	PGResult* result = 
		[[self session] executeCommand: (OFConstantString*)queryString];

	if ([result count] == 0)
	{
		return [OFArray array];
	}

	OFMutableArray* returnArr = [OFMutableArray array];

	OFArray* propertyNames = 
		[SKIntrospection propertyNamesForClass: query.queryingClass];

	for (PGResultRow* row in result)
	{
		OFMutableDictionary* data = [OFMutableDictionary dictionary];

		for (OFString *propertyName in propertyNames)
		{
			id value = [row objectForKey: propertyName];
			[data setObject: value forKey: propertyName];
		}

		[returnArr addObject: 
			[SKIntrospection objectInstanceFor: query.queryingClass 
										  data: data]];
	}

	return returnArr;
}

- (uint32_t)countItemsForQuery: (SKQuery*)query
{
	OFConstantString* format = @"SELECT Count(ID) FROM \"%@\" %@;";

	OFMutableString* conditionString = [OFMutableString string];

	// TODO handle limit and offset

	for (SKQueryCondition* condition in query.conditions)
	{
		[conditionString appendString: 
			[self buildStringForCondition: condition]];
	}

	OFString* className = [self escapeString: 
		[OFString stringWithUTF8String: class_getName(query.queryingClass)]];

	OFString* queryString = 
		[OFString stringWithFormat: format, className, conditionString];

	PGResult* result = 
		[[self session] executeCommand: (OFConstantString*)queryString];

	return [[[result objectAtIndex: 0] objectAtIndex: 0] uInt32Value];;
}

- (OFString*)buildOrderStringForQuery: (SKQuery*)query
{
	OFConstantString* format = @" ORDER BY \"%@\" %@ ";

	if (query.orderDirection == Unordered)
	{
		return @"";
	}

	OFConstantString* direction = 
		query.orderDirection == Ascending ? @"ASC" : @"DESC";

	OFString* selectorName = [self escapeString:
		[OFString stringWithUTF8String: sel_getName(query.orderSelector)]];

	return [OFString stringWithFormat: format, selectorName, direction];
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

	// TODO handle SKQuery as value

	return [OFString stringWithFormat: @" %@ %@ %@ %@ ", binding, selectorName, 
		operator, [self escapeString: [condition.value description]]];
}

- (OFString*)escapeString: (OFString*)string;
{
	char* cString = PQescapeLiteral([[self session] PG_connection], 
		[string UTF8String], [string length]);

	return [OFString stringWithUTF8String: cString];
}
@end