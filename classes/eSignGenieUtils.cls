public with sharing class eSignGenieUtils {
    public static String sendESignGenieReqst(String url,String methodType, String payload){
        eSignGenieConfiguration__c eSignGenieConfigObj = eSignGenieConfiguration__c.getInstance('Configuration');
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String responseBody;
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + eSignGenieConfigObj.Access_Token__c);
        req.setMethod(methodType);
        system.debug('URL is ::::::'+eSignGenieConfigObj.eSign_Genie_Api_URL__c + url);
        req.setEndpoint(eSignGenieConfigObj.eSign_Genie_Api_URL__c+url);
        if(payload != null && payload != ''){
            req.setBody(payload);
            system.debug('Request Payload Is ::::::'+ payload);
        }
        try{
            req.setTimeout(120000);
            res = http.send(req);
            responseBody = res.getBody();
            system.debug('RESPONSE IS :::::::' + responseBody);
        } 
        catch (Exception e) {
            ESignGenie_Log__c logObj = new ESignGenie_Log__c();
            logobj.API_Url__c = eSignGenieConfigObj.eSign_Genie_Api_URL__c+url;
            logobj.Response__c = res.getBody();
            logobj.Payload__c = payload;
            logObj.Log_Type__c = 'Error';
            logobj.Exception_Message__c = 'Exception is :' + e;
            if (Schema.sObjectType.ESignGenie_Log__c.isCreateable()) {
                insert logObj;
            }
        }
        
        return responseBody;
    }
}