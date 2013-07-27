#import <ObjFW/ObjFW.h>
#import "SKStorageDriver.h"

@interface SKManager : OFObject
+ (id /*<SKStorageDriver>*/)getStorageDriverForClass: (Class)class;
+ (void)setDefaultStorageDriver: (id /*<SKStorageDriver>*/)storageDriver;
+ (void)setStorageDriver: (id /*<SKStorageDriver>*/)storageDriver 
                forClass: (Class)class;
@end