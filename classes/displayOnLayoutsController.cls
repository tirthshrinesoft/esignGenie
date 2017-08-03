public with sharing class displayOnLayoutsController {
    //public List<String> lstLayouts {get;set;}
    public map<String,String> mapObjNameToLabel {get;set;}
    public map<String,Boolean> mapLayoutToButnPrsnt {get;set;}
    public List<lstLayoutWrapper> lstLayoutsWithDtls{get;set;}
    public map<String,List<lstLayoutWrapper>> mapObjNameToWrprCopy{get;set;}
    public set<String> setObjNames {get;set;}
    public map<String,List<lstLayoutWrapper>> mapObjNameToWrpr {get;set;}
    public boolean succmsg {get;set;}
    
    public displayOnLayoutsController(){
        system.debug('Inside Constructor...........................................');
        mapObjNameToLabel = new map<String,String>();
        mapObjNameToLabel.put('Account', 'Account');
        mapObjNameToLabel.put('Contact', 'Contact');
        mapObjNameToLabel.put('Lead', 'Lead');
        mapObjNameToLabel.put('Opportunity', 'Opportunity');
        mapObjNameToLabel.put('Quote', 'Quote');
        mapObjNameToLabel.put('Order', 'Order');
        
        
        succmsg = false;
        List<String> layOutNames = new List<String>();
        map<String,Obj_Name_With_Button_Details__c> mapObjNameToButnAdded; 
        setObjNames = new Set<String>{'Lead','Account','Contact','Opportunity','Quote','Order'};
            Set<String> setCstmDsplyObjs = new Set<String>{'eSignGenieApp__Mapping_Parent_Obj__c','eSignGenieApp__Mapping_Child_Obj__c','eSignGenieApp__ESignGenie_Log__c','eSignGenieApp__Obj_Name_With_Button_Details__c','eSignGenieApp__Folder_Details_With_Obj_Name__c','eSignGenieApp__Mapping_Profile_Access__c'};
                //lstLayouts = new List<String>();
                List<Obj_Name_With_Button_Details__c> lstObjNames = [SELECT Id,Is_eSignGenie_Button_Added__c,Is_eSign_Genie_Fields_Added__c,Obj_Label__c,Obj_Name__c FROM Obj_Name_With_Button_Details__c limit 10000];
        if(lstObjNames.size() > 0){
            mapObjNameToButnAdded = new map<String,Obj_Name_With_Button_Details__c>();
            for(Obj_Name_With_Button_Details__c ob : lstObjNames){
                system.debug('Object Name on Page load ::::' + ob.Obj_Name__c);
                mapObjNameToButnAdded.put(ob.Obj_Name__c, ob);
            }
        }
        system.debug('Map Is :::::' + mapObjNameToButnAdded);
        //App_Prefix__c preObj = App_Prefix__c.getInstance('Current Prefix');
        for (Schema.SObjectType o : Schema.getGlobalDescribe().values()){
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            
            if(objResult.getName() != null && objResult.isCustom() && !objResult.isCustomSetting() && !setCstmDsplyObjs.contains(objResult.getName()) && mapObjNameToButnAdded != null && mapObjNameToButnAdded.get(objResult.getName()) != null && mapObjNameToButnAdded.get(objResult.getName()).Is_eSignGenie_Button_Added__c){
                system.debug('Inside IFFFFFFF ::::::::::::::::::::::::::::::::::::::::::::::::::');
                String strTemp = objResult.getName();
                //mapObjNameToLabel.put(objResult.getName(),objResult.getLabel());
                mapObjNameToLabel.put(strTemp,objResult.getLabel());
                setObjNames.add(strTemp);
                //setObjNames.add(objResult.getName());
            }
        }    
        system.debug('Set Is ::::::::' + setObjNames);
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.type_x = 'Layout';
        queries.add(queryLayout);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);
        if(fileProperties != null){
            for(MetadataService.FileProperties fileProperty : fileProperties){
                String[] objNames = fileProperty.fullName.split('-');
                if(fileProperty.fullName != null && setObjNames.contains(objNames[0])){
                    System.debug(EncodingUtil.urlDecode(fileProperty.fullName, 'UTF-8'));
                    layOutNames.add(EncodingUtil.urlDecode(fileProperty.fullName, 'UTF-8'));
                }
                
            }
            //lstLayouts.sort();
            layOutNames.sort();
            checkButtonInLayout(layOutNames);
        }       
    }
    
    public void checkButtonInLayout(List<String> layOutNames){
        mapObjNameToWrpr = new map<String,List<lstLayoutWrapper>>();
        mapObjNameToWrprCopy = new map<String,List<lstLayoutWrapper>>();
        lstLayoutsWithDtls = new List<lstLayoutWrapper>();
        mapLayoutToButnPrsnt = new map<String,Boolean>();
        MetadataService.MetadataPort service = createService(); 
        if(layOutNames.size() > 0){
            for(String str : layOutNames){
                MetadataService.Layout layout = (MetadataService.Layout) service.readMetadata('Layout', new String[] { str }).getRecords()[0];
                String[] objNames = str.split('-');
                lstLayoutWrapper lyOutWrprObj = new lstLayoutWrapper(); 
                lyOutWrprObj.objName = objNames[0];
                if(layout.customButtons == null){
                    lyOutWrprObj.layOutName = objNames[1];
                    lyOutWrprObj.isPrsntInLayout = false;
                    mapLayoutToButnPrsnt.put(objNames[1],false);
                }else if(layout.customButtons != null && layout.customButtons.size() > 0){
                    Set<String> tempLayoutBtnSet = new Set<String>();
                    tempLayoutBtnSet.addAll(layout.customButtons);
                    
                    if(!tempLayoutBtnSet.add('Send_To_eSignGenie') || !tempLayoutBtnSet.add('eSignGenieApp__Send_To_eSignGenie')){ 
                        lyOutWrprObj.layOutName = objNames[1];
                        lyOutWrprObj.isPrsntInLayout = true;
                        mapLayoutToButnPrsnt.put(objNames[1],true);
                    }else{
                        lyOutWrprObj.layOutName = objNames[1];
                        lyOutWrprObj.isPrsntInLayout = false;
                        mapLayoutToButnPrsnt.put(objNames[1],false);
                    }
                }
                lstLayoutsWithDtls.add(lyOutWrprObj);
            }
            //lstLayoutsWithDtlsCopy = lstLayoutsWithDtls.clone();
            if(lstLayoutsWithDtls.size() > 0){
                for(lstLayoutWrapper lwrp : lstLayoutsWithDtls){
                    if(mapObjNameToWrpr.get(lwrp.objName) == null){
                        mapObjNameToWrpr.put(lwrp.objName,new List<lstLayoutWrapper>());                        
                    }
                    mapObjNameToWrpr.get(lwrp.objName).add(lwrp);
                }
                mapObjNameToWrprCopy = mapObjNameToWrpr.clone();
            }
        }        
    }   
    
    
    public PageReference saveData(){
        String[] layOutNames = new List<String>();
        map<String,Boolean> mapLynametoPrsnt = new map<String,Boolean>();
        if(lstLayoutsWithDtls != null && lstLayoutsWithDtls.size() > 0){
            for(lstLayoutWrapper lwrp: lstLayoutsWithDtls){
                if(mapLayoutToButnPrsnt.get(lwrp.layOutName) != null && lwrp.isPrsntInLayout != mapLayoutToButnPrsnt.get(lwrp.layOutName)){
                    mapLynametoPrsnt.put(lwrp.objName + '-' + lwrp.layOutName,lwrp.isPrsntInLayout);
                }
            }        
            
            layOutNames.addAll(mapLynametoPrsnt.keySet());
            for(String st : layOutNames){
                system.debug('Layout Name is :::::' + st);
            }
            
            MetadataService.MetadataPort service = createService();
            List<MetadataService.Layout> lstLayoutDtls = (List<MetadataService.Layout>) service.readMetadata('Layout', layOutNames).getRecords();
            system.debug('Layout Details :::::' + lstLayoutDtls.size());
            // Add the Custom Button to the Layout
            for(MetadataService.Layout ml : lstLayoutDtls){
                system.debug('Layout Full Name is ::::::'+ml);
                //system.debug('Want To Add in Layout ::::::'+mapLynametoPrsnt.get(ml.fullName));
                String tempBtnName = 'Send_To_eSignGenie';
                if(ml.fullName != null && ml.fullName.contains('-')){
                    String[] tempNames = ml.fullName.split('-');
                    set<String> setObjNames1 = new Set<String>{'Lead','Account','Contact','Opportunity','Quote','Order'};
                    if(setObjNames1.contains(tempNames[0])){
                        tempBtnName = 'eSignGenieApp__Send_To_eSignGenie';
                    }
                }
                if(ml.fullName != null && mapLynametoPrsnt.get(ml.fullName) != null && mapLynametoPrsnt.get(ml.fullName)){
                    system.debug('Inside 1st IFFFFFFFF :::::::::::::::::::::::::::');
                    if(ml.customButtons == null){
                        system.debug('Inside 2nd IFFFFFFFF :::::::::::::::::::::::::::');                        
                        //ml.customButtons = new List<String>{'Send_To_eSignGenie'};
                        ml.customButtons = new List<String>{tempBtnName};
                            }else if(ml.customButtons != null && ml.customButtons.size() > 0){
                                Set<String> tempLayoutBtnSet = new Set<String>();
                                tempLayoutBtnSet.addAll(ml.customButtons);
                                //if(!tempLayoutBtnSet.contains('Send_To_eSignGenie')){
                                if(!tempLayoutBtnSet.contains(tempBtnName)){
                                    //ml.customButtons.add('Send_To_eSignGenie');
                                    ml.customButtons = new List<String>{tempBtnName};
                                }                    
                            }
                }else{
                    system.debug('Inside ELSE :::::::::::::::::::::::::::');
                    if(ml.customButtons != null && ml.customButtons.size() > 0){
                        system.debug('Inside Else IFFFFFFFF :::::::::::::::::::::::::::');
                        Set<String> tempLayoutBtnSet = new Set<String>();
                        tempLayoutBtnSet.addAll(ml.customButtons);
                        //if(tempLayoutBtnSet.contains('Send_To_eSignGenie')){
                        if(tempLayoutBtnSet.contains(tempBtnName)){
                            //tempLayoutBtnSet.remove('Send_To_eSignGenie');
                            tempLayoutBtnSet.remove(tempBtnName);
                        }
                        ml.customButtons.clear();
                        ml.customButtons.addAll(tempLayoutBtnSet);
                    }
                }            
            }
            
            MetadataService.Metadata[] mArr = new MetadataService.Metadata[lstLayoutDtls.size()];
            Integer count = 0;
            for(MetadataService.Layout l : lstLayoutDtls) {
                mArr[count++] = l;
            }
            
            handleSaveResults(service.updateMetadata(mArr)[0]);
            
            PageReference pagRef = Page.displayonlayouts;
            succmsg = true;
            //pagRef.setRedirect(true);
            return null;
        }
        return null;        
    }
    
    public static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    
    public class lstLayoutWrapper{
        public String layOutName {get;set;}
        public Boolean isPrsntInLayout {get;set;}
        public String objName {get;set;}
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
}