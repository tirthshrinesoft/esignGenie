@isTest
public class mappingControllerTest {
    public static testmethod void method1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Mapping_Parent_Obj__c> lstMappParentObj = [select Id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Is_Active__c from Mapping_Parent_Obj__c where Is_Active__c = true];
        Test.startTest();
        mappingController mapCon = new mappingController();
        mapCon.slctedPrntObjVal = 'Contact';
        mapCon.exstMap = lstMappParentObj.get(0).id;
        mapCon.getTemplatesName();
        mapCon.getFields();
        mapCon.saveData();
        mapCon.getParentObjct();
        mapCon.changeFieldValues();
        system.assertEquals(lstMappParentObj.get(0).Is_Active__c, true);
        Test.stopTest();
    }
    
    @testSetup
    static void insertData(){
        eSignGenieConfiguration__c confObj = new eSignGenieConfiguration__c();
        confObj.Name = 'Configuration';
        confObj.Client_ID__c = 'test';
        confObj.Client_Secret__c = 'test';
        confObj.Access_Token__c = 'test';
        confObj.eSign_Genie_Api_URL__c = 'https://www.esigngenie.com/esign/api';
        insert confObj;
        
        List<Mapping_Parent_Obj__c> lstMappParentObj = new List<Mapping_Parent_Obj__c>();
        Mapping_Parent_Obj__c m1 = new Mapping_Parent_Obj__c();
        m1.Mapping_Name__c = 'test mapping name';
        m1.Parent_Obj_Name__c = 'Contact';
        m1.Template_Name__c = 'test template name';
        m1.Is_Active__c = true;
        lstMappParentObj.add(m1);
        
        Mapping_Parent_Obj__c m2 = new Mapping_Parent_Obj__c();
        m2.Mapping_Name__c = 'test mapping name';
        m2.Parent_Obj_Name__c = 'Contact';
        m2.Template_Name__c = 'test template name';
        m2.Is_Active__c = true;
        lstMappParentObj.add(m2);
        
        Mapping_Parent_Obj__c m3 = new Mapping_Parent_Obj__c();
        m3.Mapping_Name__c = 'test mapping name';
        m3.Parent_Obj_Name__c = 'Contact';
        m3.Template_Name__c = 'test template name';
        m3.Is_Active__c = true;
        lstMappParentObj.add(m3);
        
        Mapping_Parent_Obj__c m4 = new Mapping_Parent_Obj__c();
        m4.Mapping_Name__c = 'test mapping name';
        m4.Parent_Obj_Name__c = 'Contact';
        m4.Template_Name__c = 'test template name';
        m4.Is_Active__c = true;
        lstMappParentObj.add(m4);
        insert lstMappParentObj;
        
        system.assertEquals(m2.Is_Active__c, true);
    }
}