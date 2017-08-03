@RestResource(urlMapping='/UpdateFolderStatus/*')
global with sharing class UpdateFolderStatusService{
    @HttpPost 
    global static void  doPost(){
        RestRequest restreq = RestContext.request;
        RestResponse res = RestContext.response;
        
        String postBody = restreq.requestBody.toString();
        RequestWrapper rqstWrprObj = (RequestWrapper) JSON.deserialize(postBody, RequestWrapper.class);
        
        
        String folderId = rqstWrprObj.folderId;
        String updatedFldrStatus = rqstWrprObj.updatedStatus;
        
        ResponseWrapper resp = new ResponseWrapper();
        
        List<Folder_Details_With_Obj_Name__c> lstFldrDtls = [SELECT Folder_Id__c,Folder_Name__c,Folder_Status__c,Folder_Creation_Date__c,Folder_Sent_Date__c,Folder_Document_Ids__c,Object_Name__c,SF_Record_Id__c FROM Folder_Details_With_Obj_Name__c where Folder_Id__c =: folderId];
        if(lstFldrDtls != null && lstFldrDtls.size() > 0){
            if(lstFldrDtls.get(0).Folder_Status__c != updatedFldrStatus){
                lstFldrDtls.get(0).Folder_Status__c = updatedFldrStatus;
                update lstFldrDtls;
                resp.status = 'Success';
            }else{
                resp.status = 'Failure';
            }            
            String query = 'select id,folderId__c,folderStatus__c from ' + lstFldrDtls.get(0).Object_Name__c + ' where id = \'' + lstFldrDtls.get(0).SF_Record_Id__c + '\'';
            List<SObject> lstObjs = Database.query(query);
            if(lstObjs != null && lstObjs.size() > 0){
                if(lstObjs.get(0).get('folderStatus__c') != updatedFldrStatus){
                    lstObjs.get(0).put('folderStatus__c',updatedFldrStatus); 
                    update lstObjs;                    
                    // resp.status = 'Success';
                }else{
                    // resp.status = 'Failure';
                }               
            }
            String resp_JSON = JSON.serializePretty(resp);
            res.responseBody = Blob.valueOf(resp_JSON);
        }else{
            resp.status = 'Failure';
            String resp_JSON = JSON.serializePretty(resp);
            res.responseBody = Blob.valueOf(resp_JSON);
        }
    }
    
    global class RequestWrapper{
        public String folderId;
        public String updatedStatus;
    }
    
    global class ResponseWrapper{
        public String status;
    }
}