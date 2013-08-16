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

@class OCModeLayoutScheme;

@interface OCModeLayoutRule : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) OCModeLayoutBaselineType baseline;
@property (nonatomic, copy) OCModeLayoutBaselineBlock block;
@property (nonatomic, assign) unsigned long priority;

- (id)initWithView:(UIView *)view baseline:(OCModeLayoutBaselineType)baseline block:(OCModeLayoutBaselineBlock)block;
- (BOOL)priorityHigherThan:(OCModeLayoutRule *)layoutRule;
- (NSDictionary *)layoutTable;

@end

@interface OCModeLayoutScheme : NSObject

@property (nonatomic, strong) NSMutableDictionary *layoutTable;

+ (id)layoutSchemeWithView:(UIView *)view;
+ (id)layoutSchemeOfView:(UIView *)view;

- (void)addLayoutRule:(OCModeLayoutRule *)layoutRule;

@end

#pragma mark - OCModeLayoutRule

@implementation OCModeLayoutRule

- (id)initWithView:(UIView *)view baseline:(OCModeLayoutBaselineType)baseline block:(OCModeLayoutBaselineBlock)block {
    static unsigned long priority = 0;
    
    self = [super init];
    
    if (self) {
        self.view = view;
        self.baseline = baseline;
        self.block = block;
        self.priority = ++priority;
    }
    
    return self;
}

- (BOOL)priorityHigherThan:(OCModeLayoutRule *)layoutRule {
    return self.priority > layoutRule.priority;
}

- (NSDictionary *)layoutTable {
    return [[OCModeLayoutScheme layoutSchemeOfView:self.view] layoutTable];
}

@end

#pragma mark - OCModeLayoutScheme

static const void *LAYOUT_SCHEME_ASSOC_KEY;

@implementation OCModeLayoutScheme

+ (id)layoutSchemeWithView:(UIView *)view {
    OCModeLayoutScheme *layoutScheme = [self layoutSchemeOfView:view];
    
    if (!layoutScheme) {
        layoutScheme = [[OCModeLayoutScheme alloc] init];
        objc_setAssociatedObject(view, LAYOUT_SCHEME_ASSOC_KEY, layoutScheme, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return layoutScheme;
}

+ (id)layoutSchemeOfView:(UIView *)view {
    return objc_getAssociatedObject(view, LAYOUT_SCHEME_ASSOC_KEY);
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.layoutTable = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)addLayoutRule:(OCModeLayoutRule *)layoutRule {
    OCModeLayoutBaselineType baseline = layoutRule.baseline;
    
    self.layoutTable[@(baseline)] = layoutRule;
    
    [self checkConflictForBaseline:baseline];
}

- (void)checkConflictForBaseline:(OCModeLayoutBaselineType)baseline {
    switch (baseline) {
        case OCModeLayoutBaselineTop:
        case OCModeLayoutBaselineAxisY:
        case OCModeLayoutBaselineBottom: {
            [self deleteLowestBaselines:OCModeLayoutBaselineTop, OCModeLayoutBaselineAxisY, OCModeLayoutBaselineBottom, NO];
        }
            break;
        case OCModeLayoutBaselineLeft:
        case OCModeLayoutBaselineAxisX:
        case OCModeLayoutBaselineRight: {
            [self deleteLowestBaselines:OCModeLayoutBaselineLeft, OCModeLayoutBaselineAxisX, OCModeLayoutBaselineRight, NO];
        }
            break;
            
        default:
            break;
    }
}

- (void)deleteLowestBaselines:(OCModeLayoutBaselineType)baseline, ... {
    OCModeLayoutRule *lowestLayoutRule = self.layoutTable[@(baseline)];
    
    if (!lowestLayoutRule) {
        return;
    }
    
    va_list args;
    va_start(args, baseline);
    
    while ((baseline = va_arg(args, OCModeLayoutBaselineType))) {
        OCModeLayoutRule *layoutRule = self.layoutTable[@(baseline)];
        
        if (!layoutRule) {
            return;
        }
        
        if ([lowestLayoutRule priorityHigherThan:layoutRule]) {
            lowestLayoutRule = layoutRule;
        }
    }
    
    va_end(args);
    
    [self.layoutTable removeObjectForKey:@(lowestLayoutRule.baseline)];
}

@end

#pragma mark - OCModeLayoutSystem

static const void *LAYOUT_SYSTEM_ASSOC_KEY;

@implementation OCModeLayoutSystem {
    __weak UIView *_layoutView;
}

+ (id)layoutSystem {
    return [[self alloc] init];
}

- (instancetype)addTo:(UIView *)view {
    if (!_layoutView) {
        _layoutView = view;
        
        __weak OCModeLayoutSystem *that = self;
        
        objc_setAssociatedObject(view, LAYOUT_SYSTEM_ASSOC_KEY, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [Eigen eigenInstance:view handler:^(id instance, Eigen *eigen) {
            SEL sel = @selector(layoutSubviews);
            void(^superBlock)(id) = [eigen superBlock:sel];
            __weak Eigen *localEigen = eigen;
            
            [eigen addMethod:@selector(layoutSubviews) byBlock:^(id receiver) {
                if (superBlock) {
                    superBlock(receiver);
                } else {
                    IMP imp = [localEigen superImplementation:sel];
                    if (imp != NULL) {
                        imp(receiver, sel);
                    }
                }
                
                [that layoutSubviews:receiver];
            }];
        }];
        
        [view setNeedsLayout];
    }
    
    return self;
}

- (instancetype)useTo:(UIView *)view {
    if (!_layoutView) {
        _layoutView = view;
        
        __weak OCModeLayoutSystem *that = self;
        
        objc_setAssociatedObject(view, LAYOUT_SYSTEM_ASSOC_KEY, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [Eigen eigenInstance:view handler:^(id instance, Eigen *eigen) {
            [eigen addMethod:@selector(layoutSubviews) byBlock:^(UIView *receiver) {
                [that layoutSubviews:receiver];
            }];
        }];
        
        [view setNeedsLayout];
    }
    
    return self;
}

- (instancetype)fix:(UIView *)view baseline:(OCModeLayoutBaselineType)baseline to:(OCModeLayoutBaselineBlock)block {
    OCModeLayoutScheme *layoutScheme = [OCModeLayoutScheme layoutSchemeWithView:view];
    OCModeLayoutRule *layoutRule = [[OCModeLayoutRule alloc] initWithView:view baseline:baseline block:block];
    
    [layoutScheme addLayoutRule:layoutRule];
    
    return self;
}

- (instancetype)fix:(UIView *)view basepoint:(OCModeLayoutBasepointType)basepoint at:(OCModeLayoutBasepointBlock)block {
    OCModeLayoutScheme *layoutScheme = [OCModeLayoutScheme layoutSchemeWithView:view];
    
    OCModeLayoutBaselineBlock blockX = ^CGFloat(UIView *reciever){ return block(reciever).x; };
    OCModeLayoutBaselineBlock blockY = ^CGFloat(UIView *reciever){ return block(reciever).y; };
    
    switch (basepoint) {
        case OCModeLayoutBasepointTopLeft: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineTop block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineLeft block:blockX]];
        }
            break;
        case OCModeLayoutBasepointTopRight: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineTop block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineRight block:blockX]];
        }
            break;
        case OCModeLayoutBasepointBottomLeft: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineBottom block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineLeft block:blockX]];
        }
            break;
        case OCModeLayoutBasepointBottomRight: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineBottom block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineRight block:blockX]];
        }
            break;
        case OCModeLayoutBasepointCenter: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineAxisX block:blockX]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeLayoutBaselineAxisY block:blockY]];
        }
            
        default:
            break;
    }
    
    return self;
}

- (void)layoutSubviews:(UIView *)receiver {
    NSMutableArray *layoutRules = [[NSMutableArray alloc] init];
    
    for (UIView *view in [receiver subviews]) {
        OCModeLayoutScheme *layoutScheme = [OCModeLayoutScheme layoutSchemeOfView:view];
        if (layoutScheme) {
            [layoutRules addObjectsFromArray:[layoutScheme.layoutTable allValues]];
        }
    }
    
    [layoutRules sortUsingComparator:^NSComparisonResult(OCModeLayoutRule *obj1, OCModeLayoutRule *obj2) {
        if (obj1.priority < obj2.priority) return NSOrderedAscending;
        if (obj1.priority > obj2.priority) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    for (OCModeLayoutRule *layoutRule in layoutRules) {
        [self layoutView:receiver layoutRule:layoutRule];
    }
}

- (void)layoutView:(UIView *)layoutView layoutRule:(OCModeLayoutRule *)layoutRule {
    UIView *view = layoutRule.view;
    NSDictionary *layoutTable = [layoutRule layoutTable];
    
    switch (layoutRule.baseline) {
        case OCModeLayoutBaselineTop: {
            CGFloat top = layoutRule.block(layoutView);
            OCModeLayoutRule *axisYRule = layoutTable[@(OCModeLayoutBaselineAxisY)];
            
            if (axisYRule && [layoutRule priorityHigherThan:axisYRule]) {
                CGFloat axisY = axisYRule.block(layoutView);
                CGFloat height = 2 * (axisY - top);
                view.height = MAX(height, 0.0f);
            } else {
                OCModeLayoutRule *bottomRule = layoutTable[@(OCModeLayoutBaselineBottom)];
                
                if (bottomRule && [layoutRule priorityHigherThan:bottomRule]) {
                    CGFloat bottom = bottomRule.block(layoutView);
                    CGFloat height = bottom - top;
                    view.height = MAX(height, 0.0f);
                }
            }
            
            view.top = top;
        }
            break;
        case OCModeLayoutBaselineLeft: {
            CGFloat left = layoutRule.block(layoutView);
            OCModeLayoutRule *axisXRule = layoutTable[@(OCModeLayoutBaselineAxisX)];
            
            if (axisXRule && [layoutRule priorityHigherThan:axisXRule]) {
                CGFloat axisX = axisXRule.block(layoutView);
                CGFloat width = 2 * (axisX - left);
                view.width = MAX(width, 0.0f);
            } else {
                OCModeLayoutRule *rightRule = layoutTable[@(OCModeLayoutBaselineRight)];
                
                if (rightRule && [layoutRule priorityHigherThan:rightRule]) {
                    CGFloat right = rightRule.block(layoutView);
                    CGFloat width = right - left;
                    view.width = MAX(width, 0.0f);
                }
            }
            
            view.left = left;
        }
            break;
        case OCModeLayoutBaselineRight: {
            CGFloat right = layoutRule.block(layoutView);
            OCModeLayoutRule *axisXRule = layoutTable[@(OCModeLayoutBaselineAxisX)];
            
            if (axisXRule && [layoutRule priorityHigherThan:axisXRule]) {
                CGFloat axisX = axisXRule.block(layoutView);
                CGFloat width = 2 * (right - axisX);
                view.width = MAX(width, 0.0f);
            } else {
                OCModeLayoutRule *leftRule = layoutTable[@(OCModeLayoutBaselineLeft)];
                
                if (leftRule && [layoutRule priorityHigherThan:leftRule]) {
                    CGFloat left = leftRule.block(layoutView);
                    CGFloat width = right - left;
                    view.width = MAX(width, 0.0f);
                }
            }
            
            view.right = right;
        }
            break;
        case OCModeLayoutBaselineBottom: {
            CGFloat bottom = layoutRule.block(layoutView);
            OCModeLayoutRule *axisYRule = layoutTable[@(OCModeLayoutBaselineAxisY)];
            
            if (axisYRule && [layoutRule priorityHigherThan:axisYRule]) {
                CGFloat axisY = axisYRule.block(layoutView);
                CGFloat height = 2 * (bottom - axisY);
                view.height = MAX(height, 0.0f);
            } else {
                OCModeLayoutRule *topRule = layoutTable[@(OCModeLayoutBaselineTop)];
                
                if (topRule && [layoutRule priorityHigherThan:topRule]) {
                    CGFloat top = topRule.block(layoutView);
                    CGFloat height = bottom - top;
                    view.height = MAX(height, 0.0f);
                }
            }
            
            view.bottom = bottom;
        }
            break;
        case OCModeLayoutBaselineAxisX: {
            CGFloat axisX = layoutRule.block(layoutView);
            OCModeLayoutRule *leftRule = layoutTable[@(OCModeLayoutBaselineLeft)];
            
            if (leftRule && [layoutRule priorityHigherThan:leftRule]) {
                CGFloat left = leftRule.block(layoutView);
                CGFloat width = 2 * (axisX - left);
                view.width = MAX(width, 0.0f);
            } else {
                OCModeLayoutRule *rightRule = layoutTable[@(OCModeLayoutBaselineRight)];
                
                if (rightRule && [layoutRule priorityHigherThan:rightRule]) {
                    CGFloat right = rightRule.block(layoutView);
                    CGFloat width = 2 * (right - axisX);
                    view.width = MAX(width, 0.0f);
                }
            }
            
            view.centerX = axisX;
        }
            break;
        case OCModeLayoutBaselineAxisY: {
            CGFloat axisY = layoutRule.block(layoutView);
            OCModeLayoutRule *topRule = layoutTable[@(OCModeLayoutBaselineTop)];
            
            if (topRule && [layoutRule priorityHigherThan:topRule]) {
                CGFloat top = topRule.block(layoutView);
                CGFloat height = 2 * (axisY - top);
                view.height = MAX(height, 0.0f);
            } else {
                OCModeLayoutRule *bottomRule = layoutTable[@(OCModeLayoutBaselineBottom)];
                
                if (bottomRule && [layoutRule priorityHigherThan:bottomRule]) {
                    CGFloat bottom = bottomRule.block(layoutView);
                    CGFloat height = 2 * (bottom - axisY);
                    view.height = MAX(height, 0.0f);
                }
            }
            
            view.centerY = axisY;
        }
            break;
            
        default:
            break;
    }
}

@end