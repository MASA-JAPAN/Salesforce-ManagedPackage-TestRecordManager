import { LightningElement, track } from "lwc";
import RecordDefinitionModal from 'c/recordDefinitionModal';
import RecordCreationModal from 'c/recordCreationModal';
import getAllRecordDefinitions from '@salesforce/apex/RecordDefinitionService.getAllRecordDefinitions';
import searchRecordDefinitions from '@salesforce/apex/RecordDefinitionService.searchRecordDefinitions';
import { subscribe, unsubscribe, publish } from 'c/pubsub';

export default class RecordManagement extends LightningElement {

    @track isSpinning = false;
    @track searchInput = "";

    @track recordDefinitions;
    columns = [
        { label: 'Definition', fieldName: 'Name' },
        { label: 'Object', fieldName: 'MJ_TRM__Object__c' },
        {
            label: 'Created At', 
            fieldName: 'CreatedDate', 
            type: 'date', 
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            },
            sortable: false 
        },
        {
            label: 'Modified At', 
            fieldName: 'LastModifiedDate', 
            type: 'date', 
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            },
            sortable: false 
        },
        { label: 'View Definition', type: 'button', typeAttributes: { label: 'View', name: 'View', title: 'View', disabled: false } },
        { label: 'Create Records', type: 'button', typeAttributes: { label: 'Create', name: 'Create', title: 'Create', disabled: false, variant: 'brand' } }
    ];

    connectedCallback() {

        getAllRecordDefinitions()
            .then(result => {
                this.recordDefinitions = result;

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body.message, 'error');
            });

        subscribe('refreshdatatable', this.handleRefreshDatatable.bind(this));
    }

    handleClickNewDefinition() {
        RecordDefinitionModal.open({
            size: 'medium',
            content: null,
            label: 'Record Definition'
        });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'View':
                RecordDefinitionModal.open({
                    size: 'medium',
                    content: row,
                    label: 'Record Definition'
                });

                break;
            case 'Create':

                RecordCreationModal.open({
                    size: 'small',
                    content: row,
                    label: 'Record Creation'
                });


                break;
            default:
                break;
        }
    }

    handleRefreshDatatable() {

        this.openSpinner();

        searchRecordDefinitions({searchInput: this.searchInput})
            .then(result => {
                this.recordDefinitions = result;

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.closeSpinner();
            });

    }

    handleSearchInputChange(event) {
        const inputValue = event.target.value;
        this.searchInput = inputValue;
    }

    keyEventOfSearchInput(event) {
        if (event.key == 'Enter') {

            this.openSpinner();

            searchRecordDefinitions({searchInput: event.target.value})
                .then(result => {
                    this.recordDefinitions = result;
                })
                .catch(error => {
                    console.error(error);
                    this.showToast('Error', error.body.message, 'error');
                })
                .finally(() => {
                    this.closeSpinner();
                });

        }
    }

    openSpinner() {
        this.isSpinning = true;
    }

    closeSpinner() {
        this.isSpinning = false;
    }

}