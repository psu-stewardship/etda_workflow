// This is a manifest file that'll be compiled into author.js, which will include all the files
// listed below.
//

//var $ = require('jquery');
//window.jQuery = $;

require('bootstrap/dist/css/bootstrap.css');
require('../author/invention_disclosure.js');
require('../author/committee_members');
require('../author/toggle_committee_email_form.js');
require('../styles/author/committee.scss');
require('../styles/author/screen.scss');
// Must be included last in order for close icon to appear on keyword tag
require('../styles/author/tag-it.scss');
require('../author/populate_program_head.js');
