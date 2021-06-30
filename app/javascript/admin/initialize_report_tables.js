/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//= require dataTables.js
//= require dataTables.bootstrap.js
var $ = require('jquery');
window.jQuery = $;

setup_report_tables = function() {

    let committee_report_options, custom_report_options;
    const table = $('.datatable');

    if (!table.length) { return; }

    const report_common_options = {
        ajax: (table.attr('data-ajax-url') + '.json'),
        deferRender: true,
        processing: true,
        pageLength: 25,
        stateSave: true,
        stateDuration: 60 * 60 * 24,
        paginate: false,
        language: {
            loadingRecords: '&nbsp;',
            processing: "<div class='spinner'><div class='spinner-info'>Loading Data...</div></div>",
        }
    };

    const column_options = () =>
        table.find('th').map(function() {
            const column = $(this);
            return { "name": column.data('name'), "orderable": column.data('orderable'), "visible": column.data('visible') };})
    ;

    return $('.custom-report-index.datatable').dataTable(
        (custom_report_options = {
            columns: column_options(),
            rowCallback(row, custom_report_data) {
                const id = custom_report_data[0];
                return $(row).attr('data-submission-id', id);
            },
            initComplete() {
                this.api().column( 0 ).visible( false );
                const column = this.api().column("semester_year:name");
                const default_semester = $(this).data('default-semester');
                const select = $('.semester').on('change', function() {
                    const val = $.fn.dataTable.util.escapeRegex($(this).val() || '');
                    column.search( (val ? `^${val}$` : '') , true, false).draw();
                });

                const selected_item = default_semester;

                select.val(selected_item).change();

                const $filters = $("#row-selection-buttons");

                return select.val(selected_item).prop('selected', true);
            }
        }),
        $.extend(custom_report_options, report_common_options)
    );
};

$(document).ready(setup_report_tables);