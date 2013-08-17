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

enum OCModeBaselineType {
    OCModeBaselineTop = 1,
    OCModeBaselineLeft,
    OCModeBaselineRight,
    OCModeBaselineBottom,
    OCModeBaselineAxisX,
    OCModeBaselineAxisY
};

enum OCModeBasepointType {
    OCModeBasepointTopLeft,
    OCModeBasepointTopRight,
    OCModeBasepointBottomLeft,
    OCModeBasepointBottomRight,
    OCModeBasepointAxis
};

typedef enum OCModeBaselineType OCModeBaselineType;
typedef enum OCModeBasepointType OCModeBasepointType;

typedef CGFloat(^OCModeBaselineBlock)(UIView *receiver);
typedef CGPoint(^OCModeBasepointBlock)(UIView *receiver);

@interface OCModeLayout : NSObject

- (instancetype)addTo:(UIView *)view;
- (instancetype)useTo:(UIView *)view;

- (instancetype)align:(UIView *)view baseline:(OCModeBaselineType)baseline to:(OCModeBaselineBlock)block;
- (instancetype)align:(UIView *)view basepoint:(OCModeBasepointType)basepoint to:(OCModeBasepointBlock)block;

- (instancetype)align:(UIView *)view baseline:(OCModeBaselineType)baseline be:(CGFloat)value;
- (instancetype)align:(UIView *)view basepoint:(OCModeBasepointType)basepoint be:(CGPoint)point;

@end