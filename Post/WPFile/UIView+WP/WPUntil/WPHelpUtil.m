//
//  WPHelpUtil.m
//  HuanYinBusiness
//
//  Created by chinalong on 16/2/26.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import "WPHelpUtil.h"

@implementation WPHelpUtil

#pragma mark -- color
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert {
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor colorWithWhite:1.0 alpha:0.5];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor colorWithWhite:1.0 alpha:0.5];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

// RGB
+(UIColor*)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a {
    return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a];
}

#pragma mark -- 沙盒

// 拼接Document目录中的文件路径
+ (NSString *)fileByDocumentPath:(NSString *)fileName {
    NSArray *documentArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[documentArr objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}
// 拼接Library目录中的文件路径
+ (NSString *)fileByLibraryPath:(NSString *)fileName {
    
    NSArray *libraryArr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[libraryArr objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;

}
#pragma mark - 文件

// 格式化Byte，KB, MB
+ (NSString *)formatByte:(NSInteger)size {
    float f;
    if ((float)size < 1024.0 * 1024.0) {
        f = ((float)size / 1024.0);
        return [NSString stringWithFormat:@"%.2fKB", f];
    }
    f = ((float)size / (1024.0 * 1024.0));
    return [NSString stringWithFormat:@"%.2fMB", f];
}


#pragma mark - NSUserDefaults

// 读取 UserDefaults 值
+ (NSString *)getUserDefaults:(NSString *)name defaultValue:(NSString *)defaultValue {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:name];
    if (!value) {
        return defaultValue;
    }
    return value;
}

// 保存 UserDefaults 值
+ (void)setUserDefaults:(NSString *)name value:(NSString *)value {
    if ((NSNull *)name != [NSNull null] && (NSNull *)value != [NSNull null]) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:name];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// 邮箱验证
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

// 判断是否是中文字母或数字
+ (BOOL)isChineseNumberEnglish:(NSString *)inputStr {
    
    NSString *regex = @"[a-zA-Z0-9\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([pred evaluateWithObject:inputStr]) {
        return NO;
    }
    return YES;
}

#pragma mark -- json dictionary data 转换

// NSData 转 JSONString
+ (NSString *)dataToJSONString:(NSData *)data {
    NSError *error;
    id dataObject = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    
    if (dataObject != nil && error == nil) {
        return [[NSString alloc] initWithData:dataObject encoding:NSUTF8StringEncoding];
    }
    return nil;
}

//  NSData 转 NSArray 或 NSDictionary
+ (id)dataToArrayOrDictionary:(NSData *)data {
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    } else {
        return nil;
    }
}



// NSData 转 NSDictionary

+ (id)dataToDictionary:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dictionary = [unarchiver decodeObjectForKey:@"Some Key Value"];
    [unarchiver finishDecoding];
    
    return dictionary;
}

// NSDictionary 转 JSONString
+ (id)dictionaryToJSONString:(NSDictionary *)dictionary {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        //        NSLog(@"Got an error: %@", error);
    }
    return jsonString;
}

// NSArray 转 JSONString
+ (id)arrayToJSONString:(NSArray *)array {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        //        NSLog(@"Got an error: %@", error);
    }
    return jsonString;
}

// JSONString 转 NSDictionary
+ (id)jsonStringToDictionary:(NSString *)jsonString {
    NSDictionary *dict = nil;
    NSError *error;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return dict;
}


#pragma mark - Escapes
/**
 *  URL 编码
 *
 *  @param input <#input description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)encodeToPercentEscapeString:(NSString *)input {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return outputStr;
}

/**
 *  URL 解码
 *
 *  @param input <#input description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)decodeFromPercentEscapeString:(NSString *)input {
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


// 检测各种空值并替换
+ (NSString *)checkNullString:(NSString *)string defaultStr:(NSString *)defaultStr {
    if ([self isBlankString:string]) {
        return defaultStr;
    }else{
        return string;
    }
}

// 检测各种空值
+ (BOOL) isBlankString:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    else if (string == nil || string == NULL || [string isEqualToString:@"<null>"] || [string isEqualToString:@""]) {
        return YES;
    }
    else if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    
    return NO;
}


+ (NSString *)htmlShuangyinhao:(NSString *)values {
    if (values == nil) {
        return @"";
    }
    /*
     注：将字符串中的参数进行替换
     参数1：目标替换值
     参数2：替换成为的值
     参数3：类型为默认：NSLiteralSearch
     参数4：替换的范围
     */
    NSMutableString *temp = [NSMutableString stringWithString:values];
    [temp replaceOccurrencesOfString:@"\"" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"\r" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    return temp;
}

+ (CAShapeLayer *)setRoundingCornesRect:(CGRect)rect radius:(CGFloat)radius corners:(UIRectCorner)corners {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;

}


@end
