json.array! [
  submission_view.id,
  "<input type='checkbox' class='row-checkbox' />",
  submission_view.ok_to_release?,
  link_to_if(submission_view.admin_can_edit? && submission_view.title.present?, submission_view.title.truncate(30) || '[Title not available]', admin_edit_submission_path(submission_view.id)),
  submission_view.author.last_name,
  submission_view.author.first_name,
  "<span class='label release-label #{submission_view.ok_to_release? ? 'badge badge-primary' : 'badge-none'}'>#{submission_view.released_for_publication_date}</span>",
  submission_view.semester_and_year.presence || 'Date unknown',
  submission_view.most_relevant_file_links.join(' ') + "<br />#{invention_disclosure_number(submission_view)}"
]
