public with sharing class sendContactDetailsController {
    public String searchObjName {get;set;}
    public String searchName {get;set;}
    public List<SelectOption> lstSearchResult {get;set;}
    public map<String,SObject> mapSObject {get;set;}
    public String lstSearchSelectedResult {get;set;}
    public String rowNo {get;set;}
    public String objId {get;set;}
    public String frstName {get;set;}
    public String lstName {get;set;}
    public String emailId {get;set;}
    public String parentObjName {get;set;}
    public List<Mapping_Child_Obj__c> lstChldMapping {get;set;}
    public List<Parties> lstParties {get;set;}
    public eSignGenieConfiguration__c eSignGenieConfigObj{get;set;}
    public map<String,map<String,String>> mapObjectToFieldNameType {get;set;}
    public List<SelectOption> fieldOptions {get;set;}
    public List<String> slctTemPlateName {get;set;}
    public boolean isPreview {get;set;}
    public boolean isSignandSend {get;set;}
    public String embedUrl {get;set;}
    public boolean isMappingAvlbl {get;set;}
    public boolean openPopup {get;set;}
    public boolean isSuccess {get;set;}
    public String embedPrvwUrl {get;set;}
    public map<String,String> mapTmpltNameToNumOfParty {get;set;}
    public String errDisplayMsg{get;set;}
    public Integer maxNoOfParties {get;set;}
    public String folderName {get;set;}
    //public map<String,String> mapTemplateIdToFldrName {get;set;}
    public map<String,String> mapMppnNameToTmpltName {get;set;}
    public Boolean isPrflAccess {get;set;}
    public Boolean signInSequence {get;set;}
    public Boolean isUserError {get;set;}
    
    public sendContactDetailsController(){
        maxNoOfParties = 0;
        isPrflAccess = false;
        isMappingAvlbl = false;
        isUserError = false;
        slctTemPlateName = new List<String>();
        mapSObject = new map<String,SObject>();
        lstSearchResult = new List<SelectOption>();
        isPreview = false;
        isSignandSend = false;
        fieldOptions = new List<SelectOption>();
        mapObjectToFieldNameType = new map<String,map<String,String>>();
        mapTmpltNameToNumOfParty = new map<String,String>();
        //mapTemplateIdToFldrName = new map<String,String>();
        mapMppnNameToTmpltName = new map<String,String>();
        eSignGenieConfigObj = eSignGenieConfiguration__c.getInstance('Configuration');
        lstParties = new List<Parties>();
        map<String,List<String>> mappingNameToProfl = new map<String,List<String>>();
        
        if(ApexPages.currentPage().getParameters().get('objId') != null){
            objId = ApexPages.currentPage().getParameters().get('objId');
        }
        if(ApexPages.currentPage().getParameters().get('prntObjName') != null){
            parentObjName = ApexPages.currentPage().getParameters().get('prntObjName');
        }
        
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
        
        List<Mapping_Parent_Obj__c> lstMappingName = [SELECT Id,Is_Active__c,Mapping_Name__c,Parent_Obj_Name__c,Template_Name__c,Is_Default_Mapping__c,Number_Of_Parties__c,folder_name__c,Template_File_Name__c  FROM Mapping_Parent_Obj__c where Parent_Obj_Name__c =: parentObjName and Is_Active__c=true];
        if(lstMappingName.size()>0){
            for(Mapping_Parent_Obj__c mpc : lstMappingName){
                if(mpc.Is_Default_Mapping__c){
                    slctTemPlateName.add(mpc.Id);
                    folderName = mpc.Template_File_Name__c;
                }
                //mapTemplateIdToFldrName.put(mpc.Template_Name__c,mpc.folder_name__c);
                mapMppnNameToTmpltName.put(mpc.Id,mpc.Template_File_Name__c);
                mapTmpltNameToNumOfParty.put(mpc.Id,mpc.Number_Of_Parties__c);
                
                if(mappingNameToProfl.get(mpc.Id) != null && mappingNameToProfl.get(mpc.Id).size() > 0){
                    set<String> setPrflIds = new set<String>();
                    setPrflIds.addAll(mappingNameToProfl.get(mpc.Id));
                    if(setPrflIds.contains(userInfo.getProfileId())){
                        fieldOptions.add(new SelectOption(mpc.id,mpc.Mapping_Name__c));    
                    }
                    
                }                
            }
            if(fieldOptions.size() == 0){
                isPrflAccess = true;
            }
            
            system.debug('List Size :::::' + fieldOptions.size());
            lstParties = removeBlankParties(lstParties);
            for(String strName : slctTemPlateName){
                if(mapTmpltNameToNumOfParty.get(strName) != null){
                    Integer noParties = Integer.valueOf(mapTmpltNameToNumOfParty.get(strName));
                    if(maxNoOfParties < noParties)   {
                        maxNoOfParties  =  noParties;
                    }
                }
            }            
            
            /*if(parentObjName != null && parentObjName.equalsIgnoreCase('Contact') && objId != null){
                maxNoOfParties = maxNoOfParties - 1;
                Contact cnt = [select id,firstName,LastName,email from Contact where id =: objId];
                Parties partyObj = new Parties();
                partyObj.firstName = cnt.firstname;
                partyObj.lastName = cnt.lastname;
                partyObj.emailId = cnt.email;
                lstParties.add(partyObj);
            }*/
            /*Parties partyObj1 = new Parties();
partyObj1.firstName = UserInfo.getFirstName();
partyObj1.lastName = UserInfo.getLastName();
partyObj1.emailId = UserInfo.getUserEmail();
lstParties.add(partyObj1);*/
            /*else{
partyObj.firstName = UserInfo.getFirstName();
partyObj.lastName = UserInfo.getLastName();
partyObj.emailId = UserInfo.getUserEmail();
lstParties.add(partyObj);
}*/
            if(maxNoOfParties > 0){
                for(Integer i = 0;i<maxNoOfParties;i++){
                    Parties partyObj = new Parties();
                    lstParties.add(partyObj); 
                }
            }
            
        }else{
            isMappingAvlbl = true;
        }
    }
    
    public void saveData(){
        system.debug('Selected template value is ::::: ' + slctTemPlateName);
        Set<String> setTemplteIds = new Set<String>();
        lstChldMapping = [SELECT Id,Is_Overwrite__c,Mapping_Parent_Obj__c,Name,Field_Name__c,Obj_Name__c,Target_Field_Name__c,Parent_Obj_Field_Name__c,Mapping_Parent_Obj__r.Parent_Obj_Name__c,Mapping_Parent_Obj__r.mapping_Name__c,Mapping_Parent_Obj__r.template_Name__c,Target_Field_Type__c,Target_Field_Type_Format__c FROM Mapping_Child_Obj__c where Mapping_Parent_Obj__r.Parent_Obj_Name__c =: parentObjName and Mapping_Parent_Obj__c in: slctTemPlateName];
        String objQuery = 'Select id, ';
        Set<String> checkDuplicateFlds = new Set<String>();
        if(lstChldMapping.size()>0){
            for(Mapping_Child_Obj__c mc :lstChldMapping){
                setTemplteIds.add(mc.Mapping_Parent_Obj__r.template_Name__c);
                //filling map against object name to map of filed name to type
                if(mapObjectToFieldNameType.get(mc.Obj_Name__c) == null){
                    sObjectType objToken = Schema.getGlobalDescribe().get(mc.Obj_Name__c);
                    DescribeSObjectResult objDef = objToken.getDescribe();
                    Map<String, SObjectField> fields = objDef.fields.getMap();
                    map<String,String> mapTempFldNameToType = new map<String,String>();
                    
                    for(String st : fields.keySet()){
                        SObjectField fldName = fields.get(st);
                        DescribeFieldResult fldDesc = fldName.getDescribe();
                        system.debug('Field Name :::' + fldDesc.getName() + 'Field Type :::' + String.valueOf(fldDesc.GetType()));
                        mapTempFldNameToType.put(fldDesc.getName(),String.valueOf(fldDesc.GetType()));
                    }
                    mapObjectToFieldNameType.put(mc.Obj_Name__c,mapTempFldNameToType);
                }
                
                
                //End of map filling
                
                if(mc.Parent_Obj_Field_Name__c != null){
                    if(mc.Field_Name__c.contains('Id') && mc.Field_Name__c.lastIndexOf('Id') == mc.Field_Name__c.length() - 2){
                        String strTemp = mc.Field_Name__c.substring(0,mc.Field_Name__c.length() - 2) + '.' + mc.Parent_Obj_Field_Name__c +', ';
                        if(checkDuplicateFlds.add(strTemp)){
                            objQuery += strTemp;    
                        }
                    }
                    else if (mc.Field_Name__c.contains('__c') && mc.Field_Name__c.lastIndexOf('__c') == mc.Field_Name__c.length() - 3){
                        String strTemp = mc.Field_Name__c.substring(0,mc.Field_Name__c.length() - 3) + '__r.' + mc.Parent_Obj_Field_Name__c +', ';
                        if(checkDuplicateFlds.add(strTemp)){
                            objQuery += strTemp;    
                        }
                    }
                }
                else{
                    String strTemp = mc.Field_Name__c + ', ';
                    if(checkDuplicateFlds.add(strTemp)){
                        objQuery += strTemp;    
                    }
                }
            }
            
            objQuery = objQuery.substring(0,objQuery.length() - 2);
            objId = String.escapeSingleQuotes(objId);
            objQuery += ' from ' + lstChldMapping.get(0).Mapping_Parent_Obj__r.Parent_Obj_Name__c + ' where id= : objId';
            
            system.debug('QUERY IS **********'+ objQuery);
            
            SObject sObjTypeObj = Database.query(objQuery);
            
            //Remove blank party from list
            List<Parties> lstTempParties = new List<Parties>();
            Integer tempSqnce = 0;
            for(Parties pt : lstParties){
                if((pt.firstName == null || pt.firstName == '') && (pt.lastName == null || pt.lastName == '') && (pt.emailId == null || pt.emailId == '')){
                    continue;
                }/*else if(pt.canSign == true){
pt.permission = 'FILL_FIELDS_AND_SIGN';
}else if(pt.canSign == false){
pt.permission = 'VIEW_ONLY';
}*/
                //pt.permission = pt.canSign;
                tempSqnce += 1;
                pt.sequence = tempSqnce;
                lstTempParties.add(pt);
            }
            TemplateDetails tempDtlsObj = new TemplateDetails();
            tempDtlsObj.senderEmail = userInfo.getUserEmail();
            tempDtlsObj.parties = lstTempParties;
            tempDtlsObj.signInSequence = signInSequence;
            
            //tempDtlsObj.parties = lstParties;
            //tempDtlsObj.folderName = 'Demo Folder Name';
            //List<String> lstTmpltIds = new List<String>();
            List<Integer> lstTmpltIds = new List<Integer>();
            for(String st : setTemplteIds){
                lstTmpltIds.add(Integer.valueOf(st));
            }
            //lstTmpltIds.addAll(setTemplteIds);
            tempDtlsObj.templateIds = lstTmpltIds;
            tempDtlsObj.folderName = folderName;
            //tempDtlsObj.folderName = mapTemplateIdToFldrName.get(String.valueOf(lstTmpltIds.get(0)));
            //tempDtlsObj.templateIds.add(lstChldMapping.get(0).Mapping_Parent_Obj__r.template_Name__c);
            if(isPreview){
                tempDtlsObj.sendNow = false;
                tempDtlsObj.createEmbeddedSendingSession = true;
                tempDtlsObj.fixRecipientParties = true;
                tempDtlsObj.fixDocuments = true;
                tempDtlsObj.sendSuccessUrl = 'https://'+System.URL.getSalesforceBaseURL().getHost()+'/apex/ThankYouPage';
                //tempDtlsObj.embeddedSignersEmailIds.add(UserInfo.getUserEmail());
                isPreview = false;
            }
            if(isSignandSend){
                /* Parties ptobj = new Parties();
ptobj.firstName = UserInfo.getFirstName();
ptobj.lastName = UserInfo.getLastName();
ptobj.emailId = UserInfo.getUserEmail();
tempDtlsObj.parties.add(ptobj); */
                tempDtlsObj.createEmbeddedSigningSession = true;
                tempDtlsObj.createEmbeddedSigningSessionForAllParties = true;
                tempDtlsObj.embeddedSignersEmailIds.add(UserInfo.getUserEmail());
                isSignandSend = false;
            }
            
            Map<String,Object> mapTempChld = new Map<String,Object>();
            
            for(Mapping_Child_Obj__c mc1:lstChldMapping){
                if(mc1.Parent_Obj_Field_Name__c == null || mc1.Parent_Obj_Field_Name__c == ''){
                    Object val = sObjTypeObj.get(mc1.Field_Name__c);
                    if(mapObjectToFieldNameType.get(mc1.Obj_Name__c).get(mc1.Field_Name__c) == String.valueOf(Schema.DisplayType.DateTime)){
                        DateTime dt = (DateTime)sObjTypeObj.get(mc1.Field_Name__c);
                        if(mc1.Target_Field_Type_Format__c != null){
                            val = dt.format(mc1.Target_Field_Type_Format__c);
                        }else{
                            val = dt.format('MM/dd/YYYY');    
                        }
                    }
                    if(mapObjectToFieldNameType.get(mc1.Obj_Name__c).get(mc1.Field_Name__c) == String.valueOf(Schema.DisplayType.Date)){
                        Date dt = (Date)sObjTypeObj.get(mc1.Field_Name__c);
                        if(mc1.Target_Field_Type_Format__c != null){
                            Datetime dt1 = DateTime.newInstance(dt.Year(), dt.Month(), dt.Day());
                            val = dt1.format(mc1.Target_Field_Type_Format__c);
                        }else{
                            val = dt.Month() + '/' + dt.Day()+ '/' + dt.Year();    
                        }                        
                    }
                    if(mc1.Target_Field_Type__c != null &&  mc1.Target_Field_Type__c == 'checkboxfield'){
                        if(sObjTypeObj.get(mc1.Field_Name__c) == 'Yes' ||  sObjTypeObj.get(mc1.Field_Name__c) == 'true'){
                            val = true;
                        }else{
                            val = false;
                        }
                    }                   
                    
                    mapTempChld.put(mc1.Target_Field_Name__c,''+val);
                }else{
                    String fldName = '';
                    if(mc1.Field_Name__c.contains('Id') && mc1.Field_Name__c.lastIndexOf('Id') == mc1.Field_Name__c.length() - 2){
                        fldName = mc1.Field_Name__c.substring(0,mc1.Field_Name__c.length() - 2);
                    }else if (mc1.Field_Name__c.contains('__c') && mc1.Field_Name__c.lastIndexOf('__c') == mc1.Field_Name__c.length() - 3){
                        fldName = mc1.Field_Name__c.substring(0,mc1.Field_Name__c.length() - 3)+'__r';
                    }
                    else{
                        fldName = mc1.Field_Name__c;
                    }
                    Object val = sObjTypeObj.getSobject(fldName).get(mc1.Parent_Obj_Field_Name__c);
                    if(mapObjectToFieldNameType.get(mc1.Obj_Name__c).get(mc1.Parent_Obj_Field_Name__c) == String.valueOf(Schema.DisplayType.DateTime)){
                        DateTime dt = (DateTime)sObjTypeObj.getSobject(fldName).get(mc1.Parent_Obj_Field_Name__c);
                        if(mc1.Target_Field_Type_Format__c != null){
                            val = dt.format(mc1.Target_Field_Type_Format__c);
                        }else{
                            val = dt.format('MM/dd/YYYY');    
                        }                        
                    }
                    if(mapObjectToFieldNameType.get(mc1.Obj_Name__c).get(mc1.Parent_Obj_Field_Name__c) == String.valueOf(Schema.DisplayType.Date)){
                        Date dt = (Date)sObjTypeObj.getSobject(fldName).get(mc1.Parent_Obj_Field_Name__c);
                        if(mc1.Target_Field_Type_Format__c != null){
                            Datetime dt1 = DateTime.newInstance(dt.Year(), dt.Month(), dt.Day());
                            val = dt1.format(mc1.Target_Field_Type_Format__c);
                        }else{
                            val = dt.Month() + '/' + dt.Day()+ '/' + dt.Year();    
                        }
                    }
                    if(mc1.Target_Field_Type__c != null &&  mc1.Target_Field_Type__c == 'checkboxfield'){
                        if(sObjTypeObj.get(mc1.Field_Name__c) == 'Yes' ||  sObjTypeObj.get(mc1.Field_Name__c) == 'true'){
                            val = true;
                        }else{
                            val = false;
                        }
                    }
                    mapTempChld.put(mc1.Target_Field_Name__c,''+val);
                }                
            } 
            tempDtlsObj.fields = mapTempChld;
            
            String resBody = eSignGenieUtils.sendESignGenieReqst('/templates/createFolder', 'POST', JSON.serialize(tempDtlsObj));
            ResponseWrapper rspnsWrprObj = (ResponseWrapper)JSON.deserialize(resBody,ResponseWrapper.class);
            system.debug('RESPONSE IS rspnsWrprObj ::::::' + rspnsWrprObj);
            if(rspnsWrprObj.result == 'success'){
                isSuccess = true; 
            }
            if(rspnsWrprObj.result == 'error'){
                isUserError = true; 
            }
            if(rspnsWrprObj.embeddedSigningSessions != null){
                List<embeddedSigningSessionsClass> lstEmbedSessions = rspnsWrprObj.embeddedSigningSessions;
                for(embeddedSigningSessionsClass em :lstEmbedSessions){
                    //if(em.emailIdOfSigner != null && em.emailIdOfSigner == userInfo.getUserEmail()){
                    embedUrl = em.embeddedSessionURL;
                    //}
                }
                
            }
            
            if(rspnsWrprObj.embeddedSessionURL != null){
                embedPrvwUrl = rspnsWrprObj.embeddedSessionURL;
            }
            
            if(eSignGenieConfigObj.Is_Log_Enable__c){
                ESignGenie_Log__c logObj = new ESignGenie_Log__c();
                logObj.Salesforce_Obj_Name__c = parentObjName;
                logObj.Salesforce_Record_Id__c = objId;
                logObj.Log_Type__c = 'Debug';
                String partyDtlsTemp = '';
                for(Parties p : lstParties){
                    partyDtlsTemp += 'FirstName: ' + p.firstName + ' & LastName: ' + p.lastName + ' &  Email Id :' + p.emailId + '\n';
                }
                logObj.Party_Details__c = partyDtlsTemp;
                if (Schema.sObjectType.ESignGenie_Log__c.isCreateable()) {
                    insert logObj;
                }
            }
            
            if(rspnsWrprObj.folder != null){
                FolderDetails fldDetObj = rspnsWrprObj.folder;
                
                sObjTypeObj.put('folderId__c',fldDetObj.folderId);
                sObjTypeObj.put('folderName__c',fldDetObj.folderName);
                sObjTypeObj.put('folderStatus__c',fldDetObj.folderStatus);
                sObjTypeObj.put('folderCreationDate__c',DateTime.newInstance(Long.valueOf(fldDetObj.folderCreationDate)));
                if(fldDetObj.folderSentDate == null || fldDetObj.folderSentDate == ''){
                    sObjTypeObj.put('folderSentDate__c',system.today());    
                }else{
                    sObjTypeObj.put('folderSentDate__c',DateTime.newInstance(Long.valueOf(fldDetObj.folderSentDate)));
                }
                String tempDocIds;
                if(fldDetObj.folderDocumentIds.size() > 0){                
                    for(String str : fldDetObj.folderDocumentIds){
                        tempDocIds = str +',';
                    } 
                    sObjTypeObj.put('folderDocumentIds__c',tempDocIds.substring(0, tempDocIds.length()-1));
                }
                update sObjTypeObj;
                Folder_Details_With_Obj_Name__c fdObj = new Folder_Details_With_Obj_Name__c();
                fdObj.Object_Name__c = parentObjName;
                fdObj.Folder_Id__c = fldDetObj.folderId;
                fdObj.Folder_Name__c = fldDetObj.folderName;
                fdObj.Folder_Document_Ids__c = tempDocIds.substring(0, tempDocIds.length()-1);
                fdobj.Folder_Creation_Date__c = DateTime.newInstance(Long.valueOf(fldDetObj.folderCreationDate));
                if(fldDetObj.folderSentDate == null || fldDetObj.folderSentDate == ''){
                    fdobj.Folder_Sent_Date__c = system.today();    
                }else{
                    fdobj.Folder_Sent_Date__c = DateTime.newInstance(Long.valueOf(fldDetObj.folderSentDate));
                }            
                fdObj.Folder_Status__c = fldDetObj.folderStatus;
                fdObj.SF_Record_Id__c = objId;
                if(!(parentObjName != null && parentObjName.contains('__c'))){
                    fdobj.put(parentObjName+'__c',objId);
                }else if(parentObjName != null && parentObjName.contains('__c')){
                    fdobj.put(parentObjName,objId);
                }
                if (Schema.sObjectType.Folder_Details_With_Obj_Name__c.isCreateable()) {
                    insert fdObj;
                }
            }
        }
    }
    
    public void sendDataDirect(){
        saveData();
        /*Integer maxNumber = 0;
lstParties = removeBlankParties(lstParties);
for(String strName : slctTemPlateName){
if(mapTmpltNameToNumOfParty.get(strName) != null){
Integer noParties = Integer.valueOf(mapTmpltNameToNumOfParty.get(strName));
if(maxNumber < noParties)   {
maxNumber  =  noParties;
}
}
}
if((maxNumber - 1) == lstParties.size())  {
saveData();            
} else {
errDisplayMsg = 'Please select exact ' + (maxNumber - 1) + ' parties.';
}*/
    }
    
    public void displayPreview(){
        /* Integer maxNumber = 0;
lstParties = removeBlankParties(lstParties);
for(String strName : slctTemPlateName){
if(mapTmpltNameToNumOfParty.get(strName) != null){
Integer noParties = Integer.valueOf(mapTmpltNameToNumOfParty.get(strName));
if(maxNumber < noParties)   {
maxNumber  =  noParties;
}
}
}
if(maxNumber == lstParties.size())  {
isPreview = true;
saveData();     
} else {
errDisplayMsg = 'Please select exact ' + maxNumber + ' parties.';
}  */
        isPreview = true;
        saveData();
    }
    
    public void signAndSend(){
        isSignandSend = true;
        saveData();
        /*Integer maxNumber = 0;
lstParties = removeBlankParties(lstParties);
for(String strName : slctTemPlateName){
if(mapTmpltNameToNumOfParty.get(strName) != null){
Integer noParties = Integer.valueOf(mapTmpltNameToNumOfParty.get(strName));
if(maxNumber < noParties)   {
maxNumber  =  noParties;
}
}
}
if((maxNumber - 1) == lstParties.size())  {
isSignandSend = true;
saveData();     
} else {
errDisplayMsg = 'Please select exact ' + (maxNumber - 1) + ' parties.';
}*/        
    }
    
    public void addRow(){
        lstParties.add(new Parties());        
    }
    
    public void deleteRow(){
        lstParties.remove(Integer.valueOf(rowNo) - 1);
    }
    
    public List<SelectOption> getMappingName() {
        SelectOptionSorter.doSort(fieldOptions, SelectOptionSorter.FieldToSort.Label);
        return fieldOptions;
    }
    
    public void searchObjectData(){
        mapSObject = new map<String,SObject>();
        lstSearchResult = new List<SelectOption>();
        
        String sobjQuery;
        if(searchObjName == 'Contact' && parentObjName == 'Account'){
            objId = String.escapeSingleQuotes(objId);
            searchName = '%' + String.escapeSingleQuotes(searchName) + '%';
            sobjQuery = 'select id,name,email,firstname,lastname from '+ searchObjName + ' where accountId =:objId  and name like : searchName';
        }else if(searchObjName == 'Contact' && parentObjName == 'Quote'){
            List<Quote> lstTempQuote = [select id,accountId from Quote where id =:objId and accountId != null];
            if(lstTempQuote != null && lstTempQuote.size() > 0){
                if(lstTempQuote.get(0).accountId != null){
                    String actId = String.escapeSingleQuotes(lstTempQuote.get(0).accountId);
                    searchName = '%' + String.escapeSingleQuotes(searchName) + '%';
                    sobjQuery = 'select id,name,email,firstname,lastname from '+ searchObjName + ' where accountId =: actId and name like : searchName';
                }
            }            
        }else if(searchObjName == 'Contact' && parentObjName == 'Opportunity'){
            List<Opportunity> lstTempOpps = [select id,accountId from Opportunity where id =:objId and accountId != null];
            if(lstTempOpps != null && lstTempOpps.size() > 0){
                if(lstTempOpps.get(0).accountId != null){
                    String actId = String.escapeSingleQuotes(lstTempOpps.get(0).accountId);
                    searchName = '%' + String.escapeSingleQuotes(searchName) + '%';
                    sobjQuery = 'select id,name,email,firstname,lastname from '+ searchObjName + ' where accountId =: actId and name like : searchName';
                }
            }
        }else{
            searchName = '%' + String.escapeSingleQuotes(searchName) + '%';
            sobjQuery = 'Select id,name,email,firstname,lastname from ' + searchObjName + ' where name like: searchName';
        }
        
        if(sobjQuery == null || sobjQuery == ''){
            sobjQuery = 'select id from contact where createddate > today';
        }
        List<SObject> lstSobject = database.query(sobjQuery);
        if(lstSobject != null && lstSobject.size() > 0){
            for(SObject s:lstSobject){
                mapSObject.put((String)s.get('id'),s);
                lstSearchResult.add(new SelectOption((String)s.get('Id'),s.get('name') + '('+s.get('email')+')'));
            } 
        }
    }
    
    public List<SelectOption> getSearchResult(){
        return lstSearchResult;
    }
    
    public void displayPartyData(){
        system.debug('INSIDE DISPLAY METHOD');
        SObject sObj = mapSObject.get(lstSearchSelectedResult);
        system.debug('SOBJECT++++++' + sObj);
        Boolean found = false;
        if(lstParties.size() > 0){            
            for(integer k = 0 ; k < lstParties.size() ; k++)  {
                Integer lastIndx = k;
                if((lstParties.get(lastIndx).firstName == null || lstParties.get(lastIndx).firstName == '') && (lstParties.get(lastIndx).lastName == null || lstParties.get(lastIndx).lastName == '') && (lstParties.get(lastIndx).emailId == null || lstParties.get(lastIndx).emailId == '')){
                    lstParties.get(lastIndx).firstName = (String)sObj.get('firstname');
                    lstParties.get(lastIndx).lastName = (String)sObj.get('lastname');
                    lstParties.get(lastIndx).emailId= (String)sObj.get('email');
                    found = true;
                    break;
                }
            }
        }
        if(!found) {
            Parties partyObj = new Parties();
            partyObj.firstName = (String)sObj.get('firstname');
            partyObj.lastName = (String)sObj.get('lastname');
            partyObj.emailId = (String)sObj.get('email');
            lstParties.add(partyObj);
        }      
    }
    
    public List<Parties> removeBlankParties(List<Parties> tempListParties){
        List<Parties> lstTemp = new List<Parties>();
        if(tempListParties.size() > 0){
            for(Parties ptObj : tempListParties){
                if(ptObj.firstName != null && ptObj.firstName != ''){
                    lstTemp.add(ptObj); 
                }
            }    
        }       
        return lstTemp;
    }
    
    public List<SelectOption> getAccessLevel() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('FILL_FIELDS_AND_SIGN','FILL FIELDS AND SIGN'));
        options.add(new SelectOption('FILL_FIELDS_ONLY','FILL FIELDS ONLY'));
        options.add(new SelectOption('VIEW_ONLY','VIEW ONLY'));
        return options;
    }
    
    public void changeNumOfParties(){
        String tempFldrName = '';
        
        lstParties.clear();
        Integer maxTempNoOfParties = 0;
        system.debug('Selected Template Size is :: ' + slctTemPlateName.size());
        for(String strName : slctTemPlateName){
            if(mapMppnNameToTmpltName.get(strName) != null){
                tempFldrName += mapMppnNameToTmpltName.get(strName) + ',';
            }
            if(mapTmpltNameToNumOfParty.get(strName) != null){
                Integer noParties = Integer.valueOf(mapTmpltNameToNumOfParty.get(strName));
                if(maxTempNoOfParties < noParties)   {
                    maxTempNoOfParties  =  noParties;
                }
            }
        }
        tempFldrName = tempFldrName.substring(0,tempFldrName.length() - 1);
        folderName = tempFldrName;
        for(Integer i = 0;i<maxTempNoOfParties;i++){
            Parties partyObj = new Parties();
            lstParties.add(partyObj); 
        }
    }
    
    public PageReference lighteningRedirect() {
        PageReference pg = new PageReference('/'+objId);
        pg.setRedirect(true);
        return pg; 
    }
    
    public class TemplateDetails {
        public String folderName;
        //public List<String> templateIds;
        public List<Integer> templateIds;
        public map<String,Object> fields;
        public List<Parties> parties;
        public boolean createEmbeddedSigningSession;
        public boolean createEmbeddedSigningSessionForAllParties;
        public List<String> embeddedSignersEmailIds;
        public Boolean sendNow;
        public Boolean signInSequence;
        public Boolean createEmbeddedSendingSession;
        public Boolean fixRecipientParties;
        public Boolean fixDocuments;
        public String sendSuccessUrl;
        public String senderEmail;
        
        public TemplateDetails(){
            //templateIds = new List<String>();
            templateIds = new List<Integer>();
            embeddedSignersEmailIds = new List<String>();
        }
    }
    
    public class Parties{
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String emailId {get;set;}
        // public String canSign {get;set;}
        public String permission {get;set;}
        public Integer sequence;
        //public String sequence;
        
        public Parties(){
            //permission = 'FILL_FIELDS_AND_SIGN';
            sequence = 1;
        }
    }
    
    public class ResponseWrapper {
        public String result;
        public FolderDetails folder;
        public list<embeddedSigningSessionsClass> embeddedSigningSessions;
        public String embeddedSessionURL;
    }
    
    public class FolderDetails {
        public String folderId;
        public String folderName;
        public String folderCreationDate;
        public String folderSentDate;
        public String folderStatus;
        public List<String> folderDocumentIds;        
    }
    
    public class embeddedSigningSessionsClass {
        public String emailIdOfSigner;
        public String embeddedToken;
        public String embeddedSessionURL;
    }
    
}