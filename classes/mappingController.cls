public with sharing class mappingController {
    public Map<String,String> mapObjLabelToName {get;set;}
    public String slctedPrntObjVal {get;set;}
    public String parentObjName {get;set;}
    public String mappingName {get;set;}
    //public String folderName {get;set;}
    public String templateName {get;set;}
    public List<Mapping_Parent_Obj__c> lstMappingObj {get;set;}
    public String exstMap {get;set;}
    public List<String> lstCustmObjcts {get;set;}
    public Map<String,List<String>> mapObjFlds {get;set;}
    public List<SelectOption> fieldOptions;
    public map<String,map<Id,String>> mapObjExstngMapName{get;set;}
    public eSignGenieConfiguration__c eSignGenieConfigObj{get;set;}
    public TemplateWrapper tmpltWrprObj {get;set;}
    List<TemplateDetailsWrapper> lstTempDetails {get;set;}
    public map<String,String> mapTemplateNames {get;set;}
    public map<String,String> mapTemplateNameToNumOfParties {get;set;}
    
    public mappingController(){
        Set<String> setDsplyObjs = new Set<String>{'Lead','Account','Contact','Opportunity','Quote','Order'};
        Set<String> setCstmDsplyObjs = new Set<String>{'Mapping_Parent_Obj__c','Mapping_Child_Obj__c','ESignGenie_Log__c','Obj_Name_With_Button_Details__c','Folder_Details_With_Obj_Name__c','Mapping_Profile_Access__c'};
        eSignGenieConfigObj = eSignGenieConfiguration__c.getInstance('Configuration');
        fieldOptions = new List<SelectOption>();
        //fieldOptions.add(new SelectOption('0','Select Value'));
        lstCustmObjcts = new List<String>();
        mapObjFlds = new Map<String,List<String>>();
        mapObjLabelToName = new Map<String,String>();
        mapObjExstngMapName = new map<String,map<Id,String>>();
        lstTempDetails = new List<TemplateDetailsWrapper>();
        mapTemplateNames = new map<String,String>();
        mapTemplateNameToNumOfParties = new map<String,String>();
        
        lstMappingObj = [select Id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Template_File_Name__c,Is_Active__c,folder_name__c from Mapping_Parent_Obj__c where Is_Active__c = true];
        
        for(Mapping_Parent_Obj__c mpo :lstMappingObj){
            if(mapObjExstngMapName.get(mpo.Parent_Obj_Name__c) == null){
                mapObjExstngMapName.put(mpo.Parent_Obj_Name__c,new map<Id,String>());
            }
            mapObjExstngMapName.get(mpo.Parent_Obj_Name__c).put(mpo.id,mpo.Mapping_Name__c);
        }
        
        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ){
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            if(objResult.getName() != null && setDsplyObjs.contains(objResult.getName())){
                mapObjLabelToName.put(objResult.getName(),objResult.getLabel());    
            }            
            if(objResult.isCustom() && !objResult.isCustomSetting() && !setCstmDsplyObjs.contains(objResult.getName())){
                mapObjLabelToName.put(objResult.getName(),objResult.getLabel());
                lstCustmObjcts.add(objResult.getName());
            }   
        }
        
        for(String s :  mapObjLabelToName.keySet()) {
            SObjectType objToken = Schema.getGlobalDescribe().get(s);
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap(); 
            
            Set<String> fieldSet = fields.keySet();
            List<String> lstFields = new List<String>();
            for(String st:fieldSet) {
                SObjectField fieldToken = fields.get(st);
                DescribeFieldResult selectedField = fieldToken.getDescribe();
                lstFields.add(selectedField.getLabel());
            }
            mapObjFlds.put(s,lstFields);
        }
        
        String resBody = eSignGenieUtils.sendESignGenieReqst('/templates/list', 'GET', null);
        tmpltWrprObj = (TemplateWrapper)JSON.deserialize(resBody,TemplateWrapper.class);
        if(tmpltWrprObj.templatesList.size() > 0){
            lstTempDetails = tmpltWrprObj.templatesList;
            for(TemplateDetailsWrapper st : lstTempDetails){
                mapTemplateNames.put(st.templateId, st.templateName);
                mapTemplateNameToNumOfParties.put(st.templateId,st.numberOfParties);
            }
        }
        
        
    }
    
    public List<SelectOption> getParentObjct(){
        List<SelectOption> optns = new List<Selectoption>();
        //optns.add(new selectOption('0', 'Select Value'));
        for(String s : mapObjLabelToName.keySet()){
            optns.add(new selectOption(s, mapObjLabelToName.get(s)));
        }
        SelectOptionSorter.doSort(optns, SelectOptionSorter.FieldToSort.Label);
        return optns;
    }
    
    public List<SelectOption> getTemplatesName(){
        List<SelectOption> optns = new List<Selectoption>();
        //optns.add(new selectOption('0', 'Select Value'));
        for(TemplateDetailsWrapper s : lstTempDetails){
            optns.add(new selectOption(s.templateId, s.templateName));
        }
        SelectOptionSorter.doSort(optns, SelectOptionSorter.FieldToSort.Label);
        return optns;
    }
    
    public void  changeFieldValues(){
        fieldOptions = new List<SelectOption>();
       // fieldOptions.add(new SelectOption('0','Select Value'));
        if(mapObjExstngMapName.get(slctedPrntObjVal) != null){
            map<Id,String> tempMap = mapObjExstngMapName.get(slctedPrntObjVal);           
            for(Id i : tempMap.keySet()){
                fieldOptions.add(new SelectOption(i,tempMap.get(i)));
            } 
        }
        
    }
    
    public List<SelectOption> getFields() {
        SelectOptionSorter.doSort(fieldOptions, SelectOptionSorter.FieldToSort.Label);
        return fieldOptions;
    }
    
    
    public PageReference saveData(){
        Mapping_Parent_Obj__c mapParObj = new Mapping_Parent_Obj__c();
        mapParObj.Mapping_Name__c = mappingName;
        mapParObj.Parent_Obj_Name__c = parentObjName;
        //mapParObj.folder_name__c = folderName;    
        mapParObj.Template_Name__c = templateName;
        mapParObj.Template_File_Name__c = mapTemplateNames.get(templateName);
        mapParObj.Number_Of_Parties__c = mapTemplateNameToNumOfParties.get(templateName);
        mapParObj.Is_Active__c = true;
        if (Schema.sObjectType.Mapping_Parent_Obj__c.isCreateable()) {
            insert mapParObj;
        }
        
        PageReference pagRef = Page.mappingstep1;
        pagRef.getParameters().put('mapId',mapParObj.id);
        if(exstMap != null && exstMap != '0'){
            pagRef.getParameters().put('exstMapId',exstMap);
        }
        
        pagRef.setRedirect(true);
        return pagRef;
    }
    
    public class TemplateWrapper{           
        public String result;
        public String total_templates;
        public List<TemplateDetailsWrapper> templatesList;
    }
    
    public class TemplateDetailsWrapper{           
        public String templateId;
        public String templateName;
        public String templateDesc;
        public String templateType;
        public String templateCreationDate;
        public String templateLastUpdateDate;
        public Boolean editable;
        public String numberOfParties;
        public String companyId;
        public Boolean shareAll;
    }
}