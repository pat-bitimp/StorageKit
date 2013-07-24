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

	obj.connectionParameters = connectionParameters;

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
	OFString* queryString = [OFString stringWithFormat: @"DELETE FROM %@ WHERE "
		@"id = %d;", [self escapeString: [object className]], [object id]];

	[[self session] executeCommand: (OFConstantString*)queryString];
}

- (void)saveObject: (SKObject*)object
{

}

- (void)updateObject: (SKObject*)object
{

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
	                  : condition.binding == And ? @" and "
	                  : @" or ";

	OFString* operator = condition.operator == IsEqual ? @" = " 
	                   : condition.operator == IsNotEqual ? @" <> "
	                   : condition.operator == IsGreaterThen ? @" > "
	                   : condition.operator == IsLowerThen ? @" < "
	                   : @" LIKE ";

	// in case we re comparing null objects we use null operators
	if (condition.value == nil)
	{
		operator = condition.operator == IsEqual ? @" ISNULL" : @" NOTNULL";

		return [OFString stringWithFormat: @" %@ %@", selectorName, operator];
	}

	id value = condition.value;

	// In case we compare with an SKObject, we want to compare the ids
	if ([condition.value class] == [SKObject class])
	{
		// TODO check if local instance is dirty and compare properties?
		value = [OFNumber numberWithUInt32: [condition.value id]];
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