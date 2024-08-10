import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPublicUrl from '@salesforce/apex/PublicUrlBuilderController.getPublicUrl';
import getAvailableSessions from '@salesforce/apex/PublicUrlBuilderController.getAvailableSessions';

const DAYS_OF_WEEK = [
    { label: 'Sunday', value: 'Sunday' },
    { label: 'Monday', value: 'Monday' },
    { label: 'Tuesday', value: 'Tuesday' },
    { label: 'Wednesday', value: 'Wednesday' },
    { label: 'Thursday', value: 'Thursday' },
    { label: 'Friday', value: 'Friday' },
    { label: 'Saturday', value: 'Saturday' }
];

export default class PublicUrlBuilder extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    error;

    isLoading = false;
    showFilterPanel = false;
    urlIsCopied = false;

    wiredUrl = [];
    baseUrl;
    wiredSessions = [];
    availableSessions = [];
    daysOfWeek = DAYS_OF_WEEK;

    /*************************
     * Selected Filters
     *************************/
    filters = {};
    filteredDays = [];
    filteredAge;
    filteredStartDate;
    filteredEndDate;
    filteredSession;

    get sessionOptions() {
        let options = [];
        if (this.availableSessions && this.availableSessions.length > 0) {
            this.availableSessions.forEach(session => {
                options.push(this.getSessionOption(session));
            });
        }
        return options;
    }

    getSessionOption(session) {
        console.log(':::: session --> ',JSON.stringify(session));
        return {
            label: session.Name,
            value: session.Id
        };
    }

    @wire(getPublicUrl, {objApiName: '$objectApiName', recordId: '$recordId'})
    wiredUrlResult(result) {
        this.wiredUrlResult = result;
        this.isLoading = true;
        if (result.data) {
            this.baseUrl = result.data;
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.baseUrl = undefined;
            this.error = result.error;
            this.isLoading = false;
        }
    }

    @wire(getAvailableSessions)
    wiredSessionResult(result) {
        this.isLoading = true;
        this.wiredSessions = result;
        if (result.data) {
            this.availableSessions = result.data;
            console.table(this.availableSessions);
            this.error = undefined;
            this.availableSessions = result.data;
            this.isLoading = false;
        } else if (result.error) {
            this.availableSessions = undefined;
            this.error = result.error;
            this.isLoading = false;
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
        if (this.filteredSession) {
            filters['session'] = this.filteredSession;
        }
        if (this.filteredStartDate || this.filteredEndDate) {
            const filteredDateRange = [this.filteredStartDate, this.filteredEndDate];
            filters['dateRange'] = filteredDateRange;
        }
        return '&filters=' + JSON.stringify(filters);
    }

    get hasFilters() {
        return this.filteredAge || 
            this.filteredDays.length > 0 || 
            this.filteredSession ||
            this.filteredStartDate ||
            this.filteredEndDate;
    }

    handleToggleFilterPanel() {
        this.showFilterPanel = !this.showFilterPanel;
    }

    handleDaysOfWeekChange(event) {
        this.filteredDays = event.detail.value;
    }
    
    handleAgeChange(event) {
        this.filteredAge = event.detail.value;
    }

    handleSessionChange(event) {
        console.log(event.detail.value);
        this.filteredSession = event.detail.value;
    }

    handleStartDateChange(event) {
        console.log(event.detail.value);
        this.filteredStartDate = event.detail.value;
    }

    handleEndDateChange(event) {
        console.log(event.detail.value);
        this.filteredEndDate = event.detail.value;
    }

    handleCopyUrl() {
        if (!this.url) {
            return;
        }

        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(this.url)
            .then(() => {
                this.showToast('Success', 'URL copied to clipboard', 'success');
            })
            .catch(err => {
                this.showToast('Error', 'URL could not be copied', 'error');
                console.error('Failed to copy text: ', err);
            });
        } else {
            let input = document.createElement("input");
            input.value = this.url;
            document.body.appendChild(input);
            input.focus();
            input.select();
            document.execCommand("Copy");
            input.remove();
            this.showToast('Success', 'URL copied to clipboard', 'success');
        }

        this.urlIsCopied = true;
        setTimeout(() => {
            this.urlIsCopied = false;
        }, 3000);
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
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

}