import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPublicUrl from '@salesforce/apex/PublicUrlBuilderController.getPublicUrl';

export default class PublicUrlBuilder extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    isLoading = false;
    error;

    wiredUrlResult = [];
    baseUrl;

    filters = {};

    filteredDays = [];
    filteredAge;

    get daysOfWeek() {
        return [
            { label: 'Sunday', value: 'Sunday' },
            { label: 'Monday', value: 'Monday' },
            { label: 'Tuesday', value: 'Tuesday' },
            { label: 'Wednesday', value: 'Wednesday' },
            { label: 'Thursday', value: 'Thursday' },
            { label: 'Friday', value: 'Friday' },
            { label: 'Saturday', value: 'Saturday' }
        ];
    }

    @wire(getPublicUrl, {objApiName: '$objectApiName', recordId: '$recordId'})
    wiredResult(result) {
        this.wiredUrlResult = result;
        this.isLoading = true;
        if (result.data) {
            this.isLoading = false;
            this.baseUrl = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.isLoading = false;
            this.baseUrl = undefined;
            this.error = result.error;
        }
    }

    get url() {
        return this.baseUrl + (this.hasFilters ? this.filterString : '');
    }

    get filterString() {
        let filters = {};
        if (this.filteredAge) {
            filters['age'] = this.filteredAge;
        }
        if (this.filteredDays.length > 0) {
            filters['dayOfWeek'] = this.filteredDays;
        }
        return '&filters=' + JSON.stringify(filters);
    }

    get hasFilters() {
        return this.filteredAge || this.filteredDays.length > 0;
    }

    handleDaysOfWeekChange(event) {
        this.filteredDays = event.detail.value;
    }
    
    handleAgeChange(event) {
        this.filteredAge = event.detail.value;
    }

    handleGoToUrl() {
        window.open(this.url, '_blank');
    }

    handleError(error) {
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map((e) => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
            title: 'Error loading contact',
            message,
            variant: 'error',
            }),
        );
    }

}