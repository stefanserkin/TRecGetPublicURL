@IsTest
private class PublicUrlBuilder_Test {

    private static final String ENCODING_SCHEME = 'UTF-8';

    @TestSetup
    static void makeData() {
        List<TREX1__Program__c> programs = TestDataFactory.createPrograms(1);
        insert programs;
        List<TREX1__Course__c> courses = TestDataFactory.createCourses(programs, 1);
        insert courses;
        TREX1__Session__c session = TestDataFactory.createSessions(1).get(0);
        insert session;
        List<TREX1__Course_Session__c> courseSessions = TestDataFactory.createCourseSessions(courses, session.Id, 2);
        insert courseSessions;
    }
    
    @IsTest
    static void testGetPublicProgramUrl() {
        TREX1__Program__c program = [SELECT Id, Name FROM TREX1__Program__c LIMIT 1];

        Test.startTest();
        String objectApiName = String.valueOf(program.getSObjectType());
        String url = new PublicUrlBuilder(objectApiName, program.Id).getUrl();
        Test.stopTest();

        External_Site_Setting__mdt siteSetting = PublicUrlBuilder.getSiteSetting();
        String expectedUrl = siteSetting.Site_URL__c + siteSetting.Registration_Page_Path__c + 
            '?' + 'program=' + EncodingUtil.urlEncode(program.Name, ENCODING_SCHEME);

        Assert.areEqual(expectedUrl, url, 'Did not receive the expected url');
    }

    @IsTest
    static void testGetPublicCourseUrl() {
        TREX1__Course__c course = [SELECT Id, Name FROM TREX1__Course__c LIMIT 1];

        Test.startTest();
        String objectApiName = String.valueOf(course.getSObjectType());
        String url = new PublicUrlBuilder(objectApiName, course.Id).getUrl();
        Test.stopTest();

        External_Site_Setting__mdt siteSetting = PublicUrlBuilder.getSiteSetting();
        String expectedUrl = siteSetting.Site_URL__c + siteSetting.Registration_Page_Path__c + 
            '?' + 'course=' + EncodingUtil.urlEncode(course.Name, ENCODING_SCHEME);

        Assert.areEqual(expectedUrl, url, 'Did not receive the expected url');
    }

    @IsTest
    static void testGetPublicCourseSessionUrl() {
        TREX1__Course_Session__c courseSession = [SELECT Id, Name FROM TREX1__Course_Session__c LIMIT 1];

        Test.startTest();
        String objectApiName = String.valueOf(courseSession.getSObjectType());
        String url = new PublicUrlBuilder(objectApiName, courseSession.Id).getUrl();
        Test.stopTest();

        External_Site_Setting__mdt siteSetting = PublicUrlBuilder.getSiteSetting();
        String expectedUrl = siteSetting.Site_URL__c + siteSetting.Registration_Page_Path__c + 
            '?' + 'courseSession=' + EncodingUtil.urlEncode(courseSession.Name, ENCODING_SCHEME);

        Assert.areEqual(expectedUrl, url, 'Did not receive the expected url');
    }

    @IsTest
    static void testGetPublicUrlForUnsupportedObject() {
        String unsupportedObject = 'Account';
        Id fakeAccountId = TestUtility.getFakeId(Account.SObjectType);
        
        Test.startTest();
        try {
            PublicUrlBuilder builder = new PublicUrlBuilder(unsupportedObject, fakeAccountId);
            Assert.fail('Should have received an exception for the unsupported object name');
        } catch (Exception e) {
            Assert.areEqual('PublicUrlBuilder.PublicUrlBuilderException', e.getTypeName(), 'Should have received a PublicUrlBuilderException');
            Assert.areEqual('Unsupported object type: ' + unsupportedObject, e.getMessage(), 'Should have received an exception for the unsupported object type');
        }
        Test.stopTest();
    }

}