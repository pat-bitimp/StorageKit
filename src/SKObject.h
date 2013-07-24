#import <ObjFW/ObjFW.h>
#import "SKManager.h"
#import "SKNoDriverFoundException.h"

@interface SKObject : OFObject
{
	uint32_t id;
}
@property uint32_t id;
- (void)save;
- (void)delete;
@end