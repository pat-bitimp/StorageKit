#import <ObjFW/ObjFW.h>

typedef enum { 
	IsEqual = 0,
	IsNotEqual = 1,
	IsGreaterThen = 2,
	IsLowerThen = 3,
	IsLike = 4
} SKQueryOperator;

typedef enum {
	Where = 0,
	And = 1,
	Or = 2
} SKBinding;

@interface SKQueryCondition : OFObject
{
	SEL selector;
	SKQueryOperator operator;
	SKBinding binding;
	id value;
}
@property SEL selector;
@property SKQueryOperator operator;
@property SKBinding binding;
@property (copy) id value;
+ conditionForSelector: (SEL)selector 
            andBinding: (SKBinding)binding
           andOperator: (SKQueryOperator)operator 
              andValue: value;
@end