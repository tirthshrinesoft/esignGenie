public with sharing class MappingProfileAccessController {
    public List<Profile> lstProfiles {get;set;}
    public List<Mapping_Parent_Obj__c> lstMapParent {get;set;}
    public List<profileWrapper> lstPrflWrapper {get;set;}
    public Boolean isMappingAvlbl {get;set;}
    public Boolean showSucMsg {get;set;}
    
    public MappingProfileAccessController(){
        showSucMsg = false;
        lstProfiles = new List<Profile>();
        lstMapParent = new List<Mapping_Parent_Obj__c>();
        lstPrflWrapper = new List<profileWrapper>();
        map<String,List<String>> mappingNameToProfl = new map<String,List<String>>();
        
        lstProfiles = [SELECT Id,Name,UserType FROM Profile limit 10000];
        lstMapParent = [select Id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Is_Active__c,Is_Default_Mapping__c,Template_File_Name__c from Mapping_Parent_Obj__c where Is_Active__c = true];
        List<Mapping_Profile_Access__c> lstPrflAccess = [select id,Mapping_Parent_Obj__c,Profile_Id__c from Mapping_Profile_Access__c limit 10000];
        if(lstPrflAccess != null && lstPrflAccess.size() > 0){
            for(Mapping_Profile_Access__c mpaObj :lstPrflAccess){
                if(mpaObj.Profile_Id__c != null){
                    if(mpaObj.Profile_Id__c.contains(',')){
                        String[] arrTest = mpaObj.Profile_Id__c.split(','); 
                        mappingNameToProfl.put(mpaObj.Mapping_Parent_Obj__c, arrTest);
                    }else{
                        List<String> lstTempIds = new List<String>();
                        lstTempIds.add(mpaObj.Profile_Id__c);
                        mappingNameToProfl.put(mpaObj.Mapping_Parent_Obj__c, lstTempIds);
                    }                    
                }
            }
        }
        if(lstMapParent.size() > 0){
            isMappingAvlbl = false;
            for(Mapping_Parent_Obj__c parObj : lstMapParent){
                profileWrapper pfrlWrprObj = new profileWrapper();
                pfrlWrprObj.mapId = parObj.Id;
                pfrlWrprObj.mapName = parObj.Mapping_Name__c;
                if(mappingNameToProfl.get(parObj.Id) != null && mappingNameToProfl.get(parObj.Id).size() > 0){
                    pfrlWrprObj.slctdProfiles = mappingNameToProfl.get(parObj.Id);
                }else{
                    pfrlWrprObj.slctdProfiles = new List<String>();    
                }
                
                lstPrflWrapper.add(pfrlWrprObj);
            }
        }else{
            isMappingAvlbl = true;
        }
        
    }
    
    public List<SelectOption> getProfiles(){
        List<SelectOption> optns = new List<Selectoption>();
        for(Profile pObj : lstProfiles){
            optns.add(new selectOption(pObj.Id, pObj.Name));
        }
        return optns;
    }
    
    public PageReference saveData(){        
        List<Mapping_Profile_Access__c> lstPrflAccess = [select id from Mapping_Profile_Access__c limit 10000];
        if (Schema.sObjectType.Mapping_Profile_Access__c.isDeletable()){
            delete lstPrflAccess;
        }
        
        List<Mapping_Profile_Access__c> lstPrflAccessInsert = new List<Mapping_Profile_Access__c>();
        if(lstPrflWrapper.size() > 0){
            for(profileWrapper pwrObj : lstPrflWrapper){
                if(pwrObj.slctdProfiles.size() == 0){
                    continue;
                }
                Mapping_Profile_Access__c mpPrflAccsObj = new Mapping_Profile_Access__c();
                mpPrflAccsObj.Mapping_Parent_Obj__c = pwrObj.mapId;                
                if(pwrObj.slctdProfiles.size() > 0){
                    String tempPrflIds = '';
                    for(String prflId : pwrObj.slctdProfiles){
                        tempPrflIds += prflId + ',';
                    }
                    tempPrflIds = tempPrflIds.substring(0,tempPrflIds.length()-1);
                    mpPrflAccsObj.Profile_Id__c = tempPrflIds;
                }
                
                lstPrflAccessInsert.add(mpPrflAccsObj);
            }
            system.debug(lstPrflAccessInsert);
            if (Schema.sObjectType.Mapping_Profile_Access__c.isCreateable()) {
                insert lstPrflAccessInsert;        
            }
        }
        PageReference pagRef = Page.MappingProfileAccess;
        showSucMsg = true;
        return null;
    }
    
    public class profileWrapper {
        public String mapId {get;set;}
        public String mapName {get;set;}
        public List<String> slctdProfiles {get;set;}
        
        public profileWrapper(){
            slctdProfiles = new List<String>();
        }
    }
}