var $ = require('jquery');
window.jQuery = $;

initialize_tooltips = function () {
    $('[data-toggle="tooltip"]').tooltip();
};

reinitialize_tooltips = function () {
    let add_field = $('.add_field');
    add_field.click(setTimeout(initialize_tooltips, 500));
    add_field.click(setTimeout(reinitialize_tooltips, 500));
};

$(document).ready(initialize_tooltips);
$(document).ready(reinitialize_tooltips);