class CreateSeeds < ActiveRecord::Migration
	def up
		load Rails.root.join('db', 'seeds.rb')		
	end
end

