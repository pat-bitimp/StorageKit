#import "SKManager.h"

static OFMutableDictionary* storageDrivers;
static id defaultStorageDriver;

@implementation SKManager
+ (id /*<SKStorageDriver>*/)getStorageDriverForClass: (Class)class
{
	if (storageDrivers == nil)
		return defaultStorageDriver;

	id driver = [storageDrivers objectForKey: class];
	driver = driver == nil ? defaultStorageDriver : driver;

	return driver;
}

+ (void)setDefaultStorageDriver: (id /*<SKStorageDriver>*/)storageDriver
{
	defaultStorageDriver = storageDriver;
}

+ (void)setStorageDriver: (id /*<SKStorageDriver>*/)storageDriver 
                forClass: (Class)class
{
	if (storageDrivers == nil)
	{
		storageDrivers = [OFMutableDictionary dictionary];
	}

	[storageDrivers setObject: storageDriver forKey: class];
}

+ (void)setMappingOptions: (MappingOptions)mappingOption 
                 forClass: (Class)class 
              andSelector: (SEL)selector
{

}
@end