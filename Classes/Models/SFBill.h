//
//  SFBill.h
//  Congress
//
//  Created by Daniel Cloud on 1/8/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SFSynchronizedObject.h"
#import "SFBillIdentifier.h"

@class SFLegislator;
@class SFBillAction;

@interface SFBill : SFSynchronizedObject <SFSynchronizedObject>

@property (nonatomic, copy) NSString *billId;
@property (nonatomic, strong) NSString *referredToCommittee; // The date on which bill was referred to a committee
@property (nonatomic, strong) NSString *reportFromCommittee; // The date on which a report was presented by the committee on this bill
@property (nonatomic, strong) NSString *introducedBy;
@property (nonatomic, strong) NSDate *introducedOn;
@property (nonatomic, strong) NSString *lastAction;
@property (nonatomic, strong) NSDate *lastActionAt;
@property (nonatomic, strong) NSString *lokSabhaStatus;
@property (nonatomic, strong) NSString *ministry;
@property (nonatomic, strong) NSString *rajyaSabhaStatus;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;

// Legacy properties that have been modified
@property (nonatomic, readonly) NSString *shortTitle;
@property (nonatomic, readonly) NSString *officialTitle;
@property (nonatomic, readonly) NSString *shortSummary;

@property (nonatomic, strong) NSString *billType;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *congress;
@property (nonatomic, strong) NSNumber *abbreviated;
@property (nonatomic, strong) NSString *chamber;
@property (nonatomic, copy) NSString *sponsorId;
@property (nonatomic, strong) NSDate *lastPassageVoteAt;
@property (nonatomic, strong) NSDate *lastVoteAt;
@property (nonatomic, strong) NSDictionary *lastVersion;
@property (nonatomic, strong) NSDate *housePassageResultAt;
@property (nonatomic, strong) NSDate *senatePassageResultAt;
@property (nonatomic, strong) NSDate *vetoedAt;
@property (nonatomic, strong) NSDate *houseOverrideResultAt;
@property (nonatomic, strong) NSDate *senateOverrideResultAt;
@property (nonatomic, strong) NSDate *senateClotureResultAt;
@property (nonatomic, strong) NSDate *awaitingSignatureSince;
@property (nonatomic, strong) NSDate *enactedAt;
@property (nonatomic, strong) NSString *housePassageResult;
@property (nonatomic, strong) NSString *senatePassageResult;
@property (nonatomic, strong) NSString *houseOverrideResult;
@property (nonatomic, strong) NSString *senateOverrideResult;
@property (nonatomic, strong) SFLegislator *sponsor;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSArray *cosponsorIds;

@property (nonatomic, strong) NSArray *rollCallVotes;
@property (readonly) BOOL lastActionAtIsDateTime;
@property (nonatomic, readonly) NSArray *actionsAndVotes;
@property (nonatomic, readonly) NSString *displayBillType;
@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, readonly) SFBillIdentifier *identifier;
@property (nonatomic, readonly) NSURL *shareURL;

+ (NSString *)normalizeToCode:(NSString *)inputText;
+ (NSTextCheckingResult *)billCodeCheckingResult:(NSString *)searchText;

- (NSURL *)govTrackURL;
- (NSURL *)govTrackFullTextURL;
- (NSURL *)openCongressURL;
- (NSURL *)openCongressFullTextURL;
- (NSURL *)congressGovURL;
- (NSURL *)congressGovFullTextURL;

@end
