// This is a manifest file that'll be compiled into admin.js, which will include all the files
// listed below.
//
//require('popper.js');
require('../admin/bulk_selectors_and_actions.js');
//require('../admin/edit_submission_form.js');
require('bootstrap/dist/css/bootstrap.min.css');
require('bootstrap/dist/css/bootstrap.css');
require('../admin/initialize_datatables.js');
require('../styles/admin/datatable_images.css.scss');
require( 'datatables.net-bs4' );
require('../styles/base/_base.scss');
require('../styles/admin/screen.scss');
require('../styles/admin/print.scss');
require('../admin/initialize_report_tables.js');
require('../admin/print_format_review.js');
require('../admin/send_email_reminder.js');
require('../admin/approval_configuration_radios.js');
