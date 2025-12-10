class ApplicationRecord < ActiveRecord::Base
  include SearchableTextColumn

  primary_abstract_class
end
