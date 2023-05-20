import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import createRecords from '@salesforce/apex/RecordOperationService.createRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecordCreationModal extends LightningModal {

    @api content;
    @track numberOfCreation = 1;

    handleCancel() {
        this.close();
    }

    handleCreate() {

        try {

            const recordDefinitionDto = {
                id: this.content.Id,
                name: this.content.Name,
                obj: this.content.Object__c,
                keyedFieldValues: JSON.parse(this.content.Field_Values__c)
            };
    
            const recordDefinitionDtoString = JSON.stringify(recordDefinitionDto);

            const numberOfCreation = this.numberOfCreation;
    
            createRecords({ numberOfCreation, recordDefinitionDtoString })
                .then(() => {
                    this.close();
                    this.showToast('Success', 'Record created successfully', 'success');
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.showToast('Error', error.body.message, 'error');
                });
        } catch (error) {
            console.log( "error: " + error);
        }


    }

    handleNumberOfCreationInputChange(event) {
        const inputValue = event.target.value;
        this.numberOfCreation = inputValue;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant
        });
        this.dispatchEvent(event);
    }

}