# Create and save the Favorite Colors survey
favorites = Survey.new(title: "Favorites",
                       reference_identifier: 'favorite-colors',
                       access_code: 'favorite-colors')

colors = SurveySection.new(title: 'colors',
                           description: "These questions are examples of the basic supported input types",
                           survey: favorites,
                           display_order: 1)
favorites.sections << colors

colors_q1 = Question.new(text: "What is your favorite color?",
                         reference_identifier: "1",
                         pick: 'one',
                         display_order: 1,
                         survey_section: colors)
colors.questions << colors_q1

a1q1 = Answer.new(text: "red",
                  reference_identifier: "r",
                  data_export_identifier: "1",
                  question: colors_q1)
a2q1 = Answer.new(text: "blue",
                  reference_identifier: "r",
                  data_export_identifier: "1",
                  question: colors_q1)
a3q1 = Answer.new(text: "green",
                  reference_identifier: "r",
                  data_export_identifier: "1",
                  question: colors_q1)
a4q1 = Answer.new(text: :other,
                  question: colors_q1)

colors_q1.answers << a1q1 << a2q1 << a3q1 << a4q1


colors_q2 = Question.new(text: "Choose the colors you don't like",
                         pick: :any,
                         display_order: 2,
                         survey_section: colors)

a1q2 = Answer.new(text: "orange",
                  display_order: 1,
                  question: colors_q2)
a2q2 = Answer.new(text: "purple",
                  display_order: 2,
                  question: colors_q2)
a3q2 = Answer.new(text: "brown",
                  display_order: 0,
                  question: colors_q2)
a4q2 = Answer.new(text: :omit,
                  question: colors_q2)

colors_q2.answers << a1q2 << a2q2 << a3q2 << a4q2
colors.questions << colors_q2

colors_q3 = Question.new(text: "What is the best color for a fire engine?",
                         display_order: 3,
                         survey_section: colors)
a1q3 = Answer.new(text: 'Color',
                  display_type: :string,
                  question: colors_q3)

colors_q3.answers << a1q3
colors.questions << colors_q3

numbers = SurveySection.new(title: "Numbers",
                            display_order: 2,
                            survey: favorites)

favorites.sections << numbers

favorites.save!
