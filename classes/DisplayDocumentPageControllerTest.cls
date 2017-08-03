@isTest
public class DisplayDocumentPageControllerTest {
    public static testmethod void method1(){
        List<Folder_Details_With_Obj_Name__c> lstDtls = [select id,Folder_Id__c from Folder_Details_With_Obj_Name__c];
        ApexPages.currentPage().getParameters().put('sfRcrdId',lstDtls.get(0).Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        DisplayDocumentPageController dsObj = new DisplayDocumentPageController();
        system.assertEquals(lstDtls.get(0).Folder_Id__c,'1');
        test.stopTest();
    }
    
    @testSetup
    Static void insertData(){
        eSignGenieConfiguration__c confObj = new eSignGenieConfiguration__c();
        confObj.Name = 'Configuration';
        confObj.Client_ID__c = 'test';
        confObj.Client_Secret__c = 'test';
        confObj.Access_Token__c = 'test';
        confObj.eSign_Genie_Api_URL__c = 'https://www.esigngenie.com/esign/api';
        insert confObj;
        
        List<Folder_Details_With_Obj_Name__c> lstFldrDtls = new List<Folder_Details_With_Obj_Name__c>();
        Folder_Details_With_Obj_Name__c f1 = new Folder_Details_With_Obj_Name__c();
        f1.Folder_Id__c = '1';
        f1.Folder_Status__c = 'DRAFT';
        lstFldrDtls.add(f1);
        insert lstFldrDtls;
        
        system.assertEquals(f1.Folder_Id__c, '1');
    }
}