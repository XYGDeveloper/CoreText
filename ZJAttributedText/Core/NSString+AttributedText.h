//
//  NSString+AttributedText.h
//  ZJAttributedText
//
//  Created by Syik on 2018/6/23.
//

#import <Foundation/Foundation.h>

#define TextBuild @""

@class ZJTextElement;

typedef void(^ZJTextReturnBlock)(ZJTextElement *element);
typedef NSString *(^ZJTextDotFontBlock)(UIFont *font);
typedef NSString *(^ZJTextDotColorBlock)(UIColor *color);
typedef NSString *(^ZJTextDotValueBlock)(NSValue *value);
typedef NSString *(^ZJTextDotNumberBlock)(NSNumber *number);
typedef NSString *(^ZJTextDotShadowBlock)(NSShadow *shadow);
typedef NSString *(^ZJTextDotLayerBlock)(CALayer *layer);
typedef NSString *(^ZJTextDotBlockBlock)(ZJTextReturnBlock block);
typedef NSString *(^ZJTextDotAppendBlock)(id content);
typedef NSString *(^ZJTextDotEntireBlock)(void);
typedef void(^ZJTextLayerDrawCompletionBlock)(CALayer *drawLayer);
typedef NSString *(^ZJTextDotLayerDrawBlock)(ZJTextLayerDrawCompletionBlock completion);
typedef void(^ZJTextViewDrawCompletionBlock)(UIView *drawView);
typedef NSString *(^ZJTextDotViewDrawBlock)(ZJTextViewDrawCompletionBlock completion);

@interface NSString (AttributedText)

#pragma mark - core method

/**
 拼接字符串, 可以是 文本(NSString)/图片(UIImage)/网络图片(NSURL)/自定义视图(CALayer/UIView)
 */
@property (nonatomic, copy) ZJTextDotAppendBlock append;

/**
 设置整段富文本
 */
@property (nonatomic, copy) ZJTextDotEntireBlock entire;

/**
 绘制layer, 无法响应手势, 当绘制内容中存在UIView时建议不使用此API
 */
@property (nonatomic, copy) ZJTextDotLayerDrawBlock drawLayer;

/**
 绘制View, 可响应手势, 一般建议使用此API生成视图
 */
@property (nonatomic, copy) ZJTextDotViewDrawBlock drawView;

#pragma mark - common attributes

/**
 垂直方向偏移
 */
@property (nonatomic, copy) ZJTextDotNumberBlock verticalOffset;

/**
 水平方向偏移
 */
@property (nonatomic, copy) ZJTextDotNumberBlock horizontalOffset;

/**
 点击Block
 */
@property (nonatomic, copy) ZJTextDotBlockBlock onClicked;

/**
 显示后会调用, 整段富文本设置其中一个元素即可
 */
@property (nonatomic, copy) ZJTextDotBlockBlock onLayout;

/**
 是否缓存frame, 会计算文本在整段富文本中的frame
 */
@property (nonatomic, copy) ZJTextDotNumberBlock cacheFrame;

#pragma mark - string attributes

/**
 字体: 文字字体/图片居中对齐字体
 */
@property (nonatomic, copy) ZJTextDotFontBlock font;

/**
 颜色
 */
@property (nonatomic, copy) ZJTextDotColorBlock color;

/**
 字间距
 */
@property (nonatomic, copy) ZJTextDotNumberBlock letterSpace;

/**
 描边宽度, 整数为镂空, Color不生效; 负数Color生效
 */
@property (nonatomic, copy) ZJTextDotNumberBlock strokeWidth;

/**
 描边颜色
 */
@property (nonatomic, copy) ZJTextDotColorBlock strokeColor;

/**
 文字绘制随文字书写方向, 默认 否(0), 是(非0)
 */
@property (nonatomic, copy) ZJTextDotNumberBlock verticalForm;

/**
 下划线类型, 整形, 0为none, 1为细线 2为加粗 9为双条 参考 CTUnderlineStyle(仅枚举了三种, 其他值也有不同效果)
 */
@property (nonatomic, copy) ZJTextDotNumberBlock underline;

#pragma mark - attach attributes

/**
 图片尺寸, 默认为图片本身尺寸
 */
@property (nonatomic, copy) ZJTextDotValueBlock attachSize;

/**
 图片对齐模式 参看 ZJTextattachAlign
 */
@property (nonatomic, copy) ZJTextDotNumberBlock attachAlign;

#pragma mark - paragraph attributes

/**
 * 整段文本属性 *: 绘制的约束尺寸, 默认Max
 */
@property (nonatomic, copy) ZJTextDotValueBlock maxSize;

/**
 * 整段文本属性 *: 阴影属性, 在 entire() 后生效, 或仅有一段文字生效!
 */
@property (nonatomic, copy) ZJTextDotShadowBlock shadow;

/**
 * 整段文本属性 *: 期望高度, 设置本属性后绘制结果会以此高度居中, 在 entire() 后生效, 或仅有一段文字生效!
 */
@property (nonatomic, copy) ZJTextDotNumberBlock preferHeight;

/**
 * 整段文本属性 *: 垂直方向间距, 若设置了 preferHeight 此属性不生效, 在 entire() 后生效, 或仅有一段文字生效!
 */
@property (nonatomic, copy) ZJTextDotNumberBlock verticalMargin;

/**
 * 整段文本属性 *: 水平方向间距, 在 entire() 后生效, 或仅有一段文字生效!
 */
@property (nonatomic, copy) ZJTextDotNumberBlock horizontalMargin;

/**
 * 整段文本属性 *: 背景颜色, 在 entire() 后生效, 或仅有一段文字生效!
 */
@property (nonatomic, copy) ZJTextDotColorBlock backgroundColor;

/**
 * 整段文本属性 *: 背景图层, 主要用作渐变色/图片背景, 在 entire() 后生效, 或仅有一段文字生效!
 */
@property (nonatomic, copy) ZJTextDotLayerBlock backgroundLayer;

/**
 * 整段文本属性 *: 设置圆角
 */
@property (nonatomic, copy) ZJTextDotNumberBlock cornerRadius;

/**
 最小行间距
 */
@property (nonatomic, copy) ZJTextDotNumberBlock minLineSpace;

/**
 最大行间距
 */
@property (nonatomic, copy) ZJTextDotNumberBlock maxLineSpace;

/**
 最小行高
 */
@property (nonatomic, copy) ZJTextDotNumberBlock minLineHeight;

/**
 最小行高
 */
@property (nonatomic, copy) ZJTextDotNumberBlock maxLineHeight;

/**
 对齐, 整形, 0为默认靠左 1为靠右 2为居中, 参考 CTTextAlignment
 */
@property (nonatomic, copy) ZJTextDotNumberBlock align;

/**
 对齐, 整形, 参考 CTLineBreakMode
 */
@property (nonatomic, copy) ZJTextDotNumberBlock lineBreakMode;

@end
