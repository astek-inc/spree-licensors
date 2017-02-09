//= require jquery-ui/datepicker

// From assets/javascripts/spree/backend/admin.js
var DYW = DYW || {
    handle_date_picker_fields: function(){
        $('.datepicker').datepicker({
            dateFormat: 'yy/mm/dd',
            // dayNames: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            // firstDay: Spree.translations.first_day,
            // monthNames: Spree.translations.month_names,
            prevText: 'Previous',
            nextText: 'Next',
            showOn: 'focus'
        });

        // Correctly display range dates
        $('.date-range-filter .datepicker-from').datepicker('option', 'onSelect', function(selectedDate) {
            $('.date-range-filter .datepicker-to' ).datepicker( 'option', 'minDate', selectedDate );
        });
        $('.date-range-filter .datepicker-to').datepicker('option', 'onSelect', function(selectedDate) {
            $('.date-range-filter .datepicker-from' ).datepicker( 'option', 'maxDate', selectedDate );
        });
    }
};

$(function() {
    DYW.handle_date_picker_fields();
});
