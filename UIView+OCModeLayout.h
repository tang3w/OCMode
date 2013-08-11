// UIView+OCModeLayout.h
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

#import <UIKit/UIKit.h>

@protocol OCModeLayoutDelegate <NSObject>

@required
- (void)layoutSubviews:(UIView *)receiver;

@end

@interface UIView (OCModeLayout)

- (void)useLayoutSystem:(id<OCModeLayoutDelegate>)system;
- (void)addLayoutSystem:(id<OCModeLayoutDelegate>)system;

@end

typedef CGPoint(^OCModeLayoutFixPoint)(UIView *receiver);

typedef enum {
    OCModeLayoutFixTop = 1 << 0,
    OCModeLayoutFixLeft = 1 << 1,
    OCModeLayoutFixRight = 1 << 2,
    OCModeLayoutFixBottom = 1 << 3,
    
    OCModeLayoutFixTopLeft = OCModeLayoutFixTop | OCModeLayoutFixLeft,
    OCModeLayoutFixTopRight = OCModeLayoutFixTop | OCModeLayoutFixRight,
    OCModeLayoutFixBottomLeft = OCModeLayoutFixBottom | OCModeLayoutFixLeft,
    OCModeLayoutFixBottomRight = OCModeLayoutFixBottom | OCModeLayoutFixRight
} OCModeLayoutFixType;

@interface OCModeLayoutSystem : NSObject <OCModeLayoutDelegate>

+ (id)layoutSystem;
+ (id)layoutSystemAddToView:(UIView *)view;
+ (id)layoutSystemUseToView:(UIView *)view;

- (instancetype)addToView:(UIView *)view;
- (instancetype)useToView:(UIView *)view;

- (instancetype)fix:(OCModeLayoutFixType)type view:(UIView *)view to:(OCModeLayoutFixPoint)point;
- (instancetype)fix:(OCModeLayoutFixType)type views:(NSArray *)views to:(OCModeLayoutFixPoint)point;

@end
