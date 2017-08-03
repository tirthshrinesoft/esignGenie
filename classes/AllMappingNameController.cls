public with sharing class AllMappingNameController {
    public Id mapId{get;set;}
    public String rowNo {get;set;}
    public Map<String,String> mapObjLabelToName {get;set;}
    public List<Mapping_Parent_Obj__c> lstMapParent {get;set;}
    public List<Mapping_Parent_Obj__c> lstActiveMapping {get;set;}
    public List<Mapping_Parent_Obj__c> lstDeActiveMapping {get;set;}
    
    public AllMappingNameController(){
        mapObjLabelToName = new map<String,String>();
        lstMapParent = new List<Mapping_Parent_Obj__c>();
        lstActiveMapping = new List<Mapping_Parent_Obj__c>();
        lstDeActiveMapping = new List<Mapping_Parent_Obj__c>();
        
        for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ){
            Schema.DescribeSObjectResult objResult = o.getDescribe();
            mapObjLabelToName.put(objResult.getName(),objResult.getLabel());   
        }
        
        lstMapParent = [select Id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Is_Active__c,Is_Default_Mapping__c,Template_File_Name__c from Mapping_Parent_Obj__c limit 10000];
        
        for(Mapping_Parent_Obj__c m : lstMapParent){
            if(m.Is_Active__c == true){
                lstActiveMapping.add(m);
            }else{
                lstDeActiveMapping.add(m);
            }
        }
    }
    
    public void deactiveMapping(){
        lstActiveMapping.remove(Integer.valueOf(rowNo));
        Mapping_Parent_Obj__c m1 = new Mapping_Parent_Obj__c(Id=mapId,Is_Active__c=false,Is_Default_Mapping__c=false);
        update m1;
        for(Mapping_Parent_Obj__c m :lstMapParent){
            if(m.id == mapId){
                lstDeActiveMapping.add(m);
            }
        }
    }
    
    public void activeMapping(){
        lstDeActiveMapping.remove(Integer.valueOf(rowNo));
        Mapping_Parent_Obj__c m1 = new Mapping_Parent_Obj__c(Id=mapId,Is_Active__c=true);
        update m1;
        for(Mapping_Parent_Obj__c m :lstMapParent){
            if(m.id == mapId){
                lstActiveMapping.add(m);
            }
        }
    }
    
    public void deleteMapping(){
        for(Mapping_Parent_Obj__c m :lstMapParent){
            if(m.id == mapId){
                lstDeActiveMapping.remove(Integer.valueOf(rowNo));
            }
        }
        List<Mapping_Child_Obj__c> lstMpChld = [select id from Mapping_Child_Obj__c where Mapping_Parent_Obj__c =: mapId];
        if (Schema.sObjectType.Mapping_Child_Obj__c.isDeletable()){
            delete lstMpChld;
        }
        Mapping_Parent_Obj__c m1 = new Mapping_Parent_Obj__c(Id=mapId);
        if (Schema.sObjectType.Mapping_Parent_Obj__c.isDeletable()){
            delete m1;
        }
    }
    
    public PageReference goToCreateMapping(){
        PageReference pagRef = Page.mapping;
        pagRef.setRedirect(true);
        return pagRef;
    }
}