import { LightningElement, wire, track } from "lwc";
import { refreshApex } from '@salesforce/apex';
import RecordDefinitionCreationModal from 'c/recordDefinitionCreationModal';
import RecordCreationModal from 'c/recordCreationModal';
import getRecordDefinitions from '@salesforce/apex/RecordDefinitionService.getRecordDefinitions';
import { subscribe, unsubscribe, publish } from 'c/pubsub';

export default class RecordManagement extends LightningElement {

    @track isLoading = false; 

    async handleClick() {
        const result = await RecordDefinitionCreationModal.open({
            size: 'medium',
            content: null,
            label: 'Create Record Definition'
        });
        console.log(result);
    }

    @track recordDefinitions;
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Object', fieldName: 'Object__c' },
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

        getRecordDefinitions()
            .then(result => {
                this.recordDefinitions = result;

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            });

        subscribe('refreshdatatable', this.handleRefreshDatatable.bind(this));
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'View':
                RecordDefinitionCreationModal.open({
                    size: 'medium',
                    content: row,
                    label: 'Create Record Definition'
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

        this.isLoading = true;

        getRecordDefinitions()
            .then(result => {
                this.recordDefinitions = result;

            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', error, 'error');
            });

        this.isLoading = false;

    }

}