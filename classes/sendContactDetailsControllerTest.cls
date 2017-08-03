@isTest
public class sendContactDetailsControllerTest {
    public static testmethod void method1(){
        List<String> lstTmplName = new List<String>();
        List<Mapping_Parent_Obj__c> lstMapPrnt = [select id from Mapping_Parent_Obj__c];
        for(Mapping_Parent_Obj__c mp : lstMapPrnt){
            lstTmplName.add(mp.id);    
        }        
        Contact cntObj = [select id from contact where lastname = 'test last name' and email='test@test.com'];
        ApexPages.currentPage().getParameters().put('objId',cntObj.Id);
        ApexPages.currentPage().getParameters().put('prntObjName','contact');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        sendContactDetailsController sc = new sendContactDetailsController();
        sc.rowNo = '1';
        sc.isSignandSend = true;
        sc.isPreview = true;
        sc.frstName = 'test';
        sc.lstName = 'tets';
        sc.emailId = 'xyz@west.com';
        sc.searchObjName = 'contact';
        sc.searchName = 'test';
        sc.slctTemPlateName = lstTmplName;
        sc.lstSearchSelectedResult = cntObj.Id;
        List<sendContactDetailsController.Parties> lstParties1 = new List<sendContactDetailsController.Parties>();
        sendContactDetailsController.Parties pt = new sendContactDetailsController.Parties();
        pt.firstName = 'Test first name';
        pt.lastName = 'Test last name';
        pt.emailId= 'test@test.com';
        pt.permission = 'test';
        pt.sequence = 1;
        lstParties1.add(pt);
        sc.lstParties = lstParties1; 
        sc.addRow();
        sc.deleteRow();
        sc.getMappingName();
        sc.searchObjectData();
        sc.getSearchResult();
        sc.saveData();
        sc.displayPartyData();
        sc.getAccessLevel();
        sc.lighteningRedirect();
        List<Mapping_Parent_Obj__c> lstMappParentObj = [select id,Is_active__c from Mapping_Parent_Obj__c where Is_active__c = true];
        system.assertEquals(lstMappParentObj.get(0).Is_active__c, true);
        Test.stopTest();
    }
    
    @testSetup
    static void insertData(){
        List<Profile> lpf= [SELECT Id,Name,UserType FROM Profile limit 10];
        String tempPrflId = '';
        for(Profile pobj : lpf){
            tempPrflId += pobj.Id + ',';
        }
        tempPrflId = tempPrflId.substring(0,tempPrflId.length() - 1);
        
        eSignGenieConfiguration__c confObj = new eSignGenieConfiguration__c();
        confObj.Name = 'Configuration';
        confObj.Client_ID__c = 'test';
        confObj.Client_Secret__c = 'test';
        confObj.Access_Token__c = 'test';
        confObj.eSign_Genie_Api_URL__c = 'https://www.esigngenie.com/esign/api';
        confObj.Is_Log_Enable__c = true;
        insert confObj;
        
        Account ac1 = new Account();
        ac1.Name = 'test acnt name';
        insert ac1;
        
        Contact cnt1 = new Contact();
        cnt1.AccountId = ac1.Id;
        cnt1.Email = 'test@test.com';
        cnt1.LastName = 'test last name';
        insert cnt1;
        
        List<Mapping_Parent_Obj__c> lstMappParentObj = new List<Mapping_Parent_Obj__c>();
        Mapping_Parent_Obj__c m1 = new Mapping_Parent_Obj__c();
        m1.Mapping_Name__c = 'test mapping name';
        m1.Parent_Obj_Name__c = 'Contact';
        m1.Template_Name__c = '1';
        m1.Number_Of_Parties__c = '2';
        m1.Is_Active__c = true;
        lstMappParentObj.add(m1);
        
        Mapping_Parent_Obj__c m2 = new Mapping_Parent_Obj__c();
        m2.Mapping_Name__c = 'test mapping name';
        m2.Parent_Obj_Name__c = 'Contact';
        m2.Template_Name__c = '1';
        m2.Number_Of_Parties__c = '1';
        m2.Is_Active__c = true;
        lstMappParentObj.add(m2);
        
        Mapping_Parent_Obj__c m3 = new Mapping_Parent_Obj__c();
        m3.Mapping_Name__c = 'test mapping name';
        m3.Parent_Obj_Name__c = 'Contact';
        m3.Is_Default_Mapping__c = true;
        m3.Template_Name__c = '1';
        m3.Number_Of_Parties__c = '2';
        m3.Is_Active__c = true;
        lstMappParentObj.add(m3);
        
        Mapping_Parent_Obj__c m4 = new Mapping_Parent_Obj__c();
        m4.Mapping_Name__c = 'test mapping name';
        m4.Parent_Obj_Name__c = 'Contact';
        m4.Template_Name__c = '1';
        m4.Number_Of_Parties__c = '2';
        m4.Is_Active__c = true;
        lstMappParentObj.add(m4);
        insert lstMappParentObj;
        
        List<Mapping_Child_Obj__c> lstMapChldObj = new List<Mapping_Child_Obj__c>();
        Mapping_Child_Obj__c mc1 = new Mapping_Child_Obj__c();
        mc1.Is_Overwrite__c = true;
        mc1.Mapping_Parent_Obj__c = m1.id;
        mc1.Obj_Name__c = 'Contact';
        mc1.Field_Name__c = 'firstname';
        mc1.Target_Field_Name__c = 'Is_Active__c';
        lstMapChldObj.add(mc1);
        
        Mapping_Child_Obj__c mc2 = new Mapping_Child_Obj__c();
        mc2.Is_Overwrite__c = false;
        mc2.Mapping_Parent_Obj__c = m1.id;
        mc2.Obj_Name__c = 'Contact';
        mc2.Field_Name__c = 'Lastname';
        mc2.Target_Field_Name__c = 'Is_Active__c';
        mc2.Target_Field_Type__c = 'checkboxfield';
        //mc2.Parent_Obj_Field_Name__c = 'CreatedBy';
        lstMapChldObj.add(mc2); 
        
        Mapping_Child_Obj__c mc3 = new Mapping_Child_Obj__c();
        mc3.Is_Overwrite__c = false;
        mc3.Mapping_Parent_Obj__c = m1.id;
        mc3.Obj_Name__c = 'Contact';
        mc3.Field_Name__c = 'AccountId';
        mc3.Target_Field_Name__c = 'Test target';
        mc3.Parent_Obj_Field_Name__c = 'CreatedDate';
        lstMapChldObj.add(mc3);
        
        Mapping_Child_Obj__c mc4 = new Mapping_Child_Obj__c();
        mc4.Is_Overwrite__c = false;
        mc4.Mapping_Parent_Obj__c = m1.id;
        mc4.Obj_Name__c = 'Contact';
        mc4.Field_Name__c = 'OwnerId';
        mc4.Target_Field_Name__c = 'Test target';
        mc4.Parent_Obj_Field_Name__c = 'CreatedDate';
        lstMapChldObj.add(mc4);
        
        Mapping_Child_Obj__c mc5 = new Mapping_Child_Obj__c();
        mc5.Is_Overwrite__c = false;
        mc5.Mapping_Parent_Obj__c = m1.id;
        mc5.Obj_Name__c = 'Contact';
        mc5.Field_Name__c = 'Languages__c';
        mc5.Target_Field_Name__c = 'Test target 1 ';
        lstMapChldObj.add(mc5);
       
        insert lstMapChldObj;
        
        List<Mapping_Profile_Access__c> lstPrfl = new List<Mapping_Profile_Access__c>();
        Mapping_Profile_Access__c mpaObj = new Mapping_Profile_Access__c();
        mpaObj.Mapping_Parent_Obj__c = m1.Id;
        mpaObj.Profile_Id__c = tempPrflId;
        lstPrfl.add(mpaObj);
        
        Mapping_Profile_Access__c mpaObj1 = new Mapping_Profile_Access__c();
        mpaObj1.Mapping_Parent_Obj__c = m2.Id;
        mpaObj1.Profile_Id__c = lpf.get(0).Id;
        lstPrfl.add(mpaObj1);
        
        Mapping_Profile_Access__c mpaObj2 = new Mapping_Profile_Access__c();
        mpaObj2.Mapping_Parent_Obj__c = m3.Id;
        lstPrfl.add(mpaObj2);
        insert lstPrfl;
        
        system.assertEquals(m2.Is_Active__c, true);
    }
}