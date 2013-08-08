// NSObject+OCMode.m
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

#import "NSObject+OCMode.h"
#import <objc/runtime.h>
#import "Block+OCMode.h"

static void *const EIGENCLASS_ASSOC_KEY;

static Class imp_class(id self, SEL _cmd) {
    if ([self eigenclass] != Nil) {
        Class cls = class_getSuperclass([self eigenclass]);
        IMP imp = method_getImplementation(class_getClassMethod(cls, _cmd));
        return imp(cls, _cmd);
    } else {
        return object_getClass(self);
    }
}

@implementation NSObject (OCMode)

- (Class)eigenclass {
    return objc_getAssociatedObject(self, EIGENCLASS_ASSOC_KEY);
}

- (instancetype)extendInstance:(tExtendInstanceBlock)handler {
    static unsigned long long suffix = 0;
    
    Class cls = [self class];
    const char *name = [[NSString stringWithFormat:@"%s#%llu", class_getName(cls), ++suffix] UTF8String];
    
    Class eigenclass = Nil;
    
    if (objc_getClass(name) == nil) {
        eigenclass = objc_allocateClassPair(object_getClass(self), name, 0);
        
        if (eigenclass != Nil) {
            Method m = class_getInstanceMethod(cls, @selector(class));
            class_addMethod(eigenclass, @selector(class), (IMP)imp_class, method_getTypeEncoding(m));
            
            objc_registerClassPair(eigenclass);
            object_setClass(self, eigenclass);
        }
    }
    
    objc_setAssociatedObject(self, EIGENCLASS_ASSOC_KEY, eigenclass, OBJC_ASSOCIATION_ASSIGN);
    
    handler(self, eigenclass);
    
    return self;
}

- (instancetype)addEigenMethod:(SEL)selector byBlock:(id)block {
    if ([self eigenclass] != Nil) {
        const char *sig = blockSignature(block);
        if (sig != NULL) {
            [block copy];
            class_addMethod([self eigenclass], selector, imp_implementationWithBlock(block), sig);
        }
    }
    
    return self;
}

@end
