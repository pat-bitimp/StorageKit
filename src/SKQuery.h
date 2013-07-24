#import <ObjFW/ObjFW.h>
#import "SKStorageDriver.h"
#import "SKQueryCondition.h"

typedef enum { 
	Unordered = 0,
	Ascending = 1,
	Descending = 2
} OrderDirection;


@interface SKQuery : OFObject
{
	OFList* conditions;
	Class queryingClass;
	OrderDirection orderDirection;
	SEL orderSelector;
	uint32_t limit;
	uint32_t offset;
}
@property (copy) Class queryingClass;
@property (copy) OFList* conditions;
@property uint32_t limit;
@property uint32_t offset;
@property OrderDirection orderDirection;
@property SEL orderSelector;
+ queryOverClass: (Class)class;
- where: (SEL)selector isEqual: (id)value;
- where: (SEL)selector isNotEqual: (id)value;
- where: (SEL)selector isLike: (id)value;
- where: (SEL)selector isGreaterThen: (id)value;
- where: (SEL)selector isLowerThen: (id)value;
- and: (SEL)selector isEqual: (id)value;
- and: (SEL)selector isNotEqual: (id)value;
- and: (SEL)selector isLike: (id)value;
- and: (SEL)selector isGreaterThen: (id)value;
- and: (SEL)selector isLowerThen: (id)value;
- or: (SEL)selector isEqual: (id)value;
- or: (SEL)selector isNotEqual: (id)value;
- or: (SEL)selector isLike: (id)value;
- or: (SEL)selector isGreaterThen: (id)value;
- or: (SEL)selector isLowerThen: (id)value;
- withLimit: (uint32_t)limit;
- withOffset: (uint32_t)offset;
- whereConditionComplied: (SKQueryCondition*)condition;
- descendingOrderBy: (SEL)selector;
- ascendingOrderBy: (SEL)selector;
- (id)firstOrNil;
- (OFList*)list;
- (int)count;
@end