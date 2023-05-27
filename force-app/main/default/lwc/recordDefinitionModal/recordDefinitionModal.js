import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import upsertDefinition from '@salesforce/apex/RecordDefinitionService.upsertDefinition';
import deleteDefinition from '@salesforce/apex/RecordDefinitionService.deleteDefinition';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, publish } from 'c/pubsub';

export default class RecordDefinitionModal extends LightningModal {

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

            this.id = this.content.Id;
            this.definitionName = this.content.Name;
            this.objectName = this.content.MJ_TRM__Object__c;
            this.inputList = JSON.parse(this.content.MJ_TRM__FieldValuesToEdit__c);

            let largestKey = 0;
            this.inputList.forEach(input => {
                if (input.key > largestKey) {
                    largestKey = input.key;
                }
            });

            this.nextKey = largestKey + 1;

        } catch (error) {
            console.log(error);
        }

    }

    handleSave() {
        const recordDefinitionDto = {
            id: this.id,
            name: this.definitionName,
            obj: this.objectName,
            keyedFieldValues: this.inputList
        };

        const recordDefinitionDtoString = JSON.stringify(recordDefinitionDto);

        upsertDefinition({ recordDefinitionDtoString })
            .then(() => {
                this.close();
                this.showToast('Success', 'Definition saved successfully', 'success');
                publish('refreshdatatable');

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body.message, 'error');
            });
    }
    
    handleCancel() {
        this.close();
    }

    handleDelete() {
        deleteDefinition({ id: this.id })
            .then(() => {
                this.close();
                this.showToast('Success', 'Definition deleted successfully', 'success');
                publish('refreshdatatable');

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body.message, 'error');
            });
    }
  
    handleAddClick() {
      this.inputList = [...this.inputList, 
        { 
            key: this.nextKey++, 
            fieldValue: {
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
                input.fieldValue.field = inputValue;
            }

            return input;
        });
    }

    handleValueInputChange(event) {
        const key = event.target.id.substr(0, event.target.id.indexOf('-'));
        const inputValue = event.target.value;
        this.inputList = this.inputList.map(input => {
            if (input.key == key) {
                input.fieldValue.value = inputValue;
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