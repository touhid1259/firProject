class DfaDbConnection < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "dfa_#{Rails.env}"
end
