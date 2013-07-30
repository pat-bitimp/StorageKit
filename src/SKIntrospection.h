#import <ObjFW/ObjFW.h>
#import "SKObject.h"

@interface SKIntrospection : OFObject
+ (OFArray*)propertyNamesForClass: (Class)class;
+ (OFDictionary*)propertiesForObject: (OFObject*)object;
+ (SKObject*)objectInstanceFor: (Class)class data: (OFDictionary*)data;
@end