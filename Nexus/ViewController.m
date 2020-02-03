//
//  ViewController.m
//  Nexus
//
//  Created by Thanh Hai Tran on 2/2/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

#import "ViewController.h"

#import "NSObject+Category.h"

@interface ViewController()<NSURLConnectionDelegate>
{
    IBOutlet NSTextField * email;
    
    IBOutlet NSSecureTextField * password;
    
    IBOutlet NSButton * login;
    
    IBOutlet NSTextField * name, * status;
    
    IBOutlet NSImageView * pulsing;
    
    IBOutlet NSView * loginView, * requestView;
    
    NSTimer * timer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
    
    [self.view.layer setBackgroundColor:[[NSColor colorWithRed:11/255 green:6/255 blue:17/255 alpha:1] CGColor]];
    
    [self stating];
    
    [self localNofification];
}

- (void)localNofification {
    NSDate *date = [NSDate date];
       NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear|NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitHour) fromDate:date];
   components.timeZone = [NSTimeZone localTimeZone];
   [components setDay: components.day + 0];
   [components setHour: 15];
   [components setMinute: 25];
   NSDate *dateToFire = [calendar dateFromComponents:components];

   NSUserNotification *localNotif = [NSUserNotification new];
   localNotif.deliveryRepeatInterval.day = 1;
   localNotif.informativeText = @"Nexus daily report!";
   localNotif.deliveryTimeZone = [NSTimeZone localTimeZone];
   localNotif.deliveryDate = dateToFire;
   NSDateComponents *repeatTime = [NSDateComponents new];
    repeatTime.day = 1;
    localNotif.deliveryRepeatInterval = repeatTime;
   NSUserNotificationCenter *notiCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
   [notiCenter scheduleNotification:localNotif];
}

- (void)onTick {
    if ([self isInRange]) {
        [self checkReport];
    } else {
        status.stringValue = @"Watching out 4 u.";
    }
}

- (void)stating {
    BOOL logged = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] != nil;
    
    loginView.hidden = logged;
    
    requestView.hidden = !logged;
    
    if (logged) {
        [self getProfile];
        pulsing.imageScaling = NSImageScaleProportionallyDown;
        pulsing.animates = YES;
        pulsing.canDrawSubviewsIntoLayer = YES;
        [pulsing setImage: [NSImage imageNamed:@"source-2.gif"]];
        
        if (timer == nil) {
            timer = [NSTimer scheduledTimerWithTimeInterval: 30.0
              target: self
              selector:@selector(onTick)
              userInfo: nil repeats:YES];
            
//            NSDate *timestamp;
//            NSDateComponents *comps = [[NSDateComponents alloc] init];
//
//            [comps setHour:11];
//            [comps setMinute:56];
//            timestamp = [[NSCalendar currentCalendar] dateFromComponents:comps];
//            timer = [[NSTimer alloc] initWithFireDate:timestamp
//                                         interval:0
//                                           target:self
//                                         selector:@selector(onTick)
//                                         userInfo:nil repeats:NO];
//            NSRunLoop *runner = [NSRunLoop currentRunLoop];
//            [runner addTimer:timer forMode: NSDefaultRunLoopMode];
        }
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)didPressLogout:(NSButton*)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    [self stating];
}

- (IBAction)didPressLogin:(NSButton*)sender
{
    NSDictionary * post = @{@"email": email.stringValue,
                            @"password": password.stringValue,
                            @"client_id": @"2",
                            @"client_secret": @"tCNb7eYXDM8SMQjjTF7Srl6IZsDMgSZOWKWqPYXl"};
    
    NSError *error;

    NSData *postData = [NSJSONSerialization dataWithJSONObject: post
    options:NSJSONWritingPrettyPrinted
      error:&error];
   NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[postData length]];

   NSMutableURLRequest *request = [NSMutableURLRequest new];
   [request setURL:[NSURL URLWithString:@"https://insight.nexusfrontier.tech/api/v1/signin"]];
   [request setHTTPMethod:@"POST"];
   [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   [request setHTTPBody:postData];

   NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)getProfile
{
   NSMutableURLRequest *request = [NSMutableURLRequest new];
   [request setURL:[NSURL URLWithString:@"https://insight.nexusfrontier.tech/api/v1/my-profile"]];
   [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:@{@"Authorization": [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]]}];
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)checkReport
{
    NSString * uId = [self getValue:@"id"];
    
    NSDateFormatter * dateFor = [NSDateFormatter new];
    
    dateFor.dateFormat = @"yyyy-MM-dd";
    
    NSString * date = [dateFor stringFromDate: [NSDate date]];
    
    NSString * url = [NSString stringWithFormat:@"https://insight.nexusfrontier.tech/api/v1/daily_reports/employee_reports?user_id=%@&from_date=%@&to_date=%@&limit=10&offset=0", uId, date, date];

   NSMutableURLRequest *request = [NSMutableURLRequest new];
   
   [request setURL:[NSURL URLWithString: url]];
   [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:@{@"Authorization": [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]]}];
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)getProject
{
    NSString * url = @"https://insight.nexusfrontier.tech/api/v1/projects/assigned-me";
   NSMutableURLRequest *request = [NSMutableURLRequest new];
   [request setURL:[NSURL URLWithString: url]];
   [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:@{@"Authorization": [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]]}];
   [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)report:(NSArray*)projects
{
    NSDictionary * tempProject = [projects firstObject];
    
    NSDateFormatter * dateFor = [NSDateFormatter new];
    
    dateFor.dateFormat = @"yyyy-MM-dd";
    
    NSString * date = [dateFor stringFromDate: [NSDate date]];
    
    NSDictionary * report = @{@"report_id": @(0), @"task_id": @"", @"summary": @"Temporary report",@"time_worked": @(1),@"current_progress": @(100),@"previous_progress": @(0), @"type": @(1)};
    
    NSDictionary * project = @{@"date_report": date, @"name": tempProject[@"name"], @"project_id": tempProject[@"id"], @"tasks": @[report]};
    
    NSDictionary * post = @{@"reports": @[project]};
        
     NSError *error;

     NSData *postData = [NSJSONSerialization dataWithJSONObject: post
     options:NSJSONWritingPrettyPrinted
       error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[postData length]];

   NSString * url = @"https://insight.nexusfrontier.tech/api/v1/daily_reports";
   NSMutableURLRequest *request = [NSMutableURLRequest new];
   [request setURL:[NSURL URLWithString: url]];
   [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:@{@"Authorization": [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"token"]]}];
   [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error;
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                    options:NSJSONReadingMutableContainers
                                    error:&error];
    NSString * url = connection.originalRequest.URL.absoluteString;

    if ([url containsString:@"signin"]) {
        [[NSUserDefaults standardUserDefaults] setValue:responseJson[@"accessToken"] forKey:@"token"];
        [self stating];
    }
    
    if ([url containsString:@"my-profile"]) {
        name.stringValue = [NSString stringWithFormat:@"%@, welcome!", responseJson[@"informations"][@"company_name"]];
//        name.stringValue = responseJson[@"email"];
        [self addValue:responseJson[@"id"] andKey:@"id"];
        if ([self isInRange]) {
            [self checkReport];
        } else {
            status.stringValue = @"Watching out 4 u.";
        }
    }
    
    if ([url containsString:@"employee_reports"]) {
        if (![self isReported:responseJson[@"items"]]) {
            [self getProject];
        } else {
            status.stringValue = @"Reported, you're safe 4 today";
        }
    }
    
    if ([url containsString:@"assigned-me"]) {
        [self report:responseJson[@"items"]];
    }
    
    if ([url containsString:@"daily_reports"]) {
        NSLog(@"connection received data %@", responseJson);
        status.stringValue = @"Reported, you're safe 4 today";
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"connection received response");
    NSHTTPURLResponse *ne = (NSHTTPURLResponse *)response;
    if([ne statusCode] == 200) {
        NSLog(@"connection state is 200 - all okay");
    } else {
        NSLog(@"connection state is NOT 200");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Conn Err: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Conn finished loading");
}

- (BOOL)isWeekEnd {
    NSCalendar* currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [currentCalendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return ([dateComponents weekday] == 7 || [dateComponents weekday] == 1);
}

- (BOOL)isInRange {
    return [self isLiveRange:@"endgame"];
}

- (BOOL)isReported:(NSArray*)items {
    BOOL reported = NO;
    for (NSDictionary * dict in [items lastObject][@"projects"]) {
        if (((NSArray*)dict[@"tasks"]).count != 0) {
            reported = YES;
            break;
        }
    }
    return reported;
}

@end

@implementation NSDictionary (name)

-(NSDictionary*)dictionaryWithPlist:(NSString*)pList
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:pList ofType:@"plist"];
    return [self initWithContentsOfFile:plistPath];
}

- (BOOL)responseForKey:(NSString *)name
{
    return ([self objectForKey:name] && [self objectForKey:name] != [NSNull null]);
}

- (NSString*)responseForKind:(NSString*)name
{
    return [self responseForKey:name] ? [self[name] isKindOfClass:[NSString class]] ? self[name] : [self[name] stringValue] : @"Wrong key";
}

- (NSString*)responseForKind:(NSString*)name andOption:(NSString*)placeHolder
{
    return [self responseForKey:name] ? [self[name] isKindOfClass:[NSString class]] ? self[name] : [self[name] stringValue] : placeHolder ? placeHolder : name;
}

- (NSString*)getValueFromKey:(NSString *)name
{
    if(!self[name])
    {
        return @"";
    }
    if(self[name] == [NSNull null])
    {
        return @"";
    }
    if([self[name] isKindOfClass:[NSString class]])
    {
        return self[name];
    }
    else
    {
        return [self[name] stringValue];
    }
    return nil;
}

- (BOOL)responseForKindOfClass:(NSString *)name andTarget:(NSString*)target
{
    if([self[name] isKindOfClass:[NSString class]])
    {
        if([self[name] isEqualToString:target])
            return YES;
        else
            return NO;
    }
    else
    {
        if([self[name] isEqualToNumber:@([target intValue])])
            return YES;
        else
            return NO;
    }
    return NO;
}

- (NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    if (! jsonData)
    {
        return @"{}";
    }
    else
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end

@implementation NSObject (Extension_Category)

- (void)addValue:(NSString*)value andKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (NSString*)getValue:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)removeValue:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (BOOL)isLiveRange:(NSString*)region
{
    NSDictionary * dict = [[NSDictionary new] dictionaryWithPlist:@"LiveRange"];

    NSDictionary * ranges = dict[region];

    NSDate * start = [[NSString stringWithFormat:@"%@ %@",[[[NSDate date] stringWithFormat:@"dd/MM/yyyy HH:mm:ss"] componentsSeparatedByString:@" "][0], ranges[@"start"]] dateWithFormat:@"dd/MM/yyyy HH:mm:ss"];

    NSDate * end = [[NSString stringWithFormat:@"%@ %@",[[[NSDate date] stringWithFormat:@"dd/MM/yyyy HH:mm:ss"] componentsSeparatedByString:@" "][0], ranges[@"end"]] dateWithFormat:@"dd/MM/yyyy HH:mm:ss"];

    if([[NSDate date] timeIntervalSince1970] > [start timeIntervalSince1970] && [[NSDate date] timeIntervalSince1970] < [end timeIntervalSince1970])
    {
        return YES;
    }

    return NO;
}

@end

@implementation NSDate (extension)

- (NSDate*)nowByTime:(NSInteger)days
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
}

- (NSDate *)addDays:(NSInteger)days toDate:(NSDate *)originalDate
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:originalDate options:0];
}

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df stringFromDate:self];
}

- (BOOL)isPastTime:(NSString*)theDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy"];
    NSDate *newDate = [df dateFromString:theDate];
    
    NSComparisonResult result;
    
    result = [self compare:newDate];
    
    if(result==NSOrderedAscending)
        return NO;
    else if(result==NSOrderedDescending)
        return YES;
    else
        return NO;
}

@end


@implementation NSString (Contains)

- (NSString*)trim
{
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)myContainsString:(NSString*)other
{
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

- (BOOL)containsString:(NSString *)str
{
    return [self myContainsString:str];
}

- (NSString*)specialDateFromTimeStamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:self];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    return [dateFormatter stringFromDate:dateFromString];
}

- (NSString*)specialDateAndTimeFromTimeStamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:self];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss a"];
    return [dateFormatter stringFromDate:dateFromString];
}

- (NSString*)dateAndTimeFromTimeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

- (NSString*)dateFromTimeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    return [dateFormatter stringFromDate:date];
}

- (NSString*)dateFromTimeStamp:(NSString*)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

- (NSString*)normalizeDateTime:(int)position//:(NSString*)dateTime
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZZ"];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZZ"];
    
    //df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *result = [df stringFromDate:[dateFormatter dateFromString:self]];
    
    NSString * final = [result componentsSeparatedByString:@" "][position];
    
    return final;
}

- (NSDate*)dateWithFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:self];
}

- (NSString*)numbeRize
{
    return [NSNumberFormatter localizedStringFromNumber:@([self intValue]) numberStyle:NSNumberFormatterDecimalStyle];
}

- (NSString *)convertPercentage
{
    NSString *convert = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)self,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 ));
    return convert;
}

- (BOOL)isEmail
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc]
                                  initWithPattern:regExPattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:self
                                                     options:0
                                                       range:NSMakeRange(0, [self length])];
    return (regExMatches == 0) ? NO : YES ;
}

@end
