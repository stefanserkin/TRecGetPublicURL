public with sharing class PublicUrlBuilder {

    private static final String SITE_SETTING_NAME = 'Default';
    private static final String REGISTRATION_PAGE_URL = '/s/registration';
    private static final String OBJECT_PROGRAM = 'TREX1__Program__c';
    private static final String OBJECT_COURSE = 'TREX1__Course__c';
    private static final String OBJECT_COURSE_SESSION = 'TREX1__Course_Session__c';
    private static final String ENCODING_SCHEME = 'UTF-8';

    private static External_Site_Setting__mdt siteSetting;

    private String objectApiName;
    private String recordId;

    public PublicUrlBuilder(String objectApiName, String recordId) {
        System.debug('::::: obj --> ' + objectApiName);
        System.debug('::::: recId --> ' + recordId);
        this.objectApiName = objectApiName;
        this.recordId = recordId;
    }

    public String getUrl() {
        String url = getSiteSetting().Site_URL__c + REGISTRATION_PAGE_URL;
        System.debug(':::: base url --> ' + url);
        return hasFilters() ? url + '?' + getRecordFilter() : url;
    }

    private Boolean hasFilters() {
        Boolean filterHas = this.objectApiName != null && this.recordId != null;
        System.debug('::::: has filters? --> ' + filterHas);
        return this.objectApiName != null && this.recordId != null;
    }

    private static External_Site_Setting__mdt getSiteSetting() {
        if (siteSetting == null) {
            siteSetting = External_Site_Setting__mdt.getInstance(SITE_SETTING_NAME);
        }
        System.debug(':::: siteSetting --> ' + siteSetting);
        return siteSetting;
    }

    private String getRecordFilter() {
        String filter = '';
        String recordName = getEncodedString( getRecordName() );
        if (this.objectApiName == OBJECT_PROGRAM) {
            filter += 'program=' + recordName;
        } else if (this.objectApiName == OBJECT_COURSE) {
            filter += 'course=' + recordName;
        } else if (this.objectApiName == OBJECT_COURSE_SESSION) {
            filter += 'courseSession=' + recordName;
        }
        System.debug(':::: filter --> ' + filter);
        return filter;
    }

    private String getRecordName() {
        String query = 'SELECT Name FROM ' + String.escapeSingleQuotes(this.objectApiName) + 
            ' WHERE Id = \'' + String.escapeSingleQuotes(this.recordId) + '\' LIMIT 1';
        List<sObject> records = Database.query(query);
        String recordName = (String) records[0].get('Name');
        return recordName;
    }

    private String getEncodedString(String s) {
        return EncodingUtil.urlEncode(s, ENCODING_SCHEME);
    }

}