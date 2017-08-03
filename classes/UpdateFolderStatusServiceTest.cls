@isTest
public class UpdateFolderStatusServiceTest {
    /*
	static String uri = '/services/restapex/UpdateFolderStatus';
    static String method = 'POST';
    
    public static testmethod void method1(){
        String strTemp ='{"folderId":"1","updatedStatus":"EXECUTED"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI =   uri;
        req.httpMethod = method;
        req.requestBody = Blob.valueOf(strTemp);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateFolderStatusService.doPost();
        Test.stopTest();
    }
    
    public static testmethod void method2(){
        String strTemp ='{"folderId":"2","updatedStatus":"EXECUTED"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI =   uri;
        req.httpMethod = method;
        req.requestBody = Blob.valueOf(strTemp);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateFolderStatusService.doPost();
        Test.stopTest();
    }
    
    @testSetup
    static void insertData(){
        Account ac1 = new Account();
        ac1.folderId__c = '1';
        ac1.folderStatus__c = 'PARTIALLY SIGNED';
        ac1.Name = 'test account name';
        insert ac1;
        
        List<Folder_Details_With_Obj_Name__c> lstFldrDtls = new List<Folder_Details_With_Obj_Name__c>();
        Folder_Details_With_Obj_Name__c f1 = new Folder_Details_With_Obj_Name__c();
        f1.Folder_Name__c = 'TEst';
        f1.Folder_Id__c = '1';
        f1.Folder_Status__c = 'DRAFT';
        f1.SF_Record_Id__c = ac1.id;
        f1.Object_Name__c = 'Account';
        lstFldrDtls.add(f1);
        insert lstFldrDtls;
    }
    */
}