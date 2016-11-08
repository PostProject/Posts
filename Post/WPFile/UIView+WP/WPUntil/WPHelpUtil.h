//
//  WPHelpUtil.h
//  HuanYinBusiness
//
//  Created by chinalong on 16/2/26.
//  Copyright © 2016年 com.chinalong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface WPHelpUtil : NSObject
/**
 *  十六进制颜色转换
 *
 *  @param stringToConvert 十六进制字符串
 *
 *  @return UIColor
 */
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

/**
 *  rgb颜色转换
 *
 *  @return UIColor
 */
+(UIColor*)colorWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a;

/**
 *  存放文件到Document目录下
 *
 *  [WPHelpUtil fileByDocumentPath:@"/userInfo.sqlite"]
 *
 *  @param fileName /文件名.后缀
 *
 *  @return 存放文件的路径
 */
+ (NSString *)fileByDocumentPath:(NSString *)fileName;

/**
 *  存放文件到Library目录下
 *
 *  @param fileName 文件名
 *
 *  @return 文件路径
 */
+ (NSString *)fileByLibraryPath:(NSString *)fileName;


/**
 *  格式化Byte，KB, MB
 *
 *  @param size <#size description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)formatByte:(NSInteger)size;

/**
 *  读取 UserDefaults 值
 *
 *  @param name         名称
 *  @param defaultValue 默认值
 *
 *  @return value
 */
+ (NSString *)getUserDefaults:(NSString *)name defaultValue:(NSString *)defaultValue;

/**
 *  保存 UserDefaults 值
 *
 *  @param name  名称
 *  @param value 值
 */
+ (void)setUserDefaults:(NSString *)name value:(NSString *)value;

/**
 *  邮箱验证
 *
 *  @param email 要验证的邮箱
 *
 *  @return yes OR no
 */
+ (BOOL)isValidateEmail:(NSString *)email;
/**
 *  判断是否是中文或数字或字母
 *
 *  @param inputStr 要验证的字符串
 *
 *  @return yes OR no
 */
+ (BOOL)isChineseNumberEnglish:(NSString *)inputStr;

/**
 *  NSData 转 JSONString
 *
 *  @param data data
 *
 *  @return json字符串
 */
+ (NSString *)dataToJSONString:(NSData *)data;


/**
 *  NSData 转 NSArray 或 NSDictionary
 *
 *  @param data data
 *
 *  @return NSArray 或 NSDictionary
 */
+ (id)dataToArrayOrDictionary:(NSData *)data;

/**
 *  NSData 转 NSDictionary
 *
 *  @param data data
 *
 *  @return NSDictionary
 */
+ (id)dataToDictionary:(NSData *)data;

/**
 *  NSArray 转 JSONString
 *
 *  @param array NSArray
 *
 *  @return json字符串
 */
+ (id)arrayToJSONString:(NSArray *)array;

/**
 *  NSDictionary 转 JSONString
 *
 *  @param dictionary NSDictionary
 *
 *  @return json字符串
 */
+ (id)dictionaryToJSONString:(NSDictionary *)dictionary;

/**
 *  JSONString 转 NSDictionary
 *
 *  @param jsonString json字符串
 *
 *  @return NSDictionary
 */
+ (id)jsonStringToDictionary:(NSString *)jsonString;

/**
 *  URL 编码
 *
 *  @param input <#input description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)encodeToPercentEscapeString:(NSString *)input;

/**
 *  URL 解码
 *
 *  @param input <#input description#>
 *
 *  @return <#return value description#>
 */
+ (NSString *)decodeFromPercentEscapeString:(NSString *)input;

/**
 *  检测各种空值并替换
 *
 *  @param string     要检测的字符串
 *  @param defaultStr 用来替换的字符串
 *
 *  @return <#return value description#>
 */
+ (NSString *)checkNullString:(NSString *)string defaultStr:(NSString *)defaultStr;

/**
 *  检测各种空值
 *
 *  @param string 要检测的字符串
 *
 *  @return <#return value description#>
 */
+ (BOOL) isBlankString:(NSString *)string;

/**
 *  替换html源码字符串中的双引号
 *
 *  @param values 网页源码String类型
 *
 *  @return 替换过的字符串
 */
+ (NSString *)htmlShuangyinhao:(NSString *)values;

/**
 *  设置view指定的角为圆角
 *
 *  @param rect    view的frame
 *  @param radius  圆角半径
 *  @param corners 指定的角
 *
 *  @return 返回 CAShapeLayer对象
 */
+ (CAShapeLayer *)setRoundingCornesRect:(CGRect)rect radius:(CGFloat)radius corners:(UIRectCorner)corners;

@end
