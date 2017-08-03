@istest
public class MappingProfileAccessControllerTest {
    public static testmethod void MappingProfileAccessController(){
        MappingProfileAccessController mpactrl = new MappingProfileAccessController();
        mpactrl.getProfiles();
        mpactrl.saveData();
        List<Mapping_Parent_Obj__c> lstPrnt = [select id,Is_Default_Mapping__c from Mapping_Parent_Obj__c where Is_Default_Mapping__c = true];
        system.assertEquals(lstPrnt.get(0).Is_Default_Mapping__c, true);
    }
    
    @testSetup
    Static void insertTestData(){
        List<Profile> lpf= [SELECT Id,Name,UserType FROM Profile limit 10];
        String tempPrflId = '';
        for(Profile pobj : lpf){
            tempPrflId += pobj.Id + ',';
        }
        tempPrflId = tempPrflId.substring(0,tempPrflId.length() - 1);
        
        List<Mapping_Parent_Obj__c> lstPrnt = new List<Mapping_Parent_Obj__c>();
        Mapping_Parent_Obj__c mapOb1 = new Mapping_Parent_Obj__c();
        mapOb1.Mapping_Name__c = 'test mapping name';
        mapOb1.Is_Default_Mapping__c = true;
        mapOb1.Is_Active__c = true;
        mapOb1.folder_name__c = 'test folder name';
        lstPrnt.add(mapOb1);
        
        Mapping_Parent_Obj__c mapOb2 = new Mapping_Parent_Obj__c();
        mapOb2.Mapping_Name__c = 'test mapping name';
        mapOb2.Is_Default_Mapping__c = true;
        mapOb2.Is_Active__c = true;
        mapOb2.folder_name__c = 'test folder name';
        lstPrnt.add(mapOb2);
        
        Mapping_Parent_Obj__c mapOb3 = new Mapping_Parent_Obj__c();
        mapOb3.Mapping_Name__c = 'test mapping name';
        mapOb3.Is_Default_Mapping__c = true;
        mapOb3.Is_Active__c = true;
        mapOb3.folder_name__c = 'test folder name';
        lstPrnt.add(mapOb3);
        insert lstPrnt;
        
        List<Mapping_Profile_Access__c> lstPrfl = new List<Mapping_Profile_Access__c>();
        Mapping_Profile_Access__c mpaObj = new Mapping_Profile_Access__c();
        mpaObj.Mapping_Parent_Obj__c = mapOb1.Id;
        mpaObj.Profile_Id__c = tempPrflId;
        lstPrfl.add(mpaObj);
        
        Mapping_Profile_Access__c mpaObj1 = new Mapping_Profile_Access__c();
        mpaObj1.Mapping_Parent_Obj__c = mapOb2.Id;
        mpaObj1.Profile_Id__c = lpf.get(0).Id;
        lstPrfl.add(mpaObj1);
        
        Mapping_Profile_Access__c mpaObj2 = new Mapping_Profile_Access__c();
        mpaObj2.Mapping_Parent_Obj__c = mapOb3.Id;
        lstPrfl.add(mpaObj2);
        insert lstPrfl;
        
        system.assertEquals(mapOb3.Is_Active__c, true);
    }
}