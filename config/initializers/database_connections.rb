class DfaDbConnection < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "dfa_#{Rails.env}"
end

class GeneralEnergyConnection < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "general_energy_#{Rails.env}"
end
