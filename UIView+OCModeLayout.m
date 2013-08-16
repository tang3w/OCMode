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
@property (nonatomic, assign) OCModeBaselineType baseline;
@property (nonatomic, copy) OCModeBaselineBlock block;
@property (nonatomic, assign) unsigned long priority;

- (id)initWithView:(UIView *)view baseline:(OCModeBaselineType)baseline block:(OCModeBaselineBlock)block;
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

- (id)initWithView:(UIView *)view baseline:(OCModeBaselineType)baseline block:(OCModeBaselineBlock)block {
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
    OCModeBaselineType baseline = layoutRule.baseline;
    
    self.layoutTable[@(baseline)] = layoutRule;
    
    [self checkConflictForBaseline:baseline];
}

- (void)checkConflictForBaseline:(OCModeBaselineType)baseline {
    switch (baseline) {
        case OCModeBaselineTop:
        case OCModeBaselineAxisY:
        case OCModeBaselineBottom: {
            [self deleteLowestBaselines:OCModeBaselineTop, OCModeBaselineAxisY, OCModeBaselineBottom, NO];
        }
            break;
        case OCModeBaselineLeft:
        case OCModeBaselineAxisX:
        case OCModeBaselineRight: {
            [self deleteLowestBaselines:OCModeBaselineLeft, OCModeBaselineAxisX, OCModeBaselineRight, NO];
        }
            break;
            
        default:
            break;
    }
}

- (void)deleteLowestBaselines:(OCModeBaselineType)baseline, ... {
    OCModeLayoutRule *lowestLayoutRule = self.layoutTable[@(baseline)];
    
    if (!lowestLayoutRule) {
        return;
    }
    
    va_list args;
    va_start(args, baseline);
    
    while ((baseline = va_arg(args, OCModeBaselineType))) {
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

#pragma mark - OCModeLayout

static const void *LAYOUT_ASSOC_KEY;

@implementation OCModeLayout {
    __weak UIView *_layoutView;
}

+ (id)layout {
    return [[self alloc] init];
}

- (instancetype)addTo:(UIView *)view {
    if (!_layoutView) {
        _layoutView = view;
        
        __weak OCModeLayout *that = self;
        
        objc_setAssociatedObject(view, LAYOUT_ASSOC_KEY, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
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
        
        __weak OCModeLayout *that = self;
        
        objc_setAssociatedObject(view, LAYOUT_ASSOC_KEY, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [Eigen eigenInstance:view handler:^(id instance, Eigen *eigen) {
            [eigen addMethod:@selector(layoutSubviews) byBlock:^(UIView *receiver) {
                [that layoutSubviews:receiver];
            }];
        }];
        
        [view setNeedsLayout];
    }
    
    return self;
}

- (instancetype)fix:(UIView *)view baseline:(OCModeBaselineType)baseline to:(OCModeBaselineBlock)block {
    OCModeLayoutScheme *layoutScheme = [OCModeLayoutScheme layoutSchemeWithView:view];
    OCModeLayoutRule *layoutRule = [[OCModeLayoutRule alloc] initWithView:view baseline:baseline block:block];
    
    [layoutScheme addLayoutRule:layoutRule];
    
    return self;
}

- (instancetype)fix:(UIView *)view basepoint:(OCModeBasepointType)basepoint at:(OCModeBasepointBlock)block {
    OCModeLayoutScheme *layoutScheme = [OCModeLayoutScheme layoutSchemeWithView:view];
    
    OCModeBaselineBlock blockX = ^CGFloat(UIView *reciever){ return block(reciever).x; };
    OCModeBaselineBlock blockY = ^CGFloat(UIView *reciever){ return block(reciever).y; };
    
    switch (basepoint) {
        case OCModeBasepointTopLeft: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineTop block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineLeft block:blockX]];
        }
            break;
        case OCModeBasepointTopRight: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineTop block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineRight block:blockX]];
        }
            break;
        case OCModeBasepointBottomLeft: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineBottom block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineLeft block:blockX]];
        }
            break;
        case OCModeBasepointBottomRight: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineBottom block:blockY]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineRight block:blockX]];
        }
            break;
        case OCModeBasepointCenter: {
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineAxisX block:blockX]];
            [layoutScheme addLayoutRule:[[OCModeLayoutRule alloc] initWithView:view baseline:OCModeBaselineAxisY block:blockY]];
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
        case OCModeBaselineTop: {
            CGFloat top = layoutRule.block(layoutView);
            OCModeLayoutRule *axisYRule = layoutTable[@(OCModeBaselineAxisY)];
            
            if (axisYRule && [layoutRule priorityHigherThan:axisYRule]) {
                CGFloat axisY = axisYRule.block(layoutView);
                CGFloat height = 2 * (axisY - top);
                view.height = MAX(height, 0.0f);
            } else {
                OCModeLayoutRule *bottomRule = layoutTable[@(OCModeBaselineBottom)];
                
                if (bottomRule && [layoutRule priorityHigherThan:bottomRule]) {
                    CGFloat bottom = bottomRule.block(layoutView);
                    CGFloat height = bottom - top;
                    view.height = MAX(height, 0.0f);
                }
            }
            
            view.top = top;
        }
            break;
        case OCModeBaselineLeft: {
            CGFloat left = layoutRule.block(layoutView);
            OCModeLayoutRule *axisXRule = layoutTable[@(OCModeBaselineAxisX)];
            
            if (axisXRule && [layoutRule priorityHigherThan:axisXRule]) {
                CGFloat axisX = axisXRule.block(layoutView);
                CGFloat width = 2 * (axisX - left);
                view.width = MAX(width, 0.0f);
            } else {
                OCModeLayoutRule *rightRule = layoutTable[@(OCModeBaselineRight)];
                
                if (rightRule && [layoutRule priorityHigherThan:rightRule]) {
                    CGFloat right = rightRule.block(layoutView);
                    CGFloat width = right - left;
                    view.width = MAX(width, 0.0f);
                }
            }
            
            view.left = left;
        }
            break;
        case OCModeBaselineRight: {
            CGFloat right = layoutRule.block(layoutView);
            OCModeLayoutRule *axisXRule = layoutTable[@(OCModeBaselineAxisX)];
            
            if (axisXRule && [layoutRule priorityHigherThan:axisXRule]) {
                CGFloat axisX = axisXRule.block(layoutView);
                CGFloat width = 2 * (right - axisX);
                view.width = MAX(width, 0.0f);
            } else {
                OCModeLayoutRule *leftRule = layoutTable[@(OCModeBaselineLeft)];
                
                if (leftRule && [layoutRule priorityHigherThan:leftRule]) {
                    CGFloat left = leftRule.block(layoutView);
                    CGFloat width = right - left;
                    view.width = MAX(width, 0.0f);
                }
            }
            
            view.right = right;
        }
            break;
        case OCModeBaselineBottom: {
            CGFloat bottom = layoutRule.block(layoutView);
            OCModeLayoutRule *axisYRule = layoutTable[@(OCModeBaselineAxisY)];
            
            if (axisYRule && [layoutRule priorityHigherThan:axisYRule]) {
                CGFloat axisY = axisYRule.block(layoutView);
                CGFloat height = 2 * (bottom - axisY);
                view.height = MAX(height, 0.0f);
            } else {
                OCModeLayoutRule *topRule = layoutTable[@(OCModeBaselineTop)];
                
                if (topRule && [layoutRule priorityHigherThan:topRule]) {
                    CGFloat top = topRule.block(layoutView);
                    CGFloat height = bottom - top;
                    view.height = MAX(height, 0.0f);
                }
            }
            
            view.bottom = bottom;
        }
            break;
        case OCModeBaselineAxisX: {
            CGFloat axisX = layoutRule.block(layoutView);
            OCModeLayoutRule *leftRule = layoutTable[@(OCModeBaselineLeft)];
            
            if (leftRule && [layoutRule priorityHigherThan:leftRule]) {
                CGFloat left = leftRule.block(layoutView);
                CGFloat width = 2 * (axisX - left);
                view.width = MAX(width, 0.0f);
            } else {
                OCModeLayoutRule *rightRule = layoutTable[@(OCModeBaselineRight)];
                
                if (rightRule && [layoutRule priorityHigherThan:rightRule]) {
                    CGFloat right = rightRule.block(layoutView);
                    CGFloat width = 2 * (right - axisX);
                    view.width = MAX(width, 0.0f);
                }
            }
            
            view.centerX = axisX;
        }
            break;
        case OCModeBaselineAxisY: {
            CGFloat axisY = layoutRule.block(layoutView);
            OCModeLayoutRule *topRule = layoutTable[@(OCModeBaselineTop)];
            
            if (topRule && [layoutRule priorityHigherThan:topRule]) {
                CGFloat top = topRule.block(layoutView);
                CGFloat height = 2 * (axisY - top);
                view.height = MAX(height, 0.0f);
            } else {
                OCModeLayoutRule *bottomRule = layoutTable[@(OCModeBaselineBottom)];
                
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