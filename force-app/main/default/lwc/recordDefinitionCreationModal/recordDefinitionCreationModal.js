import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import createDefinition from '@salesforce/apex/RecordDefinitionService.createDefinition';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecordDefinitionCreationModal extends LightningModal {

    @track id = "";
    @track definitionName = "";
    @track objectName = "";
    @track inputList = [];
    nextKey = 0;

    @api content;

    connectedCallback() {

        try {
            if (this.content == null) {
                return;
            }

            this.id = this.content.id;
            this.definitionName = this.content.Name;
            this.objectName = this.content.Object__c;
            this.inputList = JSON.parse(this.content.Record_Values__c);

        } catch (error) {
            console.log(error);
        }

    }

    handleSave() {
        const recordDefinitionDto = {
            id: this.id,
            name: this.definitionName,
            obj: this.objectName,
            fieldToValueWithKeys: this.inputList
        };

        const recordDefinitionDtoString = JSON.stringify(recordDefinitionDto);

        createDefinition({ recordDefinitionDtoString })
            .then(() => {
                this.close();
                this.showToast('Success', 'Record saved successfully', 'success');
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            });
    }
    
    handleCancel() {

        this.close();

    }

  
    handleAddClick() {
      this.inputList = [...this.inputList, 
        { 
            key: this.nextKey++, 
            fieldToValue: {
                field: "",
                value: ""
            }
        }
    ];
    }
  
    handleDeleteClick(event) {
      const index = event.target.dataset.index;
      this.inputList = this.inputList.filter((_, i) => i !== parseInt(index, 10));
    }

    handleDefinitionNameInputChange(event) {
        const inputValue = event.target.value;
        this.definitionName = inputValue;
    }

    handleObjectNameInputChange(event) {
        const inputValue = event.target.value;
        this.objectName = inputValue;
    }


    handleFieldNameInputChange(event) {
        const key = event.target.id.substr(0, event.target.id.indexOf('-'));
        const inputValue = event.target.value;
        this.inputList = this.inputList.map(input => {

            if (input.key == key) {
                input.fieldToValue.field = inputValue;
            }

            return input;
        });
    }

    handleValueInputChange(event) {
        const key = event.target.id.substr(0, event.target.id.indexOf('-'));
        const inputValue = event.target.value;
        this.inputList = this.inputList.map(input => {
            if (input.key == key) {
                input.fieldToValue.value = inputValue;
            }
            return input;
        });
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