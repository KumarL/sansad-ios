//
//  SFBill.m
//  Congress
//
//  Created by Daniel Cloud on 1/8/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFBill.h"
#import "SFBillAction.h"
#import "SFLegislator.h"
#import "SFCongressURLService.h"
#import "SFBillIdentifierTransformer.h"
#import "SFBillTypeTransformer.h"
#import "SFBillIdTransformer.h"
#import "SFDateFormatterUtil.h"

@implementation SFBill
{
    SFBillIdentifier *_identifier;
    NSString *_displayBillType;
    NSString *_displayName;
}

@synthesize lastActionAtIsDateTime = _lastActionAtIsDateTime;
@synthesize shortTitle = _shortTitle;

#pragma mark - initWithDictionary

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    NSString *lastActionAtRaw = [dictionaryValue valueForKeyPath:@"last_action_at"];
    _lastActionAtIsDateTime = ([lastActionAtRaw length] == 10) ? NO : YES;
    return self;
}

#pragma mark - MTLModel Versioning

+ (NSUInteger)modelVersion {
    return 3;
}

#pragma mark - MTLModel Transformers

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
               @"billId": @"bill_id",
               @"referredToCommittee": @"com_ref",
               @"reportFromCommittee": @"com_rep",
               @"introducedBy": @"introduced_by",
               @"introducedOn": @"introduced_on",
               @"lastAction": @"last_action",
               @"lastActionAt": @"last_action_at",
               @"lokSabhaStatus": @"ls_status",
               @"ministry": @"ministry",
               @"rajyaSabhaStatus": @"rs_status",
               @"status": @"status",
               @"summary": @"summary",
               @"title": @"title",
               @"url": @"url",
    };
}

+ (NSValueTransformer *)officialTitleJSONTransformer {
    return [MTLValueTransformer transformerWithBlock: ^id (NSString *str) {
        NSArray *stringComponents = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        return [stringComponents componentsJoinedByString:@" "];
    }];
}

+ (NSValueTransformer *)lastActionAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock: ^(NSString *str) {
        id value = (str != nil) ? [[SFDateFormatterUtil isoDateTimeFormatter] dateFromString:str] : nil;
        return value;
    } reverseBlock: ^(NSDate *date) {
        return [[SFDateFormatterUtil isoDateTimeFormatter] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)lastVoteAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock: ^(NSString *str) {
        id value = (str != nil) ? [[SFDateFormatterUtil isoDateTimeFormatter] dateFromString:str] : nil;
        return value;
    } reverseBlock: ^(NSDate *date) {
        return [[SFDateFormatterUtil isoDateTimeFormatter] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)introducedOnJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock: ^(NSString *str) {
        id value = (str != nil) ? [[SFDateFormatterUtil isoDateFormatter] dateFromString:str] : nil;
        return value;
    } reverseBlock: ^(NSDate *date) {
        return [[SFDateFormatterUtil isoDateFormatter] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)actionsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[SFBillAction class]];
}

+ (NSValueTransformer *)cosponsorIdsJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock: ^id (id idArr) {
        return idArr;
    }];
}

+ (NSValueTransformer *)sponsorJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[SFLegislator class]];
}

+ (NSValueTransformer *)lastVersionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock: ^id (id obj) {
        NSDictionary *version = @{ @"urls": [[NSMutableDictionary alloc] init] };
        for (NSString * key in @[@"html", @"pdf", @"xml"]) {
            NSString *value = [obj valueForKeyPath:[NSString stringWithFormat:@"urls.%@", key]];
            if (value) {
                [version[@"urls"] setObject:value forKey:key];
            }
        }
        return version;
    }];
}

#pragma mark - MTLModel (NSCoding)

+ (NSDictionary *)encodingBehaviorsByPropertyKey {
    NSDictionary *excludedProperties = @{
        @"lastActionAtIsDateTime": @(MTLModelEncodingBehaviorExcluded),
        @"actionsAndVotes": @(MTLModelEncodingBehaviorExcluded),
        @"displayBillType": @(MTLModelEncodingBehaviorExcluded),
        @"displayName": @(MTLModelEncodingBehaviorExcluded),
        @"identifier": @(MTLModelEncodingBehaviorExcluded),
        @"shareURL": @(MTLModelEncodingBehaviorExcluded),
    };
    NSDictionary *encodingBehaviors = [[super encodingBehaviorsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:excludedProperties];
    return encodingBehaviors;
}

#pragma mark - SynchronizedObject protocol methods

+ (NSString *)remoteResourceName {
    return @"bills";
}

+ (NSString *)remoteIdentifierKey {
    return @"billId";
}

#pragma mark - SFBill

- (SFBillIdentifier *)identifier {
    if (!_identifier) {
        _identifier = [[NSValueTransformer valueTransformerForName:SFBillIdentifierTransformerName] transformedValue:self.billId];
    }
    return _identifier;
}

- (NSString *)displayBillType {
    if (!_displayBillType) {
        _displayBillType = [[NSValueTransformer valueTransformerForName:SFBillTypeTransformerName] transformedValue:self.billType];
    }
    return _displayBillType;
}

- (NSString *)displayName {
    if (!_displayName) {
        _displayName = [[NSValueTransformer valueTransformerForName:SFBillIdTransformerName] transformedValue:self.billId];
    }
    return _displayName;
}

- (NSString *)shortTitle {
    if (!_shortTitle) {
        // We strip the year suffix, if it exists, from the title
        _shortTitle = [[self class] stripYearFromTitle:self.title];
    }
    return _shortTitle;
}

- (NSString *)officialTitle {
    // The regular title is official title
    return self.title;
}

- (NSString *)shortSummary {
    // There is no short summary
    return self.summary;
}

- (NSArray *)actionsAndVotes {
    NSMutableArray *combinedObjects = [NSMutableArray array];
    [combinedObjects addObjectsFromArray:self.actions];
    [combinedObjects addObjectsFromArray:self.rollCallVotes];
    [combinedObjects sortUsingComparator: ^NSComparisonResult (id obj1, id obj2) {
        Class billActionClass = [SFBillAction class];
        NSDate *obj1Date = [obj1 isKindOfClass:billActionClass] ? [obj1 valueForKey:@"actedAt"] : [obj1 valueForKey:@"votedAt"];
        NSDate *obj2Date = [obj2 isKindOfClass:billActionClass] ? [obj2 valueForKey:@"actedAt"] : [obj2 valueForKey:@"votedAt"];
        NSTimeInterval dateDifference = [obj1Date timeIntervalSinceDate:obj2Date];
        if (dateDifference < 0) {
            return NSOrderedDescending;
        }
        else if (dateDifference > 0) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    return combinedObjects;
}

- (NSURL *)shareURL {
    return [SFCongressURLService landingPageForBillWithId:self.billId];
}

- (NSURL *)govTrackURL {
    return [NSURL sam_URLWithFormat:@"http://www.govtrack.us/congress/bills/%@/%@%@", self.identifier.session, self.identifier.type, self.identifier.number];
}

- (NSURL *)govTrackFullTextURL {
    return [NSURL sam_URLWithFormat:@"http://www.govtrack.us/congress/bills/%@/%@%@/text", self.identifier.session, self.identifier.type, self.identifier.number];
}

- (NSURL *)openCongressURL {
    NSString *type = [_identifier.type isEqualToString:@"hr"] ? @"h" : self.identifier.type;
    return [NSURL sam_URLWithFormat:@"http://www.opencongress.org/bill/%@-%@%@", self.identifier.session, type, self.identifier.number];
}

- (NSURL *)openCongressFullTextURL {
    NSString *type = [_identifier.type isEqualToString:@"hr"] ? @"h" : self.identifier.type;
    return [NSURL sam_URLWithFormat:@"http://www.opencongress.org/bill/%@-%@%@/text", self.identifier.session, type, self.identifier.number];
}

- (NSURL *)congressGovURL {
    return [NSURL sam_URLWithFormat:@"http://beta.congress.gov/bill/%@th-congress/%@-bill/%@", self.identifier.session, self.chamber, self.identifier.number];
}

- (NSURL *)congressGovFullTextURL {
    return [NSURL sam_URLWithFormat:@"http://beta.congress.gov/bill/%@th-congress/%@-bill/%@/text", self.identifier.session, self.chamber, self.identifier.number];
}

+ (NSString *)normalizeToCode:(NSString *)inputText {
    static NSCharacterSet *nonAlphaChars = nil;
    if (!nonAlphaChars) {
        nonAlphaChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    }
    NSMutableArray *stringComponents = [[[inputText lowercaseString] componentsSeparatedByCharactersInSet:nonAlphaChars] mutableCopy];
    if ([stringComponents[0] isEqualToString:@"house"]) {
        stringComponents[0] = @"h";
    }
    else if ([stringComponents[0] isEqualToString:@"senate"]) {
        stringComponents[0] = @"s";
    }
    NSMutableString *alphaString = [[stringComponents componentsJoinedByString:@""] mutableCopy];
    [alphaString replaceOccurrencesOfString:@"joint" withString:@"j" options:0 range:NSMakeRange(0, [alphaString length])];
    [alphaString replaceOccurrencesOfString:@"cres" withString:@"conres" options:0 range:NSMakeRange(0, [alphaString length])];
    return alphaString;
}

+ (NSTextCheckingResult *)billCodeCheckingResult:(NSString *)searchText {
    static NSRegularExpression *regex = nil;
    if (!regex) {
        regex = [NSRegularExpression regularExpressionWithPattern:@"^(hr|hres|hjres|hconres|s|sres|sjres|sconres)(\\d+)$" options:0 error:nil];
    }
    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, [searchText length])];
    return result;
}

+ (NSString *)stripYearFromTitle:(NSString *)completeTitle {
    NSString *strippedTitle = completeTitle; // The default value
    NSRange range = [completeTitle rangeOfString:@", " options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSUInteger rangeEndLocation = range.location + range.length;
        NSString *billYear = [completeTitle substringFromIndex:rangeEndLocation];
        if ([billYear length] == 4) {
            // We found the year string
            NSScanner *yearScanner = [NSScanner scannerWithString:billYear];
            NSInteger year;
            if ([yearScanner scanInteger:&year]) {
                strippedTitle = [completeTitle substringToIndex:range.location];
            }
        }
    }
    return strippedTitle;
}

@end
