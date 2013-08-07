//
//  Created by ShareSDK.cn on 13-1-14.
//  官网地址:http://www.ShareSDK.cn
//  技术支持邮箱:support@sharesdk.cn
//  官方微信:ShareSDK   （如果发布新版本的话，我们将会第一时间通过微信将版本更新内容推送给您。如果使用过程中有任何问题，也可以通过微信与我们取得联系，我们将会在24小时内给予回复）
//  商务QQ:4006852216
//  Copyright (c) 2013年 ShareSDK.cn. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	@brief	继承值对象，用于标识取值是否继承父级对象
 */
@interface SSInheritValue : NSObject
{
@private
    NSString *_name;
}

/**
 *	@brief	名称
 */
@property (nonatomic,readonly) NSString *name;

/**
 *	@brief	初始化继承值对象
 *
 *	@param 	name 	名称，制定继承对象的某个属性名称
 *
 *	@return	继承值对象
 */
- (id)initWithName:(NSString *)name;


/**
 *	@brief	创建继承值对象
 *
 *	@return	继承值对象
 */
+ (id)inherit;

/**
 *	@brief	创建继承值对象
 *
 *	@param 	name 	名称，指定继承对象的某个值名称。
 *
 *	@return	继承值对象
 */
+ (id)inheritWithName:(NSString *)name;


@end
