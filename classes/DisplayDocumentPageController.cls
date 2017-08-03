public with sharing class DisplayDocumentPageController {
    //public String sfId;
    public String foldrAccssUrl {get;set;}
    
    public DisplayDocumentPageController(){
        String sfId;
        if(ApexPages.currentPage().getParameters().get('sfRcrdId') != null){
            sfId = ApexPages.currentPage().getParameters().get('sfRcrdId');
        }
        
        Folder_Details_With_Obj_Name__c fdObj = [select id,Folder_Id__c,Folder_Status__c from Folder_Details_With_Obj_Name__c where id =: sfId];
        if(fdObj != null && fdObj.Folder_Id__c != null){
            String resBody = eSignGenieUtils.sendESignGenieReqst('/folders/myfolder?folderId='+fdObj.Folder_Id__c, 'GET', null);
            ResponseWrapper respnsWrprObj = (ResponseWrapper) JSON.deserialize(resBody, ResponseWrapper.class);
            system.debug('REsponse of Display ::::'+respnsWrprObj.folder.folderRecipientParties.get(0));
            /*if(respnsWrprObj != null){
                List<FolderRcpntParties> lstFdlRcpObj = respnsWrprObj.folder.folderRecipientParties;
                if(lstFdlRcpObj != null && lstFdlRcpObj.size() > 0){
                    foldrAccssUrl = lstFdlRcpObj.get(0).folderAccessURL;
                }
            }*/
            if(respnsWrprObj != null){
                foldrDetails fldrObj = respnsWrprObj.folder;
                if(fldrObj != null && fldrObj.folderAccessURLForAuthor != null){
                    foldrAccssUrl = fldrObj.folderAccessURLForAuthor;
                }
            }
        }
    }
    
    public class ResponseWrapper{
        public foldrDetails folder;
    }
    
    public class foldrDetails {
        public List<FolderRcpntParties> folderRecipientParties;
        public String folderAccessURLForAuthor;
    }
    public class FolderRcpntParties{
        public String folderAccessURL;
        public String partyId;
    }

}