@isTest
public class displayOnLayoutsControllerTest {
    public static testmethod void method1(){
        Test.startTest();
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        //MetadataService metaDataService = new MetadataService();
        new MetadataService.createMetadataResponse_element();
        new MetadataService.createMetadata_element();
        displayOnLayoutsController disObj = new displayOnLayoutsController();
        List<displayOnLayoutsController.lstLayoutWrapper> lstLayoutsWithDtls = disObj.lstLayoutsWithDtls;        
        disObj.saveData();
        List<Obj_Name_With_Button_Details__c> lstObjs = [select id,Is_eSignGenie_Button_Added__c from Obj_Name_With_Button_Details__c where Is_eSignGenie_Button_Added__c =  true];
        system.assertEquals(lstObjs.get(0).Is_eSignGenie_Button_Added__c, true);
        Test.stopTest();
    }
    
    @testSetup
    Static void insertData(){
        List<Obj_Name_With_Button_Details__c> lstObjs = new List<Obj_Name_With_Button_Details__c>();
        
        Obj_Name_With_Button_Details__c obj1 = new Obj_Name_With_Button_Details__c();
        obj1.Obj_Label__c = 'Test1';
        obj1.Obj_Name__c = 'Test1__c';
        obj1.Is_eSign_Genie_Fields_Added__c = false;
        obj1.Is_eSignGenie_Button_Added__c = false;
        lstObjs.add(obj1);
        
        Obj_Name_With_Button_Details__c obj2 = new Obj_Name_With_Button_Details__c();
        obj2.Obj_Label__c = 'Test2';
        obj2.Obj_Name__c = 'Test2__c';
        obj2.Is_eSign_Genie_Fields_Added__c = true;
        obj2.Is_eSignGenie_Button_Added__c = true;
        lstObjs.add(obj2);
        
        insert lstObjs;
        
        system.assertEquals(obj1.Is_eSign_Genie_Fields_Added__c ,false);
    }
    
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            else if(request instanceof MetadataService.checkDeployStatus_element)
                response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataService.describeMetadata_element)
                response.put('response_x', new MetadataService.describeMetadataResponse_element());
            else if(request instanceof MetadataService.deploy_element)
                response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            return;
        }
        
    }
}