//
//  ZJTextAttributes.h
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/11.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZJTextattachAlign) {
    ZJTextAttachAlignBottomToBaseLine = 0,         //图片底部对齐基准线
    ZJTextAttachAlignCenterToFont                  //图片居中向特定字体对齐, 需要设置 font 属性, 若没有为系统12号字体
};

@class ZJTextElement;

typedef void(^ZJTextReturnBlock)(ZJTextElement *element);

@interface ZJTextAttributes : NSObject

#pragma mark - common attributes

/**
 垂直方向偏移
 */
@property (nonatomic, strong) NSNumber *verticalOffset;

/**
 水平方向偏移
 */
@property (nonatomic, strong) NSNumber *horizontalOffset;

/**
 点击Block
 */
@property (nonatomic, copy) ZJTextReturnBlock onClicked;

/**
 显示后会调用, 整段富文本设置其中一个元素即可
 */
@property (nonatomic, copy) ZJTextReturnBlock onLayout;

/**
 是否缓存frame, 会计算文本在整段富文本中的frame
 */
@property (nonatomic, strong) NSNumber *cacheFrame;

#pragma mark - string attributes

/**
 字体: 文字字体/图片居中对齐字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 颜色
 */
@property (nonatomic, strong) UIColor *color;

/**
 字间距
 */
@property (nonatomic, strong) NSNumber *letterSpace;

/**
 描边宽度, 整数为镂空, Color不生效; 负数Color生效
 */
@property (nonatomic, strong) NSNumber *strokeWidth;

/**
 描边颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 文字绘制随文字书写方向, 默认 否(0), 是(非0)
 */
@property (nonatomic, strong) NSNumber *verticalForm;

/**
 下划线类型, 整形, 0为none, 1为细线 2为加粗 9为双条 参考 CTUnderlineStyle(仅枚举了三种, 其他值也有不同效果)
 */
@property (nonatomic, strong) NSNumber *underline;

#pragma mark - attach attributes

/**
 图片尺寸, 默认为图片本身尺寸
 */
@property (nonatomic, strong) NSValue *attachSize;

/**
 图片对齐模式 参看 ZJTextattachAlign
 */
@property (nonatomic, strong) NSNumber *attachAlign;

#pragma mark - paragraph attributes

/**
 * 整段文本属性 *: 绘制的约束尺寸, 默认Max
 */
@property (nonatomic, strong) NSValue *maxSize;

/**
 * 整段文本属性 *: 阴影属性, 单独设置在某一段字符串无效
 */
@property (nonatomic, strong) NSShadow *shadow;

/**
 * 整段文本属性 *: 期望高度, 设置本属性后绘制结果会以此高度居中
 */
@property (nonatomic, strong) NSNumber *preferHeight;

/**
 * 整段文本属性 *: 垂直方向间距, 若设置了 preferHeight 此属性不生效
 */
@property (nonatomic, strong) NSNumber *verticalMargin;

/**
 * 整段文本属性 *: 水平方向间距
 */
@property (nonatomic, strong) NSNumber *horizontalMargin;

/**
 * 整段文本属性 *: 背景颜色
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 * 整段文本属性 *: 背景图层, 主要用作渐变色/图片背景
 */
@property (nonatomic, strong) CALayer *backgroundLayer;

/**
 * 整段文本属性 *: 设置圆角
 */
@property (nonatomic, strong) NSNumber *cornerRadius;

/**
 最小行间距
 */
@property (nonatomic, strong) NSNumber *minLineSpace;

/**
 最大行间距
 */
@property (nonatomic, strong) NSNumber *maxLineSpace;

/**
 最小行高
 */
@property (nonatomic, strong) NSNumber *minLineHeight;

/**
 最小行高
 */
@property (nonatomic, strong) NSNumber *maxLineHeight;

/**
 对齐, 整形, 0为默认靠左 1为靠右 2为居中, 参考 CTTextAlignment
 */
@property (nonatomic, strong) NSNumber *align;

/**
 对齐, 整形, 参考 CTLineBreakMode
 */
@property (nonatomic, strong) NSNumber *lineBreakMode;

@end
