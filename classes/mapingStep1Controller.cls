public with sharing class mapingStep1Controller {
    public Boolean isDfltMapping {get;set;}
    public Boolean showRefrshMsg {get;set;}
    public Id mapId{get;set;}
    public Id exstMapId {get;set;}
    public String parObjName {get;set;}
    public map<String,List<String>> mapParentObjName {get;set;}
    public Mapping_Parent_Obj__c mapParObj {get;set;}
    public List<Mapping_Child_Obj__c> lstExstnMapping {get;set;}
    public Map<String,String> mapObjLabelToName {get;set;}
    public List<String> lstCustmObjcts {get;set;}
    public Map<String,map<String,String>> mapObjFlds {get;set;}
    public List<childWrapper> lstMapDataToObj {get;set;}
    public String rowNo {get;set;}
    public Boolean showSucMsg {get;set;}
    public Boolean showMappingErrMsg {get;set;}
    public String showMappingErr {get;set;}
    public templateDetails temdetobj {get;set;}
    public map<String,String> mapeSgnGneFldNameToType {get;set;}
    public map<String,String> mapeSgnGneFldNameToFormat {get;set;}
    
    public mapingStep1Controller(){
        showRefrshMsg = false;
        lstCustmObjcts = new List<String>();
        mapObjFlds = new Map<String,map<String,String>>();
        mapObjLabelToName = new Map<String,String>();
        mapParentObjName = new map<String,list<String>>();
        lstMapDataToObj = new List<childWrapper>();
        lstExstnMapping = new List<Mapping_Child_Obj__c>();
        temdetobj = new templateDetails();
        mapeSgnGneFldNameToType = new map<String,String>();
        mapeSgnGneFldNameToFormat = new map<String,String>();
        
        if(ApexPages.currentPage().getParameters().get('mapId') != null){
            mapId = ApexPages.currentPage().getParameters().get('mapId');
            mapParObj = [select id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Template_File_Name__c,Is_Default_Mapping__c,folder_name__c from Mapping_Parent_Obj__c where id=:mapId];
            isDfltMapping = mapParObj.Is_Default_Mapping__c;
            if(ApexPages.currentPage().getParameters().get('exstMapId') != null){
                exstMapId = ApexPages.currentPage().getParameters().get('exstMapId');
                lstExstnMapping = [SELECT Id,Is_Overwrite__c,Mapping_Parent_Obj__c,Name,Field_Name__c,Obj_Name__c,Target_Field_Name__c,Parent_Obj_Field_Name__c FROM Mapping_Child_Obj__c where Mapping_Parent_Obj__c=:exstMapId];
                
                for(Mapping_Child_Obj__c mc : lstExstnMapping){
                    childWrapper c = new childWrapper(mc.Obj_Name__c);
                    if(mc.Parent_Obj_Field_Name__c != null){
                        c.objName = mc.Obj_Name__c + '|' + mc.Field_Name__c; 
                        c.objFldName = mc.Parent_Obj_Field_Name__c;
                    }else{
                        c.objName = mc.Obj_Name__c;
                        c.objFldName = mc.Field_Name__c;
                    }
                    
                    c.targetFld = mc.Target_Field_Name__c;
                    c.overWriteExst = mc.Is_Overwrite__c;
                    lstMapDataToObj.add(c);
                }
            }
            
            for ( Schema.SObjectType o : Schema.getGlobalDescribe().values() ){
                Schema.DescribeSObjectResult objResult = o.getDescribe();
                mapObjLabelToName.put(objResult.getName(),objResult.getLabel());
                if(objResult.isCustom()){
                    lstCustmObjcts.add(objResult.getName());
                }   
            }
            lstMapDataToObj.add(new childWrapper(mapParObj.Parent_Obj_Name__c));
            if(ApexPages.currentPage().getParameters().get('exstMapId') == null){
                for(Integer i=0;i<4;i++){
                    lstMapDataToObj.add(new childWrapper(mapParObj.Parent_Obj_Name__c));
                }
            }
            for(String s :  mapObjLabelToName.keySet()) {
                if(s == mapParObj.Parent_Obj_Name__c){
                    parObjName = mapObjLabelToName.get(s);
                    
                    
                    sObjectType objToken = Schema.getGlobalDescribe().get(s);
                    DescribeSObjectResult objDef = objToken.getDescribe();
                    Map<String, SObjectField> fields = objDef.fields.getMap(); 
                    List<String> lstTempPrntObjs = new List<String>();
                    for(String st : fields.keySet()) {                        
                        SObjectField s2 = fields.get(st);
                        DescribeFieldResult s1 = s2.getDescribe();
                        if(s1.GetType() == Schema.DisplayType.REFERENCE)  {
                            List <Schema.sObjectType> lstTemp = s1.getReferenceTo();
                            System.debug(s1.getName() + ' : ** ' + lstTemp.get(0).getDescribe().getLabel());
                            for(Schema.sObjectType so2 : lstTemp )  {
                                lstTempPrntObjs.add(so2.getDescribe().getName()+ '|' + s1.getName()+'|'+s1.getLabel());
                            }
                        }                        
                    }
                    mapParentObjName.put(s,lstTempPrntObjs);
                }
                
                SObjectType objToken = Schema.getGlobalDescribe().get(s);
                DescribeSObjectResult objDef = objToken.getDescribe();
                Map<String, SObjectField> fields = objDef.fields.getMap(); 
                
                Set<String> fieldSet = fields.keySet();
                map<String,String> mapFields = new map<String,String>();
                for(String st:fieldSet) {
                    SObjectField fieldToken = fields.get(st);
                    DescribeFieldResult selectedField = fieldToken.getDescribe();
                    mapFields.put(selectedField.getName(),selectedField.getLabel());
                }
                
                mapObjFlds.put(s,mapFields);
            }
            
            String resBody = eSignGenieUtils.sendESignGenieReqst('/templates/mytemplate?templateId='+mapParObj.Template_Name__c, 'GET', null);
            system.debug('Response is ' + resBody);
            temdetobj = (templateDetails)JSON.deserialize(resBody, templateDetails.class);
            
            for(allFieldsDetails fldObj: temdetobj.allfields){
                if(fldObj.fieldType != null && fldObj.fieldType == 'textfield'){
                    mapeSgnGneFldNameToType.put(fldObj.textfieldName, fldObj.fieldType);
                }
                if(fldObj.fieldType != null && fldObj.fieldType == 'checkboxfield'){
                    mapeSgnGneFldNameToType.put(fldObj.cbname, fldObj.fieldType);
                }
                if(fldObj.fieldType != null && fldObj.fieldType == 'datefield'){
                    mapeSgnGneFldNameToType.put(fldObj.datefieldName, fldObj.fieldType);
                    mapeSgnGneFldNameToFormat.put(fldObj.datefieldName, fldObj.dateFormat);
                }
                
            }
            
        }
        
    }
    
    public void  changeFieldValues(){
        system.debug('Row Number is *******' + rowNo);
        map<String,String> tempStr = new map<String,String>();
        lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).objFldName = '0';
        lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).fieldOptions = new List<SelectOption>();
        lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).fieldOptions.add(new SelectOption('0','-- Select Value --'));
        System.debug(lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).objName);
        
        if(lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).objName.contains('|'))  {
            String[] nameSplits = lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).objName.split('\\|');
            tempStr = mapObjFlds.get(nameSplits[0]);
        }else{
            tempStr = mapObjFlds.get(lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).objName);
        }
        
        
        for(String s : tempStr.keySet()){
            lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).fieldOptions.add(new SelectOption(s,tempStr.get(s)));
        } 
        SelectOptionSorter.doSort(lstMapDataToObj.get(Integer.valueOf(rowNo) - 1).fieldOptions, SelectOptionSorter.FieldToSort.Label);
    }
    
    public List<SelectOption> getParentObjct(){
        List<SelectOption> optns = new List<Selectoption>();
        Set<String> setTemp = new Set<String>();
        List<String> lstTemp = new List<String>();
        setTemp.addAll(mapParentObjName.get(mapParObj.Parent_Obj_Name__c));
        lstTemp.addAll(setTemp);
        lstTemp.add(mapParObj.Parent_Obj_Name__c);
        for(String s : lstTemp){
            System.debug('###### : ' + s);
            if(s.contains('|'))  {
                System.debug(s);
                String[] nameSplits = s.split('\\|');
                optns.add(new selectOption(nameSplits[0]+'|'+nameSplits[1], mapObjLabelToName.get(nameSplits[0]) + '('+ nameSplits[2] +')'));
            }else  {
                System.debug('****** : ' + s);
                optns.add(new selectOption(s, mapObjLabelToName.get(s)));
                
            }
            
        }
        SelectOptionSorter.doSort(optns, SelectOptionSorter.FieldToSort.Label);
        return optns;
    }
    
    public List<SelectOption> getTrgtFields(){
        set<String> lstFldsHidden = new set<String>{'Date Signed'};
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption('0','-- Select Value --'));
        List<allFieldsDetails> fldList = temdetobj.allfields;
        if(fldList.size() > 0){
            for(allFieldsDetails fldObj : fldList){
                if(!lstFldsHidden.contains(fldObj.datefieldName)){
                    if(fldObj.fieldType != null && fldObj.fieldType == 'textfield' && fldObj.textfieldName != 'Signer Name'){
                        optns.add(new selectOption(fldObj.textfieldName,fldObj.textfieldName));
                    }
                    if(fldObj.fieldType != null && fldObj.fieldType == 'checkboxfield'){
                        optns.add(new selectOption(fldObj.cbname,fldObj.cbname ));
                    }
                    if(fldObj.fieldType != null && fldObj.fieldType == 'datefield'){
                        optns.add(new selectOption(fldObj.datefieldName,fldObj.datefieldName));
                    }
                }
            }
        }
        Set<Selectoption> tempOptns = new Set<Selectoption>();
        tempOptns.addAll(optns);
        optns.clear();
        optns.addAll(tempOptns);
        return optns;
    }
    
    public void AddRow(){
        lstMapDataToObj.add(new childWrapper(mapParObj.Parent_Obj_Name__c));
    }
    
    public void deleteRow(){
        lstMapDataToObj.remove(Integer.valueOf(rowNo) - 1);
    }
    
    public PageReference saveData(){
        /* map<String,Mapping_Child_Obj__c> mapTempChildObj = new map<String,Mapping_Child_Obj__c>();
List<Mapping_Child_Obj__c> lstExstMapBaseOnObjName = [SELECT Id,Is_Overwrite__c,Mapping_Parent_Obj__c,Name,Field_Name__c,Obj_Name__c,Target_Field_Name__c,Parent_Obj_Field_Name__c,Mapping_Parent_Obj__r.mapping_name__c FROM Mapping_Child_Obj__c where Mapping_Parent_Obj__r.Parent_Obj_Name__c =: mapParObj.Parent_Obj_Name__c and id !=: mapId];
if(lstExstMapBaseOnObjName.size() > 0){
for(Mapping_Child_Obj__c mapChld :lstExstMapBaseOnObjName ){
mapTempChildObj.put(mapChld.Target_Field_Name__c,mapChld);
}
Boolean mappingErrorFound = false;
for(childWrapper chldObj :lstMapDataToObj){
Mapping_Child_Obj__c tempChldObj = mapTempChildObj.get(chldObj.targetFld);
system.debug('CHILD OBJECT IS ::::::: ' + tempChldObj);
if(tempChldObj != null){
system.debug('Hello In Check Block');
if(tempChldObj.Parent_Obj_Field_Name__c != null){
String tempObjName = tempChldObj.Obj_Name__c + '|' + tempChldObj.Field_Name__c;
if((tempObjName != chldObj.objName) || (tempChldObj.Parent_Obj_Field_Name__c != chldObj.objFldName)){
system.debug('In Pipeline Block');
showMappingErr = 'This eSign Genie fields are matched with another mapping name '+tempChldObj.Mapping_Parent_Obj__r.mapping_name__c +' with same object';
mappingErrorFound = true;
break;
}
}else{
if((tempChldObj.Obj_Name__c != chldObj.objName)||(tempChldObj.Field_Name__c != chldObj.objFldName)){
system.debug('In without Pipeline Block');
showMappingErr = 'This eSign Genie fields are matched with another mapping name '+tempChldObj.Mapping_Parent_Obj__r.mapping_name__c +' with same object';
mappingErrorFound = true;
break;
}
}
}
}

if(mappingErrorFound)  {
PageReference pagRef = Page.mappingstep1;
showSucMsg = false;
showMappingErrMsg = true;
return null;
}
} */
        List<Mapping_Child_Obj__c> lstExstMapping = [SELECT Id,Is_Overwrite__c,Mapping_Parent_Obj__c,Name,Field_Name__c,Obj_Name__c,Target_Field_Name__c,Parent_Obj_Field_Name__c,Target_Field_Type__c,Target_Field_Type_Format__c FROM Mapping_Child_Obj__c where Mapping_Parent_Obj__c=:mapId];
        if (Schema.sObjectType.Mapping_Child_Obj__c.isDeletable()){
            delete lstExstMapping;
        }
        
        List<Mapping_Child_Obj__c> lstmapParentObjName = new List<Mapping_Child_Obj__c>();
        
        for(childWrapper c :lstMapDataToObj){
            if(c.targetFld == '0'){
                continue;
            } 
            Mapping_Child_Obj__c chldObj = new Mapping_Child_Obj__c();
            if(c.objName.contains('|')){
                String[] nameSplits = c.objName.split('\\|');
                chldObj.Obj_Name__c = nameSplits[0];
                chldObj.Field_Name__c = nameSplits[1];
                chldObj.Parent_Obj_Field_Name__c = c.objFldName;
            }else{
                chldObj.Obj_Name__c = c.objName;
                chldObj.Field_Name__c = c.objFldName;
            }
            
            chldObj.Mapping_Parent_Obj__c = mapId;
            chldObj.Target_Field_Type__c = mapeSgnGneFldNameToType.get(c.targetFld);
            chldObj.Target_Field_Name__c =  c.targetFld;
            if(mapeSgnGneFldNameToFormat.get(c.targetFld) != null){
                String tempFrmt = mapeSgnGneFldNameToFormat.get(c.targetFld);
                if(tempFrmt.contains('DD')){
                    tempFrmt = tempFrmt.replace('DD', 'dd');
                }
                chldObj.Target_Field_Type_Format__c = tempFrmt;    
            }
            
            chldObj.Is_Overwrite__c = c.overWriteExst;
            
            lstmapParentObjName.add(chldObj);
        }
        
        if (Schema.sObjectType.Mapping_Child_Obj__c.isCreateable()) {
            insert lstmapParentObjName;
        }
        //make default mapping false if present in system
        if(isDfltMapping){
            List<Mapping_Parent_Obj__c> lstPrntMaps = [SELECT Is_Default_Mapping__c,Mapping_Name__c,Parent_Obj_Name__c FROM Mapping_Parent_Obj__c where Parent_Obj_Name__c=: mapParObj.Parent_Obj_Name__c];
            if(lstPrntMaps.size() > 0){
                for(Mapping_Parent_Obj__c mp :lstPrntMaps){                  
                    if(mp.Mapping_Name__c == mapParObj.Mapping_Name__c){
                        mp.Is_Default_Mapping__c = isDfltMapping;
                    }else{
                        mp.Is_Default_Mapping__c = false;
                    }                    
                }
            }
            update lstPrntMaps;
        }
        //Update default mapping 
        /* mapParObj.Is_Default_Mapping__c = isDfltMapping;
update mapParObj; */
        
        PageReference pagRef = Page.mappingstep1;
        exstMapId = mapId;
        showSucMsg = true;
        showMappingErrMsg = false;
        return null;
        
    } 
    
    public PageReference refreshTemplateDetails(){
        List<Mapping_Parent_Obj__c> lstMapParObj = [select id,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Template_File_Name__c,Is_Default_Mapping__c,folder_name__c,Number_Of_Parties__c from Mapping_Parent_Obj__c where id=:mapId];
        List<Mapping_Child_Obj__c> lstExstMapping = [SELECT Id,Is_Overwrite__c,Mapping_Parent_Obj__c,Name,Field_Name__c,Obj_Name__c,Target_Field_Name__c,Parent_Obj_Field_Name__c,Target_Field_Type__c,Target_Field_Type_Format__c FROM Mapping_Child_Obj__c where Mapping_Parent_Obj__c=:mapId];
        templateType tmptypeObj = temdetobj.template;
        
        if(lstMapParObj != null && lstMapParObj.size() > 0){          
            if(tmptypeObj != null && tmptypeObj.numberOfParties != null){
                lstMapParObj.get(0).Number_Of_Parties__c = tmptypeObj.numberOfParties;
            }            
        }
        if(lstExstMapping != null && lstExstMapping.size() > 0){
            for(Mapping_Child_Obj__c chObj : lstExstMapping){
                if(mapeSgnGneFldNameToType.get(chObj.Target_Field_Name__c) != null){
                    chObj.Target_Field_Type__c = mapeSgnGneFldNameToType.get(chObj.Target_Field_Name__c);
                    if(chObj.Target_Field_Type_Format__c != null && mapeSgnGneFldNameToFormat.get(chObj.Target_Field_Name__c) != null){
                        chObj.Target_Field_Type_Format__c = mapeSgnGneFldNameToFormat.get(chObj.Target_Field_Name__c);
                    }
                }                
            }
        }
        update lstMapParObj;
        update lstExstMapping;
        
        PageReference pagRef = Page.mappingstep1;
        exstMapId = mapId;
        showRefrshMsg = true;
        return null;
    }
    
    public class childWrapper{
        public String objName {get;set;}
        public String objFldName {get;set;}
        public String targetFld {get;set;}
        public Boolean overWriteExst {get;set;}
        public String prntObjFldName {get;set;}
        public List<SelectOption> fieldOptions {get;set;}
        
        public childWrapper(String objName)  {
            overWriteExst = false;
            Set<String> setESignGenieFlds = new Set<String>{'folderId__c','folderName__c','folderSentDate__c','folderCreationDate__c','folderDocumentIds__c','folderStatus__c'};
            this.objName = objName;
            fieldOptions = new List<SelectOption>();
            fieldOptions.add(new selectOption('0','-- Select Value --'));
            
            SObjectType objToken = Schema.getGlobalDescribe().get(objName);
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap(); 
            
            Set<String> fieldSet = fields.keySet();
            for(String st:fieldSet) {
                SObjectField fieldToken = fields.get(st);
                DescribeFieldResult selectedField = fieldToken.getDescribe();
                if(!setESignGenieFlds.contains(selectedField.getName())){
                    fieldOptions.add(new selectOption(selectedField.getName(),selectedField.getLabel()));
                }                
            }
            SelectOptionSorter.doSort(fieldOptions, SelectOptionSorter.FieldToSort.Label);
        }
    }
    
    public class templateDetails {
        public String result;
        public list<allFieldsDetails> allfields;
        public templateType template;
    }
    
    public class templateType{
        public String templateName;
        public String numberOfParties;
        public String templateId;
    }
    
    public class allFieldsDetails{
        public String fieldType;
        public String textfieldName;
        public String datefieldName;
        public String cbname;
        public String dateFormat;
    }
    
}