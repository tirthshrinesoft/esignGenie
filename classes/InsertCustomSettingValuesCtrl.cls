global with sharing class InsertCustomSettingValuesCtrl implements InstallHandler{
    global void onInstall(InstallContext context) {
        eSignGenieConfiguration__c eSignConf = new eSignGenieConfiguration__c(Name='Configuration',Client_ID__c = '10d6154ade2148e28ce62bfa89967fa0',Client_Secret__c='bca357ab9bbe44cc99da39688f506096',eSign_Genie_Api_URL__c='https://www.esigngenie.com/esign/api',eSign_Genie_URL__c = 'https://www.esigngenie.com/esign/oauth2/authorize', End_URL__c = 'https://www.esigngenie.com/esign/api/oauth2/access_token',Batch_Run_Time__c = 1);
        insert eSignConf;
        
        Datetime dt = System.now();
        
        Datetime newDt = dt.addHours(1);
        
        string day = string.valueOf(newDt.day());
        String month = string.valueOf(newDt.month());
        String hour = string.valueOf(newDt.hour());
        String minute = string.valueOf(newDt.minute() );
        String second = string.valueOf(newDt.second());
        String year = string.valueOf(newDt.year());
        
        String strSchedule = second +' ' + minute+' '+ hour +' '+ day+' '+month+' ?'+' '+ year;
        SchedulerFolderStatusUpdate s1 = new SchedulerFolderStatusUpdate();
        String jobID = system.schedule('Batch Folder Status Running' + strSchedule, strSchedule, s1);
    }
}