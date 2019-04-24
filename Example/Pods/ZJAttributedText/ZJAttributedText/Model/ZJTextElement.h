//
//  ZJElement.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/4.
//

#import <Foundation/Foundation.h>

@class ZJTextAttributes;

@interface ZJTextElement : NSObject

#pragma mark - common

/**
 内容: 文本(NSString)、图片(UIImage)、图片链接(NSURL)(必须指定attachSize属性)、视图(CALayer/UIView)
 */
@property (nonatomic, strong) id content;

/**
 属性
 */
@property (nonatomic, strong) ZJTextAttributes *attributes;

/**
 在富文本中的范围
 */
@property (nonatomic, strong, readonly) NSValue *rangeValue;

/**
 在富文本中的绘制frame的数组
 */
@property (nonatomic, strong, readonly) NSArray<NSValue *> *frameValueArray;

@end
