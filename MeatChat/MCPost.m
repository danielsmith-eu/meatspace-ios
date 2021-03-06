//
//  NMeatPost.m
//  MeatChat
//
//  Created by Marcus Ramberg on 13.09.14.
//  Copyright (c) 2014 Nordaaker AS. All rights reserved.
//

#import "MCPost.h"
#import "NSDate+TimeAgo.h"


@interface MCPost ()
@property (nonatomic,strong) NSDictionary *postData;
@end

@implementation MCPost


-(id)initWithDictionary: (NSDictionary*)dict
{
  self = [super init];
  if(self) {
    self.postData=[dict dictionaryWithValuesForKeys: @[@"message",@"created"]];
    self.created=[dict objectForKey: @"created"];
    self.fingerprint=[dict objectForKey: @"fingerprint"];
    self.attributedString=[self attributedBody];
    NSString *media=[[dict objectForKey: @"media"] substringFromIndex:22];
    NSData *videoData=[[NSData alloc] initWithBase64EncodedString: media options: NSDataBase64DecodingIgnoreUnknownCharacters];
    
    [videoData writeToFile: [self path] atomically:NO];
    self.videoUrl=[NSURL fileURLWithPath: [self path]];
    
    
  }

  return self;
}

- (NSString*)path
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  return [[paths objectAtIndex:0] stringByAppendingPathComponent:[[self.created stringValue] stringByAppendingString: @".mp4"]];
}

- (NSString*)relativeTime
{
  NSTimeInterval epoch=[[self.postData objectForKey: @"created"] doubleValue]/1000;
  NSDate *postDate=[NSDate dateWithTimeIntervalSince1970: epoch];
 return [postDate dateTimeAgo];
}

- (void)cleanup
{
  NSError *err;
  [[NSFileManager defaultManager] removeItemAtPath: [self path] error:&err];
  if(err) {
    NSLog(@"Could not remove %@: %@",[self path],err);
  }
}

- (BOOL)isObsolete
{
  NSDate *postDate=[NSDate dateWithTimeIntervalSince1970: [[self.postData objectForKey: @"created"] doubleValue]/1000];
  NSDate *oldMessage=[NSDate dateWithTimeIntervalSinceNow: -1200];
  if([oldMessage compare: postDate] == NSOrderedDescending) {
    return YES;
  }
  return NO;
}

- (NSAttributedString*)attributedBody {
  NSString *text=[self.postData objectForKey: @"message"];
  // Let's make an NSAttributedString first
  if(!text) {
    return [[NSAttributedString alloc] init];
  }
  
  NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
  
  NSError *error;
  NSDictionary *attributes=@{};
  NSString *html=[NSString stringWithFormat: @"<html><head><style>* { margin: 0; padding:0; }p,body { font-family: Helvetica Neue;margin: 0;padding: 0; font-size:12px;} a { background-color: #95f7f1; color: #2d7470; text-decoration: none }</style></head><body><span>%@</span></body></html>",text];
 NSAttributedString *string=[[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:&attributes error:&error];
  return string;

  
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
  // Add Background Color for Smooth rendering
  [attributedString setAttributes:@{NSBackgroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, attributedString.length)];
  // Add Main Font Color
  [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.23 alpha:1.0]} range:NSMakeRange(0, attributedString.length)];
  // Add paragraph style
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
  [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
  // Add Font
  [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} range:NSMakeRange(0, attributedString.length)];
  // And finally set the text on the label to use this
  return attributedString;
  
}


@end
