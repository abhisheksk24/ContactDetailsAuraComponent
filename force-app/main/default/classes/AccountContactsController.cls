public with sharing class AccountContactsController {
    @AuraEnabled
    public static List<Contact> getContacts(Id accountId) {
    return [
        SELECT Id, FirstName, LastName, Email, Phone, Account.BillingCity, Account.BillingState 
        FROM Contact 
        WHERE AccountId = :accountId
        ];
    
    }
}
