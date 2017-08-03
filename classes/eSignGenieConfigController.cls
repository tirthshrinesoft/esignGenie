public with sharing class eSignGenieConfigController {
    public eSignGenieConfiguration__c eSignGenieConfigObj{get;set;}
    public boolean showConnectBtn {get;set;}
    
    public eSignGenieConfigController(){
        eSignGenieConfigObj = eSignGenieConfiguration__c.getInstance('Configuration');
        if(eSignGenieConfigObj.Access_Token__c != null){
            showConnectBtn  = false;
        }else{
            showConnectBtn = true;
        }
    }
    
    public PageReference removeAccessToken(){
        if(eSignGenieConfigObj.Access_Token__c != null){
            system.debug('Id is ++++++' + eSignGenieConfigObj.id);
            system.debug('Name is ++++' + eSignGenieConfigObj.name);
            eSignGenieConfiguration__c eSignConf = new eSignGenieConfiguration__c(Id=eSignGenieConfigObj.id,name=eSignGenieConfigObj.name,Access_Token__c=null,Refresh_Token__c=null,Access_Token_Generated_Date__c = null,Expires_In__c=null);
            update eSignConf;
            showConnectBtn = true;            
        }
        return null;
    }
}