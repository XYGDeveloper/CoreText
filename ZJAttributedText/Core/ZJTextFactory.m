//
//  ZJTextFactory.m
//  ZJAttributedText
//
//  Created by zhangjun on 2018/6/6.
//

#import "ZJTextFactory.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import "ZJTextView.h"
#import "ZJTextLayer.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>

typedef NS_ENUM(NSUInteger, ZJTextDrawType) {
    ZJTextDrawTypeLayer = 0,
    ZJTextDrawTypeView
};

static NSString *const kZJTextElementAttributeName = @"kZJTextElementAttributeName";
static NSString *const kZJTextDrawFrameAssociateKey = @"kZJTextDrawFrameAssociateKey";
static NSString *const kZJTextDrawImageAssociateKey = @"kZJTextDrawImageAssociateKey";
static NSString *const kZJTextImageAscentAssociateKey = @"kZJTextImageAscentAssociateKey";
static NSString *const kZJTextImageDescentAssociateKey = @"kZJTextImageDescentAssociateKey";
static NSString *const kZJTextImageWidthAssociateKey = @"kZJTextImageWidthAssociateKey";

@implementation ZJTextFactory

#pragma mark - public

+ (void)drawTextViewWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(void(^)(UIView *drawView))completion {
    
    [self drawTextType:ZJTextDrawTypeView WithElements:elements defaultAttributes:defaultAttributes completion:completion];
}

+ (void)drawTextLayerWithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(void(^)(CALayer *drawLayer))completion {
    
    [self drawTextType:ZJTextDrawTypeLayer WithElements:elements defaultAttributes:defaultAttributes completion:completion];
}

#pragma mark - private

+ (void)drawTextType:(ZJTextDrawType)type WithElements:(NSArray<ZJTextElement *> *)elements defaultAttributes:(ZJTextAttributes *)defaultAttributes completion:(void(^)(id draw))completion {
    
    if (!elements.count) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //组装完整字符串
        CFMutableAttributedStringRef entireAttributedString = CFAttributedStringCreateMutable(CFAllocatorGetDefault(), 0);
        NSMutableArray *imageElements = [NSMutableArray array];
        NSMutableArray *imageURLElements = [NSMutableArray array];
        NSMutableArray *viewElements = [NSMutableArray array];
        ZJTextAttributes *tempDefaultAttributes = defaultAttributes;
        
        for (ZJTextElement *element in elements) {
            
            //若没有属性, 创建一个空属性占位
            if (!element.attributes) {
                element.attributes = [ZJTextAttributes new];
            }
            
            //合并全局属性至元素属性
            if (tempDefaultAttributes) {
                ZJTextAttributes *combineAttributes = [self combineWithAttributesArray:@[element.attributes, tempDefaultAttributes]];
                element.attributes = combineAttributes;
            } else if (elements.count == 1) {
                tempDefaultAttributes = element.attributes;
            }
            
            //处理元素间的padding
            if (element.attributes.horizontalOffset) {
                
                ZJTextElement *placeHolderElement = [ZJTextElement new];
                placeHolderElement.content = [UIImage new];
                placeHolderElement.attributes.attachSize = [NSValue valueWithCGSize:CGSizeMake(element.attributes.horizontalOffset.floatValue, 1)];
                
                //保存图片类的元素
                [imageElements addObject:placeHolderElement];
                
                //保存绘制的图片
                objc_setAssociatedObject(placeHolderElement, kZJTextDrawImageAssociateKey.UTF8String, placeHolderElement.content, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                //生成图片占位富文本
                [self appendAttachElement:placeHolderElement toEntireAttributedString:entireAttributedString];
            }
            
            //拼接字符串
            if ([element.content isKindOfClass:[NSString class]]) {
                
                //生成文字富文本
                [self appendStringElement:element toEntireAttributedString:entireAttributedString];
                
            } else if ([element.content isKindOfClass:[UIImage class]]) {
                
                //保存图片类的元素
                [imageElements addObject:element];
                
                //保存绘制的图片
                objc_setAssociatedObject(element, kZJTextDrawImageAssociateKey.UTF8String, element.content, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                //生成图片占位富文本
                [self appendAttachElement:element toEntireAttributedString:entireAttributedString];
                
            } else if ([element.content isKindOfClass:[NSURL class]]) {
                
                //若有缓存则转换为图片元素
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:element.content];
                UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
                if (cachedImage) {
                    
                    //保存绘制的图片
                    objc_setAssociatedObject(element, kZJTextDrawImageAssociateKey.UTF8String, cachedImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                    //保存图片类的元素
                    [imageElements addObject:element];
                } else {
                    
                    //保存图片URL类的元素
                    [imageURLElements addObject:element];
                }
                
                //生成图片占位富文本
                [self appendAttachElement:element toEntireAttributedString:entireAttributedString];
                
            } else if ([element.content isKindOfClass:[CALayer class]] || ([element.content isKindOfClass:[UIView class]] && type == ZJTextDrawTypeLayer)) {
                
                //CALayer转换为图片
                UIImage *image = [self drawImageWithContent:element.content];
                
                if (image) {
                    
                    //保存绘制的图片
                    objc_setAssociatedObject(element, kZJTextDrawImageAssociateKey.UTF8String, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                    //保存图片类的元素
                    [imageElements addObject:element];
                    
                    //生成图片占位富文本
                    [self appendAttachElement:element toEntireAttributedString:entireAttributedString];
                }
            } else if ([element.content isKindOfClass:[UIView class]] || type == ZJTextDrawTypeView) {
             
                //保存视图类元素
                [viewElements addObject:element];
                
                //生成图片占位富文本
                [self appendAttachElement:element toEntireAttributedString:entireAttributedString];
            }
        }
        
        //约束尺寸计算
        CGSize defaultParagraphSize = [tempDefaultAttributes.maxSize CGSizeValue];
        CGSize paragraphSize = CGSizeEqualToSize(defaultParagraphSize, CGSizeZero) ? CGSizeMake(MAXFLOAT, MAXFLOAT) : defaultParagraphSize;
        CGFloat verticalMargin = tempDefaultAttributes.verticalMargin.floatValue;
        CGFloat horizontalMargin = tempDefaultAttributes.horizontalMargin.floatValue;
        CGSize fixParagraphSize = CGSizeMake(paragraphSize.width - 2 * horizontalMargin, paragraphSize.height - 2 * verticalMargin);
        
        //试算文本尺寸
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(entireAttributedString);
        CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(entireAttributedString)), nil, fixParagraphSize, nil);
        
        //输出尺寸
        CGFloat outputWidth = textSize.width + horizontalMargin * 2;
        CGFloat outputHeight = 0;
        if (tempDefaultAttributes.preferHeight) {
            outputHeight = tempDefaultAttributes.preferHeight.floatValue;
        } else {
            outputHeight = textSize.height + verticalMargin * 2;
        }
        CGSize outputSize = CGSizeMake(outputWidth, outputHeight);
        CGFloat textOffsetY = (outputSize.height - textSize.height) / 2;
        
        //生成相关路径->CTFrame
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(horizontalMargin, textOffsetY, textSize.width, textSize.height));
        CFIndex length = CFAttributedStringGetLength(entireAttributedString);
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, length), path, NULL);
        
        //绘制图片
        UIImage *drawImage = [self drawBitmapWithTextFrame:frame defaultAttributes:tempDefaultAttributes imageElements:imageElements outputSize:outputSize];
        
        //主线程生成Layer
        dispatch_async(dispatch_get_main_queue(), ^{
            
            ZJTextLayer *layer = [ZJTextLayer layer];
            [self drawURLImageOnLayer:layer imageURLElements:imageURLElements];
            layer.elements = elements;
            layer.frame = CGRectMake(0, 0, outputSize.width, outputSize.height);
            layer.contents = (__bridge id)drawImage.CGImage;
            layer.contentsGravity = kCAGravityResizeAspect;

            id draw = layer;
            if (type == ZJTextDrawTypeView) {
                ZJTextView *drawView = [[ZJTextView alloc] initWithFrame:layer.bounds];
                [self addOnView:drawView viewElements:viewElements];
                drawView.elements = elements;
                drawView.drawLayer = layer;
                draw = drawView;
            }
            if (completion) {
                completion(draw);
            }
        });
        
        //释放内存
        CFRelease(entireAttributedString);
        CFRelease(frameSetter);
        CFRelease(path);
        CFRelease(frame);
    });
}

+ (ZJTextAttributes *)combineWithAttributesArray:(NSArray<ZJTextAttributes *> *)attributesArray {
    
    //根据传入属性对象数组合并出一个新的属性对象. 按数组下表为属性取值优先级
    ZJTextAttributes *combineAttributes = [ZJTextAttributes new];
    
    Class class = [ZJTextAttributes class];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(class, &count);
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
        id value = nil;
        for (ZJTextAttributes *attributes in attributesArray) {
            value = [attributes valueForKey:key];
            if (value) {
                [combineAttributes setValue:value forKey:key];
                break;
            }
        }
    }
    free(ivars);
    return combineAttributes;
}

+ (void)appendStringElement:(ZJTextElement *)element toEntireAttributedString:(CFMutableAttributedStringRef)entireAttributedString {
    
    if (!element || !element.content || ![element.content isKindOfClass:[NSString class]]) return;
    
    //创建富文本
    CFMutableAttributedStringRef mutableAttributedString = CFAttributedStringCreateMutable(CFAllocatorGetDefault(), 0);
    if (!mutableAttributedString) return;
    
    CFAttributedStringReplaceString(mutableAttributedString, CFRangeMake(0, 0), (CFStringRef)element.content);
    CFRange range = CFRangeMake(0, CFAttributedStringGetLength(mutableAttributedString));
    
    //增加基本属性
    CFDictionaryRef attributesDic = [self generateattributesDicWithElement:element];
    if (attributesDic) {
        CFAttributedStringSetAttributes(mutableAttributedString, range, attributesDic, false);
    }
    
    //记录该段文本的位置
    NSInteger location = CFAttributedStringGetLength(entireAttributedString);
    NSInteger length = CFAttributedStringGetLength(mutableAttributedString);
    [element setValue:[NSValue valueWithRange:NSMakeRange(location, length)] forKey:@"rangeValue"];
    
    //拼接
    CFAttributedStringReplaceAttributedString(entireAttributedString, CFRangeMake(location, 0), mutableAttributedString);
    CFRelease(mutableAttributedString);
    if (attributesDic) {
        CFRelease(attributesDic);
    }
}

+ (UIImage *)drawImageWithContent:(id)content {
    
    //开启图片上下文
    UIGraphicsBeginImageContextWithOptions([content size], NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [content setFrame:CGRectMake(0, 0, [content size].width, [content size].height)];
    if ([content isKindOfClass:[UIView class]]) {
        [[content layer]  renderInContext:context];
    } else if ([content isKindOfClass:[CALayer class]]) {
        [content renderInContext:context];
    }
    
    //获取位图
    UIImage *drawImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return drawImage;
}

+ (CFDictionaryRef)generateattributesDicWithElement:(ZJTextElement *)element {
    
    if (!element) return nil;
    
    //创建字典
    CFMutableDictionaryRef attributesDic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    //关联元素
    CFDictionaryAddValue(attributesDic, (CFStringRef)kZJTextElementAttributeName, (__bridge const void *)element);
    
    //基础属性
    ZJTextAttributes *attributes = element.attributes;
    if (attributes.font) {
        CTFontRef font = CTFontCreateWithName((CFStringRef)attributes.font.fontName, attributes.font.pointSize, NULL);
        CFDictionaryAddValue(attributesDic, kCTFontAttributeName, font);
        CFRelease(font);
    }
    
    if (attributes.color) {
        CFDictionaryAddValue(attributesDic, kCTForegroundColorAttributeName, attributes.color.CGColor);
    }
    
    if (attributes.letterSpace) {
        CFDictionaryAddValue(attributesDic, kCTKernAttributeName, (CFNumberRef)attributes.letterSpace);
    }
    
    if (attributes.strokeWidth) {
        CFDictionaryAddValue(attributesDic, kCTStrokeWidthAttributeName, (CFNumberRef)attributes.strokeWidth);
    }
    
    if (attributes.strokeColor) {
        CFDictionaryAddValue(attributesDic, kCTStrokeColorAttributeName, attributes.strokeColor.CGColor);
    }
    
    if (attributes.verticalForm) {
        CFDictionaryAddValue(attributesDic, kCTVerticalFormsAttributeName, (CFNumberRef)attributes.verticalForm);
    }
    
    if (attributes.verticalOffset) {
        CFDictionaryAddValue(attributesDic, NSBaselineOffsetAttributeName, (CFNumberRef)attributes.verticalOffset);
    }
    
    if (attributes.underline) {
        CFDictionaryAddValue(attributesDic, kCTUnderlineStyleAttributeName, (CFNumberRef)attributes.underline);
    }
    
    //段落属性
    CFMutableArrayRef settingsArray =  CFArrayCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeArrayCallBacks);
    
    if (attributes.minLineSpace) {
        CGFloat params = attributes.minLineSpace.doubleValue;
        CTParagraphStyleSetting setting;
        setting.spec = kCTParagraphStyleSpecifierMinimumLineSpacing;
        setting.valueSize = sizeof(CGFloat);
        setting.value = &params;
        NSValue *settingValue = [NSValue valueWithBytes:&setting objCType:@encode(CTParagraphStyleSetting)];
        if (settingValue) {
            CFArrayAppendValue(settingsArray, (__bridge const void *)settingValue);
        }
    }
    
    if (attributes.maxLineSpace) {
        CGFloat params = attributes.maxLineSpace.doubleValue;
        CTParagraphStyleSetting setting;
        setting.spec = kCTParagraphStyleSpecifierMaximumLineSpacing;
        setting.valueSize = sizeof(CGFloat);
        setting.value = &params;
        NSValue *settingValue = [NSValue valueWithBytes:&setting objCType:@encode(CTParagraphStyleSetting)];
        if (settingValue) {
            CFArrayAppendValue(settingsArray, (__bridge const void *)settingValue);
        }
    }
    
    if (attributes.minLineHeight) {
        CGFloat params = attributes.minLineHeight.doubleValue;
        CTParagraphStyleSetting setting;
        setting.spec = kCTParagraphStyleSpecifierMinimumLineHeight;
        setting.valueSize = sizeof(CGFloat);
        setting.value = &params;
        NSValue *settingValue = [NSValue valueWithBytes:&setting objCType:@encode(CTParagraphStyleSetting)];
        if (settingValue) {
            CFArrayAppendValue(settingsArray, (__bridge const void *)settingValue);
        }
    }
    
    if (attributes.maxLineHeight) {
        CGFloat params = attributes.maxLineHeight.doubleValue;
        CTParagraphStyleSetting setting;
        setting.spec = kCTParagraphStyleSpecifierMaximumLineHeight;
        setting.valueSize = sizeof(CGFloat);
        setting.value = &params;
        NSValue *settingValue = [NSValue valueWithBytes:&setting objCType:@encode(CTParagraphStyleSetting)];
        if (settingValue) {
            CFArrayAppendValue(settingsArray, (__bridge const void *)settingValue);
        }
    }
    
    if (attributes.align) {
        int8_t params = attributes.align.intValue;
        CTParagraphStyleSetting setting;
        setting.spec = kCTParagraphStyleSpecifierAlignment;
        setting.valueSize = sizeof(int8_t);
        setting.value = &params;
        NSValue *settingValue = [NSValue valueWithBytes:&setting objCType:@encode(CTParagraphStyleSetting)];
        if (settingValue) {
            CFArrayAppendValue(settingsArray, (__bridge const void *)settingValue);
        }
    }
    
    if (attributes.lineBreakMode) {
        int8_t params = attributes.align.intValue;
        CTParagraphStyleSetting setting;
        setting.spec = kCTParagraphStyleSpecifierLineBreakMode;
        setting.valueSize = sizeof(int8_t);
        setting.value = &params;
        NSValue *settingValue = [NSValue valueWithBytes:&setting objCType:@encode(CTParagraphStyleSetting)];
        if (settingValue) {
            CFArrayAppendValue(settingsArray, (__bridge const void *)settingValue);
        }
    }
    
    const int settingsCount = (int)CFArrayGetCount(settingsArray);
    CTParagraphStyleSetting settings[settingsCount];
    for (NSInteger i = 0; i < settingsCount; i++) {
        NSValue *settingValue = CFArrayGetValueAtIndex(settingsArray, i);
        CTParagraphStyleSetting setting;
        [settingValue getValue:&setting];
        settings[i] = setting;
    }
    CFRelease(settingsArray);
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, settingsCount);
    if (paragraphStyle) {
        CFDictionaryAddValue(attributesDic, kCTParagraphStyleAttributeName, paragraphStyle);
        CFRelease(paragraphStyle);
    }
    
    return attributesDic;
}

+ (void)appendAttachElement:(ZJTextElement *)element toEntireAttributedString:(CFMutableAttributedStringRef)entireAttributedString {
    
    if (!element) return;
    
    CGSize originSize = CGSizeZero;
    UIImage *image = objc_getAssociatedObject(element, kZJTextDrawImageAssociateKey.UTF8String);
    if (image) {
        originSize = image.size;
    } else if ([element.content isKindOfClass:[UIView class]]) {
        originSize = [element.content bounds].size;
    }
    
    //缓存图片绘制属性
    //基本属性
    CGFloat height = 0;
    CGFloat width = 0;
    if (element.attributes && element.attributes.attachSize) {
        CGSize attachSize = [element.attributes.attachSize CGSizeValue];
        height = attachSize.height;
        width = attachSize.width;
    } else {
        height = originSize.height / [UIScreen mainScreen].scale;
        width = originSize.width / [UIScreen mainScreen].scale;
    }
    
    //对齐模式
    CGFloat ascent = 0;
    CGFloat descent = 0;
    switch (element.attributes.attachAlign.integerValue) {
        case ZJTextAttachAlignBottomToBaseLine:
            ascent = height;
            break;
            
        case ZJTextAttachAlignCenterToFont: {
            UIFont *font = element.attributes.font ? : [UIFont systemFontOfSize:12];
            CGFloat fontAscent = fabs(font.ascender);
            CGFloat deltaHeght = (height - font.lineHeight) / 2;
            CGFloat preAscent = deltaHeght + fontAscent;
            CGFloat fix = preAscent / 0.5;
            ascent = fix * 0.5;
            descent = height - ascent;
            break;
        }
    }
    
    //垂直偏移
    if (element.attributes.verticalOffset) {
        ascent += element.attributes.verticalOffset.doubleValue;
        descent -= element.attributes.verticalOffset.doubleValue;
    }
    
    objc_setAssociatedObject(element, kZJTextImageAscentAssociateKey.UTF8String, @(ascent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(element, kZJTextImageDescentAssociateKey.UTF8String, @(descent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(element, kZJTextImageWidthAssociateKey.UTF8String, @(width), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //设置回调
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    
    //创建代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)element);
    if (delegate) {
        
        CFDictionaryRef placeHolderAttributesDic = [self generateattributesDicWithElement:element];
        if (!placeHolderAttributesDic) return;
        CFMutableDictionaryRef attributesDic = CFDictionaryCreateMutableCopy(CFAllocatorGetDefault(), CFDictionaryGetCount(placeHolderAttributesDic), placeHolderAttributesDic);
        CFDictionaryAddValue(attributesDic, kCTRunDelegateAttributeName, delegate);
        CFDictionaryAddValue(attributesDic, (CFStringRef)kZJTextElementAttributeName, (__bridge const void *)element);
        
        unichar placeHolder = 0xFFFC;
        CFStringRef placeHolderString = CFStringCreateWithCharacters(CFAllocatorGetDefault(), &placeHolder, 1);
        CFAttributedStringRef attributedString = CFAttributedStringCreate(CFAllocatorGetDefault(), placeHolderString, attributesDic);
        
        //保存图片位置
        NSInteger location = CFAttributedStringGetLength(entireAttributedString);
        NSInteger length = CFAttributedStringGetLength(attributedString);
        [element setValue:[NSValue valueWithRange:NSMakeRange(location, length)] forKey:@"rangeValue"];
        
        //拼接
        CFAttributedStringReplaceAttributedString(entireAttributedString, CFRangeMake(location, 0), attributedString);
        
        //内存释放
        CFRelease(placeHolderAttributesDic);
        CFRelease(attributesDic);
        CFRelease(delegate);
        CFRelease(placeHolderString);
        CFRelease(attributedString);
    }
}

+ (void)cacheFrameToElementIfNeeded:(CTFrameRef)frame size:(CGSize)size {
    
    CFArrayRef linesArray = CTFrameGetLines(frame);
    CFIndex linesCount = CFArrayGetCount(linesArray);
    CGPoint points[linesCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    CGPathRef path = CTFrameGetPath(frame);
    CGRect boxRect = CGPathGetBoundingBox(path);
    
    //遍历CTLine
    for (CFIndex i = 0; i < linesCount; i++) {
        
        CTLineRef line = CFArrayGetValueAtIndex(linesArray, i);
        CFArrayRef runsArray = CTLineGetGlyphRuns(line);
        CFIndex runsCount = CFArrayGetCount(runsArray);
        //遍历CTRun
        for (CFIndex j = 0; j < runsCount; j++) {
            
            CTRunRef run = CFArrayGetValueAtIndex(runsArray, j);
            CFDictionaryRef attributes = CTRunGetAttributes(run);
            
            //是否必要计算
            BOOL needCaculate = YES;
            ZJTextElement *element = CFDictionaryGetValue(attributes, (__bridge CFStringRef)kZJTextElementAttributeName);
            if (element) {
                needCaculate = (BOOL)CFDictionaryGetValue(attributes, kCTRunDelegateAttributeName); //图片
                needCaculate = needCaculate ? : (BOOL)element.attributes.onClicked; //可点击
                needCaculate = needCaculate ? : element.attributes.cacheFrame.boolValue; //是否外部需要计算
            } else {
                needCaculate = NO;
            }
            
            if (needCaculate) {
                CGPoint point = points[i];
                CGFloat ascent;
                CGFloat descent;
                CGRect runBounds;
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
                runBounds.size.height = ascent + descent;
                CGFloat offsetX = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                runBounds.origin.x = point.x + offsetX;
                runBounds.origin.y = point.y - descent;
                
                //绘制的基础frame
                CGRect bounds = CGRectOffset(runBounds, boxRect.origin.x, boxRect.origin.y);
                NSValue *frameValue = [NSValue valueWithCGRect:bounds];
                
                NSArray *drawFrameValueArray = objc_getAssociatedObject(element, kZJTextDrawFrameAssociateKey.UTF8String);
                if (!drawFrameValueArray) {
                    drawFrameValueArray = @[frameValue];
                } else {
                    drawFrameValueArray = [drawFrameValueArray arrayByAddingObject:frameValue];
                }
                objc_setAssociatedObject(element, kZJTextDrawFrameAssociateKey.UTF8String, drawFrameValueArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                //显示的frame: 由绘制的基础frame->翻转得到
                CGFloat overY = bounds.origin.y;
                overY = size.height - overY - bounds.size.height;
                if ([element.content isKindOfClass:[NSString class]]) {
                    overY -= element.attributes.verticalOffset.doubleValue;
                }
                CGRect overBounds = CGRectMake(bounds.origin.x, overY, bounds.size.width, bounds.size.height);
                NSValue *overFrameValue = [NSValue valueWithCGRect:overBounds];
                
                NSArray *frameValueArray = element.frameValueArray;
                if (!frameValueArray) {
                    frameValueArray = @[overFrameValue];
                } else {
                    frameValueArray = [frameValueArray arrayByAddingObject:overFrameValue];
                }
                [element setValue:frameValueArray forKey:@"frameValueArray"];
            }
        }
    }
}

+ (UIImage *)drawBitmapWithTextFrame:(CTFrameRef)frame defaultAttributes:(ZJTextAttributes *)defaultAttributes imageElements:(NSArray<ZJTextElement *> *)imageElements outputSize:(CGSize)outputSize {
    
    //开启图片上下文
    UIGraphicsBeginImageContextWithOptions(outputSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    //渲染背景
    if (defaultAttributes.backgroundLayer) {
        
        defaultAttributes.backgroundLayer.frame = CGRectMake(defaultAttributes.backgroundLayer.frame.origin.x, defaultAttributes.backgroundLayer.frame.origin.y, outputSize.width, outputSize.height);
        
        if (defaultAttributes.backgroundColor) {
            defaultAttributes.backgroundLayer.backgroundColor = defaultAttributes.backgroundColor.CGColor;
        }
        if (defaultAttributes.cornerRadius) {
            defaultAttributes.backgroundLayer.cornerRadius = defaultAttributes.cornerRadius.floatValue;
        }
        
        [defaultAttributes.backgroundLayer renderInContext:context];
        
    } else if (defaultAttributes.backgroundColor || defaultAttributes.cornerRadius) {
        
        UIGraphicsBeginImageContextWithOptions(outputSize, NO, [UIScreen mainScreen].scale);
        CGContextRef backgroundContext = UIGraphicsGetCurrentContext();
        CGRect rect = CGRectMake(0, 0, outputSize.width, outputSize.height);
        
        if (defaultAttributes.cornerRadius) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:defaultAttributes.cornerRadius.doubleValue * [UIScreen mainScreen].scale];
            CGContextAddPath(backgroundContext, path.CGPath);
            CGContextClip(backgroundContext);
        }
        
        if (defaultAttributes.backgroundColor) {
            CGContextSetFillColorWithColor(backgroundContext, defaultAttributes.backgroundColor.CGColor);
            CGContextFillRect(backgroundContext, rect);
        }
        
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGContextDrawImage(context, rect, backgroundImage.CGImage);
    }

    //翻转上下文
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, outputSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //缓存位置
    [self cacheFrameToElementIfNeeded:frame size:outputSize];
    
    //绘制图片
    for (ZJTextElement *imageElement in imageElements) {
        
        NSArray *frameValueArray = objc_getAssociatedObject(imageElement, kZJTextDrawFrameAssociateKey.UTF8String);
        CGRect imageFrame = [[frameValueArray firstObject] CGRectValue];
        
        UIImage *image = objc_getAssociatedObject(imageElement, kZJTextDrawImageAssociateKey.UTF8String);
        CGContextDrawImage(context, imageFrame, image.CGImage);
    }
    
    if (shadow) {
        NSAssert([defaultAttributes.shadow.shadowColor isKindOfClass:[UIColor class]], @"shadow color is not UIColor class");
        CGContextSetShadowWithColor(context, defaultAttributes.shadow.shadowOffset, defaultAttributes.shadow.shadowBlurRadius, [defaultAttributes.shadow.shadowColor CGColor]);
    }
    
    //绘制文本
    CTFrameDraw(frame, context);
    
    //获取位图
    UIImage *drawImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return drawImage;
}

+ (void)drawURLImageOnLayer:(CALayer *)layer imageURLElements:(NSArray *)imageURLElements {
    
    if (!layer || !imageURLElements.count) return;
    //绘制图片
    for (ZJTextElement *imageURLElement in imageURLElements) {
        //URL的图片首次会缓存
        [[SDWebImageManager sharedManager] loadImageWithURL:imageURLElement.content options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (!error && image) {
                NSArray *frameValueArray = imageURLElement.frameValueArray;
                CGRect imageFrame = [[frameValueArray firstObject] CGRectValue];
                CALayer *imageLayer = [CALayer layer];
                imageLayer.frame = imageFrame;
                imageLayer.contents = (id)image.CGImage;
                
                [layer addSublayer:imageLayer];
            }
        }];
    }
}

+ (void)addOnView:(UIView *)view viewElements:(NSArray *)viewElements {
    
    if (!view || !viewElements.count) return;
    for (ZJTextElement *viewElement in viewElements) {
        NSArray *frameValueArray = viewElement.frameValueArray;
        CGRect contentViewFrame = [[frameValueArray firstObject] CGRectValue];
        UIView *contentView = viewElement.content;
        contentView.frame = contentViewFrame;
    
        [view addSubview:contentView];
    }
}

static CGFloat ascentCallback(void *ref) {
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    NSNumber *ascent = objc_getAssociatedObject(element, kZJTextImageAscentAssociateKey.UTF8String);
    return ascent.doubleValue;
}

static CGFloat descentCallback(void *ref) {
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    NSNumber *descent = objc_getAssociatedObject(element, kZJTextImageDescentAssociateKey.UTF8String);
    return descent.doubleValue;
}

static CGFloat widthCallback(void *ref) {
    ZJTextElement *element = (__bridge ZJTextElement *)ref;
    NSNumber *width = objc_getAssociatedObject(element, kZJTextImageWidthAssociateKey.UTF8String);
    return width.doubleValue;
}

@end
