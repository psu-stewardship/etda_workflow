// This is a manifest file that'll be compiled into base.js, which will include all the files
// listed below.
//
//= require bootstrap-sprockets   */

var $ = require('jquery');
window.jQuery = $;

require('../styles/base/_base.scss');
require('bootstrap');
require('jquery-ui');
require('jquery-ujs');

require('jquery-ui/ui/widgets/spinner');
require('jquery-ui/ui/widgets/button');

// require('bootstrap-modal');
require('../../../vendor/assets/javascripts/tag-it.js');
require('../../../vendor/assets/javascripts/breakpoints.js');
require('../base/cocoon.js');
require('../base/alerts.js');
require('../base/display_first_nested_field.js');
require('../base/layout.js');
require('jquery-ui/ui/widgets/autocomplete');
require('../base/ldap_lookup.js');
require('../base/tagit.js');
require('../images/PS_HOR_REV_RGB_2C.png');
require('../images/PS_UL_REV_RGB_2C.png');
require('../admin/edit_submission_form.js');
require('../base/committee_member_focus.js');
require('../base/initialize_tooltips.js');
require('../base/aria_defended_date.js');
require('../base/fees_confirm_dialog.js');
require('../base/collapse_indicators.js');
