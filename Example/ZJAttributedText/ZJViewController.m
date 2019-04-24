//
//  ZJViewController.m
//  ZJAttributedText
//
//  Created by Jsoul1227@hotmail.com on 06/04/2018.
//  Copyright (c) 2018 Jsoul1227@hotmail.com. All rights reserved.
//

#import "ZJViewController.h"
#import "ZJAttributedText.h"
#import "ZJTestLabel.h"

#define RGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ZJViewController ()

@end

@implementation ZJViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //链式语法
    [self dotFeature];
    
    //链式语法组合
    //[self dotCombineFeature];
    
    //性能测试
    //[self performanceTest];
}

- (void)dotFeature {
    
    /************常量生成************/
    
    //回调
    ZJTextReturnBlock titleOnLayout = ^(ZJTextElement *element) {
        NSLog(@"已显示: %@", element.content);
    };
    ZJTextReturnBlock titleOnClicked = ^(ZJTextElement *element) {
        NSLog(@"标题被点击: %@", element.content);
    };
    ZJTextReturnBlock textOnClicked = ^(ZJTextElement *element) {
        NSLog(@"其他被点击: %@", element.content);
    };
    ZJTextReturnBlock bookOnClicked = ^(ZJTextElement *element) {
        NSLog(@"书被点击: %@", element.content);
    };
    
    //字体与颜色
    UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
    UIColor *titleColor = [UIColor whiteColor];
    UIColor *firstParaColor = RGBHex(0xf5eee6);
    UIFont *separateLineFont = [UIFont boldSystemFontOfSize:15];
    UIColor *separateLineColor = RGBHex(0x216583);
    UIFont *lastParaFont = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    UIColor *lastParaColor = RGBHex(0x0d7e83);
    UIFont *bookNameFont = [UIFont boldSystemFontOfSize:22];
    UIColor *bookNameColor = RGBHex(0xf76262);
    UIColor *quoteColor = RGBHex(0xfab2ac);
    
    //Layer
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = RGBHex(0xf6f6f6).CGColor;
    lineLayer.frame = CGRectMake(0, 0, 15, 3);
    lineLayer.cornerRadius = 1.5;
    
    //View
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton setTitle:@"购买本书" forState:UIControlStateNormal];
    [buyButton setTitleColor:RGBHex(0xffe2e2) forState:UIControlStateNormal];
    [buyButton setFrame:CGRectMake(0, 0, 120, 30)];
    [buyButton setBackgroundColor:RGBHex(0xbad7df)];
    buyButton.layer.cornerRadius = 15;
    [buyButton addTarget:self action:@selector(buyBook) forControlEvents:UIControlEventTouchUpInside];
    
    //绘制大小限制
    NSValue *maxSize = [NSValue valueWithCGSize:CGSizeMake(325, MAXFLOAT)];
    NSValue *attachSize = [NSValue valueWithCGSize:CGSizeMake(35, 35)];
    NSValue *lineLayerSize = [NSValue valueWithCGSize:lineLayer.bounds.size];
    NSValue *buyButtonSize = [NSValue valueWithCGSize:buyButton.bounds.size];
    
    //内容
    NSString *title = @"随笔\n\n";
    NSString *firstPara = @"       张嘉佳又出了新书，把书名取成《云边有个小卖部》。他说“时隔五年了，写给离开我们的人，写给陪伴我们的人，写给每个人心中的山和海。\n       《云边有个小卖部》离他上次的一本书，已经过去五年了。\n";
    NSURL *webImage = [NSURL URLWithString:@"http://osnabh9h1.bkt.clouddn.com/18-6-27/92507897.jpg"];
    NSString *separateLine = @"-----分界-----";
    NSString *localImagePath = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
    UIImage *locolImage = [UIImage imageWithContentsOfFile:localImagePath];
    NSString *lastPara = @"\n我从来没想过时间会过的这么快，\n快的这五年我好像还没有认真生活，\n时间就没有了。\n没有认识新朋友，\n没有去过新景点，\n也没有吃过更新奇的食物，\n五年里没有任何值得留念的回忆。\n这本";
    NSString *bookName = @"《云边有个小卖部》\n\n";
    NSString *quote = @" 他说，他陆陆续续写了两年，中间写到情绪崩溃，不得已停笔半年。\n";
    
    //阴影
    NSShadow *shadow = [NSShadow new];
    shadow.shadowBlurRadius = 4;
    shadow.shadowColor = RGBHex(0x99ddcc);
    
    //期望输出高度, 屏幕高度减去状态栏(20), 与左右间隔(27.5 * 2)一致
    CGFloat preferHeight = [UIScreen mainScreen].bounds.size.height - 20 - 55;
    
    //背景
    UIColor *backgroundColor1 = RGBHex(0Xbad7df);
    UIColor *backgroundColor2 = RGBHex(0Xffe2e2);
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)backgroundColor1.CGColor, (__bridge id)backgroundColor2.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    
    /************核心使用************/
    
    //一次性生成文章
    
    TextBuild
    .append(title).font(titleFont).color(titleColor).onClicked(titleOnClicked).onLayout(titleOnLayout)
    .append(firstPara).color(firstParaColor).align(@0)
    .append(webImage).font(separateLineFont).minLineHeight(@100)
    .append(separateLine).font(separateLineFont).strokeColor(separateLineColor).strokeWidth(@1).horizontalOffset(@30)
    .append(locolImage).horizontalOffset(@30)
    .append(lastPara).font(lastParaFont).align(@1).maxLineHeight(@20).color(lastParaColor)
    .append(bookName).font(bookNameFont).color(bookNameColor).onClicked(bookOnClicked).align(@1)
    .append(lineLayer).attachSize(lineLayerSize)
    .append(quote).color(quoteColor).letterSpace(@0).minLineSpace(@8).align(@0)
    .append(buyButton).attachSize(buyButtonSize).attachAlign(@0)
    //设置全局默认属性, 优先级低于指定属性
    .entire().maxSize(maxSize).align(@2).letterSpace(@3).minLineHeight(@20).attachAlign(@1).onClicked(textOnClicked).attachSize(attachSize).shadow(shadow).cornerRadius(@50).backgroundLayer(gradientLayer).horizontalMargin(@10).preferHeight(@(preferHeight))
    //绘制View
    .drawView(^(UIView *drawView) {
        drawView.frame = CGRectMake(27.5, 47.5, drawView.frame.size.width, drawView.frame.size.height);
        [self.view addSubview:drawView];
    });
}

- (void)dotCombineFeature {
    
    /************常量生成************/
    
    //回调
    ZJTextReturnBlock titleOnLayout = ^(ZJTextElement *element) {
        NSLog(@"已显示: %@", element.content);
    };
    ZJTextReturnBlock titleOnClicked = ^(ZJTextElement *element) {
        NSLog(@"标题被点击: %@", element.content);
    };
    ZJTextReturnBlock textOnClicked = ^(ZJTextElement *element) {
        NSLog(@"其他被点击: %@", element.content);
    };
    ZJTextReturnBlock bookOnClicked = ^(ZJTextElement *element) {
        NSLog(@"书被点击: %@", element.content);
    };
    
    //字体与颜色
    UIFont *titleFont = [UIFont boldSystemFontOfSize:20];
    UIColor *titleColor = [UIColor whiteColor];
    UIColor *firstParaColor = RGBHex(0xf5eee6);
    UIFont *separateLineFont = [UIFont boldSystemFontOfSize:15];
    UIColor *separateLineColor = RGBHex(0x216583);
    UIFont *lastParaFont = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    UIColor *lastParaColor = RGBHex(0x0d7e83);
    UIFont *bookNameFont = [UIFont boldSystemFontOfSize:22];
    UIColor *bookNameColor = RGBHex(0xf76262);
    UIColor *quoteColor = RGBHex(0xfab2ac);
    
    //Layer
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = RGBHex(0xf6f6f6).CGColor;
    lineLayer.frame = CGRectMake(0, 0, 15, 3);
    lineLayer.cornerRadius = 1.5;
    
    //View
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyButton setTitle:@"购买本书" forState:UIControlStateNormal];
    [buyButton setTitleColor:RGBHex(0xffe2e2) forState:UIControlStateNormal];
    [buyButton setFrame:CGRectMake(0, 0, 120, 30)];
    [buyButton setBackgroundColor:RGBHex(0xbad7df)];
    buyButton.layer.cornerRadius = 15;
    [buyButton addTarget:self action:@selector(buyBook) forControlEvents:UIControlEventTouchUpInside];
    
    //绘制大小限制
    NSValue *maxSize = [NSValue valueWithCGSize:CGSizeMake(325, MAXFLOAT)];
    NSValue *attachSize = [NSValue valueWithCGSize:CGSizeMake(35, 35)];
    NSValue *lineLayerSize = [NSValue valueWithCGSize:lineLayer.bounds.size];
    NSValue *buyButtonSize = [NSValue valueWithCGSize:buyButton.bounds.size];
    
    //内容
    NSString *title = @"随笔\n\n";
    NSString *firstPara = @"       张嘉佳又出了新书，把书名取成《云边有个小卖部》。他说“时隔五年了，写给离开我们的人，写给陪伴我们的人，写给每个人心中的山和海。\n       《云边有个小卖部》离他上次的一本书，已经过去五年了。\n";
    NSURL *webImage = [NSURL URLWithString:@"http://osnabh9h1.bkt.clouddn.com/18-6-27/92507897.jpg"];
    NSString *separateLine = @"-----分界-----";
    NSString *localImagePath = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
    UIImage *locolImage = [UIImage imageWithContentsOfFile:localImagePath];
    NSString *lastPara = @"\n我从来没想过时间会过的这么快，\n快的这五年我好像还没有认真生活，\n时间就没有了。\n没有认识新朋友，\n没有去过新景点，\n也没有吃过更新奇的食物，\n五年里没有任何值得留念的回忆。\n这本";
    NSString *bookName = @"《云边有个小卖部》\n\n";
    NSString *quote = @" 他说，他陆陆续续写了两年，中间写到情绪崩溃，不得已停笔半年。\n";
    
    //阴影
    NSShadow *shadow = [NSShadow new];
    shadow.shadowBlurRadius = 4;
    shadow.shadowColor = RGBHex(0x99ddcc);
    
    //期望输出高度, 屏幕高度减去状态栏(20), 与左右间隔(27.5 * 2)一致
    CGFloat preferHeight = [UIScreen mainScreen].bounds.size.height - 20 - 55;
    
    //背景
    UIColor *backgroundColor1 = RGBHex(0Xbad7df);
    UIColor *backgroundColor2 = RGBHex(0Xffe2e2);
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)backgroundColor1.CGColor, (__bridge id)backgroundColor2.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    
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
    NSString *lastParaString = TextBuild.append(lastPara).font(lastParaFont).align(@1).maxLineHeight(@20).color(lastParaColor);
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
    titleString
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
        drawLayer.frame = CGRectMake(27.5, 47.5, drawLayer.frame.size.width, drawLayer.frame.size.height);
        [self.view.layer addSublayer:drawLayer];
    });
}

- (void)performanceTest {
    
    /*
     机型: iPhone 6
     
     测试结果:
     
     常规过程: 创建->显示(绘制)
     常规分析:
     1. 主线程代码在 28ms 左右. (主线程代码开始 至 结束耗时)
     2. UILabel 显示(绘制)耗时在 42ms 左右. (addSubview 至 drawRect 耗时)
     3. 综合耗时 70ms 左右, 全部在主线程
     
     异步绘制过程: 创建->异步绘制->显示
     异步绘制分析:
     1. 主线程(创建)代码在 28ms 左右. (主线程代码开始 至 结束耗时)
     2. 创建(主线程) + 异步绘制耗时 84ms 左右. (主线程代码开始 至 绘制出图片回调)
     3. 由 1、2 得出子线程绘制耗时 56ms 左右, 另外经过多次试验(大段文字绘制)得出绘制复杂的段落也耗时增长较少
     4. 显示耗时 0.75 ms 左右. (addSubview 至 drawRect 耗时)
     5. 综合耗时 85ms 左右, 其中主线程 29ms, 子线程 56ms
     
     结论:
     1. 相较于常规方式降低了主线程压力 70ms -> 29ms
     2. 越复杂的文本收益越高, (多控件合一, 异步绘制, 耗时增长少).
     */
    

//    //1. NSAttributedString + label
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"      陈一发儿了解一下? 冯提莫了解一下? 阿冷了解一下?"];
//    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, attributedString.length)];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:[[UIColor blueColor] colorWithAlphaComponent:0.5] range:NSMakeRange(0, attributedString.length)];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineSpacing = 10;
//    style.lineBreakMode = NSLineBreakByCharWrapping;
//    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
//
//    NSString *image1Path = [[NSBundle mainBundle] pathForResource:@"dy008" ofType:@"png"];
//    UIImage *image1 = [UIImage imageWithContentsOfFile:image1Path];
//    NSTextAttachment *attachment1 = [[NSTextAttachment alloc] init];
//    attachment1.image = image1;
//    NSAttributedString *attachString1 = [NSAttributedString attributedStringWithAttachment:attachment1];
//
//    NSString *image2Path = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
//    UIImage *image2 = [UIImage imageWithContentsOfFile:image2Path];
//    NSTextAttachment *attachment2 = [[NSTextAttachment alloc] init];
//    attachment2.image = image2;
//    NSAttributedString *attachString2 = [NSAttributedString attributedStringWithAttachment:attachment2];
//
//    [attributedString appendAttributedString:attachString1];
//    [attributedString appendAttributedString:attachString2];
//
//    ZJTestLabel *label = [[ZJTestLabel alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 200)];
//    label.numberOfLines = 0;
//    label.attributedText = attributedString;
//
//    CGFloat startTime = [[NSDate date] timeIntervalSince1970] * 1000;
//    OnLayoutBlock onLayout = ^{
//        CGFloat endTime = [[NSDate date] timeIntervalSince1970] * 1000;
//        NSLog(@"绘制耗时: %f ms", endTime - startTime);
//        //iphone 6上 绘制耗时: 42.32 ms
//    };
//    label.onLayout = onLayout;
//    [self.view addSubview:label];
    
    
    //2. ZJAttributedText
    __block CGFloat startTime = 0;

    ZJTextReturnBlock onLayout = ^(ZJTextElement *element) {
        CGFloat endTime = [[NSDate date] timeIntervalSince1970] * 1000;
        NSLog(@"绘制耗时: %f ms", endTime - startTime);
        //iphone 6上 绘制耗时: 0.75 ms, (将onLayout放在视图的drawRect中执行的结果)
    };

    NSString *image1Path = [[NSBundle mainBundle] pathForResource:@"dy008" ofType:@"png"];
    UIImage *image1 = [UIImage imageWithContentsOfFile:image1Path];
    NSString *image2Path = [[NSBundle mainBundle] pathForResource:@"dy122" ofType:@"png"];
    UIImage *image2 = [UIImage imageWithContentsOfFile:image2Path];

    NSString *content =  @"      陈一发儿了解一下? 冯提莫了解一下? 阿冷了解一下?";

    content.font([UIFont systemFontOfSize:15]).color([[UIColor blueColor] colorWithAlphaComponent:0.5]).minLineSpace(@10).lineBreakMode(@1).onLayout(onLayout)
    .append(image1)
    .append(image2)
    .entire().maxSize([NSValue valueWithCGSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 200)])
    .drawView(^(UIView *drawView) {

        startTime = [[NSDate date] timeIntervalSince1970] * 1000;

        CGRect frame = drawView.frame;
        frame.origin.y = 50;
        drawView.frame = frame;
        [self.view addSubview:drawView];
    });
}

- (void)buyBook {
    NSLog(@"%s", __func__);

    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.view.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    //链式语法
    [self dotFeature];
}

@end
