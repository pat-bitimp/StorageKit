#import <ObjFW/ObjFW.h>
#import "SKStorageDriver.h"

typedef enum { 
	NotNull = 1,
	NoLazyLoading = 2
} MappingOptions;

@interface SKManager : OFObject
+ (id /*<SKStorageDriver>*/)getStorageDriverForClass: (Class)class;
+ (void)setDefaultStorageDriver: (id /*<SKStorageDriver>*/)storageDriver;
+ (void)setStorageDriver: (id /*<SKStorageDriver>*/)storageDriver 
                forClass: (Class)class;
+ (void)setMappingOptions: (MappingOptions)mappingOption 
                 forClass: (Class)class 
              andSelector: (SEL)selector;
@end