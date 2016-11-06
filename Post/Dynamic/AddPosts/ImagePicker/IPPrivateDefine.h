//
//  IPPrivateDefine.h
//  AHBusiness
//
//  Created by Wangjianlong on 2016/11/2.
//  Copyright © 2016年 Autohome. All rights reserved.
//

#ifndef Header_h
#define Header_h

#if DEBUG
#define IPLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define IPLog(format, ...)
#endif

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)

#define headerHeight 44.0f
#define IOS7_STATUS_BAR_HEGHT (iOS7Later ? 20.0f : 0.0f)

#endif /* Header_h */
