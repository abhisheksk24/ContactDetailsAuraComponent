global class BatchDemo1 implements Database.Batchable<SObject>{

    private Integer magicNum = 0;
    
    

    global Database.QueryLocator StaticResourceCalloutMock(Database.BatchableContext bc){
        return Database.getQueryLocator([Select Id, Name From Account]);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){
        System.debug('In the execute method');
        for(Integer i=0; i<5; i++){
            magicNum = i;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('In the finish method');
        System.debug('magicNum' + magicNum);
    }

    executeit(){
        BatchDemo1 bd = new BatchDemo1();
        Database.executeBatch(bd);
    }
} 