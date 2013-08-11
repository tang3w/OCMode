// UIView+OCModeLayout.m
//
// Copyright (c) 2013 Tang Tianyong
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
// KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
// AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#import "UIView+OCModeLayout.h"
#import <objc/runtime.h>
#import "UIView+OCMode.h"
#import "Eigen.h"

@implementation UIView (OCModeLayout)

- (void)useLayoutSystem:(id<OCModeLayoutDelegate>)system {
    [Eigen eigenInstance:self handler:^(id instance, Eigen *eigenclass) {
        [eigenclass addMethod:@selector(layoutSubviews) byBlock:^(id receiver) {
            [system layoutSubviews:receiver];
        }];
    }];
    
    [self setNeedsLayout];
}

- (void)addLayoutSystem:(id<OCModeLayoutDelegate>)system {
    [Eigen eigenInstance:self handler:^(id instance, Eigen *eigenclass) {
        SEL sel = @selector(layoutSubviews);
        void(^superBlock)(id) = [eigenclass superBlock:sel];
        
        [eigenclass addMethod:@selector(layoutSubviews) byBlock:^(id receiver) {
            if (superBlock) {
                superBlock(receiver);
            }
            
            [system layoutSubviews:receiver];
        }];
    }];
    
    [self setNeedsLayout];
}

@end

static void *RELATIONSHIPS_ASSOC_KEY;

@implementation OCModeLayoutSystem

+ (id)layoutSystem {
    return [[self alloc] init];
}

+ (id)layoutSystemAddToView:(UIView *)view {
    OCModeLayoutSystem *ls = [self layoutSystem];
    [view addLayoutSystem:ls];
    return ls;
}

+ (id)layoutSystemUseToView:(UIView *)view {
    OCModeLayoutSystem *ls = [self layoutSystem];
    [view useLayoutSystem:ls];
    return ls;
}

- (instancetype)addToView:(UIView *)view {
    [view addLayoutSystem:self];
    
    return self;
}

- (instancetype)useToView:(UIView *)view {
    [view useLayoutSystem:self];
    
    return self;
}

- (instancetype)fix:(OCModeLayoutFixType)type view:(UIView *)view to:(OCModeLayoutFixPoint)point {
    static unsigned long priority = 0;
    ++priority;
    
    NSMutableDictionary *relationships = objc_getAssociatedObject(view, RELATIONSHIPS_ASSOC_KEY);
    
    if (relationships == nil) {
        relationships = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(view, RELATIONSHIPS_ASSOC_KEY, relationships, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [point copy];
    
    if (type & OCModeLayoutFixTop) {
        relationships[@(OCModeLayoutFixTop)] = @{
            @"view":view, @"of":@(OCModeLayoutFixTop), @"to":point, @"priority":@(priority)
        };
    }
    
    if (type & OCModeLayoutFixLeft) {
        relationships[@(OCModeLayoutFixLeft)] = @{
            @"view":view, @"of":@(OCModeLayoutFixLeft), @"to":point, @"priority":@(priority)
        };
    }
    
    if (type & OCModeLayoutFixRight) {
        relationships[@(OCModeLayoutFixRight)] = @{
            @"view":view, @"of":@(OCModeLayoutFixRight), @"to":point, @"priority":@(priority)
        };
    }
    
    if (type & OCModeLayoutFixBottom) {
        relationships[@(OCModeLayoutFixBottom)] = @{
            @"view":view, @"of":@(OCModeLayoutFixBottom), @"to":point, @"priority":@(priority)
        };
    }
    
    return self;
}

- (instancetype)fix:(OCModeLayoutFixType)type views:(NSArray *)views to:(OCModeLayoutFixPoint)point {
    for (UIView *view in views) {
        [self fix:type view:view to:point];
    }
    
    return self;
}

- (void)layoutSubviews:(UIView *)receiver {
    NSMutableArray *allRelationships = [[NSMutableArray alloc] init];
    
    for (UIView *view in [receiver subviews]) {
        NSDictionary *relationships = objc_getAssociatedObject(view, RELATIONSHIPS_ASSOC_KEY);
        
        if (relationships) {
            [allRelationships addObjectsFromArray:[relationships allValues]];
        }
    }
    
    [allRelationships sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"priority"] compare:obj2[@"priority"]];
    }];
    
    [self applyRelationships:allRelationships to:receiver];
}

- (void)applyRelationships:(NSArray *)allRelationships to:(UIView *)receiver {
    for (NSDictionary *relationship in allRelationships) {
        
        UIView *view = relationship[@"view"];
        OCModeLayoutFixType keepType = [relationship[@"of"] integerValue];
        NSDictionary *relationships = objc_getAssociatedObject(view, RELATIONSHIPS_ASSOC_KEY);
        CGPoint referencePoint = ((CGPoint(^)(UIView *))relationship[@"to"])(receiver);
        
        switch (keepType) {
            case OCModeLayoutFixTop:
                if (relationships[@(OCModeLayoutFixBottom)]) {
                    CGFloat height = view.bottom - referencePoint.y;
                    view.height = MAX(height, 0.0f);
                }
                view.top = referencePoint.y;
                break;
            case OCModeLayoutFixLeft:
                if (relationships[@(OCModeLayoutFixRight)]) {
                    CGFloat width = view.right - referencePoint.x;
                    view.width = MAX(width, 0.0f);
                }
                view.left = referencePoint.x;
                break;
            case OCModeLayoutFixRight:
                if (relationships[@(OCModeLayoutFixLeft)]) {
                    CGFloat width = referencePoint.x - view.left;
                    view.width = MAX(width, 0.0f);
                }
                view.right = referencePoint.x;
                break;
            case OCModeLayoutFixBottom:
                if (relationships[@(OCModeLayoutFixTop)]){
                    CGFloat height = referencePoint.y - view.top;
                    view.height = MAX(height, 0.0f);
                }
                view.bottom = referencePoint.y;
                break;
            default: break;
        }
    }
}

@end
