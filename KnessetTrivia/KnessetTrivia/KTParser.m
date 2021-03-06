//
//  KTParser.m
//  KnessetTrivia
//
//  Created by Stav Ashuri on 4/27/12.
//   
//

#import "KTParser.h"

#import "SBJsonParser.h"
#import "KTParserStrings.h"
#import "KTMember.h"
#import "KTLink.h"
#import "KTCommitteeLink.h"
#import "KTBillLink.h"
#import "KTBill.h"
#import "KTComitteeMeetings.h"
#import "KTCommitteeMeeting.h"
#import "KTParty.h"

@implementation KTParser

#pragma mark - Private

+ (NSDateFormatter *)generalDateFormatter {
    NSDateFormatter *generalDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    generalDateFormatter.dateFormat = kParserGeneralDateFormat; 
    generalDateFormatter.timeZone = [NSTimeZone timeZoneWithName:kParserGeneralDateTimezoneName];
    return generalDateFormatter;
}

+ (KTComitteeMeetings *)parseCommitteeMeetingsFromTree:(NSDictionary *)committeeMeetingsTree {
    KTComitteeMeetings *committeeMeetings = [[[KTComitteeMeetings alloc] init] autorelease];
    
    NSMutableArray *allMeetingsArr = [[NSMutableArray alloc] init];
    NSArray *allArr = [committeeMeetingsTree objectForKey:kParserCMKeyAll];
    for (NSDictionary *committeeMeetingDict in allArr) {
        KTCommitteeMeeting *meeting = [KTParser parseCommitteeMeetingFromTree:committeeMeetingDict];
        [allMeetingsArr addObject:meeting];
    }
    committeeMeetings.all = [NSArray arrayWithArray:allMeetingsArr];
    [allMeetingsArr release];
    
    NSMutableArray *firstMeetingsArr = [[NSMutableArray alloc] init];
    NSArray *firstArr = [committeeMeetingsTree objectForKey:kParserCMKeyFirst];
    for (NSDictionary *committeeMeetingDict in firstArr) {
        KTCommitteeMeeting *meeting = [KTParser parseCommitteeMeetingFromTree:committeeMeetingDict];
        [firstMeetingsArr addObject:meeting];
    }
    committeeMeetings.first = [NSArray arrayWithArray:firstMeetingsArr];
    [firstMeetingsArr release];
    
    NSMutableArray *secondMeetingsArr = [[NSMutableArray alloc] init];
    NSArray *secondArr = [committeeMeetingsTree objectForKey:kParserCMKeySecond];
    for (NSDictionary *committeeMeetingDict in secondArr) {
        KTCommitteeMeeting *meeting = [KTParser parseCommitteeMeetingFromTree:committeeMeetingDict];
        [secondMeetingsArr addObject:meeting];
    }
    committeeMeetings.second = [NSArray arrayWithArray:secondMeetingsArr];
    [secondMeetingsArr release];
    
    return committeeMeetings;
}

+ (KTCommitteeMeeting *)parseCommitteeMeetingFromTree:(NSDictionary *)committeeMeetingTree {
    NSDateFormatter *generalDateFormatter = [KTParser generalDateFormatter];
    
    KTCommitteeMeeting *meeting = [[[KTCommitteeMeeting alloc] init] autorelease];
    [meeting setCommitteeMeetingId:[[committeeMeetingTree objectForKey:kParserCMKeyId]intValue]];
    [meeting setDate:[generalDateFormatter dateFromString:[committeeMeetingTree objectForKey:kParserCMKeyDate]]];
    [meeting setDescription:[committeeMeetingTree objectForKey:kParserCMKeyDescription]];
    
    return meeting;
}

+ (NSArray *)parseProposingMKsFromTree:(NSArray *)proposingMKsTree {
    NSMutableArray *proposingMKIDs = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *proposingMK in proposingMKsTree) {
        NSString *mkIdAsStr = [proposingMK objectForKey:@"id"];
        int mkId = [mkIdAsStr intValue];
        NSNumber *mkIdAsNum = [NSNumber numberWithInt:mkId];
        [proposingMKIDs addObject:mkIdAsNum];
    }
    return [NSArray arrayWithArray:proposingMKIDs];;
}


+ (void)parseVoteFromTree:(NSDictionary *)votesTree toDict:(NSMutableDictionary *)votedict fromkey:(NSString *)votekey {
    id object = [votesTree objectForKey:votekey];
    if (object != [NSNull null]) {
        NSDictionary *objDict = (NSDictionary *)object;
        NSString *voteIdAsStr = [objDict objectForKey:kParserKeyGeneralId];
        int voteId = [voteIdAsStr intValue];
        NSNumber *voteIdAsNum = [NSNumber numberWithInt:voteId];
        [votedict setValue:voteIdAsNum forKey:votekey];
    }
}

+ (void)parsePreVoteFromTree:(NSDictionary *)votesTree toDict:(NSMutableDictionary *)votedict fromkey:(NSString *)votekey {
    id object = [votesTree objectForKey:votekey];
    if (object != [NSNull null]) {
        NSArray *objArr = (NSArray *)object;
        if ([objArr count] > 0) {
            NSString *voteIdAsStr = [[objArr objectAtIndex:0] objectForKey:kParserKeyGeneralId];
            int voteId = [voteIdAsStr intValue];
            NSNumber *voteIdAsNum = [NSNumber numberWithInt:voteId];
            [votedict setValue:voteIdAsNum forKey:votekey];
        }
    }
}

+ (NSDictionary *)parseVotesFromTree:(NSDictionary *)votesTree    {
    NSMutableDictionary *votes =[[[NSMutableDictionary alloc] init] autorelease];
    
    [KTParser parsePreVoteFromTree:votesTree toDict:votes fromkey:kParserVotesKeyPre];
    [KTParser parseVoteFromTree:votesTree toDict:votes fromkey:kParserVotesKeyFirst];
    [KTParser parseVoteFromTree:votesTree toDict:votes fromkey:kParserVotesKeyApproval];
    
    return [NSDictionary dictionaryWithDictionary:(votes)];
    
}

#pragma mark - Public

+ (NSArray *)parseBillsArrayFromTree:(NSArray *)billsTree {
    NSMutableArray *billsArr = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary *billDict in billsTree) {
        KTBillLink *bill = [[KTBillLink alloc] init];
        [bill setBillTitle:[billDict objectForKey:kParserKeyBillTitle]];
        [bill setUrl:[billDict objectForKey:kParserKeyBillUrl]];
        [billsArr addObject:bill];
        [bill release];
    }
    return [NSArray arrayWithArray:billsArr];
    
}

+ (NSArray *)parseCommitteesArrayFromTree:(NSArray *)committeeTree {
    NSMutableArray *committeesArr = [[[NSMutableArray alloc] init] autorelease];
    for (NSArray *committeeArr in committeeTree) {
        KTCommitteeLink *committee = [[KTCommitteeLink alloc] init];
        [committee setCommitteeDescription:[committeeArr objectAtIndex:0]];
        [committee setUrl:[committeeArr objectAtIndex:1]];
        [committeesArr addObject:committee];
        [committee release];
    }
    return [NSArray arrayWithArray:committeesArr];
}

+ (NSArray *)parseMemberLinksFromTree:(NSArray *)linksTree {
    NSMutableArray *linksArr = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary *linkDict in linksTree) {
        KTLink *link = [[KTLink alloc] init];
        link.linkDescription = [linkDict valueForKey:@"title"];
        link.url = [linkDict valueForKey:@"url"];
        [linksArr addObject:link];
        [link release];
    }
    return [NSArray arrayWithArray:linksArr];
}

+ (NSArray *)parseMembersFromTree:(NSArray *)membersTree {
    
    NSMutableArray *membersArr = [[[NSMutableArray alloc] init] autorelease];
    NSDictionary *members = [membersTree valueForKey:@"objects"];
    for (NSDictionary *memberDict in members) {
        KTMember *member = [[KTMember alloc] init];
        
        id currentRoleDescriptionsStr = [memberDict objectForKey:kParserKeyCurrentRoleDescriptions];
        if (currentRoleDescriptionsStr != [NSNull null]) {
            [member setCurrentRoleDescriptions:currentRoleDescriptionsStr];
        }
        
        id genderStr = [memberDict objectForKey:kParserKeyGender];
        if (genderStr != [NSNull null]) {
            if ([(NSString *)genderStr isEqualToString:kParserKeyGenderMale]) {
                member.gender = kGenderMale;
            } else if ([(NSString *)genderStr isEqualToString:kParserKeyGenderFemale]) {
                member.gender = kGenderFemale;
            }
        }
        
        [member setMemberId:[[memberDict objectForKey:kParserKeyId] intValue]];
        [member setImageUrl:[memberDict objectForKey:kParserKeyImgUrl]];
        [member setIsCurrent:[[memberDict objectForKey:kParserKeyIsCurrent] intValue]];
        [member setName:[memberDict objectForKey:kParserKeyName]];
        [member setParty:[memberDict objectForKey:kParserKeyParty]];
        [member setPlaceOfResidence:[memberDict objectForKey:kParserKeyPlaceOfResidence]];
        
        [member setLinks:[KTParser parseMemberLinksFromTree:[memberDict objectForKey:kParserKeyLinks]]];
        [member setEmail:[memberDict objectForKey:kParserKeyEmail]];
                
        if (member.isCurrent) {
            [membersArr addObject:member];
        }
        [member release];
    }
    return [NSArray arrayWithArray:membersArr];
}

+ (NSArray *)parseBillsFromTree:(NSArray *)billsTree {
    NSDateFormatter *generalDateFormatter = [KTParser generalDateFormatter];
    
    NSMutableArray *billsArr = [[[NSMutableArray alloc] init] autorelease];
    for (NSDictionary *billDict in billsTree) {
        KTBill *bill = [[KTBill alloc] init];

        [bill setBillTitle:[billDict objectForKey:kParserKeyBillBillTitle]];
        [bill setComitteeMeetings:[KTParser parseCommitteeMeetingsFromTree:[billDict objectForKey:kParserKeyBillCommitteeMeetings]]];
        [bill setPopularName:[billDict objectForKey:kParserKeyBillPopularName]];
        [bill setProposingMks:[KTParser parseProposingMKsFromTree:[billDict objectForKey:kParserKeyBillProposingMKs]]];
        
        id stageDateStr = [billDict objectForKey:kParserKeyBillStageDate];
        if (stageDateStr != [NSNull null]) {
            [bill setStageDate:[generalDateFormatter dateFromString:(NSString *)stageDateStr]];
        }
        
        [bill setStageText:[billDict objectForKey:kParserKeyBillStageText]];
        [bill setUrl:[billDict objectForKey:kParserKeyBillStageUrl]];
        [bill setVotes:[KTParser parseVotesFromTree:[billDict objectForKey:kParserKeyVotes]]];
        
        [billsArr addObject:bill];
        [bill release];
    }
    return [NSArray arrayWithArray:billsArr];
}

+ (NSArray *)parsePartiesFromTree:(NSArray *)partiesTree {
    NSDateFormatter *generalDateFormatter = [[NSDateFormatter alloc] init];
    generalDateFormatter.dateFormat = kParserGeneralDateFormat; 
    generalDateFormatter.timeZone = [NSTimeZone timeZoneWithName:kParserGeneralDateTimezoneName];

    NSMutableArray *partiesArr = [[[NSMutableArray alloc] init] autorelease];
    
    NSDictionary *parties = [partiesTree valueForKey:@"objects"];

    for (NSDictionary *partyDict in parties) {
        if ([partyDict isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        KTParty *party = [[KTParty alloc] init];
        
        [party setPartyId:[[partyDict objectForKey:kParserKeyPartyId] intValue]];
        [party setName:[partyDict objectForKey:kParserKeyPartyName]];
        
        id startDateStr = [partyDict objectForKey:kParserKeyPartyStartDate];
        if (startDateStr != [NSNull null]) {
            [party setStartDate:[generalDateFormatter dateFromString:(NSString *)startDateStr]];
        }
        
        id endDateStr = [partyDict objectForKey:kParserKeyPartyEndDate];
        if (endDateStr != [NSNull null]) {
            [party setStartDate:[generalDateFormatter dateFromString:(NSString *)endDateStr]];
        }
        
        [partiesArr addObject:party];
        [party release];
    }
    
    return [NSArray arrayWithArray:partiesArr];
}

@end
