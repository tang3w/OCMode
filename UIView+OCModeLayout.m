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
