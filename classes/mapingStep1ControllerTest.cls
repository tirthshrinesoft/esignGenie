@isTest
public class mapingStep1ControllerTest {
    public static testmethod void method1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<Mapping_Parent_Obj__c> lstMappParentObj = [select Id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Is_Active__c from Mapping_Parent_Obj__c where Is_Active__c = true];
        ApexPages.currentPage().getParameters().put('mapId',lstMappParentObj.get(0).Id);
        ApexPages.currentPage().getParameters().put('exstMapId',lstMappParentObj.get(0).Id);
        ApexPages.currentPage().getParameters().put('succMsg','true');
        mapingStep1Controller mapStep = new mapingStep1Controller();
        mapStep.isDfltMapping = true;
        mapingStep1Controller.childWrapper clwrpr = new mapingStep1Controller.childWrapper(lstMappParentObj.get(1).Parent_Obj_Name__c);
        mapStep.rowNo = '1';
        mapStep.AddRow();
        mapStep.changeFieldValues();
        mapStep.deleteRow();
        mapStep.getParentObjct();
        mapStep.getTrgtFields();
        mapStep.refreshTemplateDetails();
        mapStep.saveData();
        system.assertEquals(mapStep.rowNo, '1');
        Test.stopTest();
    }
    
    public static testmethod void method2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<Mapping_Parent_Obj__c> lstMappParentObj = [select Id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Is_Active__c from Mapping_Parent_Obj__c where Is_Active__c = true];
        ApexPages.currentPage().getParameters().put('mapId',lstMappParentObj.get(0).Id);
        mapingStep1Controller mapStep = new mapingStep1Controller();
        mapingStep1Controller.childWrapper clwrpr = new mapingStep1Controller.childWrapper(lstMappParentObj.get(1).Parent_Obj_Name__c);
        mapStep.rowNo = '1';
        mapStep.AddRow();
        mapStep.changeFieldValues();
        mapStep.deleteRow();
        mapStep.getParentObjct();
        mapStep.saveData();
        system.assertEquals(mapStep.rowNo, '1');
        Test.stopTest();
    }
    
    @testSetup
    Static void insertData(){
        eSignGenieConfiguration__c confObj = new eSignGenieConfiguration__c();
        confObj.Name = 'Configuration';
        confObj.Client_ID__c = 'test';
        confObj.Client_Secret__c = 'test';
        confObj.Access_Token__c = 'test';
        confObj.eSign_Genie_Api_URL__c = 'https://www.esigngenie.com/esign/api';
        confObj.Is_Log_Enable__c = true;
        insert confObj;
        
        List<Mapping_Parent_Obj__c> lstMappParentObj = new List<Mapping_Parent_Obj__c>();
        Mapping_Parent_Obj__c m1 = new Mapping_Parent_Obj__c();
        m1.Mapping_Name__c = 'test mapping name';
        m1.Parent_Obj_Name__c = 'Contact';
        m1.Template_Name__c = '1';
        m1.Is_Active__c = true;
        lstMappParentObj.add(m1);
        
        Mapping_Parent_Obj__c m2 = new Mapping_Parent_Obj__c();
        m2.Mapping_Name__c = 'test mapping name';
        m2.Parent_Obj_Name__c = 'Contact';
        m2.Template_Name__c = '1';
        m2.Is_Active__c = true;
        lstMappParentObj.add(m2);
        
        Mapping_Parent_Obj__c m3 = new Mapping_Parent_Obj__c();
        m3.Mapping_Name__c = 'test mapping name';
        m3.Parent_Obj_Name__c = 'Contact';
        m3.Template_Name__c = '1';
        m3.Is_Active__c = true;
        lstMappParentObj.add(m3);
        
        Mapping_Parent_Obj__c m4 = new Mapping_Parent_Obj__c();
        m4.Mapping_Name__c = 'test mapping name';
        m4.Parent_Obj_Name__c = 'Contact';
        m4.Template_Name__c = '1';
        m4.Is_Active__c = true;
        lstMappParentObj.add(m4);
        insert lstMappParentObj;
        
        List<Mapping_Child_Obj__c> lstMapChldObj = new List<Mapping_Child_Obj__c>();
        Mapping_Child_Obj__c mc1 = new Mapping_Child_Obj__c();
        mc1.Mapping_Parent_Obj__c = m1.id;
        mc1.Obj_Name__c = 'Contact';
        mc1.Field_Name__c = 'test 1';
        mc1.Target_Field_Name__c = 'Is_Active__c';
        //mc1.Is_Overwrite__c = false;
        lstMapChldObj.add(mc1);
        
        Mapping_Child_Obj__c mc2 = new Mapping_Child_Obj__c();
        //mc2.Is_Overwrite__c = false;
        mc2.Mapping_Parent_Obj__c = m1.id;
        mc2.Obj_Name__c = 'Contact';
        mc2.Field_Name__c = 'Createddate';
        mc2.Target_Field_Name__c = 'Agreement Date';
        mc2.Target_Field_Type__c = 'datefield';
        mc2.Parent_Obj_Field_Name__c = 'CreatedBy';
        mc2.Target_Field_Type_Format__c = 'dd/MM/YYYY';
        lstMapChldObj.add(mc2);
        
        Mapping_Child_Obj__c mc3 = new Mapping_Child_Obj__c();
        //mc3.Is_Overwrite__c = false;
        mc3.Mapping_Parent_Obj__c = m1.id;
        mc3.Obj_Name__c = 'Contact';
        mc3.Field_Name__c = 'test';
        mc3.Target_Field_Name__c = 'Test target';
        mc3.Parent_Obj_Field_Name__c = 'CreatedDate';
        lstMapChldObj.add(mc3);
        
        Mapping_Child_Obj__c mc4 = new Mapping_Child_Obj__c();
        mc4.Mapping_Parent_Obj__c = m1.id;
        //mc4.Is_Overwrite__c = true;
        mc4.Obj_Name__c = 'Contact';
        mc4.Field_Name__c = 'test 1';
        mc4.Target_Field_Name__c = 'Test target';
        mc4.Parent_Obj_Field_Name__c = 'CreatedDate';
        lstMapChldObj.add(mc4);
        
        insert lstMapChldObj;
        
        system.assertEquals(m4.Is_Active__c , true);
    }
}