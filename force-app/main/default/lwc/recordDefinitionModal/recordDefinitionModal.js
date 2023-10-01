import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import insertTagsIfUnexisting from '@salesforce/apex/RecordDefinitionService.insertTagsIfUnexisting';
import deleteTagsIfUnused from '@salesforce/apex/RecordDefinitionService.deleteTagsIfUnused';
import upsertDefinition from '@salesforce/apex/RecordDefinitionService.upsertDefinition';
import deleteDefinition from '@salesforce/apex/RecordDefinitionService.deleteDefinition';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // It is not possible to use ShowToastEvent from LightningModal because there is a bug in LWC.
import { subscribe, unsubscribe, publish } from 'c/pubsub';

export default class RecordDefinitionModal extends LightningModal {

    @track isSpinning = false;

    @track id = "";
    @track definitionName = "";
    @track initialTagsInput = "";
    @track tagsInput = "";
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
            this.initialTagsInput = this.content.MJ_TRM__Tag__c;
            this.tagsInput = this.content.MJ_TRM__Tag__c;
            this.objectName = this.content.MJ_TRM__Object__c;

            const configToInsert = JSON.parse(this.content.MJ_TRM__ConfigToInsert__c);

            configToInsert.fieldValues.forEach(fieldValue =>{
                this.inputList = [...this.inputList, 
                    { 
                        key: this.nextKey, 
                        fieldValue: {
                            field: fieldValue.field.apiName,
                            value: fieldValue.value
                        }
                    }
                ];
                this.nextKey++;
            })

        } catch (error) {
            console.log(error);
        }

    }

    async handleSave() {

        const initialInputTags = this.initialTagsInput?.split(';');
        const inputTags = this.tagsInput?.split(';');

        const addedTags = inputTags?.filter(inputTag => !initialInputTags?.includes(inputTag));
        const removedTags = initialInputTags?.filter(initialInputTag => !inputTags?.includes(initialInputTag));
        
        await insertTagsIfUnexisting({tags: addedTags});
        await deleteTagsIfUnused({tags: removedTags});

        let fieldValues = [];

        this.inputList.forEach(input => {
            fieldValues.push(input.fieldValue);
        });

        const recordDefinitionDto = {
            id: this.id,
            name: this.definitionName,
            tag: this.tagsInput,
            obj: this.objectName,
            fieldValues: fieldValues
        };

        const recordDefinitionDtoString = JSON.stringify(recordDefinitionDto);
        this.openSpinner();

        upsertDefinition({ recordDefinitionDtoString })
            .then(() => {
                this.close();
                this.showToast('Success', 'Definition saved successfully', 'success');
                publish('refreshdatatable');
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.closeSpinner();
            });
    }

    handleSaveAsNew() {

        let fieldValues = [];

        this.inputList.forEach(input => {
            fieldValues.push(input.fieldValue);
        });

        const recordDefinitionDto = {
            name: this.definitionName,
            obj: this.objectName,
            fieldValues: fieldValues
        };

        const recordDefinitionDtoString = JSON.stringify(recordDefinitionDto);
        this.openSpinner();

        upsertDefinition({ recordDefinitionDtoString })
            .then(() => {
                this.close();
                this.showToast('Success', 'Definition saved successfully', 'success');
                publish('refreshdatatable');
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.closeSpinner();
            });
    }
    
    handleCancel() {
        this.close();
    }

    handleDelete() {

        this.openSpinner();

        deleteDefinition({ id: this.id })
            .then(() => {
                this.close();
                this.showToast('Success', 'Definition deleted successfully', 'success');
                publish('refreshdatatable');

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.closeSpinner();
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

    handleTagInputChange(event) {
        const inputValue = event.target.value;
        this.tagsInput = inputValue;

        console.log(this.tagsInput);

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
        // toast-component is substitution for ShowToastEvent.
        this.template.querySelector('c-toast-component').showToast(
            title, message, variant
        );
    }

    openSpinner() {
        this.isSpinning = true;
    }

    closeSpinner() {
        this.isSpinning = false;
    }

}