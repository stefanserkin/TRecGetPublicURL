/***********************************************
 * @date 2024
 ***********************************************/
public with sharing class PublicUrlBuilderController {

    private static final String SESSION_STATUS_AVAILABLE = 'Available';
    
    @AuraEnabled(cacheable=true)
    public static String getPublicUrl(String objApiName, String recordId) {
        try {
            return new PublicUrlBuilder(objApiName, recordId).getUrl();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TREX1__Session__c> getAvailableSessions() {
        return [
            SELECT Id, Name 
              FROM TREX1__Session__c
             WHERE TREX1__Status__c = :SESSION_STATUS_AVAILABLE
              WITH USER_MODE
             ORDER BY TREX1__Start_Date__c DESC
             LIMIT 10000
        ];
    }

}