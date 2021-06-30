var $ = require('jquery');
window.jQuery = $;

initialize_email_checkboxes = function() {
    $('[id=email_form_release_switch]').click(function () {
        var i = $(this).closest('.card').find("input[type='email']");
        if (this.checked) {
            i.removeAttr('readonly');
            i.fadeOut(100).fadeIn(100).fadeOut(100).fadeIn(100);
        } else {
            i.attr('readonly', 'readonly');
        }
    });
};

$(document).ready(initialize_email_checkboxes);