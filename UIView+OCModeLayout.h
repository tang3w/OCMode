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

enum OCModeLayoutBaselineType {
    OCModeLayoutBaselineTop    = 1 << 1,
    OCModeLayoutBaselineLeft   = 1 << 2,
    OCModeLayoutBaselineRight  = 1 << 3,
    OCModeLayoutBaselineBottom = 1 << 4,
    OCModeLayoutBaselineAxisX  = 1 << 5,
    OCModeLayoutBaselineAxisY  = 1 << 6
};

enum OCModeLayoutBasepointType {
    OCModeLayoutBasepointTopLeft     = OCModeLayoutBaselineTop | OCModeLayoutBaselineLeft,
    OCModeLayoutBasepointTopRight    = OCModeLayoutBaselineTop | OCModeLayoutBaselineRight,
    OCModeLayoutBasepointBottomLeft  = OCModeLayoutBaselineBottom | OCModeLayoutBaselineLeft,
    OCModeLayoutBasepointBottomRight = OCModeLayoutBaselineBottom | OCModeLayoutBaselineRight,
    OCModeLayoutBasepointCenter      = OCModeLayoutBaselineAxisX | OCModeLayoutBaselineAxisY
};

typedef enum OCModeLayoutBaselineType OCModeLayoutBaselineType;
typedef enum OCModeLayoutBasepointType OCModeLayoutBasepointType;

typedef CGFloat(^OCModeLayoutBaselineBlock)(UIView *receiver);
typedef CGPoint(^OCModeLayoutBasepointBlock)(UIView *receiver);

@interface OCModeLayoutSystem : NSObject

+ (id)layoutSystem;

- (instancetype)addTo:(UIView *)view;
- (instancetype)useTo:(UIView *)view;

- (instancetype)fix:(UIView *)view baseline:(OCModeLayoutBaselineType)baseline to:(OCModeLayoutBaselineBlock)block;
- (instancetype)fix:(UIView *)view basepoint:(OCModeLayoutBasepointType)basepoint at:(OCModeLayoutBasepointBlock)block;

@end