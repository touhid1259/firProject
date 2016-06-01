class ControlController < ApplicationController
	def index
		@tables = ActiveRecord::Base.connection.tables		
	end
end
