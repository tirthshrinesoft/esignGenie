global with sharing class BatchUpdateFieldSecurity implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful  {
    
    global String objName;
    global String prflName;
    global String sessionId;
    
    global BatchUpdateFieldSecurity(String objName,String prflName,String sessionId)  {
        this.objName = objName;
        this.prflName = prflName;
        this.sessionId = sessionId;
    }
    global Database.QueryLocator  start(Database.BatchableContext BC)  {
        return Database.getQueryLocator('select id from User Limit 1');
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope)  {
        updateFieldSecurity(sessionId);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public void updateFieldSecurity(String sessionID){
        MetadataService.MetadataPort service = createService(sessionId);
        MetadataService.Profile prfl = new MetadataService.Profile();
        prfl.fullName = prflName;
        //prfl.custom = false;
        MetadataService.ProfileFieldLevelSecurity fieldSec1 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec1.field = objName+'.folderId__c';
        fieldSec1.editable = true;
        
        MetadataService.ProfileFieldLevelSecurity fieldSec2 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec2.field = objName+'.folderName__c';
        fieldSec2.editable=true;
        
        MetadataService.ProfileFieldLevelSecurity fieldSec3 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec3.field = objName+'.folderCreationDate__c';
        fieldSec3.editable=true;
        
        MetadataService.ProfileFieldLevelSecurity fieldSec4 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec4.field = objName+'.folderSentDate__c';
        fieldSec4.editable=true;
        
        MetadataService.ProfileFieldLevelSecurity fieldSec5 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec5.field = objName+'.folderDocumentIds__c';
        fieldSec5.editable=true;
        
        MetadataService.ProfileFieldLevelSecurity fieldSec6 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec6.field = objName+'.folderStatus__c';
        fieldSec6.editable=true;
        
        MetadataService.ProfileFieldLevelSecurity fieldSec7 = new MetadataService.ProfileFieldLevelSecurity();
        fieldSec7.field = 'Folder_Details_With_Obj_Name__c.'+objName;
        fieldSec7.editable=true;
        
        prfl.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec1,fieldSec2,fieldSec3,fieldSec4,fieldSec5,fieldSec6,fieldSec7} ;
            
            List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { prfl });
        handleSaveResults(results[0]);
    }
    
    public static MetadataService.MetadataPort createService(String sessionId){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId =sessionId;
        return service;     
    }
    
    public static void handleSaveResults(MetadataService.SaveResult saveResult){
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            
        }        
        
    }
    
}