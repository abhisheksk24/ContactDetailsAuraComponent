global class AccountBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {//implementing interfaces
    global Database.QueryLocator start(Database.BatchableContext bc) { // start method to fetch records
    Datetime oneHourAgo = System.now().addHours(-1);//Get DateTime value for one hour ago
    return Database.getQueryLocator ([ SELECT Id, Name, Phone, Website, Rating, LastModifiedDate //soql query to fetch last 1 hour records
    FROM Account
    WHERE LastModifiedDate >=: oneHourAgo]);
    }
    global void execute(Database.BatchableContext bc, List<Account> accList){ //execute method
    system.debug('Current Scope is =='+accList.size());
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('callout:SFDCBC/services/apexrest/Account');
    request.setMethod('PUT');
    request.setHeader('Content-Type', 'application/json;charset.UTF-8');
    string jd=JSON.serialize(accList); //converting acclist into json format
    request.setBody(jd);
    system.debug('send json'+jd);
    HttpResponse response = new HttpResponse();
    try{
    response = http.send(request);
    system.debug('getStatusCode: '+ response.getStatusCode());
    System.debug(response);
    }
    catch(exception e){
    system.debug(e.getMessage());
    }
    if(response.getStatusCode() != 201) {
    System.debug('The status code returned was not expected:'+ response.getStatusCode() + ' '+ response.getStatus());
    }
    else{
    System.debug(response.getBody());
    }
    }
    global void finish(Database.BatchableContext bc){
    // exeCute any post-processing operations
    system.debug('Data upserted');
    }
    global void execute(SchedulableContext sc){
    AccountBatch m1 = new AccountBatch();
    Id jobId = Database.executeBatch(m1);
    System.debug('JobId'+jobId);
    }
    }