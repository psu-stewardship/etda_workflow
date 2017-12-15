class MockUniversityDirectory
  AUTHOR_LDAP_MAP = ::LdapResultsMap::AUTHOR_LDAP_MAP

  ADMIN_LDAP_MAP = ::LdapResultsMap::ADMIN_LDAP_MAP

  COMMITTEE_LDAP_MAP = ::LdapResultsMap::COMMITTEE_LDAP_MAP

  KNOWN_ACCESS_IDS = %w(
    saw140
    jxb13
    amg32
    xxb13
    conf123
  )

  # Return an array of tuples that are suitable for returning
  # to a jQuery autocomplete widget.
  def autocomplete(search_string, _only_faculty_staff: true)
    case search_string
    when /(joni)/i
      [
        { id: 'jxd2@psu.edu', label: 'Joni Davis', value: 'Joni Davis' },
        { id: 'jxb13@psu.edu', label: 'Joni Barnoff', value: 'Joni Barnoff' }
      ]
    when /(scott)/i
      [
        { id: 'sar3@psu.edu', label: 'Scott Rogers', value: 'Scott Rogers' },
        { id: 'saw140@psu.edu', label: 'Scott Woods', value: 'Scott Woods' }
      ]
    else
      []
    end
  end

  def exists?(psu_access_id)
    KNOWN_ACCESS_IDS.include?(psu_access_id)
  end

  def retrieve(psu_access_id, attributes_map)
    result = get_id_info(psu_access_id)
    return result if result.empty?
    if attributes_map == ADMIN_LDAP_MAP
      result.except(:middle_name, :city, :state, :zip, :country, :confidential_hold)
    else
      result.except(:administrator, :site_administrator)
    end
  end

  def populate_with_ldap_attributes
    case access_id
    when /(xxb13)/i
      { access_id: 'xxb13', first_name: 'Test', middle_name: 'Person',
        last_name: 'Rails', address_1: 'TSB Building',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', psu_idn: '999999999', confidential_hold: false }
    else
      {}
    end
  end

  def get_psu_id_number(_psu_access_id)
    '999999999'
  end

  def authors_confidential_status(psu_access_id)
    results = retrieve(psu_access_id, AUTHOR_LDAP_MAP)
    return false if results.empty?
    results[:confidential_hold]
  end

  def in_admin_group?(this_access_id)
    result = get_id_info(this_access_id)
    return false if result.nil? || result.empty?
    result[:administrator] || false
  end

  def get_id_info(psu_access_id)
    case psu_access_id
    when /(jxb13)/i
      { access_id: 'jxb13', first_name: 'Joni', middle_name: 'Lee',
        last_name: 'Barnoff', address_1: 'TSB Building',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', psu_idn: '999999999', confidential_hold: true,
        administrator: true, site_administrator: true }
    when /(amg32)/i
      { access_id: 'amg32', first_name: 'Andrew', middle_name: 'Michael',
        last_name: 'Gearhart', address_1: 'Pattee Library',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '814-867-5373',
        country: 'US', psu_idn: '987654321', confidential_hold: false,
        administrator: true, site_administrator: true }
    when /(saw140)/i
      { access_id: 'saw140', first_name: 'Scott', middle_name: 'Aaron',
        last_name: 'Woods', address_1: 'Allenway Bldg.',
        city: 'State College', state: 'PA',
        zip: '16801', phone_number: '666-666-6666',
        country: 'US', psu_idn: '981818181', confidential_hold: false,
        administrator: false, site_administrator: false }
    when /(xxb13)/i
      { access_id: 'testid', first_name: 'testfirst', middle_name: 'testmiddle',
        last_name: 'testlast', address_1: 'Anywhere',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', confidential_hold: false, psu_idn: '999999999',
        administrator: true, site_administrator: true }
    when /(conf123)/i
      { access_id: 'conf123', first_name: 'Confidential', middle_name: 'X.',
        last_name: 'Student', address_1: 'I cannot tell you', city: 'Secret', state: 'PA',
        zip: '16801', phone_number: '111-111-1111', psu_idn: '977777777',
        confidential_hold: true, administrator: false, site_administrator: true }
    else
      []
    end
  end
end
