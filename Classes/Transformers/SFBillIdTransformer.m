//
//  SFBillIDTransformer.m
//  Congress
//
//  Created by Daniel Cloud on 6/6/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFBillIdTransformer.h"
#import "SFBillTypeTransformer.h"

NSString *const SFBillIdTransformerName = @"SFBillIdTransformerName";

@implementation SFBillIdTransformer

+ (void)load {
    [NSValueTransformer setValueTransformer:[SFBillIdTransformer new] forName:SFBillIdTransformerName];
}

#pragma mark - NSValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if (value == nil) return nil;
    if (![value isKindOfClass:[NSString class]]) return nil;
    
    NSMutableString *newValue = [NSMutableString stringWithString:value];

    return newValue;
}

@end
