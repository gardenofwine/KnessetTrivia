//
//  KTParty.h
//  KnessetTrivia
//
//  Created by Stav Ashuri on 5/13/12.
//

#import <Foundation/Foundation.h>

@interface KTParty : NSObject {
    int partyId;
    NSString *name;
    NSDate *endDate;
    NSDate *startDate;
}

@property (assign) int partyId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *startDate;

@end
