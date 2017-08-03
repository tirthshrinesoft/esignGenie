@isTest
public class eSignGenieConfigControllerTest {
    public static testmethod void method1(){
        eSignGenieConfigController ec = new eSignGenieConfigController();
        ec.removeAccessToken();
        List<eSignGenieConfiguration__c> lst = [select Access_Token__c from eSignGenieConfiguration__c];
        system.assertEquals(lst.get(0).Access_Token__c, null);
    }
    
    @testSetup
    Static void insertData(){
        eSignGenieConfiguration__c confObj = new eSignGenieConfiguration__c();
        confObj.Name = 'Configuration';
        confObj.Client_ID__c = 'test';
        confObj.Client_Secret__c = 'test';
        confObj.Access_Token__c = 'test';
        insert confObj;
        
        system.assertEquals(confObj.Client_ID__c, 'test');
    }
}