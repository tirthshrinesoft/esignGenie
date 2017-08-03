@isTest
public class AllMappingNameControllerTest {
    public static testmethod void method1(){
        List<Mapping_Parent_Obj__c> lstMappParentObj = [select Id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Is_Active__c from Mapping_Parent_Obj__c];
        AllMappingNameController allMapCon = new AllMappingNameController();
        allMapCon.mapId = lstMappParentObj.get(0).Id;
        allMapCon.rowNo = '1';
        allMapCon.activeMapping();
        allMapCon.deactiveMapping();
        allMapCon.deleteMapping();
        allMapCon.goToCreateMapping();
        Integer count = [select count() from Mapping_Parent_Obj__c where Is_Active__c = true];
        system.assertEquals(count+1, 2);
    }
    
    @testSetup
    static void insertData(){
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
        m2.Is_Active__c = false;
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
        m4.Is_Active__c = false;
        lstMappParentObj.add(m4);
        insert lstMappParentObj;
        
        system.assertEquals(m1.Is_Active__c , true);
    }
}