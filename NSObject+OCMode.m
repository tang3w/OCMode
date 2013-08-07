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

- (Class)createEigenclassByName:(NSString *)name {
    if (NSClassFromString(name) != Nil) {
        return Nil;
    }
    
    Class cls = [self class];
    Class eigenclass = objc_allocateClassPair(cls, [name UTF8String], 0);
    
    if (eigenclass != Nil) {
        
        Method m = class_getInstanceMethod(cls, @selector(class));
        class_addMethod(eigenclass, @selector(class), (IMP)imp_class, method_getTypeEncoding(m));
        
        objc_registerClassPair(eigenclass);
        object_setClass(self, eigenclass);
    }
    
    objc_setAssociatedObject(self, EIGENCLASS_ASSOC_KEY, eigenclass, OBJC_ASSOCIATION_ASSIGN);
    
    return eigenclass;
}

@end
