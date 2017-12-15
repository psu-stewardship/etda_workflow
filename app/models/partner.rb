class Partner < EtdaUtilities::Partner
  def email_address
    I18n.t("#{id}.partner.email.address")
  end

  def name
    I18n.t("#{id}.partner.name")
  end

  def slug
    I18n.t("#{id}.partner.slug")
  end

  def program_label
    I18n.t("#{id}.program.label")
  end
end
