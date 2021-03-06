DROP TABLE IF EXISTS `submissions`;
CREATE TABLE `submissions` (
  `id` bigint(20) NOT NULL,
  `author_id` bigint(20) DEFAULT NULL,
  `program_id` bigint(20) DEFAULT NULL,
  `degree_id` bigint(20) DEFAULT NULL,
  `semester` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `title` varchar(400)  DEFAULT NULL,
  `format_review_notes` text DEFAULT NULL,
  `final_submission_notes` text DEFAULT NULL,
  `defended_at` datetime DEFAULT NULL,
  `abstract` text,
  `access_level` varchar(255) DEFAULT NULL,
  `has_agreed_to_terms` tinyint(1) DEFAULT NULL,
  `committee_provided_at` datetime DEFAULT NULL,
  `format_review_files_uploaded_at` datetime DEFAULT NULL,
  `format_review_rejected_at` datetime DEFAULT NULL,
  `format_review_approved_at` datetime DEFAULT NULL,
  `final_submission_files_uploaded_at` datetime DEFAULT NULL,
  `final_submission_rejected_at` datetime DEFAULT NULL,
  `final_submission_approved_at` datetime DEFAULT NULL,
  `released_for_publication_at` datetime DEFAULT NULL,
  `fedora_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `released_metadata_at` datetime DEFAULT NULL,
  `legacy_id` int(11) DEFAULT NULL,
  `final_submission_legacy_id` int(11) DEFAULT NULL,
  `final_submission_legacy_old_id` int(11) DEFAULT NULL,
  `format_review_legacy_id` int(11) DEFAULT NULL,
  `format_review_legacy_old_id` int(11) DEFAULT NULL,
  `admin_notes` varchar(255) DEFAULT NULL,
  `is_printed` tinyint(1) DEFAULT NULL,
  `allow_all_caps_in_title` tinyint(1) DEFAULT NULL,
  `public_id` varchar(255) DEFAULT NULL,
  `format_review_files_first_uploaded_at` datetime DEFAULT NULL,
  `final_submission_files_first_uploaded_at` datetime DEFAULT NULL,
  `lion_path_degree_code` varchar(255) DEFAULT NULL,
  `restricted_notes` text,
  `confidential_hold_embargoed_at` datetime DEFAULT NULL);
INSERT INTO `submissions` (
  `id`,
  `author_id`,
  `program_id`,
  `degree_id`,
  `semester`,
  `year`,
  `created_at`,
  `updated_at`,
  `status`,
  `title`,
  `format_review_notes`,
  `final_submission_notes`,
  `defended_at`,
  `abstract`,
  `access_level`,
  `has_agreed_to_terms`,
  `committee_provided_at`,
  `format_review_files_uploaded_at`,
  `format_review_rejected_at`,
  `format_review_approved_at`,
  `final_submission_files_uploaded_at`,
  `final_submission_rejected_at` ,
  `final_submission_approved_at`,
  `released_for_publication_at`,
  `fedora_id` ,
  `released_metadata_at`,
  `legacy_id`,
  `final_submission_legacy_id`,
  `final_submission_legacy_old_id`,
  `format_review_legacy_id`,
  `format_review_legacy_old_id`,
  `admin_notes`,
  `is_printed`,
  `allow_all_caps_in_title`,
  `public_id`,
  `format_review_files_first_uploaded_at`,
  `final_submission_files_first_uploaded_at`,
  `lion_path_degree_code`,
  `restricted_notes`,
  `confidential_hold_embargoed_at`)
VALUES(
1,
1,
1,
1,
"Spring",
"2008",
"2008-04-13",
"2016-05-16",
"released for publication",
"A probabilistic explanation of a natural phenomenomena",
"format notes",
"final notes",
NULL,
"Regression is the procedure that attempts to relate",
"open_access",
true,
NULL,
"2010-06-08",
NULL,
NULL,
"2008-10-14",
NULL,
NULL,
"2008-05-18",
NULL,
"2008-05-20",
1023,
8317,
2643,
10932,
5387,
"dtap; OK",
true,
true,
"8317",
"2010-06-08",
"2008-10-14",
NULL,
NULL,
NULL),
(2,
5,
1,
1,
"Spring",
"2018",
"2018-01-18",
"2018-10-18",
"waiting for format review response",
"title here",
"goodbye",
"hello there",
NULL,
NULL,
"",
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
11,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL,
0,
NULL,
NULL,
NULL,
NULL,
NULL,
NULL);