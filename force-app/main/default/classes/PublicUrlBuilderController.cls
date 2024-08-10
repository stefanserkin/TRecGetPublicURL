public with sharing class PublicUrlBuilderController {
    
    @AuraEnabled(cacheable=true)
    public static String getPublicUrl(String objApiName, String recordId) {
        try {
            System.debug('::::: called get public url with object --> ' + objApiName);
            System.debug('::::: called get public url with recordId --> ' + recordId);
            return new PublicUrlBuilder(objApiName, recordId).getUrl();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}