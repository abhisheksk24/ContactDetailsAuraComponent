public with sharing class LeadSyncService {
    @AuraEnabled
    public static String syncLead(Id leadId) {
        try {
            syncLeadToDestination(leadId);
            return 'Lead synced successfully!';
        } catch (Exception e) {
            System.debug('Error in syncLead: ' + e.getMessage());
            return 'Error syncing the Lead: ' + e.getMessage();
        }
    }

    @future(callout=true)
    private static void syncLeadToDestination(Id leadId) {
        Lead lead = [
            SELECT Id, FirstName, LastName, Email, Company
            FROM Lead
            WHERE Id = :leadId
        ];
        
        LeadData leadData = new LeadData(lead);
        String jsonString = JSON.serialize(leadData);
        System.debug('Serialized Lead: ' + jsonString);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:LeadManagementCredentials/services/apexrest/LeadSync');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonString);
        
        HttpResponse res = http.send(req);
        System.debug('Response Status: ' + res.getStatus());
        System.debug('Response Body: ' + res.getBody());
        if (res.getStatusCode() != 200) {
            System.debug('Error in syncLeadToDestination: ' + res.getBody());
            throw new AuraHandledException('Error syncing the Lead: ' + res.getBody());
        }
    }

    public class LeadData {
        public Id Id;
        public String FirstName;
        public String LastName;
        public String Email;
        public String Company;
      

        public LeadData(Lead lead) {
            this.Id = lead.Id;
            this.FirstName = lead.FirstName;
            this.LastName = lead.LastName;
            this.Email = lead.Email;
            this.Company = lead.Company;
        
        }
    }
}