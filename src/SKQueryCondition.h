#import <ObjFW/ObjFW.h>

typedef enum { 
	IsEqual = 0,
	IsNotEqual = 1,
	IsGreaterThen = 2,
	IsLowerThen = 3,
	IsLike = 4
} QueryOperator;

typedef enum {
	Where = 0,
	And = 1,
	Or = 2
} Binding;

@interface SKQueryCondition : OFObject
{
	SEL selector;
	QueryOperator operator;
	Binding binding;
	id value;
}
@property SEL selector;
@property QueryOperator operator;
@property Binding binding;
@property (copy) id value;
+ conditionForSelector: (SEL)selector 
            andBinding: (Binding)binding
           andOperator: (QueryOperator)operator 
              andValue: value;
@end