/***********************************************
 * @description Builds a base url for the Rec Web Reg app
 * @date 2024
 * @see https://quip.com/OVnCA8kl62Qq/Public-URL-Builder 
 *      https://success.tractionrec.com/s/article/Web-Registration-URL-Parameters
 ***********************************************/
public with sharing class PublicUrlBuilder {

    private static final String SITE_SETTING_NAME = 'Default';
    private static final String ENCODING_SCHEME = 'UTF-8';
    private static final String OBJECT_PROGRAM = 'TREX1__Program__c';
    private static final String OBJECT_COURSE = 'TREX1__Course__c';
    private static final String OBJECT_COURSE_SESSION = 'TREX1__Course_Session__c';

    private static Map<String, String> objectFilterMap = new Map<String, String>{
        OBJECT_PROGRAM => 'program',
        OBJECT_COURSE => 'course',
        OBJECT_COURSE_SESSION => 'courseSession'
    };

    private static External_Site_Setting__mdt siteSetting;

    private String objectApiName;
    private String recordId;

    public PublicUrlBuilder(String objectApiName, String recordId) {
        if (!isSupportedObject(objectApiName)) {
            throw new PublicUrlBuilderException('Unsupported object type: ' + objectApiName);
        }
        this.objectApiName = objectApiName;
        this.recordId = recordId;
    }

    public static Boolean isSupportedObject(String objectApiName) {
        return objectFilterMap.containsKey(objectApiName);
    }

    public String getUrl() {
        String url = getSiteSetting().Site_URL__c + getSiteSetting().Registration_Page_Path__c;
        return hasFilters() ? url + '?' + getRecordFilter() : url;
    }

    public static External_Site_Setting__mdt getSiteSetting() {
        if (siteSetting == null) {
            siteSetting = External_Site_Setting__mdt.getInstance(SITE_SETTING_NAME);
        }
        return siteSetting;
    }

    private Boolean hasFilters() {
        Boolean filterHas = this.objectApiName != null && this.recordId != null;
        return this.objectApiName != null && this.recordId != null;
    }

    private String getRecordFilter() {
        String objectFilter = objectFilterMap.get(this.objectApiName);
        String recordName = getEncodedString( getRecordName() );
        return objectFilter + '=' + recordName;
    }

    private String getRecordName() {
        String recordName = (String) getRecord().get('Name');
        return recordName;
    }

    private sObject getRecord() {
        List<sObject> records;
        String query = 'SELECT Name FROM ' + String.escapeSingleQuotes(this.objectApiName) + 
            ' WHERE Id = \'' + String.escapeSingleQuotes(this.recordId) + '\' LIMIT 1';
        try {
            records = Database.query(query);
        } catch (Exception e) {
            throw new PublicUrlBuilderException(e.getMessage());
        }
        return records[0];
    }

    private String getEncodedString(String s) {
        return EncodingUtil.urlEncode(s, ENCODING_SCHEME);
    }

    private class PublicUrlBuilderException extends Exception {}

}