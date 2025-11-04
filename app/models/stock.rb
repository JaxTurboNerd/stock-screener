class Stock < ApplicationRecord
  # Validations (if any):
  validates :name ,presence: true
end
