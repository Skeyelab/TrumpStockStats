class Company
  include Mongoid::Document
  field :name, type: String
  field :symbol, type: String
  field :volume, type: Integer
end
