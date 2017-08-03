global class SchedulerFolderStatusUpdate implements Schedulable {
    
    global void execute(SchedulableContext SC){
        BatchFolderStatusUpdate b1 = new BatchFolderStatusUpdate();
        Database.executeBatch(b1);
        
        eSignGenieConfiguration__c eSignGenieConfigObj = eSignGenieConfiguration__c.getInstance('Configuration');
        if(eSignGenieConfigObj.Batch_Run_Time__c == null){
            eSignGenieConfigObj.Batch_Run_Time__c = 1;
        }
        Datetime dt = System.now();
        Datetime newDt = dt.addHours((Integer)eSignGenieConfigObj.Batch_Run_Time__c);
        //Datetime newDt = dt.addMinutes((Integer)eSignGenieConfigObj.Batch_Run_Time__c);
        
        string day = string.valueOf(newDt.day());
        String month = string.valueOf(newDt.month());
        String hour = string.valueOf(newDt.hour());
        String minute = string.valueOf(newDt.minute() );
        String second = string.valueOf(newDt.second());
        String year = string.valueOf(newDt.year());
        
        String strSchedule = second +' ' + minute+' '+ hour +' '+ day+' '+month+' ?'+' '+ year;
        SchedulerFolderStatusUpdate s1 = new SchedulerFolderStatusUpdate();
        String jobID = system.schedule('Batch Folder Status Running ' + strSchedule, strSchedule, s1);
        
        /* List<String> lstAllObjNames = new List<String>();
Set<String> setUpdateStatsObjs = new Set<String>();
for (Schema.SObjectType o : Schema.getGlobalDescribe().values()){
Schema.DescribeSObjectResult objResult = o.getDescribe();
lstAllObjNames.add(objResult.getName());
}

for(String s : lstAllObjNames){
SObjectType objToken = Schema.getGlobalDescribe().get(s);
DescribeSObjectResult objDef = objToken.getDescribe();

Map<String, SObjectField> fields = objDef.fields.getMap(); 
Set<String> fieldSet = fields.keySet();

for(String st:fieldSet) {
SObjectField fieldToken = fields.get(st);
DescribeFieldResult selectedField = fieldToken.getDescribe();
if(selectedField.getName() != null && (selectedField.getName() == 'folderId__c' || selectedField.getName() == 'folderName__c' || selectedField.getName() == 'folderSentDate__c' || selectedField.getName() == 'folderStatus__c' || selectedField.getName() == 'folderCreationDate__c' || selectedField.getName() == 'folderDocumentIds__c')){
setUpdateStatsObjs.add(s);
}
}
}

if(setUpdateStatsObjs.size() > 0){
for(String strObjName : setUpdateStatsObjs){
BatchFolderStatusUpdate b1 = new BatchFolderStatusUpdate(strObjName);
Database.executeBatch(b1,9);
}
}

/* BatchFolderStatusUpdate b1 = new BatchFolderStatusUpdate('Contact');
Database.executeBatch(b1);

BatchFolderStatusUpdate b2 = new BatchFolderStatusUpdate('Lead');
Database.executeBatch(b2, 5);

BatchFolderStatusUpdate b3 = new BatchFolderStatusUpdate('Contract');
Database.executeBatch(b3, 5);

BatchFolderStatusUpdate b4 = new BatchFolderStatusUpdate('Account');
Database.executeBatch(b4, 5);

BatchFolderStatusUpdate b5 = new BatchFolderStatusUpdate('Opportunity'); 
Database.executeBatch(b5, 5); */
    }    
}