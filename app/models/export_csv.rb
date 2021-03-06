class ExportCsv
  attr_accessor :query_type
  attr_reader :records

  def initialize(query_type, records)
    @query_type = query_type
    @records = records
  end

  def columns
    case query_type
    when 'final_submission_approved'
      column_list = ['Access Id', 'Title', 'Id', 'Last Name', 'First Name', 'Middle Name', 'Program Name', 'Thesis Supervisor', 'Access Level']
      column_list = ['Title', 'Id', 'Last Name', 'First Name', 'Middle Name', 'Program Name', 'Committee Members', 'Access Level'] if current_partner.graduate?
    when 'custom_report'
      column_list = ['Last Name', 'First Name', 'Id', 'Title', 'Degree', 'Program', 'Access Level', 'Date', 'Status']
      column_list.append('Invention Disclosure Number')
    when 'confidential_hold_report'
      column_list = ['ID', 'Access ID', 'Last Name', 'First Name', 'PSU Email Address', 'Alternate Email Address', 'PSU ID', 'Confidential Hold Set At']
    else
      column_list = nil
    end
    column_list
  end

  def fields(record)
    return nil if record.nil?

    r = record

    case query_type
    when 'final_submission_approved'
      field_list = [r.author.access_id, r.cleaned_title, r.id, r.author.last_name, r.author.first_name, r.author.middle_name, r.program_name, CommitteeMember.advisor_name(r), r.current_access_level.label]
      field_list = [r.cleaned_title, r.id, r.author.last_name, r.author.first_name, r.author.middle_name, r.program_name, r.committee_members.map(&:name).join('; '), r.current_access_level.label] if current_partner.graduate?
    when 'custom_report'
      field_list = [r.author.last_name, r.author.first_name, r.id, r.cleaned_title, r.degree_type.name, r.program_name, r.current_access_level.label, r.semester_and_year, r.status]
      #      field_list.append(r.invention_disclosure.first.id_number) if current_partner.graduate? && !r.invention_disclosure.nil?
    when 'confidential_hold_report'
      field_list = [r.id, r.access_id, r.last_name, r.first_name, r.psu_email_address, r.alternate_email_address, r.psu_idn, r.confidential_hold_set_at]
    else
      field_list = nil
    end
    field_list
  end
end
