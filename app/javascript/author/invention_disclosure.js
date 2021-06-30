/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;

const bind_to_access_level = () =>
    $('body').on('click', 'div.author div.submission_access_level', function(e) {
        if ($('div.author #submission_access_level_restricted').prop('checked')) {
            $('div#invention').removeClass('d-none');
            $('#submission_invention_disclosures_attributes_0_id_number').focus();
        } else {
            $('input#submission_invention_disclosures_attributes_0_id_number').attr('value', '');
            $('div#invention').addClass('d-none');
            e.preventDefault;
        }

        if ($('div.author #submission_access_level_restricted_to_institution').prop('checked')) {
            $('div#restricted_note').removeClass('d-none');
            return $('#submission_restricted_notes').focus();
        } else {
            $('div#restricted_note').addClass('d-none');
            return e.preventDefault;
        }
    })
;


$(document).ready(bind_to_access_level);



