global with sharing class BatchFolderStatusUpdate implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful  {
    
    global final String query;
    global String objName;
    
    /*global BatchFolderStatusUpdate(String objName){
        this.objName = objName;
        this.query = 'select id, folderId__c,folderName__c,folderStatus__c,folderDocumentIds__c from ' + objName+ ' where folderStatus__c != \'CANCELLED\' and folderStatus__c != \'SIGNED\' ';
    }*/
    
    global BatchFolderStatusUpdate(){
        this.query = 'SELECT Folder_Id__c,Folder_Name__c,Folder_Status__c,Folder_Creation_Date__c,Folder_Sent_Date__c,Folder_Document_Ids__c,Object_Name__c,SF_Record_Id__c FROM Folder_Details_With_Obj_Name__c where Folder_Status__c != null and Folder_Status__c not in (\'CANCELLED\',\'EXECUTED\') ';
    }
    
    global Database.QueryLocator  start(Database.BatchableContext BC)  {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)  {
        List<SObject> lstSObjs = new List<SObject>();
        for(SObject s : scope){
            if(s.get('Folder_Id__c') != null){
                String resBody = eSignGenieUtils.sendESignGenieReqst('/folders/myfolder?folderId='+s.get('Folder_Id__c'), 'GET', null);
                ResponseWrapper rspnWrprObj = (ResponseWrapper)JSON.deserialize(resBody,ResponseWrapper.class);
                FolderDetails fldrDtlObj = rspnWrprObj.folder;
                if(s.get('Folder_Status__c') == null || s.get('Folder_Status__c') != fldrDtlObj.folderStatus){
                    s.put('Folder_Status__c',fldrDtlObj.folderStatus);
                    lstSObjs.add(s);
                }
            }            
        }        
        update lstSObjs;
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public class ResponseWrapper{
        public FolderDetails folder;
    }
    
    public class FolderDetails{
        public String folderId;
        public String folderName;
        public String folderStatus;
    }
}