//
//  SFVoteCountTableDataSource.h
//  Congress
//
//  Created by Daniel Cloud on 11/26/13.
//  Copyright (c) 2013 Sunlight Foundation. All rights reserved.
//

#import "SFDataTableDataSource.h"

@class SFRollCallVote;

@interface SFVoteCountTableDataSource : SFDataTableDataSource

@property (nonatomic, strong) SFRollCallVote *vote;

@end
