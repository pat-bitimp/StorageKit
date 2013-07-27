#import "SKQueryCondition.h"

@implementation SKQueryCondition
@synthesize selector, operator, value, binding;
+ conditionForSelector: (SEL)selector 
            andBinding: (SKBinding)binding
           andOperator: (SKQueryOperator)operator 
              andValue: value
{
	SKQueryCondition* obj = [self new];

	obj.selector = selector;
	obj.operator = operator;
	obj.value = value;
	obj.binding = binding;

	return obj;
}
@end