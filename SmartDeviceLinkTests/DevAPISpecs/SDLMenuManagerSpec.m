#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import <OCMock/OCMock.h>

#import "SDLAddCommand.h"
#import "SDLAddSubMenu.h"
#import "SDLDeleteCommand.h"
#import "SDLDeleteSubMenu.h"
#import "SDLDisplayCapabilities.h"
#import "SDLDisplayType.h"
#import "SDLFileManager.h"
#import "SDLHMILevel.h"
#import "SDLImage.h"
#import "SDLImageField.h"
#import "SDLImageFieldName.h"
#import "SDLMediaClockFormat.h"
#import "SDLMenuCell.h"
#import "SDLMenuManager.h"
#import "SDLMenuManagerConstants.h"
#import "SDLOnCommand.h"
#import "SDLOnHMIStatus.h"
#import "SDLRegisterAppInterfaceResponse.h"
#import "SDLRPCNotificationNotification.h"
#import "SDLRPCParameterNames.h"
#import "SDLRPCResponseNotification.h"
#import "SDLSetDisplayLayoutResponse.h"
#import "SDLScreenManager.h"
#import "SDLScreenParams.h"
#import "SDLSystemContext.h"
#import "SDLTextField.h"
#import "TestConnectionManager.h"


@interface SDLMenuCell()

@property (assign, nonatomic) UInt32 parentCellId;
@property (assign, nonatomic) UInt32 cellId;

@end

@interface SDLMenuManager()

@property (weak, nonatomic) id<SDLConnectionManagerType> connectionManager;
@property (weak, nonatomic) SDLFileManager *fileManager;

@property (copy, nonatomic, nullable) SDLHMILevel currentHMILevel;
@property (copy, nonatomic, nullable) SDLSystemContext currentSystemContext;
@property (strong, nonatomic, nullable) SDLDisplayCapabilities *displayCapabilities;

@property (strong, nonatomic, nullable) NSArray<SDLRPCRequest *> *inProgressUpdate;
@property (assign, nonatomic) BOOL hasQueuedUpdate;
@property (assign, nonatomic) BOOL waitingOnHMIUpdate;
@property (copy, nonatomic) NSArray<SDLMenuCell *> *waitingUpdateMenuCells;

@property (assign, nonatomic) UInt32 lastMenuId;
@property (copy, nonatomic) NSArray<SDLMenuCell *> *oldMenuCells;

@end

QuickSpecBegin(SDLMenuManagerSpec)

describe(@"menu manager", ^{
    __block SDLMenuManager *testManager = nil;
    __block TestConnectionManager *mockConnectionManager = nil;
    __block SDLFileManager *mockFileManager = nil;
    __block SDLSetDisplayLayoutResponse *testSetDisplayLayoutResponse = nil;
    __block SDLDisplayCapabilities *testDisplayCapabilities = nil;
    __block SDLRegisterAppInterfaceResponse *testRegisterAppInterfaceResponse = nil;
    __block SDLArtwork *testArtwork = nil;
    __block SDLArtwork *testArtwork2 = nil;

    __block SDLMenuCell *textOnlyCell = nil;
    __block SDLMenuCell *textOnlyCell2 = nil;
    __block SDLMenuCell *textAndImageCell = nil;
    __block SDLMenuCell *submenuCell = nil;
    __block SDLMenuCell *submenuImageCell = nil;

    beforeEach(^{
        testArtwork = [[SDLArtwork alloc] initWithData:[@"Test data" dataUsingEncoding:NSUTF8StringEncoding] name:@"some artwork name" fileExtension:@"png" persistent:NO];
        testArtwork2 = [[SDLArtwork alloc] initWithData:[@"Test data 2" dataUsingEncoding:NSUTF8StringEncoding] name:@"some artwork name 2" fileExtension:@"png" persistent:NO];

        textOnlyCell = [[SDLMenuCell alloc] initWithTitle:@"Test 1" icon:nil voiceCommands:nil handler:^(SDLTriggerSource  _Nonnull triggerSource) {}];
        textAndImageCell = [[SDLMenuCell alloc] initWithTitle:@"Test 2" icon:testArtwork voiceCommands:nil handler:^(SDLTriggerSource  _Nonnull triggerSource) {}];
        submenuCell = [[SDLMenuCell alloc] initWithTitle:@"Test 3" icon:nil subCells:@[textOnlyCell, textAndImageCell]];
        submenuImageCell = [[SDLMenuCell alloc] initWithTitle:@"Test 4" icon:testArtwork2 subCells:@[textOnlyCell]];
        textOnlyCell2 = [[SDLMenuCell alloc] initWithTitle:@"Test 5" icon:nil voiceCommands:nil handler:^(SDLTriggerSource  _Nonnull triggerSource) {}];


        mockConnectionManager = [[TestConnectionManager alloc] init];
        mockFileManager = OCMClassMock([SDLFileManager class]);
        testManager = [[SDLMenuManager alloc] initWithConnectionManager:mockConnectionManager fileManager:mockFileManager];
    });

    it(@"should instantiate correctly", ^{
        expect(testManager.menuCells).to(beEmpty());
        expect(testManager.connectionManager).to(equal(mockConnectionManager));
        expect(testManager.fileManager).to(equal(mockFileManager));
        expect(testManager.currentHMILevel).to(beNil());
        expect(testManager.displayCapabilities).to(beNil());
        expect(testManager.inProgressUpdate).to(beNil());
        expect(testManager.hasQueuedUpdate).to(beFalse());
        expect(testManager.waitingOnHMIUpdate).to(beFalse());
        expect(testManager.lastMenuId).to(equal(1));
        expect(testManager.oldMenuCells).to(beEmpty());
        expect(testManager.waitingUpdateMenuCells).to(beNil());
    });

    describe(@"updating menu cells before HMI is ready", ^{
        context(@"when in HMI NONE", ^{
            beforeEach(^{
                testManager.currentHMILevel = SDLHMILevelNone;
                testManager.menuCells = @[textOnlyCell];
            });

            it(@"should not update", ^{
                expect(mockConnectionManager.receivedRequests).to(beEmpty());
            });

            describe(@"when entering the foreground", ^{
                beforeEach(^{
                    SDLOnHMIStatus *onHMIStatus = [[SDLOnHMIStatus alloc] init];
                    onHMIStatus.hmiLevel = SDLHMILevelFull;
                    onHMIStatus.systemContext = SDLSystemContextMain;

                    SDLRPCNotificationNotification *testSystemContextNotification = [[SDLRPCNotificationNotification alloc] initWithName:SDLDidChangeHMIStatusNotification object:nil rpcNotification:onHMIStatus];
                    [[NSNotificationCenter defaultCenter] postNotification:testSystemContextNotification];
                });

                it(@"should update", ^{
                    expect(mockConnectionManager.receivedRequests).toNot(beEmpty());
                });
            });
        });

        context(@"when no HMI level has been received", ^{
            beforeEach(^{
                testManager.currentHMILevel = nil;
                testManager.menuCells = @[textOnlyCell];
            });

            it(@"should not update", ^{
                expect(mockConnectionManager.receivedRequests).to(beEmpty());
            });
        });

        context(@"when in the menu", ^{
            beforeEach(^{
                testManager.currentHMILevel = SDLHMILevelFull;
                testManager.currentSystemContext = SDLSystemContextMenu;
                testManager.menuCells = @[textOnlyCell];
            });

            it(@"should not update", ^{
                expect(mockConnectionManager.receivedRequests).to(beEmpty());
            });

            describe(@"when exiting the menu", ^{
                beforeEach(^{
                    SDLOnHMIStatus *onHMIStatus = [[SDLOnHMIStatus alloc] init];
                    onHMIStatus.hmiLevel = SDLHMILevelFull;
                    onHMIStatus.systemContext = SDLSystemContextMain;

                    SDLRPCNotificationNotification *testSystemContextNotification = [[SDLRPCNotificationNotification alloc] initWithName:SDLDidChangeHMIStatusNotification object:nil rpcNotification:onHMIStatus];
                    [[NSNotificationCenter defaultCenter] postNotification:testSystemContextNotification];
                });

                it(@"should update", ^{
                    expect(mockConnectionManager.receivedRequests).toNot(beEmpty());
                });
            });
        });
    });

    describe(@"Notificaiton Responses", ^{
        it(@"should set display capabilities when SDLDidReceiveSetDisplayLayoutResponse is received", ^{
            testDisplayCapabilities = [[SDLDisplayCapabilities alloc] init];

            testSetDisplayLayoutResponse = [[SDLSetDisplayLayoutResponse alloc] init];
            testSetDisplayLayoutResponse.success = @YES;
            testSetDisplayLayoutResponse.displayCapabilities = testDisplayCapabilities;

            SDLRPCResponseNotification *notification = [[SDLRPCResponseNotification alloc] initWithName:SDLDidReceiveRegisterAppInterfaceResponse object:self rpcResponse:testSetDisplayLayoutResponse];
            [[NSNotificationCenter defaultCenter] postNotification:notification];

            expect(testManager.displayCapabilities).to(equal(testDisplayCapabilities));
        });

        it(@"should set display capabilities when SDLDidReceiveRegisterAppInterfaceResponse is received", ^{
            testDisplayCapabilities = [[SDLDisplayCapabilities alloc] init];

            testRegisterAppInterfaceResponse = [[SDLRegisterAppInterfaceResponse alloc] init];
            testRegisterAppInterfaceResponse.success = @YES;
            testRegisterAppInterfaceResponse.displayCapabilities = testDisplayCapabilities;

            SDLRPCResponseNotification *notification = [[SDLRPCResponseNotification alloc] initWithName:SDLDidReceiveSetDisplayLayoutResponse object:self rpcResponse:testRegisterAppInterfaceResponse];
            [[NSNotificationCenter defaultCenter] postNotification:notification];

            expect(testManager.displayCapabilities).to(equal(testDisplayCapabilities));
        });
    });

    describe(@"updating menu cells", ^{
        beforeEach(^{
            testManager.currentHMILevel = SDLHMILevelFull;
            testManager.currentSystemContext = SDLSystemContextMain;

            testManager.displayCapabilities = [[SDLDisplayCapabilities alloc] init];
            SDLImageField *commandIconField = [[SDLImageField alloc] init];
            commandIconField.name = SDLImageFieldNameCommandIcon;
            testManager.displayCapabilities.imageFields = @[commandIconField];
            testManager.displayCapabilities.graphicSupported = @YES;
        });

        context(@"duplicate titles", ^{
            it(@"should fail with a duplicate title", ^{
                testManager.menuCells = @[textOnlyCell, textOnlyCell];
                expect(testManager.menuCells).to(beEmpty());
            });
        });

        context(@"duplicate VR commands", ^{
            __block SDLMenuCell *textAndVRCell1 = [[SDLMenuCell alloc] initWithTitle:@"Test 1" icon:nil voiceCommands:@[@"Cat", @"Turtle"] handler:^(SDLTriggerSource  _Nonnull triggerSource) {}];
            __block SDLMenuCell *textAndVRCell2 = [[SDLMenuCell alloc] initWithTitle:@"Test 3" icon:nil voiceCommands:@[@"Cat", @"Dog"] handler:^(SDLTriggerSource  _Nonnull triggerSource) {}];

            it(@"should fail when menu items have duplicate vr commands", ^{
                testManager.menuCells = @[textAndVRCell1, textAndVRCell2];
                expect(testManager.menuCells).to(beEmpty());
            });
        });

        it(@"should properly update a text cell", ^{
            testManager.menuCells = @[textOnlyCell];

            NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLDeleteCommand class]];
            NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];
            expect(deletes).to(beEmpty());

            NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddCommand class]];
            NSArray *add = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];
            expect(add).toNot(beEmpty());
        });

        it(@"should properly update with subcells", ^{
            OCMStub([mockFileManager uploadArtworks:[OCMArg any] completionHandler:[OCMArg invokeBlock]]);
            testManager.menuCells = @[submenuCell];
            [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

            NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddCommand class]];
            NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

            NSPredicate *submenuCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
            NSArray *submenus = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:submenuCommandPredicate];

            expect(adds).to(haveCount(2));
            expect(submenus).to(haveCount(1));
        });

        describe(@"updating with an image", ^{
            context(@"when the image is already on the head unit", ^{
                beforeEach(^{
                    OCMStub([mockFileManager hasUploadedFile:[OCMArg isNotNil]]).andReturn(YES);
                });

                it(@"should properly update an image cell", ^{
                    testManager.menuCells = @[textAndImageCell, submenuImageCell];

                    NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddCommand class]];
                    NSArray *add = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];
                    SDLAddCommand *sentCommand = add.firstObject;

                    NSPredicate *addSubmenuPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
                    NSArray *submenu = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addSubmenuPredicate];
                    SDLAddSubMenu *sentSubmenu = submenu.firstObject;

                    expect(add).to(haveCount(1));
                    expect(submenu).to(haveCount(1));
                    expect(sentCommand.cmdIcon.value).to(equal(testArtwork.name));
                    expect(sentSubmenu.menuIcon.value).to(equal(testArtwork2.name));
                });
            });

            // No longer a valid unit test
            context(@"when the image is not on the head unit", ^{
                beforeEach(^{
                    testManager.dynamicMenuUpdatesMode = SDLDynamicMenuUpdatesModeForceOff;
                    OCMStub([mockFileManager uploadArtworks:[OCMArg any] completionHandler:[OCMArg invokeBlock]]);
                });

                it(@"should wait till image is on head unit and attempt to update without the image", ^{
                    testManager.menuCells = @[textAndImageCell, submenuImageCell];
                    
                    NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddCommand class]];
                    NSArray *add = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];
                    SDLAddCommand *sentCommand = add.firstObject;

                    NSPredicate *addSubmenuPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
                    NSArray *submenu = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addSubmenuPredicate];
                    SDLAddSubMenu *sentSubmenu = submenu.firstObject;

                    expect(add).to(haveCount(1));
                    expect(submenu).to(haveCount(1));
                    expect(sentCommand.cmdIcon.value).to(beNil());
                    expect(sentSubmenu.menuIcon.value).to(beNil());
                });
            });
        });

        describe(@"updating when a menu already exists with dynamic updates on", ^{
            beforeEach(^{
                testManager.dynamicMenuUpdatesMode = SDLDynamicMenuUpdatesModeForceOn;
                OCMStub([mockFileManager uploadArtworks:[OCMArg any] completionHandler:[OCMArg invokeBlock]]);
            });
            
            it(@"should send deletes first", ^{
                testManager.menuCells = @[textOnlyCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textAndImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                expect(deletes).to(haveCount(1));
                expect(adds).to(haveCount(2));
            });

            it(@"should send dynamic deletes first then dynamic adds case with 2 submenu cells", ^{
                testManager.menuCells = @[textOnlyCell, submenuCell, submenuImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[submenuCell, submenuImageCell, textOnlyCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                NSPredicate *addSubmenuPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
                NSArray *submenu = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addSubmenuPredicate];

                expect(deletes).to(haveCount(1));
                expect(adds).to(haveCount(5));
                expect(submenu).to(haveCount(2));
            });

            it(@"should send dynamic deletes first then dynamic adds when removing one submenu cell", ^{
                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell, submenuImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *deleteSubCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteSubMenu class]];
                NSArray *subDeletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteSubCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                NSPredicate *addSubmenuPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
                NSArray *submenu = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addSubmenuPredicate];

                expect(deletes).to(haveCount(0));
                expect(subDeletes).to(haveCount(1));
                expect(adds).to(haveCount(5));
                expect(submenu).to(haveCount(2));
            });

            it(@"should send dynamic deletes first then dynamic adds when adding one new cell", ^{
                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell, submenuImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell, submenuImageCell, textOnlyCell2];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                
                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                NSPredicate *addSubmenuPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
                NSArray *submenu = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addSubmenuPredicate];

                expect(deletes).to(haveCount(0));
                expect(adds).to(haveCount(6));
                expect(submenu).to(haveCount(2));
            });

            it(@"should send dynamic deletes first then dynamic adds when cells stay the same", ^{
                testManager.menuCells = @[textOnlyCell, textOnlyCell2, textAndImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textOnlyCell, textOnlyCell2, textAndImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                expect(deletes).to(haveCount(0));
                expect(adds).to(haveCount(3));
            });
        });

        describe(@"updating when a menu already exists with dynamic updates off", ^{
            beforeEach(^{
                 testManager.dynamicMenuUpdatesMode = SDLDynamicMenuUpdatesModeForceOff;
                 OCMStub([mockFileManager uploadArtworks:[OCMArg any] completionHandler:[OCMArg invokeBlock]]);
            });

            it(@"should send deletes first", ^{
                testManager.menuCells = @[textOnlyCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textAndImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                expect(deletes).to(haveCount(1));
                expect(adds).to(haveCount(2));
            });

            it(@"should deletes first case 2", ^{
                testManager.menuCells = @[textOnlyCell, textAndImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textAndImageCell, textOnlyCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                expect(deletes).to(haveCount(2));
                expect(adds).to(haveCount(4));
            });

            it(@"should send deletes first case 3", ^{
                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell, submenuImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *deleteSubCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteSubMenu class]];
                NSArray *subDeletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteSubCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                NSPredicate *addSubmenuPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
                NSArray *submenu = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addSubmenuPredicate];

                expect(deletes).to(haveCount(2));
                expect(subDeletes).to(haveCount(2));
                expect(adds).to(haveCount(9));
                expect(submenu).to(haveCount(3));
            });

            it(@"should send deletes first case 4", ^{
                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textOnlyCell, textAndImageCell, submenuCell, textOnlyCell2];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];


                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                NSPredicate *addSubmenuPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass: %@", [SDLAddSubMenu class]];
                NSArray *submenu = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addSubmenuPredicate];

                NSPredicate *deleteSubCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteSubMenu class]];
                NSArray *subDeletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteSubCommandPredicate];

                expect(deletes).to(haveCount(2));
                expect(adds).to(haveCount(9));
                expect(submenu).to(haveCount(2));
                expect(subDeletes).to(haveCount(1));
            });

            it(@"should deletes first case 5", ^{
                testManager.menuCells = @[textOnlyCell, textOnlyCell2, textAndImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                testManager.menuCells = @[textOnlyCell, textOnlyCell2, textAndImageCell];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];
                [mockConnectionManager respondToLastMultipleRequestsWithSuccess:YES];

                NSPredicate *deleteCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLDeleteCommand class]];
                NSArray *deletes = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:deleteCommandPredicate];

                NSPredicate *addCommandPredicate = [NSPredicate predicateWithFormat:@"self isMemberOfClass:%@", [SDLAddCommand class]];
                NSArray *adds = [[mockConnectionManager.receivedRequests copy] filteredArrayUsingPredicate:addCommandPredicate];

                expect(deletes).to(haveCount(3));
                expect(adds).to(haveCount(6));
            });
        });
    });

    describe(@"running menu cell handlers", ^{
        __block SDLMenuCell *cellWithHandler = nil;
        __block BOOL cellCalled = NO;
        __block SDLTriggerSource testTriggerSource = nil;

        beforeEach(^{
            testManager.currentHMILevel = SDLHMILevelFull;
            testManager.currentSystemContext = SDLSystemContextMain;

            testManager.displayCapabilities = [[SDLDisplayCapabilities alloc] init];
            SDLImageField *commandIconField = [[SDLImageField alloc] init];
            commandIconField.name = SDLImageFieldNameCommandIcon;
            testManager.displayCapabilities.imageFields = @[commandIconField];
            testManager.displayCapabilities.graphicSupported = @YES;

            cellCalled = NO;
            testTriggerSource = nil;
        });

        context(@"on a main menu cell", ^{
            beforeEach(^{
                cellWithHandler = [[SDLMenuCell alloc] initWithTitle:@"Hello" icon:nil voiceCommands:nil handler:^(SDLTriggerSource  _Nonnull triggerSource) {
                    cellCalled = YES;
                    testTriggerSource = triggerSource;
                }];

                testManager.menuCells = @[cellWithHandler];
            });

            it(@"should call the cell handler", ^{
                SDLOnCommand *onCommand = [[SDLOnCommand alloc] init];
                onCommand.cmdID = @1;
                onCommand.triggerSource = SDLTriggerSourceMenu;

                SDLRPCNotificationNotification *notification = [[SDLRPCNotificationNotification alloc] initWithName:SDLDidReceiveCommandNotification object:nil rpcNotification:onCommand];
                [[NSNotificationCenter defaultCenter] postNotification:notification];

                expect(cellCalled).to(beTrue());
                expect(testTriggerSource).to(equal(SDLTriggerSourceMenu));
            });
        });

        context(@"on a submenu menu cell", ^{
            beforeEach(^{
                cellWithHandler = [[SDLMenuCell alloc] initWithTitle:@"Hello" icon:nil voiceCommands:nil handler:^(SDLTriggerSource  _Nonnull triggerSource) {
                    cellCalled = YES;
                    testTriggerSource = triggerSource;
                }];

                SDLMenuCell *submenuCell = [[SDLMenuCell alloc] initWithTitle:@"Submenu" icon:nil subCells:@[cellWithHandler]];

                testManager.menuCells = @[submenuCell];
            });

            it(@"should call the cell handler", ^{
                SDLOnCommand *onCommand = [[SDLOnCommand alloc] init];
                onCommand.cmdID = @2;
                onCommand.triggerSource = SDLTriggerSourceMenu;

                SDLRPCNotificationNotification *notification = [[SDLRPCNotificationNotification alloc] initWithName:SDLDidReceiveCommandNotification object:nil rpcNotification:onCommand];
                [[NSNotificationCenter defaultCenter] postNotification:notification];

                expect(cellCalled).to(beTrue());
                expect(testTriggerSource).to(equal(SDLTriggerSourceMenu));
            });
        });
    });

    context(@"On disconnects", ^{
        beforeEach(^{
            [testManager stop];
        });

        it(@"should reset correctly", ^{
            expect(testManager.connectionManager).to(equal(mockConnectionManager));
            expect(testManager.fileManager).to(equal(mockFileManager));

            expect(testManager.menuCells).to(beEmpty());
            expect(testManager.currentHMILevel).to(beNil());
            expect(testManager.displayCapabilities).to(beNil());
            expect(testManager.inProgressUpdate).to(beNil());
            expect(testManager.hasQueuedUpdate).to(beFalse());
            expect(testManager.waitingOnHMIUpdate).to(beFalse());
            expect(testManager.lastMenuId).to(equal(1));
            expect(testManager.oldMenuCells).to(beEmpty());
            expect(testManager.waitingUpdateMenuCells).to(beEmpty());
        });
    });

    afterEach(^{
        testManager = nil;
    });
});

QuickSpecEnd
