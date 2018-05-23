class LionPath::AcademicPlan
  def initialize(inbound_record, code = 0, submission = nil)
    @plan_submission = submission
    @inbound_record = inbound_record.current_data[LionPath::LpKeys::PLAN] || []
    @index = selected_index(code)
  end

  def selected
    return {} unless @index >= 0
    @inbound_record[@index]
  end

  def plan_information_collection
    # hash containing plan information for all available plans
    # added to form pages (author/admin)
    # hash values are used to populate attributes after user selects an academic plan
    desc_list = []
    @inbound_record.each do |ap|
      desc_list << LionPath::LpEtdPlan.new(ap).data
    end
    desc_list
  end

  # dropdown for Academic Plan Choices
  def degrees_display_collection
    desc_list = []
    @inbound_record.each do |ap|
      full_desc = "#{ap[LionPath::LpKeys::DEGREE_CODE]} - #{ap[LionPath::LpKeys::DEGREE_DESC]}"
      desc_list << [full_desc, ap[LionPath::LpKeys::DEGREE_CODE]]
    end
    desc_list
  end

  def committee
    selected[LionPath::LpKeys::COMMITTEE]
  end

  def committee_member(n)
    selected[LionPath::LpKeys::COMMITTEE][n]
  end

  def full_name(cm)
    "#{cm[LionPath::LpKeys::FIRST_NAME].capitalize} #{cm[LionPath::LpKeys::LAST_NAME].capitalize}"
  end

  def committee_members
    committee.each do |cm|
      @plan_submission.committee_members.build(committee_role_id: InboundLionPathRecord.etd_role(cm[:role_desc]), is_required: true, name: full_name(cm), email: cm[LionPath::LpKeys::EMAIL])
    end
  end

  def committee_members_refresh
    byebug
    refresh_committee = {}
    committee.each_with_index do |cm, index|
      refresh_committee[index.to_s] = { committee_role_id: InboundLionPathRecord.etd_role(cm[:role_desc]), is_required: true, name: full_name(cm), email: cm[LionPath::LpKeys::EMAIL] }
    end
    unless refresh_committee.empty?
      @plan_submission.committee_members_attributes = refresh_committee
      @plan_submission.save(validate: false)
      return true
    end
    false
  end

  def defense_date
    def_date = selected[LionPath::LpKeys::DEFENSE_DATE]
    Date.strptime(def_date, LionPath::LpFormats::DEFENSE_DATE_FORMAT)
  end

  private

    def selected_index(code)
      return -1 if code == ''
      @inbound_record.each_with_index do |ap, index|
        return index if ap[LionPath::LpKeys::DEGREE_CODE] == code
      end
      -1
    end
end
