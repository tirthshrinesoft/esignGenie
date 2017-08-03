public with sharing class AddButtonToCustmObjsController {
    public boolean succmsg {get;set;}
    public List<objNameWithDtls> lstObjDtls {get;set;}
    public map<String,Boolean> mapObjNameToBln {get;set;}
    
    
    public AddButtonToCustmObjsController(){
        succmsg = false;
        map<String,Obj_Name_With_Button_Details__c> mapObjNameToButnAdded;
        mapObjNameToBln = new map<String,Boolean>();
        lstObjDtls = new List<objNameWithDtls>();
        Set<String> setCstmDsplyObjs = new Set<String>{'eSignGenieApp__Mapping_Parent_Obj__c','eSignGenieApp__Mapping_Child_Obj__c','eSignGenieApp__ESignGenie_Log__c','eSignGenieApp__Obj_Name_With_Button_Details__c','eSignGenieApp__Folder_Details_With_Obj_Name__c','eSignGenieApp__Mapping_Profile_Access__c'};
            List<Obj_Name_With_Button_Details__c> lstObjNames = [SELECT Id,Is_eSignGenie_Button_Added__c,Is_eSign_Genie_Fields_Added__c,Obj_Label__c,Obj_Name__c FROM Obj_Name_With_Button_Details__c limit 10000];
        
        if(lstObjNames.size() > 0){
            mapObjNameToButnAdded = new map<String,Obj_Name_With_Button_Details__c>();
            for(Obj_Name_With_Button_Details__c ob : lstObjNames){
                mapObjNameToButnAdded.put(ob.Obj_Name__c,ob);
            }            
        }
        
        for (Schema.SObjectType o : Schema.getGlobalDescribe().values()){
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            system.debug('Object Name is :::::::'+objResult.getName());
            if(objResult.getName() != null && objResult.isCustom() && !objResult.isCustomSetting() && !setCstmDsplyObjs.contains(objResult.getName())){
                objNameWithDtls objNm = new objNameWithDtls();
                objNm.objName = objResult.getName();
                objNm.objLabel = objResult.getLabel();
                if(mapObjNameToButnAdded != null && mapObjNameToButnAdded.get(objResult.getName()) != null){
                    mapObjNameToBln.put(objResult.getName(), mapObjNameToButnAdded.get(objResult.getName()).Is_eSignGenie_Button_Added__c);                 
                    objNm.isBtnAdd = mapObjNameToButnAdded.get(objResult.getName()).Is_eSignGenie_Button_Added__c;
                    objNm.isFldsAdd = mapObjNameToButnAdded.get(objResult.getName()).Is_eSign_Genie_Fields_Added__c;
                }else{
                    mapObjNameToBln.put(objResult.getName(), false);
                    objNm.isBtnAdd = false;
                    objNm.isFldsAdd = false;
                }               
                lstObjDtls.add(objNm);
            }   
        }
    }
    
    public PageReference saveData(){
        map<String,Boolean> mapObjNames = new map<String,Boolean>();
        List<Obj_Name_With_Button_Details__c> lstObjBtnDtls = new List<Obj_Name_With_Button_Details__c>();
        for(objNameWithDtls oname : lstObjDtls){
            /*System.debug('Object Name is :::::' + oname.objName);
System.debug('Object Label is :::::' + oname.objLabel);
System.debug('Object is checked :::::' + oname.isBtnAdd); */
            if(mapObjNameToBln != null && mapObjNameToBln.get(oname.objName) != null && mapObjNameToBln.get(oname.objName) != oname.isBtnAdd){
                mapObjNames.put(oname.objName,oname.isBtnAdd);
            }
            Obj_Name_With_Button_Details__c objBtn = new Obj_Name_With_Button_Details__c();
            objBtn.Obj_Label__c = oname.objLabel;
            objBtn.Obj_Name__c = oname.objName;
            objBtn.Is_eSignGenie_Button_Added__c = oname.isBtnAdd;
            objBtn.Is_eSign_Genie_Fields_Added__c = true;
            lstObjBtnDtls.add(objBtn);
        }
        addeSignGenieButton(mapObjNames);
        createESignGenieFields(mapObjNames);
        giveProfileSecurity(mapObjNames);
        Schema.SObjectField f = Obj_Name_With_Button_Details__c.Fields.Obj_Name__c;
        if (Schema.sObjectType.Obj_Name_With_Button_Details__c.isUpdateable() && Schema.sObjectType.Obj_Name_With_Button_Details__c.isCreateable()) {
            Database.UpsertResult [] cr = Database.upsert(lstObjBtnDtls, f, false);
        }
        
        PageReference pagRef = Page.displayonlayouts;
        succmsg = true;
        //pagRef.setRedirect(true);
        return null;
    }
    
    public void addeSignGenieButton(map<String,Boolean> mapObjNames){
        MetadataService.MetadataPort service = createService();
        List<MetadataService.Metadata> lstBtnAddToObjs = new List<MetadataService.Metadata>();
        
        if(mapObjNames.size() > 0){
            for(String strName : mapObjNames.keySet()){
                if(mapObjNames.get(strName) != null && mapObjNames.get(strName)){
                    system.debug('Inside IF');
                    // Create Button
                    MetadataService.WebLink webLink = new MetadataService.WebLink();
                    webLink.fullName = strName+'.Send_To_eSignGenie' ;
                    webLink.availability = 'online';
                    webLink.displayType = 'button';
                    webLink.encodingKey = 'UTF-8';
                    webLink.hasMenubar = false;
                    webLink.hasScrollbars = true;
                    webLink.hasToolbar = false;
                    webLink.height = 600;
                    webLink.isResizable = true;
                    webLink.linkType = 'url';
                    webLink.masterLabel = 'Send via eSign Genie';
                    webLink.openType = 'newWindow';
                    webLink.position = 'fullScreen';
                    webLink.protected_x = false;
                    webLink.showsLocation = false;
                    webLink.showsStatus = false;
                    webLink.url = '/apex/eSignGenieApp__sendContactDetails?objId={!'+ strName +'.Id}&prntObjName='+ strName;
                    //webLink.width = 600;
                    lstBtnAddToObjs.add(webLink);
                }
            }
        }
        system.debug('Size of btn list:::::::::' + lstBtnAddToObjs.size());
        List<MetadataService.SaveResult> results = service.createMetadata(lstBtnAddToObjs);
        if(results != null)
        handleSaveResults(results[0]);
    }
    
    public static void createESignGenieFields(map<String,Boolean> mapObjNames) {
        MetadataService.MetadataPort service = createService();
        MetadataService.Metadata[] arrFlds;
        if(mapObjNames.size() > 0){            
            for(String strName : mapObjNames.keySet()){                
                if(mapObjNames.get(strName)){
                    arrFlds = new List<MetadataService.Metadata>();
                    
                    MetadataService.CustomField customField1 = new MetadataService.CustomField();
                    customField1.fullName = strName + '.folderCreationDate__c';
                    customField1.label = 'Last Folder Creation';
                    customField1.type_x = 'DateTime';
                    arrFlds.add(customField1);
                    
                    MetadataService.CustomField customField2 = new MetadataService.CustomField();
                    customField2.fullName = strName + '.folderSentDate__c';
                    customField2.label = 'Last Folder Sent Date';
                    customField2.type_x = 'DateTime';
                    arrFlds.add(customField2);
                    
                    
                    MetadataService.CustomField customField3 = new MetadataService.CustomField();
                    customField3.fullName = strName + '.folderDocumentIds__c';
                    customField3.label = 'Last Folder Document Ids';
                    customField3.type_x = 'Text';
                    customField3.length = 255;
                    arrFlds.add(customField3);
                    
                    MetadataService.CustomField customField4 = new MetadataService.CustomField();
                    customField4.fullName = strName + '.folderId__c';
                    customField4.label = 'Last Folder Id';
                    customField4.type_x = 'Text';
                    customField4.length = 255;
                    arrFlds.add(customField4);
                    
                    MetadataService.CustomField customField5 = new MetadataService.CustomField();
                    customField5.fullName = strName + '.folderName__c';
                    customField5.label = 'Last Folder Name';
                    customField5.type_x = 'Text';
                    customField5.length = 255;
                    arrFlds.add(customField5);
                    
                    MetadataService.CustomField customField6 = new MetadataService.CustomField();
                    customField6.fullName = strName + '.folderStatus__c';
                    customField6.label = 'Last Folder Status';
                    customField6.type_x = 'Picklist';
                    metadataservice.Picklist pt = new metadataservice.Picklist();
                    pt.sorted= false;
                    metadataservice.PicklistValue opt1 = new metadataservice.PicklistValue();
                    opt1.fullName = 'SHARED';
                    opt1.default_x = false ;
                    metadataservice.PicklistValue opt2 = new metadataservice.PicklistValue();
                    opt2.fullName = 'PARTIALLY SIGNED';
                    opt2.default_x = false ;
                    metadataservice.PicklistValue opt3 = new metadataservice.PicklistValue();
                    opt3.fullName = 'CANCELLED';
                    opt3.default_x = false ;
                    metadataservice.PicklistValue opt4 = new metadataservice.PicklistValue();
                    opt4.fullName = 'EXECUTED';
                    opt4.default_x = false ;
                    metadataservice.PicklistValue opt5 = new metadataservice.PicklistValue();
                    opt5.fullName = 'DELETED';
                    opt5.default_x = false ;
                    metadataservice.PicklistValue opt6 = new metadataservice.PicklistValue();
                    opt6.fullName = 'EXPIRED';
                    opt6.default_x = false ;
                    metadataservice.PicklistValue opt7 = new metadataservice.PicklistValue();
                    opt7.fullName = 'DRAFT';
                    opt7.default_x = false ;
                    pt.picklistValues = new List<MetadataService.PicklistValue>{opt1,opt2,opt3,opt4,opt5,opt6,opt7};
                    customField6.picklist = pt ;
                    arrFlds.add(customField6);
                    
                    //Create Look up file din Folder Details with Obj Name Object
                    MetadataService.CustomField customField7 = new MetadataService.CustomField();
                    customField7.fullName = 'Folder_Details_With_Obj_Name__c.' + strName;
                    String objLabel = strName.substring(0, strName.length()-3);
                    customField7.label = objLabel.replace('_', ' ');
                    customField7.type_x = 'Lookup';
                    customField7.relationshipLabel = 'Folder Details With Obj Name';
                    customField7.relationshipName = 'Folder_Details_With_Obj_Name';
                    customField7.referenceTo = strName;
                    arrFlds.add(customField7);
                    
                    List<MetadataService.SaveResult> results = service.createMetadata(arrFlds);
                    if(results != null)
                    handleSaveResults(results[0]);
                }
            }
        }
        
        //List<MetadataService.SaveResult> results = service.createMetadata(arrFlds);
        //handleSaveResults(results[0]);
    }
    
    public static void giveProfileSecurity(map<String,Boolean> mapObjNames){
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryWorkflow = new MetadataService.ListMetadataQuery();
        queryWorkflow.type_x = 'Profile';
        queries.add(queryWorkflow);
        
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        List<String> proName = new List<String>();
        if(fileProperties != null)
        for(MetadataService.FileProperties fileProperty : fileProperties)   {
            proName.add(EncodingUtil.urlDecode(fileProperty.fullName,'UTF-8'));
        }
        if(mapObjNames.size() > 0){            
            for(String strName : mapObjNames.keySet()){                
                if(mapObjNames.get(strName)){
                    for(String s : proName){
                        BatchUpdateFieldSecurity bt = new BatchUpdateFieldSecurity(strName,s,userInfo.getSessionId());
                        database.executeBatch(bt);
                    }
                }
            }
        }
        
    }
    
    
    public static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    
    public static void handleSaveResults(MetadataService.SaveResult saveResult){
        // Nothing to see?
        if(saveResult==null || saveResult.success){
            return;
        }
        
        // Construct error message and throw an exception
        if(saveResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add((saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            /*
if(messages.size()>0)
throw new Exception(String.join(messages, ' '));
*/
        }
        
        /*
if(!saveResult.success)
throw new Exception('Request failed with no specified error.');
*/
    }
    
    public class objNameWithDtls{
        public String objName {get;set;}
        public String objLabel {get;set;}
        public Boolean isBtnAdd {get;set;}
        public Boolean isFldsAdd {get;set;}
    }
}