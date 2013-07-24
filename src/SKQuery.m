#import "SKQuery.h"
#import "SKQueryCondition.h"

@implementation SKQuery
@synthesize queryingClass, orderDirection, orderSelector, conditions, limit, offset;
+ queryOverClass: (Class)class
{
	SKQuery* obj = [self new];

	obj.queryingClass = class;
	obj.orderDirection = Ascending;
	obj.orderSelector = @selector(Id);
	obj.conditions = [OFList list];

	return obj;
}

- where: (SEL)selector isEqual: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Where
		                                                 andOperator: IsEqual
	                                                        andValue: value]];

	return self;
}

- where: (SEL)selector isNotEqual: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Where
		                                                 andOperator: IsNotEqual
	                                                        andValue: value]];

	return self;
}

- where: (SEL)selector isGreaterThen: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Where
		                                                 andOperator: IsGreaterThen
	                                                        andValue: value]];

	return self;
}

- where: (SEL)selector isLike: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Where
		                                                 andOperator: IsLike
	                                                        andValue: value]];

	return self;
}

- where: (SEL)selector isLowerThen: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Where
		                                                 andOperator: IsLowerThen
	                                                        andValue: value]];

	return self;
}

- and: (SEL)selector isEqual: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: And
		                                                 andOperator: IsEqual
	                                                        andValue: value]];

	return self;
}

- and: (SEL)selector isNotEqual: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: And
		                                                 andOperator: IsNotEqual
	                                                        andValue: value]];

	return self;
}

- and: (SEL)selector isGreaterThen: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: And
		                                                 andOperator: IsGreaterThen
	                                                        andValue: value]];

	return self;
}

- and: (SEL)selector isLike: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: And
		                                                 andOperator: IsLike
	                                                        andValue: value]];

	return self;
}

- and: (SEL)selector isLowerThen: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: And
		                                                 andOperator: IsLowerThen
	                                                        andValue: value]];

	return self;
}

- or: (SEL)selector isEqual: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Or
		                                                 andOperator: IsEqual
	                                                        andValue: value]];

	return self;
}

- or: (SEL)selector isNotEqual: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Or
		                                                 andOperator: IsNotEqual
	                                                        andValue: value]];

	return self;
}

- or: (SEL)selector isGreaterThen: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Or
		                                                 andOperator: IsGreaterThen
	                                                        andValue: value]];

	return self;
}

- or: (SEL)selector isLike: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Or
		                                                 andOperator: IsLike
	                                                        andValue: value]];

	return self;
}

- or: (SEL)selector isLowerThen: (id)value
{
	[conditions appendObject: [SKQueryCondition conditionForSelector: selector
		                                                  andBinding: Or
		                                                 andOperator: IsLowerThen
	                                                        andValue: value]];

	return self;
}

- withLimit: (uint32_t)_limit
{
	limit = _limit;

	return self;
}

- withOffset: (uint32_t)_offset
{
	offset = _offset;

	return self;
}

- whereConditionComplied: (SKQueryCondition*)condition
{
	[conditions appendObject: condition];

	return self;
}

- descendingOrderBy: (SEL)selector
{
	orderDirection = Descending;
	orderSelector = selector;

	return self;
}

- ascendingOrderBy: (SEL)selector
{
	orderDirection = Ascending;
	orderSelector = selector;

	return self;
}

- (id)firstOrNil
{
	id <SKStorageDriver> driver = 
		[SKManager getStorageDriverForClass: [self queryingClass]];

	return [driver getFirstItemForQuery: self];
}

- (OFList*)list
{
	id <SKStorageDriver> driver = 
		[SKManager getStorageDriverForClass: [self queryingClass]];

	return [driver getAllItemsForQuery: self];
}

- (int)count
{
	id <SKStorageDriver> driver = 
		[SKManager getStorageDriverForClass: [self queryingClass]];

	return [driver countItemsForQuery: self];
}
@end