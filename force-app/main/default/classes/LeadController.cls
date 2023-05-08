public class LeadController {
    public static Http http = new Http();
    
    public static HTTPResponse response;
    public static HttpRequest request;
    public static Id recordId;
    public static lead ld;
    
     public LeadController(ApexPages.StandardController Controller)
        {
            Controller.addFields(new List<String>{'firstName', 'lastName', 'phone', 'email', 'company', 'status'});
            ld = (Lead)controller.getRecord();
            recordId = ld.Id;
        }
     //Method which is called from the Visual Force page Action attribute
    
     public PageReference leadrecordpage()
        {
            PageReference pageRef = new PageReference('/'+recordId);
            pageRef.setRedirect(true);
            
            NewRequestWrapper nw = new NewRequestWrapper();
            nw.Id = recordId;
            nw.firstName = ld.FirstName;
            nw.lastName = ld.LastName;
            nw.phone = ld.phone;
            nw.email = ld.email;
            nw.company = ld.company;
            nw.status = ld.status;
            system.debug('The lead : ' +nw);
            string serialld = JSON.serialize(nw);
            addLead(serialld);
            return pageRef; //Returns to the lead page
        }

     public class NewRequestWrapper
        {
            public Id Id{get;set;}
            public String firstName {get; set;}
            public String lastName {get; set;}
            public String phone {get; set;}
            public String email {get; set;}
            public String company {get; set;}
            public String status{get; set;}
        }
    
    @future(callout=true) // cannot call future method from constructor & cannot make a method future if the paramarter is not a primitive datattype
    public static void addLead(string newLead)
        {
        
            request = new HttpRequest();
            request.setMethod('PUT');
            request.setEndpoint('callout:LeadManagementCredentials/services/apexrest/leadTest');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');    //request.setHeader('Authorization', 'Bearer'+Token);
            request.setBody(newLead);
            
            try
                {
                    response = http.send(request);
                    System.debug(response.getBody());
                }
            catch(exception e)
                {
                    system.debug(e.getCause());
                }
        }
    }