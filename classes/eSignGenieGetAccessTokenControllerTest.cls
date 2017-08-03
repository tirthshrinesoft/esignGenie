@isTest
global class eSignGenieGetAccessTokenControllerTest {
    public static testmethod void method1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ApexPages.currentPage().getParameters().put('code','test');        
        test.startTest();
        eSignGenieGetAccessTokenController es = new eSignGenieGetAccessTokenController();
        es.storeAccessToken();
        List<eSignGenieConfiguration__c> lst = [select Access_Token__c from eSignGenieConfiguration__c];
        system.assertEquals(lst.get(0).Access_Token__c, 'ACCESS_TOKEN');
        test.stopTest();
    }
    
    @testSetup
    Static void insertData(){
        eSignGenieConfiguration__c confObj = new eSignGenieConfiguration__c();
        confObj.Name = 'Configuration';
        confObj.Client_ID__c = 'test';
        confObj.Client_Secret__c = 'test';
        confObj.Access_Token__c = 'test';
        confObj.End_URL__c = 'https://www.esigngenie.com/esign/api/oauth2/access_token';
        insert confObj;
        
        system.assertEquals(confObj.Name, 'Configuration');
    }
}