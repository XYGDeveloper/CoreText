//
//  ZJTextLayer.m
//  ZJAttributedText
//
//  Created by Syik on 2018/6/23.
//

#import "ZJTextLayer.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"

@implementation ZJTextLayer

#pragma mark - lifeCycle

- (void)layoutSublayers {
    [super layoutSublayers];
    
    for (ZJTextElement *element in _elements) {
        if (element.attributes.onLayout) {
            element.attributes.onLayout(element);
        }
    }
}

@end
