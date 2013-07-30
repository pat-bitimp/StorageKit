#import <ObjFW/ObjFW.h>
#import "SKManager.h"
#import "SKNoDriverFoundException.h"

#define SKPropertyPrefix @"__sk__dbproperty__"
#define SK(property) __sk__dbproperty__ ## property

@interface SKObject : OFObject
{
	uint32_t ID;
}
@property uint32_t ID;
- (void)save;
- (void)delete;
@end