class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods

  # custom_class = the CSS class that should be applied to this question. This is added to the  CSS class attribute when this element is rendered in a view
end
