/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

var $ = require('jquery');
window.jQuery = $;
var DataTable = require('datatables.net-bs4');

$('table').DataTable();

//require( '../../../node_modules/datatables.net' );

setup_datatables = function() {

    let admin_submission_options, degree_options, program_options;
    table = $('.datatable');

    if (table === null) { return; }

    const common_options = {
        deferRender: true,
        processing: true,
        lengthMenu: [[25, 50, 100, 200, 500, -1], [25, 50, 100, 200, 500, "All"]],
        pageLength: 25,
        stateSave: true,
        stateDuration: 60 * 60 * 24,
        paginate: true,
        language: {
            loadingRecords: "&nbsp;",
            processing: "<div class='spinner'><div class='spinner-info'>Loading Data...</div></div>"
        },
        fnDrawCallback() {
            const pagination = $('.dataTables_paginate');
            const buttons_we_care_to_see = pagination.find('.paginate_button').not('.disabled, .active');
            $('span.record-count-top').text(display_page_top_info($('.datatable').DataTable()));
            if (buttons_we_care_to_see.length) {
                return pagination.show();
            } else {
                return pagination.hide();
            }
        }
    };

    const author_options = {
        order: [[ 1, "asc" ]],
        ajax: (table.attr('data-ajax-url') + '.json')
    };

    $('#programs-index.datatable').dataTable(
        (program_options = {
            ajax: (table.attr('data-ajax-url') + '.json'),
            rowCallback(row, program_data) {
                const program_status = program_data[1];
                if (program_status === "No") {
                    return $(row).addClass('inactive');
                }
            },
            initComplete() {
                let startswith;
                return startswith= $('#starts-with_check').on('change', function(event){
                    $.fn.dataTable.ext.search.push(function(settings, data, dataIndex) {

//only use checkbox for matching on beginning of line on programs page
                        if  ($.fn.dataTable.tables('visible')[0]['id'] !== 'programs-index') { return true; }

                        startswith = $('#starts-with_check').prop('checked') || false;
                        const term = $('#programs-index_filter input').val().toLowerCase() || '';
                        let i = 0;
                        while (i < data.length) {
                            const position = (data[i].toString().toLowerCase()).indexOf(term);
                            if ((startswith && (position === 0)) || (!startswith && (position >=0)))
                              { return true; }
                            i++;
                        }
                    });

                    return false;
                });
            }

        }),
        $.extend(program_options, common_options)
    );

    $('#degrees-index.datatable').dataTable(
        (degree_options = {
            ajax: (table.attr('data-ajax-url') + '.json'),
            rowCallback(row, degree_data) {
                const degree_status = degree_data[1];
                if (degree_status === "No") {
                    return $(row).addClass('inactive');
                }
            }
        }),
        $.extend(degree_options, common_options)
    );

    $('#authors-index.datatable').dataTable(
        $.extend(author_options, common_options)
    );

    $('#authors-email-contact-list.datatable').dataTable(
        $.extend(author_options, common_options)
    );

    const $approver_select_reviews = $("#approver-select-reviews");
    const approver_select = $('<select id="reviews-select" class="form-control input-sm">');
    if ($('.approver-committees-index.datatable').length) {
        $approver_select_reviews.append(approver_select);
        approver_select.append(`<option value="Active Reviews">Active Reviews</option>`);
        approver_select.append(`<option value="Finished Reviews">Finished Reviews</option>`);
        approver_select.append(`<option value="All Reviews">All Reviews</option>`);
    }

    $('#approver-committees-index.datatable').dataTable(
        (approver_options = {
            order: [[3, 'desc']],
            ajax: (table.attr('data-ajax-url') + '.json'),
            initComplete() {
                const column = this.api().column("submission_status:name");
                column.search("Waiting For Committee Review( Rejected)?|Waiting For Head Of Program Review", true, false).draw();
                approver_select.on('change', function() {
                    const val = $.fn.dataTable.util.escapeRegex($(this).val() || '');
                    if (val === 'Active Reviews') {
                        column.search("Waiting For Committee Review( Rejected)?|Waiting For Head Of Program Review", true, false).draw();
                    } else if (val === 'Finished Reviews') {
                        column.search("Waiting For Publication Release|Released For Publication( Metadata Only)?|Waiting For Final Submission Response", true, false).draw();
                    } else {
                        column.search('').draw();
                    }
                });
            }
        }),
        $.extend(approver_options, common_options)
    );

    const column_options = () =>
        table.find('th').map(function() {
            const column = $(this);
            return { "name": column.data('name'), "orderable": column.data('orderable'), "visible": column.data('visible') };})
    ;

    // Provisioning for admin-submissions-index datatables
    function generate_semesters() {
        var semesters = [];
        var current_time = new Date()
        var current_year = current_time.getFullYear();
        for (i = current_year - 5; i < current_year + 3; i++) {
            semesters.push(`${i} Spring`);
            semesters.push(`${i} Summer`);
            semesters.push(`${i} Fall`);
        }
        semesters.push(`All Semesters`)
        return semesters;
    }

    const semesters = generate_semesters()
    const $filters = $("#row-selection-buttons");
    const select = $('<select class="form-control input-sm semester">');

    if ($('.admin-submissions-index.datatable').length) {
        const default_semester = $('.admin-submissions-index.datatable').data('default-semester');
        $filters.append($('<label class="float-right"></label>').append(select));
        for (i = 0; i < semesters.length; i++) {
            select.append(`<option value="${semesters[i]}">${semesters[i]}</option>`)
        }
        select.val(default_semester);
    }

    // Admin-submissions-index datatables
    $('.admin-submissions-index.datatable').dataTable(
        (admin_submission_options = {
            ajax: { url: (table.attr('data-ajax-url') + '.json'),
                    data: { semester: function selected_semester() {
                                return select.val().toString();
                        }
                    }
                },
            columns: column_options(),
            rowCallback(row, submission_data) {
                const id = submission_data[0];
                return $(row).attr('data-submission-id', id);
            },
            initComplete() {
                select.change(function(){
                    const table = $('.admin-submissions-index.datatable').DataTable()
                    table.clear().draw();
                    table.ajax.reload();
                });
            }
        }),
        $.extend(admin_submission_options, common_options)
    );

    $('#starts-with_check').on('click', event = $('div.dataTables_filter input').val(''));

    return $('div.dataTables_filter input').attr('placeholder', 'Search records...');
};

function display_page_top_info(info_table) {
    info_table = $('.datatable').DataTable();
    info = info_table.page.info();
    var start = info.start+1
    if (info.end == 0 && info.start == 0)
        start = 0 ;
    msg = 'Showing '+(start)+' to '+info.end+' of '+info.recordsDisplay+' entries';
    filter_msg = ' (filtered from '+info.recordsTotal+' total entries)';
    final_msg = msg;
    if (info.recordsTotal != info.recordsDisplay)
        final_msg = final_msg + filter_msg;
    return final_msg; }


$(document).ready(setup_datatables);