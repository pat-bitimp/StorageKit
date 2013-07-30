#import "SKObject.h"
#import "SKQuery.h"
@class SKObject;
@class SKQuery;

@protocol SKStorageDriver
- (SKObject*)objectForID: (uint32_t)ID class: (Class)_class;
- (void)deleteObject: (SKObject*)object;
- (void)saveObject: (SKObject*)object;
- (void)updateObject: (SKObject*)object;
- (SKObject*)getFirstItemForQuery: (SKQuery*)query;
- (OFArray*)getAllItemsForQuery: (SKQuery*)query;
- (uint32_t)countItemsForQuery: (SKQuery*)query;
@end