//
//  NSString+AttributedText.m
//  ZJAttributedText
//
//  Created by Syik on 2018/6/23.
//

#import "NSString+AttributedText.h"
#import "ZJTextFactory.h"
#import "ZJTextElement.h"
#import "ZJTextAttributes.h"
#import <objc/runtime.h>

typedef void(^ZJTextElementsGenerateCompletionBlock)(NSArray *elements, ZJTextAttributes *defaultAttributes);

static NSString *const kZJTextStringAttributesAssociateKey = @"kZJTextStringAttributesAssociateKey";
static NSString *const kZJTextStringContextAssociateKey = @"kZJTextStringContextAssociateKey";
static NSString *const kZJTextStringAttachAssociateKey = @"kZJTextStringAttachAssociateKey";
static NSString *const kZJTextStringAttachPlaceHolderPrefix = @"$AttachPlaceHolder-";
static NSString *const kZJTextStringDefaultPlaceHolderPrefix = @"$DefaultPlaceHolder-";

@implementation NSString (AttributedText)
@dynamic drawLayer;
@dynamic drawView;
@dynamic append;
@dynamic entire;
@dynamic verticalOffset;
@dynamic onClicked;
@dynamic onLayout;
@dynamic cacheFrame;
@dynamic font;
@dynamic color;
@dynamic letterSpace;
@dynamic strokeWidth;
@dynamic strokeColor;
@dynamic verticalForm;
@dynamic horizontalOffset;
@dynamic underline;
@dynamic attachSize;
@dynamic attachAlign;
@dynamic maxSize;
@dynamic shadow;
@dynamic preferHeight;
@dynamic verticalMargin;
@dynamic horizontalMargin;
@dynamic backgroundColor;
@dynamic backgroundLayer;
@dynamic cornerRadius;
@dynamic minLineSpace;
@dynamic maxLineSpace;
@dynamic minLineHeight;
@dynamic maxLineHeight;
@dynamic align;
@dynamic lineBreakMode;

#pragma mark - core method

- (ZJTextDotAppendBlock)append {
    return ^(id content) {
        if (!content) return self;
        if ([content isKindOfClass:[NSString class]]) {
            //将前文字符串关联起来
            objc_setAssociatedObject(content, kZJTextStringContextAssociateKey.UTF8String, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return (NSString *)content;
        } else if ([content isKindOfClass:[UIImage class]] || [content isKindOfClass:[NSURL class]] || [content isKindOfClass:[CALayer class]] || [content isKindOfClass:[UIView class]]) {
            //若是其他
            NSString *placeHolder = [NSString stringWithFormat:@"%@%.0f$", kZJTextStringAttachPlaceHolderPrefix, [[NSDate date] timeIntervalSince1970]];
            objc_setAssociatedObject(placeHolder, kZJTextStringAttachAssociateKey.UTF8String, content, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(placeHolder, kZJTextStringContextAssociateKey.UTF8String, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return placeHolder;
        }
        return @"";
    };
}

- (ZJTextDotEntireBlock)entire {
    return ^(void) {
        //生成全局属性占位
        NSString *placeHolder = [NSString stringWithFormat:@"%@%.0f$", kZJTextStringDefaultPlaceHolderPrefix, [[NSDate date] timeIntervalSince1970]];
        objc_setAssociatedObject(placeHolder, kZJTextStringContextAssociateKey.UTF8String, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return placeHolder;
    };
}

- (ZJTextDotLayerDrawBlock)drawLayer {
    return ^(ZJTextLayerDrawCompletionBlock completion) {
        [self generateElementsAndDefaultAttributes:^(NSArray *elements, ZJTextAttributes *defaultAttributes) {
            [ZJTextFactory drawTextLayerWithElements:elements defaultAttributes:defaultAttributes completion:^(CALayer *drawLayer) {
                if (completion) {
                    completion(drawLayer);
                }
            }];
        }];
        return self;
    };
}

- (ZJTextDotViewDrawBlock)drawView {
    return ^(ZJTextViewDrawCompletionBlock completion) {
        [self generateElementsAndDefaultAttributes:^(NSArray *elements, ZJTextAttributes *defaultAttributes) {
            [ZJTextFactory drawTextViewWithElements:elements defaultAttributes:defaultAttributes completion:^(UIView *drawView) {
                if (completion) {
                    completion(drawView);
                }
            }];
        }];
        return self;
    };
}

#pragma mark - private

- (void)setAssociate:(id)content attribute:(id)attribute forKey:(NSString *)key {
    
    if (!attribute || !key) return;
    NSMutableDictionary *attributesDic = objc_getAssociatedObject(content, kZJTextStringAttributesAssociateKey.UTF8String);
    if (!attributesDic) {
        attributesDic = [NSMutableDictionary dictionary];
    }
    
    attributesDic[key] = attribute;
    objc_setAssociatedObject(content, kZJTextStringAttributesAssociateKey.UTF8String, attributesDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)getAssociateAttributes:(id)content {
    return objc_getAssociatedObject(content, kZJTextStringAttributesAssociateKey.UTF8String);
}

- (void)generateElementsAndDefaultAttributes:(ZJTextElementsGenerateCompletionBlock)comletion {
    
    NSMutableArray *elements = [NSMutableArray array];
    ZJTextAttributes *defaultAttributes = nil;
    
    //从最后一个字符串往前文字符串遍历
    id content = self;
    while (content) {
        
        id realContent = nil;
        if ([content hasPrefix:kZJTextStringAttachPlaceHolderPrefix]) {
            //处理附加占位
            realContent = objc_getAssociatedObject(content, kZJTextStringAttachAssociateKey.UTF8String);
        } else if ([content hasPrefix:kZJTextStringDefaultPlaceHolderPrefix]) {
            //处理全局属性占位
            if (!defaultAttributes) {
                defaultAttributes = [ZJTextAttributes new];
            }
            NSDictionary *attibutesDic = [self getAssociateAttributes:content];
            for (NSString *key in attibutesDic) {
                [defaultAttributes setValue:attibutesDic[key] forKey:key];
            }
        } else {
            //处理普通文本
            realContent = content;
        }
        
        if (realContent) {
            BOOL isNotString = ![realContent isKindOfClass:[NSString class]];
            BOOL isNonEmptyString = [realContent isKindOfClass:[NSString class]] && [realContent length];
            if (isNonEmptyString || isNotString ) {
                //生成对应元素
                ZJTextElement *element = [ZJTextElement new];
                element.content = realContent;
                NSDictionary *attibutesDic = [self getAssociateAttributes:content];
                for (NSString *key in attibutesDic) {
                    [element.attributes setValue:attibutesDic[key] forKey:key];
                }
                [elements insertObject:element atIndex:0];
            }
        }
        content = objc_getAssociatedObject(content, kZJTextStringContextAssociateKey.UTF8String);
    }
    if (comletion) {
        comletion(elements, defaultAttributes);
    }
}

#pragma mark - attributes transform

- (ZJTextDotNumberBlock)verticalOffset {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"verticalOffset"];
        return self;
    };
}

- (ZJTextDotNumberBlock)horizontalOffset {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"horizontalOffset"];
        return self;
    };
}

- (ZJTextDotBlockBlock)onClicked {
    return ^(ZJTextReturnBlock block) {
        [self setAssociate:self attribute:block forKey:@"onClicked"];
        return self;
    };
}

- (ZJTextDotBlockBlock)onLayout {
    return ^(ZJTextReturnBlock block) {
        [self setAssociate:self attribute:block forKey:@"onLayout"];
        return self;
    };
}

- (ZJTextDotNumberBlock)cacheFrame {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"cacheFrame"];
        return self;
    };
}

- (ZJTextDotFontBlock)font {
    return ^(UIFont *font) {
        [self setAssociate:self attribute:font forKey:@"font"];
        return self;
    };
}

- (ZJTextDotColorBlock)color {
    return ^(UIColor *color) {
        [self setAssociate:self attribute:color forKey:@"color"];
        return self;
    };
}

- (ZJTextDotNumberBlock)letterSpace {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"letterSpace"];
        return self;
    };
}

- (ZJTextDotNumberBlock)strokeWidth {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"strokeWidth"];
        return self;
    };
}

- (ZJTextDotColorBlock)strokeColor {
    return ^(UIColor *color) {
        [self setAssociate:self attribute:color forKey:@"strokeColor"];
        return self;
    };
}

- (ZJTextDotNumberBlock)underline {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"underline"];
        return self;
    };
}

- (ZJTextDotValueBlock)attachSize {
    return ^(NSValue *value) {
        [self setAssociate:self attribute:value forKey:@"attachSize"];
        return self;
    };
}

- (ZJTextDotNumberBlock)attachAlign {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"attachAlign"];
        return self;
    };
}

- (ZJTextDotValueBlock)maxSize {
    return ^(NSValue *value) {
        [self setAssociate:self attribute:value forKey:@"maxSize"];
        return self;
    };
}

- (ZJTextDotShadowBlock)shadow {
    return ^(NSShadow *shadow) {
        [self setAssociate:self attribute:shadow forKey:@"shadow"];
        return self;
    };
}

- (ZJTextDotNumberBlock)preferHeight {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"preferHeight"];
        return self;
    };
}

- (ZJTextDotNumberBlock)verticalMargin {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"verticalMargin"];
        return self;
    };
}

- (ZJTextDotNumberBlock)horizontalMargin {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"horizontalMargin"];
        return self;
    };
}

- (ZJTextDotColorBlock)backgroundColor {
    return ^(UIColor *color) {
        [self setAssociate:self attribute:color forKey:@"backgroundColor"];
        return self;
    };
}

- (ZJTextDotLayerBlock)backgroundLayer {
    return ^(CALayer *layer) {
        [self setAssociate:self attribute:layer forKey:@"backgroundLayer"];
        return self;
    };
}

- (ZJTextDotNumberBlock)cornerRadius {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"cornerRadius"];
        return self;
    };
}

- (ZJTextDotNumberBlock)minLineSpace {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"minLineSpace"];
        return self;
    };
}

- (ZJTextDotNumberBlock)maxLineSpace {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"maxLineSpace"];
        return self;
    };
}

- (ZJTextDotNumberBlock)minLineHeight {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"minLineHeight"];
        return self;
    };
}

- (ZJTextDotNumberBlock)maxLineHeight {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"maxLineHeight"];
        return self;
    };
}

- (ZJTextDotNumberBlock)align {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"align"];
        return self;
    };
}

- (ZJTextDotNumberBlock)lineBreakMode {
    return ^(NSNumber *number) {
        [self setAssociate:self attribute:number forKey:@"lineBreakMode"];
        return self;
    };
}

@end
