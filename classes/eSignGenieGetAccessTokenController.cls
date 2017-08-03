public with sharing class eSignGenieGetAccessTokenController {
    public eSignGenieConfiguration__c eSignGenieConfigObj{get;set;}
    public requestWrapper rw {get;set;}
    
    public eSignGenieGetAccessTokenController(){
    
    }
    
    public void storeAccessToken(){
        system.debug('URL Is ******' + System.URL.getSalesforceBaseURL());
        system.debug('URL Is ******' + System.URL.getSalesforceBaseURL().getHost());
        if(ApexPages.currentPage().getParameters().get('code') != null) {
            eSignGenieConfigObj = eSignGenieConfiguration__c.getInstance('Configuration');
            //String payLoad = 'grant_type=authorization_code&client_id='+eSignGenieConfigObj.Client_ID__c+'&client_secret='+eSignGenieConfigObj.Client_Secret__c+'&code='+ApexPages.currentPage().getParameters().get('code')+'&redirect_uri=https://esigngenie.ap4.visual.force.com/apex/eSignGenieGetAccessToken';
            String payLoad = 'grant_type=authorization_code&client_id='+eSignGenieConfigObj.Client_ID__c+'&client_secret='+eSignGenieConfigObj.Client_Secret__c+'&code='+ApexPages.currentPage().getParameters().get('code')+'&redirect_uri=https://'+System.URL.getSalesforceBaseURL().getHost()+'/apex/eSignGenieGetAccessToken';
            system.debug('Payload is :::::::' + payLoad);
            //String payLoad = 'grant_type=authorization_code&client_id='+eSignGenieConfigObj.Client_ID__c+'&client_secret='+eSignGenieConfigObj.Client_Secret__c+'&code='+ApexPages.currentPage().getParameters().get('code')+'&redirect_uri=https://c.na30.visual.force.com/apex/eSignGenieGetAccessToken';
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            String responseBody;
            req.setHeader('Content-Type', 'application/x-www-form-URLencoded');        
            req.setMethod('POST');
            req.setEndpoint(eSignGenieConfigObj.End_URL__c);
            req.setBody(payLoad);
            try {
                req.setTimeout(100000);
                res = http.send(req);
                responseBody = res.getBody();
                rw = (requestWrapper)JSON.deserialize(responseBody,requestWrapper.class);
                system.debug('Response Is ::::::' +  rw);
            } 
            catch (System.CalloutException e) {
                
            }
        }
    
       system.debug('Inside Store Access Token.....' + rw.refresh_token);
       system.debug('Inside Store Access Token.....' + rw.access_token);
       eSignGenieConfiguration__c eSignConf = new eSignGenieConfiguration__c(Id=eSignGenieConfigObj.id,name=eSignGenieConfigObj.name,Access_Token__c=rw.access_token,Refresh_Token__c=rw.refresh_token,Expires_In__c= rw.expires_in,Access_Token_Generated_Date__c=system.today());
       system.debug('Object is ::::::' + eSignConf);
       update eSignConf;       
    }
    
    public class requestWrapper{
        public String refresh_token;
        public String access_token;
        public String token_type;
        public String expires_in;
    }
}