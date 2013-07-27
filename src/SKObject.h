#import <ObjFW/ObjFW.h>
#import "SKManager.h"
#import "SKNoDriverFoundException.h"

#define SK(property) __sk__dbproperty__ ## property

@interface SKObject : OFObject
{
	uint32_t ID;
}
@property uint32_t ID;
- (void)save;
- (void)delete;
- (OFDictionary*)_sk_properties;
@end