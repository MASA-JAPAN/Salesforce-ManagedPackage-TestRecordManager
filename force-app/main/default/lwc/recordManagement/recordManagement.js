import { LightningElement, wire, track } from "lwc";
import { refreshApex } from '@salesforce/apex';
import RecordDefinitionCreationModal from 'c/recordDefinitionCreationModal';
import getRecordDefinitions from '@salesforce/apex/RecordDefinitionService.getRecordDefinitions';

export default class RecordManagement extends LightningElement {

    @track clickedRow;

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
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date' },
        { label: 'View Definition', type: 'button', typeAttributes: { label: 'View', name: 'View', title: 'View', disabled: false } },
        { label: 'Create Records', type: 'button', typeAttributes: { label: 'Create', name: 'Create', title: 'Create', disabled: false, variant: 'brand' } }
    ];

    @wire(getRecordDefinitions)
    wiredRecordDefinitions(result) {

        const { error, data } = result;
        if (data) {
            this.recordDefinitions = data;
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        this.refreshData();
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'View':
                this.clickedRow = {
                    Name: row.Name,
                    Object__c: row.Object__c
                };

                console.log(row);

                RecordDefinitionCreationModal.open({
                    size: 'medium',
                    content: row,
                    label: 'Create Record Definition'
                });

                break;
            case 'Create':
                break;
            default:
                break;
        }
    }

    refreshData() {
        return refreshApex(this.recordDefinitions);
    }
}