import { LightningElement, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import searchContacts from '@salesforce/apex/WrapperClass.searchContacts';

//defining actions for each row of the table
const actions = [
          { label: 'View', name: 'view', iconName: 'utility:preview'},
          { label: 'Edit', name: 'edit', iconName: 'utility:edit' },
          { label: 'Delete', name: 'delete', iconName: 'utility:delete' }
        ];

//defining columns for the table
const COLUMNS = [
          { label: 'Name', fieldName: 'Name', type: 'text'},
          { label: 'Email', fieldName: 'Email', type: 'email' },
          { label: 'Mobile', fieldName: 'MobilePhone', type: 'phone'},
          { label: 'Billing City', fieldName: 'BillingCity', type: 'text'},
          { label: 'Billing State', fieldName: 'BillingState', type: 'text' },
          { label: '+', type: 'action', initialWidth: 120, typeAttributes: 
            { rowActions: actions, menuAlignment: 'right', iconName: 'utility:down', iconAlternativeText: 'Action' },
          }
        ];

export default class ContactTable extends NavigationMixin(LightningElement) {
  columns = COLUMNS; 
  contactList;    
  searchKey;     
  showTable = false;

  connectedCallback() {
    this.showTable = false;
  }
  
  //@track isEdited = false;

  handleInputChange(event) {
    let searchKeys = event.target.value;
    if (searchKeys === '') {
        this.contactList = [];
        this.showTable = false;
    }     
    else {
      this.showTable =true;
        this.searchKey = searchKeys;
        return refreshApex(this.contactList);
    }
  }

  // Retrieving contactList by calling wire with the Apex method and searchKey parameter
  @wire(searchContacts, {textKey : '$searchKey'}) contactList;
  
  //This function will create a new contact
  handleContactCreate() {
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes:
      {
        objectApiName: 'Contact',
        actionName: 'new'
      }
    });
  }

  //This function will return view, edit, delete the record based what will select in action
  callRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    this.recordId = row.Id;
    switch (actionName) {
      case 'view':
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: row.Id,
            actionName: 'view'
          }
        });
        break;

      case 'edit':
        this.editContact(row.Id);
        break;
      case 'delete':
        this.delContact();
        return refreshApex(this.contactList); // Record will be deleted
    }
  }

  editContact(recordId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        objectApiName: 'Contact',
        actionName: 'edit'   
      }
    });
    return refreshApex(this.contactList);
  }

  //This function created for deleting the record
  delContact() {
    //Invoke the deleteRecord to delete a record
    deleteRecord(this.recordId)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Record is successfully deleted',
            variant: 'success'
          })
        );
        return refreshApex(this.contactList);
      })
      .catch((error) => {
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Sorry',
            message: 'Cannot delete this record since it is associated with a case',
            variant: 'error'
          })
        );
      });
  }
}