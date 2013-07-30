#import <ObjFW/ObjFW.h>
#import <ObjPgSQL/ObjPgSQL.h>
#import "../../SKQuery.h"
#import "../../SKObject.h"
#import "../../SKQueryCondition.h"
#import "../../SKIntrospection.h"

@interface SKPGSQLStorageDriver : OFObject <SKStorageDriver>
{
	OFDictionary* connectionParameters;
}
@property (retain) OFDictionary* connectionParameters;
+ storageDriverWithConnectionParameters: (OFDictionary*)connectionParameters;
- (SKObject*)objectForID: (uint32_t)ID class: (Class)_class;
- (void)deleteObject: (SKObject*)object;
- (void)saveObject: (SKObject*)object;
- (void)updateObject: (SKObject*)object;
- (SKObject*)getFirstItemForQuery: (SKQuery*)query;
- (OFArray*)getAllItemsForQuery: (SKQuery*)query;
- (uint32_t)countItemsForQuery: (SKQuery*)query;
@end