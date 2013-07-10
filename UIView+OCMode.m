// UIView+OCMode.m
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

#import "UIView+OCMode.h"

@implementation UIView (OCMode)

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint point = self.center;
    point.x = centerX;
    self.center = point;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint point = self.center;
    point.y = centerY;
    self.center = point;
}

- (CGFloat)offsetCenterX {
    return 0.0f;
}

- (void)setOffsetCenterX:(CGFloat)offsetCenterX {
    self.centerX += offsetCenterX;
}

- (CGFloat)offsetCenterY {
    return 0.0f;
}

- (void)setOffsetCenterY:(CGFloat)offsetCenterY {
    self.centerY += offsetCenterY;
}

- (CGPoint)offsetCenter {
    return CGPointZero;
}

- (void)setOffsetCenter:(CGPoint)offsetCenter {
    self.centerX += offsetCenter.x;
    self.centerY += offsetCenter.y;
}

- (instancetype)centerX:(CGFloat)centerX {
    self.centerX = centerX;
    return self;
}

- (instancetype)centerY:(CGFloat)centerY {
    self.centerY = centerY;
    return self;
}

- (instancetype)center:(CGPoint)center {
    self.center = center;
    return self;
}

- (instancetype)offsetCenterX:(CGFloat)offsetCenterX {
    self.offsetCenterX = offsetCenterX;
    return self;
}

- (instancetype)offsetCenterY:(CGFloat)offsetCenterY {
    self.offsetCenterY = offsetCenterY;
    return self;
}

- (instancetype)offsetCenter:(CGPoint)offsetCenter {
    self.offsetCenter = offsetCenter;
    return self;
}

- (CGFloat)width {
    return self.bounds.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect rect = self.bounds;
    rect.size.width = width;
    self.bounds = rect;
}

- (CGFloat)height {
    return self.bounds.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect rect = self.bounds;
    rect.size.height = height;
    self.bounds = rect;
}

- (CGSize)size {
    return self.bounds.size;
}

- (void)setSize:(CGSize)size {
    self.width = size.width;
    self.height = size.height;
}

- (CGFloat)offsetWidth {
    return 0.0f;
}

- (void)setOffsetWidth:(CGFloat)offsetWidth {
    self.width += offsetWidth;
}

- (CGFloat)offsetHeight {
    return 0.0f;
}

- (void)setOffsetHeight:(CGFloat)offsetHeight {
    self.height += offsetHeight;
}

- (CGSize)offsetSize {
    return CGSizeZero;
}

- (void)setOffsetSize:(CGSize)offsetSize {
    self.offsetWidth = offsetSize.width;
    self.offsetHeight = offsetSize.height;
}

- (instancetype)width:(CGFloat)width {
    self.width = width;
    return self;
}
- (instancetype)height:(CGFloat)height {
    self.height = height;
    return self;
}

- (instancetype)size:(CGSize)size {
    self.size = size;
    return self;
}

- (instancetype)offsetWidth:(CGFloat)offsetWidth {
    self.offsetWidth = offsetWidth;
    return self;
}

- (instancetype)offsetHeight:(CGFloat)offsetHeight {
    self.offsetHeight = offsetHeight;
    return self;
}

- (instancetype)offsetSize:(CGSize)offsetSize {
    self.offsetSize = offsetSize;
    return self;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    self.x = origin.x;
    self.y = origin.y;
}

- (CGFloat)offsetX {
    return 0.0f;
}

- (void)setOffsetX:(CGFloat)offsetX {
    self.x += offsetX;
}

- (CGFloat)offsetY {
    return 0.0f;
}

- (void)setOffsetY:(CGFloat)offsetY {
    self.y += offsetY;
}

- (CGPoint)offsetOrigin {
    return CGPointZero;
}

- (void)setOffsetOrigin:(CGPoint)offsetOrigin {
    self.offsetX = offsetOrigin.x;
    self.offsetY = offsetOrigin.y;
}

- (instancetype)x:(CGFloat)x {
    self.x = x;
    return self;
}

- (instancetype)y:(CGFloat)y {
    self.y = y;
    return self;
}

- (instancetype)left:(CGFloat)left {
    return [self x:left];
}

- (instancetype)top:(CGFloat)top {
    return [self y:top];
}

- (instancetype)originX:(CGFloat)originX {
    return [self x:originX];
}

- (instancetype)originY:(CGFloat)originY {
    return [self y:originY];
}

- (instancetype)origin:(CGPoint)origin {
    self.origin = origin;
    return self;
}

- (instancetype)offsetX:(CGFloat)offsetX {
    self.offsetX = offsetX;
    return self;
}

- (instancetype)offsetY:(CGFloat)offsetY {
    self.offsetY = offsetY;
    return self;
}

- (instancetype)offsetLeft:(CGFloat)offsetLeft {
    return [self offsetX:offsetLeft];
}

- (instancetype)offsetTop:(CGFloat)offsetTop {
    return [self offsetY:offsetTop];
}

- (instancetype)offsetOrigin:(CGPoint)offsetOrigin {
    self.offsetOrigin = offsetOrigin;
    return self;
}

- (CGFloat)zoomOfWidth {
    return 0.0f;
}

- (void)setZoomOfWidth:(CGFloat)zoomOfWidth {
    self.width *= zoomOfWidth;
}

- (CGFloat)zoomOfHeight {
    return 0.0f;
}

- (void)setZoomOfHeight:(CGFloat)zoomOfHeight {
    self.height *= zoomOfHeight;
}

- (CGFloat)zoom {
    return 0.0f;
}

- (void)setZoom:(CGFloat)zoom {
    self.width *= zoom;
    self.height *= zoom;
}

- (instancetype)zoomOfWidth:(CGFloat)zoomOfWidth {
    self.zoomOfWidth = zoomOfWidth;
    return self;
}

- (instancetype)zoomOfHeight:(CGFloat)zoomOfHeight {
    self.zoomOfHeight = zoomOfHeight;
    return self;
}

- (instancetype)zoom:(CGFloat)zoom {
    self.zoom = zoom;
    return self;
}

- (CGPoint)midPoint {
    return CGPointMake(self.width / 2.0f, self.height / 2.0f);
}

@end
