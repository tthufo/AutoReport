//
//  ViewController.h
//  Nexus
//
//  Created by Thanh Hai Tran on 2/2/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController


@end

@interface NSDictionary (name)

- (BOOL)responseForKey:(NSString *)name;

- (NSString*)responseForKind:(NSString*)name;

- (NSString*)getValueFromKey:(NSString *)name;

- (NSString*)responseForKind:(NSString*)name andOption:(NSString*)placeHolder;

- (NSString*)bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;

- (BOOL)responseForKindOfClass:(NSString *)name andTarget:(NSString*)target;

- (NSDictionary*)dictionaryWithPlist:(NSString*)pList;

@end

@interface NSObject (Extension_Category)

- (void)addValue:(NSString*)value andKey:(NSString*)key;

- (NSString*)getValue:(NSString*)key;

- (void)removeValue:(NSString*)key;

- (BOOL)isLiveRange:(NSString*)region;

@end

@interface NSDate (extension)

- (NSDate*)nowByTime:(NSInteger)days;

- (NSDate *)addDays:(NSInteger)days toDate:(NSDate *)originalDate;

- (NSString *)stringWithFormat:(NSString *)format;

- (BOOL)isPastTime:(NSString*)theDate;

@end

@interface NSString (Contains)

- (NSString*)trim;

- (BOOL)myContainsString:(NSString*)other;

- (NSString*)specialDateFromTimeStamp;

- (NSString*)specialDateAndTimeFromTimeStamp;

- (NSString*)dateFromTimeStamp;

- (NSString*)dateAndTimeFromTimeStamp;

- (NSString*)dateFromTimeStamp:(NSString*)format;

- (NSString*)normalizeDateTime:(int)position;

- (NSDate*)dateWithFormat:(NSString*)format;

- (NSString*)numbeRize;

- (NSString *)convertPercentage;

- (BOOL)isEmail;

@end
