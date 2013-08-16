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
    OCModeBaselineTop    = 1 << 1,
    OCModeBaselineLeft   = 1 << 2,
    OCModeBaselineRight  = 1 << 3,
    OCModeBaselineBottom = 1 << 4,
    OCModeBaselineAxisX  = 1 << 5,
    OCModeBaselineAxisY  = 1 << 6
};

enum OCModeBasepointType {
    OCModeBasepointTopLeft     = OCModeBaselineTop | OCModeBaselineLeft,
    OCModeBasepointTopRight    = OCModeBaselineTop | OCModeBaselineRight,
    OCModeBasepointBottomLeft  = OCModeBaselineBottom | OCModeBaselineLeft,
    OCModeBasepointBottomRight = OCModeBaselineBottom | OCModeBaselineRight,
    OCModeBasepointAxis        = OCModeBaselineAxisX | OCModeBaselineAxisY
};

typedef enum OCModeBaselineType OCModeBaselineType;
typedef enum OCModeBasepointType OCModeBasepointType;

typedef CGFloat(^OCModeBaselineBlock)(UIView *receiver);
typedef CGPoint(^OCModeBasepointBlock)(UIView *receiver);

@interface OCModeLayout : NSObject

+ (id)layout;

- (instancetype)addTo:(UIView *)view;
- (instancetype)useTo:(UIView *)view;

- (instancetype)fix:(UIView *)view baseline:(OCModeBaselineType)baseline be:(CGFloat)value;
- (instancetype)fix:(UIView *)view baseline:(OCModeBaselineType)baseline to:(OCModeBaselineBlock)block;

- (instancetype)fix:(UIView *)view basepoint:(OCModeBasepointType)basepoint be:(CGPoint)point;
- (instancetype)fix:(UIView *)view basepoint:(OCModeBasepointType)basepoint to:(OCModeBasepointBlock)block;

- (instancetype)fixTop:(UIView *)view be:(CGFloat)value;
- (instancetype)fixLeft:(UIView *)view be:(CGFloat)value;
- (instancetype)fixRight:(UIView *)view be:(CGFloat)value;
- (instancetype)fixBottom:(UIView *)view be:(CGFloat)value;
- (instancetype)fixAxisX:(UIView *)view be:(CGFloat)value;
- (instancetype)fixAxisY:(UIView *)view be:(CGFloat)value;

- (instancetype)fixTop:(UIView *)view to:(OCModeBaselineBlock)block;
- (instancetype)fixLeft:(UIView *)view to:(OCModeBaselineBlock)block;
- (instancetype)fixRight:(UIView *)view to:(OCModeBaselineBlock)block;
- (instancetype)fixBottom:(UIView *)view to:(OCModeBaselineBlock)block;
- (instancetype)fixAxisX:(UIView *)view to:(OCModeBaselineBlock)block;
- (instancetype)fixAxisY:(UIView *)view to:(OCModeBaselineBlock)block;

- (instancetype)fixTopLeft:(UIView *)view be:(CGPoint)point;
- (instancetype)fixTopRight:(UIView *)view be:(CGPoint)point;
- (instancetype)fixBottomLeft:(UIView *)view be:(CGPoint)point;
- (instancetype)fixBottomRight:(UIView *)view be:(CGPoint)point;
- (instancetype)fixAxis:(UIView *)view be:(CGPoint)point;

- (instancetype)fixTopLeft:(UIView *)view to:(OCModeBasepointBlock)block;
- (instancetype)fixTopRight:(UIView *)view to:(OCModeBasepointBlock)blcok;
- (instancetype)fixBottomLeft:(UIView *)view to:(OCModeBasepointBlock)block;
- (instancetype)fixBottomRight:(UIView *)view to:(OCModeBasepointBlock)block;
- (instancetype)fixAxis:(UIView *)view to:(OCModeBasepointBlock)block;

@end