// UIView+OCMode.h
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

@interface UIView (OCMode)

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat offsetCenterX;
@property (nonatomic, assign) CGFloat offsetCenterY;
@property (nonatomic, assign) CGPoint offsetCenter;

- (instancetype)centerX:(CGFloat)centerX;
- (instancetype)centerY:(CGFloat)centerY;
- (instancetype)center:(CGPoint)center;

- (instancetype)offsetCenterX:(CGFloat)offsetCenterX;
- (instancetype)offsetCenterY:(CGFloat)offsetCenterY;
- (instancetype)offsetCenter:(CGPoint)offsetCenter;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat offsetWidth;
@property (nonatomic, assign) CGFloat offsetHeight;
@property (nonatomic, assign) CGSize offsetSize;

- (instancetype)width:(CGFloat)width;
- (instancetype)height:(CGFloat)height;
- (instancetype)size:(CGSize)size;

- (instancetype)offsetWidth:(CGFloat)offsetWidth;
- (instancetype)offsetHeight:(CGFloat)offsetHeight;
- (instancetype)offsetSize:(CGSize)offsetSize;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign, getter = x, setter = setX:) CGFloat left;
@property (nonatomic, assign, getter = y, setter = setY:) CGFloat top;
@property (nonatomic, assign, getter = x, setter = setX:) CGFloat originX;
@property (nonatomic, assign, getter = y, setter = setY:) CGFloat originY;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat rightToSuperView;
@property (nonatomic, assign) CGFloat bottomToSuperView;

@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign, getter = offsetX, setter = setOffsetX:) CGFloat offsetLeft;
@property (nonatomic, assign, getter = offsetY, setter = setOffsetY:) CGFloat offsetTop;
@property (nonatomic, assign) CGPoint offsetOrigin;

- (instancetype)x:(CGFloat)x;
- (instancetype)y:(CGFloat)y;
- (instancetype)left:(CGFloat)left;
- (instancetype)top:(CGFloat)top;
- (instancetype)originX:(CGFloat)originX;
- (instancetype)originY:(CGFloat)originY;
- (instancetype)origin:(CGPoint)origin;

- (instancetype)right:(CGFloat)right;
- (instancetype)bottom:(CGFloat)bottom;
- (instancetype)rightToSuper:(CGFloat)rightToSuperView;
- (instancetype)bottomToSuper:(CGFloat)bottomToSuperView;

- (instancetype)offsetX:(CGFloat)offsetX;
- (instancetype)offsetY:(CGFloat)offsetY;
- (instancetype)offsetLeft:(CGFloat)offsetLeft;
- (instancetype)offsetTop:(CGFloat)offsetTop;
- (instancetype)offsetOrigin:(CGPoint)offsetOrigin;

@property (nonatomic, assign) CGFloat zoomOfWidth;
@property (nonatomic, assign) CGFloat zoomOfHeight;
@property (nonatomic, assign) CGFloat zoom;

- (instancetype)zoomOfWidth:(CGFloat)zoomOfWidth;
- (instancetype)zoomOfHeight:(CGFloat)zoomOfHeight;
- (instancetype)zoom:(CGFloat)zoom;

@property (nonatomic, assign, readonly) CGPoint midPoint;

@end
