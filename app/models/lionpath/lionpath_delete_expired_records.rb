class Lionpath::LionpathDeleteExpiredRecords
  class << self
    def delete
      lp_subs_to_delete.each(&:destroy) if safe_to_delete?(total_lp_sub_count, lp_subs_to_delete.count)
      lp_cmtee_mmbrs_to_delete.each(&:destroy) if safe_to_delete?(total_lp_cmtee_mmbr_count,
                                                                  lp_cmtee_mmbrs_to_delete.count)
    end

    private

    def total_lp_subs
      Submission
        .where('submissions.lionpath_updated_at IS NOT NULL AND submissions.created_at > ?',
               (DateTime.now - 5.years))
    end

    def total_lp_cmtee_mmbrs
      CommitteeMember
        .where('committee_members.lionpath_updated_at IS NOT NULL AND committee_members.created_at > ?',
               (DateTime.now - 5.years))
    end

    def total_lp_sub_count
      total_lp_subs.count
    end

    def total_lp_cmtee_mmbr_count
      total_lp_cmtee_mmbrs.count
    end

    def lp_subs_to_delete
      total_lp_subs.where('submissions.lionpath_updated_at < ?', (DateTime.now - 2.days))
    end

    # External to PSU committee members will stop updating after they are imported.
    # Therefore, they need to be excluded from the following query.
    def lp_cmtee_mmbrs_to_delete
      total_lp_cmtee_mmbrs.where('committee_members.external_to_psu_id IS NULL AND committee_members.lionpath_updated_at < ?',
                                 (DateTime.now - 2.days))
    end

    def safe_to_delete?(total_num, num_to_delete)
      (num_to_delete.to_f / total_num.to_f) < (1.to_f / 100.to_f)
    end
  end
end
