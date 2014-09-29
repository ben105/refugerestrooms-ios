//
//  RestroomCreationTests.m
//  RRiOSApp
//
//  Created by Harlan Kellaway on 9/29/14.
//  Copyright (c) 2014 ___REFUGERESTROOMS___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MockRestroomManagerDelegate.h"
#import "MockRestroomCommunicator.h"
#import "MockRestroomBuilder.h"

#import "RestroomManager.h"

@interface RestroomCreationTests : XCTestCase

@end

@implementation RestroomCreationTests
{
    RestroomManager *restroomManager;

    MockRestroomManagerDelegate *delegate;
    NSError *underlyingError;
    MockRestroomBuilder *restroomBuilder;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    restroomManager = [[RestroomManager alloc] init];
    
    delegate = [[MockRestroomManagerDelegate alloc] init];
    restroomManager.delegate = delegate;
    
    underlyingError = [NSError errorWithDomain:@"Test domain" code:0 userInfo:nil];
    
    restroomBuilder = [[MockRestroomBuilder alloc] init];
    restroomBuilder.arrayToReturn = nil;
    restroomBuilder.errorToSet = underlyingError;
    
    restroomManager.restroomBuilder = restroomBuilder;
    
    [restroomManager recievedRestroomsJSON:@"Fake JSON"];
}

- (void)tearDown
{
    restroomManager = nil;
    delegate = nil;
    underlyingError = nil;
    restroomManager.restroomBuilder = nil;
    
    [super tearDown];
}

- (void)testThatARestroomManagerCanBeCreated
{
    XCTAssertNotNil(restroomManager, @"Should be able to create a RestroomManager instance.");
}

- (void)testNonConformingObjectCannotBeDelegate
{
    XCTAssertThrows(restroomManager.delegate = (id <RestroomManagerDelegate>)[NSNull null], @"NSNull should not be used as the delegate as it doesn't conform to the delegate protocol.");
}

- (void)testConformingObjectCanBeDelegate
{
    id <RestroomManagerDelegate> delegate = [[MockRestroomManagerDelegate alloc] init];
    
    XCTAssertNoThrow(restroomManager.delegate = delegate, @"Object conforming to the delegate protocol should be used as the delegate.");
}

- (void)testManagerAcceptsNilAsDelegate
{
    XCTAssertNoThrow(restroomManager.delegate = nil, @"It should be acceptable to use nil as an object's delegate.");
}

- (void)testSearchingForRestroomMeansReqestingData
{
    MockRestroomCommunicator *communicator = [[MockRestroomCommunicator alloc] init];
    
    NSString *query = @"Target";
    
    restroomManager.communicator = communicator;
    [restroomManager fetchRestroomsForQuery:query];
    
    XCTAssertTrue([communicator wasAskedToFetchRestrooms], @"The communicator should need to fetch data.");
}

// don't report underlying error to delegate for user to see
- (void)testErrorReturnedToDelegateIsNotSameErrorNotifiedByCommunicator
{
    [restroomManager searchingForRestroomFailedWithError:underlyingError];
    
    XCTAssertFalse(underlyingError == [delegate fetchError], @"Error should be at the correct level of abstraction.");
}

// we still want to document error for admins
- (void)testErrorReturnedToDelegateDocumentsUnderlyingError
{
    [restroomManager searchingForRestroomFailedWithError: underlyingError];
    
    XCTAssertEqualObjects([[[delegate fetchError] userInfo] objectForKey: NSUnderlyingErrorKey], underlyingError, @"The underlying should be available to client code.");
}

- (void)testRestroomJSONIsPassedToRestroomBuilder
{
    XCTAssertEqualObjects(restroomBuilder.JSON, @"Fake JSON", @"Downloaded JSON should be sent to RestroomBuilder.");
}

- (void)testDelegateNotifiedOfErrorWhenRestroomBuilderFails
{
    XCTAssertNotNil(@"The delegate should have found out about the error created when RestroomBuilder fails.");
}

// TODO: Implement this test
- (void)testRestroomCreatedFromSearchHasSearchRankSet
{
    XCTAssert(YES, @"Pass");
}

@end