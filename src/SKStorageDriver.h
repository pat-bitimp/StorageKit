#import "SKObject.h"
#import "SKQuery.h"
@class SKObject;
@class SKQuery;

@protocol SKStorageDriver
- (id)getObjectForId: (uint32_t)id andClass: (Class)class;
- (void)deleteObject: (SKObject*)object;
- (void)saveObject: (SKObject*)object;
- (void)updateObject: (SKObject*)object;
- (id)getFirstItemForQuery: (SKQuery*)query;
- (OFList*)getAllItemsForQuery: (SKQuery*)query;
- (int)countItemsForQuery: (SKQuery*)query;
@end