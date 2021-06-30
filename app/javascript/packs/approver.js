// This is a manifest file that'll be compiled into approver.js, which will include all the files
// listed below.
//

//var $ = require('jquery');
//window.jQuery = $;

require('bootstrap/dist/css/bootstrap.min.css');
require('bootstrap/dist/css/bootstrap.css');
require('../styles/author/committee.scss');
require('../styles/author/screen.scss');
require('../styles/base/_base.scss');
require('../admin/initialize_datatables.js');
require('../styles/admin/datatable_images.css.scss');
require( 'datatables.net-bs4' );
require('../styles/admin/screen.scss');
// Must be included last in order for close icon to appear on keyword tag
require('../styles/author/tag-it.scss');