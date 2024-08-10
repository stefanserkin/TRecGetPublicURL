public with sharing class PublicUrlBuilderController {
    
    @AuraEnabled(cacheable=true)
    public static String getPublicUrl(String objApiName, String recordId) {
        try {
            return new PublicUrlBuilder(objApiName, recordId).getUrl();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}