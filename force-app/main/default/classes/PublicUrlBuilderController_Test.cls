@IsTest
private class PublicUrlBuilderController_Test {

    private static final String ENCODING_SCHEME = 'UTF-8';
    private static final String SESSION_STATUS_AVAILABLE = 'Available';
    private static final String SESSION_STATUS_DRAFT = 'Draft';

    @TestSetup
    static void makeData() {
        List<TREX1__Program__c> programs = TestDataFactory.createPrograms(1);
        insert programs;

        List<TREX1__Session__c> sessions = TestDataFactory.createSessions(2);
        sessions[0].TREX1__Status__c = SESSION_STATUS_AVAILABLE;
        sessions[1].TREX1__Status__c = SESSION_STATUS_DRAFT;
        insert sessions;
    }

    @IsTest
    static void testGetPublicUrl() {
        TREX1__Program__c program = [SELECT Id, Name FROM TREX1__Program__c LIMIT 1];

        Test.startTest();
        String objectApiName = String.valueOf(program.getSObjectType());
        String programUrl = PublicUrlBuilderController.getPublicUrl(objectApiName, program.Id);
        Test.stopTest();

        External_Site_Setting__mdt siteSetting = PublicUrlBuilder.getSiteSetting();
        String expectedUrl = siteSetting.Site_URL__c + siteSetting.Registration_Page_Path__c + 
            '?' + 'program=' + EncodingUtil.urlEncode(program.Name, ENCODING_SCHEME);

        Assert.areEqual(expectedUrl, programUrl, 'Did not receive the expected url');
    }

    @IsTest
    static void testGetPublicUrlWithException() {
        String fakeObjName = 'notarealthing';
        TREX1__Program__c program = [SELECT Id, Name FROM TREX1__Program__c LIMIT 1];
        
        Test.startTest();
        try {
            String programUrl = PublicUrlBuilderController.getPublicUrl(fakeObjName, program.Id);
            Assert.fail('Should have received an exception for the fake object name');
        } catch (Exception e) {
            Assert.areEqual('System.AuraHandledException', e.getTypeName(), 'Should have received an aura handled exception');
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Should have received an aura handled exception');
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetSessions() {
        TREX1__Session__c availableSession = [
            SELECT Id, TREX1__Status__c 
              FROM TREX1__Session__c 
             WHERE TREX1__Status__c = :SESSION_STATUS_AVAILABLE 
             LIMIT 1
        ];

        Test.startTest();
        List<TREX1__Session__c> returnedSessions = PublicUrlBuilderController.getAvailableSessions();
        Test.stopTest();

        Assert.isTrue(returnedSessions.size() == 1, 'Should have received only the active session');
        Assert.areEqual(availableSession.Id, returnedSessions[0].Id, 'Should have received the active session id');
    }

    @IsTest
    static void testNoAvailableSessions() {
        TREX1__Session__c availableSession = [
            SELECT Id, TREX1__Status__c 
              FROM TREX1__Session__c 
             WHERE TREX1__Status__c = :SESSION_STATUS_AVAILABLE 
             LIMIT 1
        ];
        availableSession.TREX1__Status__c = SESSION_STATUS_DRAFT;
        update availableSession;

        Test.startTest();
        List<TREX1__Session__c> returnedSessions = PublicUrlBuilderController.getAvailableSessions();
        Test.stopTest();

        Assert.isTrue(returnedSessions.isEmpty(), 'Should have received an empty list');
    }
    
}