public with sharing class FlowTRecPublicUrlBuilder {

    @InvocableMethod()
    public static List<Request> getPublicUrl() {

    }

    public class Request {
        @InvocableVariable(required=true)
        public SObject sObjectType;
    }

    public class Result {}
}