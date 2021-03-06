class Lionpath::LionpathChair
  def import(row)
    this_program = program(row)
    return if this_program.blank?

    pc = ProgramChair.find_by(program: this_program, campus: row['Campus'], role: "Department Head")
    if pc.present?
      pc.update(chair_attrs(row))

      if row['ROLE'].present?
        pic = ProgramChair.find_by(program: this_program, campus: row['Campus'], role: "Professor in Charge")
        if pic.present?
          pic.update(prof_in_charge_attrs(row))
        else
          ProgramChair.create({ program: this_program, role: "Professor in Charge" }.merge(prof_in_charge_attrs(row)))
        end
      end
      return
    end

    ProgramChair.create({ program: this_program, role: "Department Head" }.merge(chair_attrs(row)))
    return if row['ROLE'].blank?

    ProgramChair.create({ program: this_program, role: "Professor in Charge" }.merge(prof_in_charge_attrs(row)))
  end

  private

  def chair_attrs(row)
    {
      access_id: row['Chair Access ID'].downcase,
      first_name: row['Chair First Name'],
      last_name: row['Chair Last Name'],
      campus: row['Campus'],
      phone: row['Chair Phone'],
      email: row['Chair Univ Email'].downcase,
      lionpath_updated_at: DateTime.now
    }
  end

  def prof_in_charge_attrs(row)
    {
      access_id: row['DGS/PIC Access ID']&.downcase,
      first_name: row['DGS/PIC First Name'],
      last_name: row['DGS/PIC Last Name'],
      campus: row['Campus'],
      phone: row['DGS/PIC Phone'],
      email: row['DGS/PIC Univ Email']&.downcase,
      lionpath_updated_at: DateTime.now
    }
  end

  def program(row)
    Program.find_by(code: row['Acad Plan'])
  end
end
