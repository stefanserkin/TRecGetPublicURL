/***********************************************
 * @description Builds a base url for the Rec Web Reg app
 * @date 2024
 * @see https://quip.com/OVnCA8kl62Qq/Public-URL-Builder 
 *      https://success.tractionrec.com/s/article/Web-Registration-URL-Parameters
 ***********************************************/
public with sharing class PublicUrlBuilder {

    private static final String SITE_SETTING_NAME = 'Default';
    private static final String ENCODING_SCHEME = 'UTF-8';
    private static final String NAME_FIELD = 'Name';

    @TestVisible 
    private static final String OBJECT_NOT_SUPPORTED_EXCEPTION = 'Unsupported object type: ';
    @TestVisible 
    private static final String RECORD_NOT_FOUND_EXCEPTION = 'Record not found for Record Id: ';

    private static Map<String, String> objectFilterMap = new Map<String, String>{
        'TREX1__Program__c' => 'program',
        'TREX1__Course__c' => 'course',
        'TREX1__Course_Session__c' => 'courseSession'
    };

    private static External_Site_Setting__mdt siteSetting;

    private String objectApiName;
    private String recordId;

    public PublicUrlBuilder(String objectApiName, String recordId) {
        if (!isSupportedObject(objectApiName)) {
            throw new PublicUrlBuilderException(OBJECT_NOT_SUPPORTED_EXCEPTION + objectApiName);
        }
        this.objectApiName = objectApiName;
        this.recordId = recordId;
    }

    public static Boolean isSupportedObject(String objectApiName) {
        return objectFilterMap.containsKey(objectApiName);
    }

    public String getUrl() {
        return this.getBaseUrl() + '?' + this.getRecordFilter();
    }

    private String getBaseUrl() {
        External_Site_Setting__mdt settings = getSiteSetting();
        return settings.Site_URL__c + settings.Registration_Page_Path__c;
    }

    public static External_Site_Setting__mdt getSiteSetting() {
        if (siteSetting == null) {
            siteSetting = External_Site_Setting__mdt.getInstance(SITE_SETTING_NAME);
        }
        return siteSetting;
    }

    private String getRecordFilter() {
        String objectFilter = objectFilterMap.get(this.objectApiName);
        String recordName = getEncodedString( this.getRecordName() );
        return objectFilter + '=' + recordName;
    }

    private static String getEncodedString(String s) {
        return EncodingUtil.urlEncode(s, ENCODING_SCHEME);
    }

    private String getRecordName() {
        String recordName = (String) this.getRecord().get(NAME_FIELD);
        return recordName;
    }

    private sObject getRecord() {
        List<sObject> records = Database.query( this.constructQuery() );
        if (records.isEmpty()) {
            throw new PublicUrlBuilderException(RECORD_NOT_FOUND_EXCEPTION + this.recordId);
        }
        return records[0];
    }

    private String constructQuery() {
        String query = 'SELECT ' + NAME_FIELD + ' FROM ' + String.escapeSingleQuotes(this.objectApiName) + 
            ' WHERE Id = \'' + String.escapeSingleQuotes(this.recordId) + '\' LIMIT 1';
        return query;
    }

    private class PublicUrlBuilderException extends Exception {}

}