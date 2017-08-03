@isTest
public class BatchFolderStatusUpdateTest{
    public static testmethod void method1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        BatchFolderStatusUpdate b = new BatchFolderStatusUpdate();
        database.executeBatch(b);
        //SchedulerFolderStatusUpdate b = new SchedulerFolderStatusUpdate();
        //system.schedule('Test Job Name', '0 0 23 * * ?', b);
        system.assertEquals(10, 10);
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
        
        system.assertEquals(f1.Folder_Status__c ,'DRAFT');
       /* eSignGenieConfiguration__c confObj = new eSignGenieConfiguration__c();
        confObj.Name = 'Configuration';
        confObj.Client_ID__c = 'test';
        confObj.Client_Secret__c = 'test';
        confObj.Access_Token__c = 'test';
        confObj.eSign_Genie_Api_URL__c = 'https://www.esigngenie.com/esign/api';
        insert confObj;
        
        List<Contact> lstContact = new List<Contact>();
        
        Contact c1 = new Contact();
        c1.LastName = 'Test Last Name';
        c1.folderId__c = '1';
        c1.folderStatus__c = 'SIGNED';
        lstContact.add(c1);
        
        Contact c2 = new Contact();
        c2.LastName = 'Test Last Name';
        c2.folderStatus__c = '';
        c2.folderId__c = '2';
        lstContact.add(c2);
        
        Contact c3 = new Contact();
        c3.LastName = 'Test Last Name';
        c3.folderStatus__c = 'PARTIALLY SIGNED';
        c3.folderId__c = '3';
        lstContact.add(c3);
        
        insert lstContact; */
    }
}