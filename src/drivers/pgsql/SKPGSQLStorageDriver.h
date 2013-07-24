#import <ObjFW/ObjFW.h>
#import <ObjPgSQL/ObjPgSQL.h>
#import "../../SKQuery.h"
#import "../../SKObject.h"
#import "../../SKQueryCondition.h"

@interface SKPGSQLStorageDriver : OFObject <SKStorageDriver>
{
	OFDictionary* connectionParameters;
}
@property (copy) OFDictionary* connectionParameters;
+ storageDriverWithConnectionParameters: (OFDictionary*)connectionParameters;
- (id)getObjectForId: (uint32_t)id andClass: (Class)class;
- (void)deleteObject: (SKObject*)object;
- (void)saveObject: (SKObject*)object;
- (void)updateObject: (SKObject*)object;
- (id)getFirstItemForQuery: (SKQuery*)query;
- (OFList*)getAllItemsForQuery: (SKQuery*)query;
- (int)countItemsForQuery: (SKQuery*)query;
@end