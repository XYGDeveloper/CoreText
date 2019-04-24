# ZJAttributedText

##  告别 NSAttributedString  高性能轻量级富文本框架

[![Version](https://img.shields.io/cocoapods/v/ZJAttributedText.svg?style=flat)](https://cocoapods.org/pods/ZJAttributedText)
[![License](https://img.shields.io/cocoapods/l/ZJAttributedText.svg?style=flat)](https://cocoapods.org/pods/ZJAttributedText)
[![Platform](https://img.shields.io/cocoapods/p/ZJAttributedText.svg?style=flat)](https://cocoapods.org/pods/ZJAttributedText)

## 示例说明

![](http://osnabh9h1.bkt.clouddn.com/18-7-14/84938943.jpg)

如图所示一篇图文混排, 涉及到字体, 颜色, 字间距, 行间距, 图片对齐, 文字对齐, 描边, 阴影等等属性, 还有网络图片与本地图片的混排, 手势响应, View 与 Layer 的混排, 输出视图需要渐变色背景, 指定高度, 内间距, 圆角等等要求, 算是一个相当复杂的图文混排场景了, 不论使用 TextKit / CoreText 都需要相当的代码量.

如果本框架可以下面这样实现:

```ObjectiveC
//...省略常量声明

TextBuild
.append(title).font(titleFont).color(titleColor).onClicked(titleOnClicked).onLayout(titleOnLayout)
.append(firstPara).color(firstParaColor).align(@0)
.append(webImage).font(separateLineFont).minLineHeight(@100)
.append(separateLine).font(separateLineFont).strokeColor(separateLineColor).strokeWidth(@1).horizontalOffset(@30)
.append(locolImage).horizontalOffset(@30)
.append(lastPara).font(lastParaFont).align(@1).maxLineHeight(@20)
.append(bookName).font(bookNameFont).color(bookNameColor).onClicked(bookOnClicked).align(@1)
.append(lineLayer).attachSize(lineLayerSize)
.append(quote).color(quoteColor).letterSpace(@0).minLineSpace(@8).align(@0)
.append(buyButton).attachSize(buyButtonSize).attachAlign(@0)
//设置全局默认属性, 优先级低于指定属性
.entire().maxSize(maxSize).align(@2).letterSpace(@3).minLineHeight(@20).attachAlign(@1).onClicked(textOnClicked).attachSize(attachSize).shadow(shadow).cornerRadius(@50).backgroundLayer(gradientLayer).horizontalMargin(@10).preferHeight(@(preferHeight))
//绘制View
.drawView(^(UIView *drawView) {
[self.view addSubview:drawView];
});
```

而在实际需求中也可以根据不同条件对 NSString 进行组合, 最后绘制:

```ObjectiveC
//...省略常量声明

//拼接文章
//标题
NSString *titleString = TextBuild.append(title).font(titleFont).color(titleColor).onClicked(titleOnClicked).onLayout(titleOnLayout);
//首段
NSString *firstParaString = TextBuild.append(firstPara).color(firstParaColor).align(@0);
//图片需要用一个空字符串起头
NSString *webImageString = TextBuild.append(webImage).font(separateLineFont).minLineHeight(@100);
//分割线
NSString *separateLineString = TextBuild.append(separateLine).font(separateLineFont).strokeColor(separateLineColor).strokeWidth(@1).horizontalOffset(@30);
//本地图片
NSString *locolImageString = TextBuild.append(locolImage).horizontalOffset(@30);
//最后一段
NSString *lastParaString = TextBuild.append(lastPara).font(lastParaFont).align(@1).maxLineHeight(@20);
//书名
NSString *bookNameString = TextBuild.append(bookName).font(bookNameFont).color(bookNameColor).onClicked(bookOnClicked).align(@1).maxLineHeight(@20);
//引用线Layer
NSString *lineLayerString = TextBuild.append(lineLayer).attachSize(lineLayerSize);
//引用
NSString *quoteString = TextBuild.append(quote).color(quoteColor).letterSpace(@0).minLineSpace(@8).align(@0);
//按钮
NSString *buttonString = TextBuild.append(buyButton).attachSize(buyButtonSize).attachAlign(@0);

//设置全局默认属性, 优先级低于指定属性
NSString *defaultAttributes = TextBuild.entire()
.maxSize(maxSize).align(@2).letterSpace(@3).minLineHeight(@20).attachAlign(@1).onClicked(textOnClicked).attachSize(attachSize).shadow(shadow).cornerRadius(@50).backgroundLayer(gradientLayer).horizontalMargin(@10).preferHeight(@(preferHeight));

//拼接
TextBuild
.append(titleString)
.append(firstParaString)
.append(webImageString)
.append(separateLineString)
.append(locolImageString)
.append(lastParaString)
.append(bookNameString)
.append(lineLayerString)
.append(quoteString)
.append(buttonString)
//设置默认属性
.append(defaultAttributes)
//绘制Layer
.drawLayer(^(CALayer *drawLayer) {
[self.view.layer addSublayer:drawLayer];
});
```

## 核心方法与属性

对 NSString 的扩展, 操作字符串生成绘制对应视图

#### 核心方法

* append(id content)

拼接
content 可以是文本(NSString)、图片(UIImage)、图片链接(NSURL)(必须指定attachSize属性)、视图(CALayer/UIView)

* entire()

设置整段富文本
优先级低于指定属性, 较为重要的属性 maxSize 设置绘制约束, 部分段落属性只在整段中设置生效

* drawLayer(^(CALayer *drawLayer)completion)

绘制layer, 无法响应手势, 当有UIView混排建议使用 drawView

* drawView(^(UIView *drawView)completion)

绘制View, 可响应手势, 建议使用此API

#### 属性

##### 通用属性

* verticalOffset 垂直偏移
* horizontalOffset 水平方向偏移
* onClicked 点击回调
* onLayout 展示回调
* cacheFrame 缓存该段文本绘制位置
* minLineSpace 最小行间距
* maxLineSpace 最大行间距
* minLineHeight 最小行高
* maxLineHeight 最小行高
* align 对齐, 整形, 0为默认靠左 1为靠右 2为居中, 参考 CTTextAlignment
* lineBreakMode 对齐, 整形, 参考 NSLineBreakMode

##### 字符串属性

* font 字体: 文字字体/图片居中对齐字体
* color 颜色
* letterSpace 字间距
* strokeWidth 描边宽度, 整数为镂空, Color不生效; 负数Color生效
* strokeColor 描边颜色
* verticalForm 文字绘制随文字书写方向, 默认 否(0), 是(非0)
* underline 下划线类型, 整形, 0为none, 1为细线 2为加粗 9为双条 参考 CTUnderlineStyle(仅枚举了三种, 其他值也有不同效果)

##### 图片属性

* attachSize 图片尺寸, 默认为图片本身尺寸, 会根据图片缩放(2x 3x)自动调整
* attachAlign 图片对齐模式, 0为默认, 基准线对齐. 1为居中对齐至特定字体大小 参看 ZJTextattachAlign

##### 段落属性

###### 注: 下面属性多段文本拼接只在 entire() 函数后生效; 若只有一段有效文本(非空字符及其他类型), 也可以直接生效.

* maxSize 绘制的约束尺寸, 默认不限制
* shadow 文字阴影, 对全文生效
* preferHeight 期望绘制高度, 内容居中
* verticalMargin 垂直方向间距, 若设置了 preferHeight 此属性不生效
* horizontalMargin 水平方向间距
* backgroundColor 背景颜色
* backgroundLayer 背景视图, 常用图片背景/渐变色背景
* cornerRadius 圆角

## 重要事项

设计为了方便使用, 采用对 NSString 的分类完成, 假设一个使用场景:

```ObjectiveC
//一个变量字符串
NSString *string = nil;
string.color([UIColor whiteColor]).append(@"test").....
```
声明了一个变量字符串, 但该字符串为 nil (或实际类型不为字符串), 编译器无法检查实际类型, 所以也可以使用本框架 API, 但实际代码走到这里会出现 Crash.

所以强烈建议字符串操作起始以 `TextBuild`(实际就是`@""`) 起头, 或外部判断是否存在, 如下:

```ObjectiveC
//一个变量字符串
NSString *string = nil;
TextBuild.append(string).color([UIColor whiteColor]).append(@"test").....
```
除此以外, 其他 API 不论怎么传异常值均能保证正常, 仅仅会跳过异常字符串或属性.

## 性能

总体采用 CoreText + 异步绘制图片完成, 理论上性能会比较高, 经过测试如下数据供参考:

内容: 一段文本加上两张图片

机型: iPhone 6

测试结果:

常规(使用NSAttributedString + UILabel)过程: 创建->显示(绘制)
常规分析:
1. 主线程代码在 28ms 左右. (主线程代码开始 至 结束耗时)
2. UILabel 显示(绘制)耗时在 42ms 左右. (addSubview 至 drawRect 耗时)
3. 综合耗时 70ms 左右, 全部在主线程

异步绘制(本框架)过程: 创建->异步绘制->显示
异步绘制分析:
1. 主线程(创建)代码在 28ms 左右. (主线程代码开始 至 结束耗时)
2. 创建(主线程) + 异步绘制耗时 84ms 左右. (主线程代码开始 至 绘制出图片回调)
3. 由 1、2 得出子线程绘制耗时 56ms 左右, 另外经过多次试验(大段文字绘制)得出绘制复杂的段落也耗时增长较少
4. 显示耗时 0.75 ms 左右. (addSubview 至 drawRect 耗时)
5. 综合耗时 85ms 左右, 其中主线程 29ms, 子线程 56ms

结论:
1. 相较于常规方式降低了主线程压力 70ms -> 29ms
2. 越复杂的文本收益越高(多控件合一, 异步绘制), 上图中大段富文本绘制时间也只多了 15ms, 耗时增长少
3. 总体耗时增加了15ms, 都在子线程, 毕竟处理的逻辑比系统的多
4. 与 YYText 总体性能相仿

## 依赖

网络图片下载缓存策略依赖 'SDWebImage'.

## 安装

[CocoaPods](https://cocoapods.org):

```ruby
pod 'ZJAttributedText'
```

## 作者

Jsoul1227@hotmail.com

## 许可证

ZJAttributedText is available under the MIT license. See the LICENSE file for more info.
