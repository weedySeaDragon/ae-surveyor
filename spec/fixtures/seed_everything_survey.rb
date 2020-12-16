everything_survey = Survey.new(title: 'Everything',
                               reference_identifier: 'everything',
                               access_code: 'everything')

basic_section = SurveySection.new(title: 'Basic', survey: everything_survey)
sec1q1 = Question.new(text: 'What is your favorite color?',
                      reference_identifier: "1",
                      pick: :one,
                      display_order: 1,
                      survey_section: basic_section)

sec1q1a1 = Answer.new(text: 'red',
                      reference_identifier: 'r',
                      data_export_identifier: '1',
                      question: sec1q1)
sec1q1a2 = Answer.new(text: 'blue',
                      reference_identifier: 'b',
                      data_export_identifier: '2',
                      question: sec1q1)
sec1q1a3 = Answer.new(text: 'green',
                      reference_identifier: 'g',
                      data_export_identifier: '3',
                      question: sec1q1)
sec1q1a4 = Answer.new(text: 'other',
                      display_type: :string,
                      question: sec1q1)
sec1q1.answers << sec1q1a1 << sec1q1a2 << sec1q1a3 << sec1q1a4

sec1q2 = Question.new(text: "Choose the colors you don't like",
                      pick: :any,
                      display_order: 2,
                      survey_section: basic_section)
sec1q2a1 = Answer.new(text: 'orange',
                      display_order: 1,
                      question: sec1q2)
sec1q2a2 = Answer.new(text: 'purple',
                      display_order: 2,
                      question: sec1q2)
sec1q2a3 = Answer.new(text: 'brown',
                      display_order: 0,
                      question: sec1q2)
sec1q2a4 = Answer.new(text: '',
                      display_type: :omit,
                      question: sec1q2)
sec1q2.answers << sec1q2a1 << sec1q2a2 << sec1q2a3 << sec1q2a4


sec1q3 = Question.new(text: 'What color is the sky right now?',
                      pick: :one,
                      display_type: :dropdown,
                      display_order: 3,
                      survey_section: basic_section)
sec1q3a1 = Answer.new(text: 'sky blue',
                      question: sec1q3)
sec1q3a2 = Answer.new(text: 'cloud white',
                      question: sec1q3)
sec1q3a3 = Answer.new(text: 'night black',
                      question: sec1q3)
sec1q3a4 = Answer.new(text: 'sunset red',
                      question: sec1q3)
sec1q3.answers << sec1q3a1 << sec1q3a2 << sec1q3a3 << sec1q3a4


sec1q4 = Question.new(text: "What is the best color for a fire engine?",
                      display_order: 4,
                      survey_section: basic_section)
sec1q4a1 = Answer.new(text: 'Color',
                      display_type: :string,
                      question: sec1q4)
sec1q4.answers << sec1q4a1

sec1q5 = Question.new(text: 'What was the last room you painted, and what color?',
                      pick: :one,
                      display_order: 5,
                      survey_section: basic_section)
sec1q5a1 = Answer.new(text: 'kitchen',
                      display_type: :string,
                      question: sec1q5)
sec1q5a2 = Answer.new(text: 'bedroom',
                      display_type: :string,
                      question: sec1q5)
sec1q5a3 = Answer.new(text: 'bathroom',
                      display_type: :string,
                      question: sec1q5)
sec1q5a4 = Answer.new(text: 'other',
                      display_type: :text,
                      question: sec1q5)
sec1q5.answers << sec1q5a1 << sec1q5a2 << sec1q5a3 << sec1q5a4


sec1q6 = Question.new(text: "What rooms have you painted, and what color?",
                      pick: :any,
                      display_order: 6,
                      survey_section: basic_section)
sec1q6a1 = Answer.new(text: 'kitchen',
                      display_type: :string,
                      question: sec1q6)
sec1q6a2 = Answer.new(text: 'bedroom',
                      display_type: :string,
                      question: sec1q6)
sec1q6a3 = Answer.new(text: 'bathroom',
                      display_type: :string,
                      question: sec1q6)
sec1q6a4 = Answer.new(text: 'other',
                      display_type: :text,
                      question: sec1q6)
sec1q6.answers << sec1q6a1 << sec1q6a2 << sec1q6a3 << sec1q6a4

sec1q7 = Question.new(text: 'When is the next color run?',
                      display_order: 7,
                      survey_section: basic_section)
sec1q7a1 = Answer.new(text: 'On',
                      display_type: :date,
                      question: sec1q7)
sec1q7.answers << sec1q7a1


sec1q8 = Question.new(text: 'What time does it start?',
                      display_order: 8,
                      survey_section: basic_section)
sec1q8a1 = Answer.new(text: 'At',
                      display_type: :time,
                      question: sec1q8)
sec1q8.answers << sec1q8a1

sec1q9 = Question.new(text: 'When is your next hair color appointment?',
                      display_order: 9,
                      survey_section: basic_section)
sec1q9a1 = Answer.new(text: 'At',
                      display_type: :datetime,
                      question: sec1q9)
sec1q9.answers << sec1q9a1


sec1q10 = Question.new(text: 'Please compose a poem about a color',
                       display_order: 10,
                       survey_section: basic_section)
sec1q10a1 = Answer.new(text: 'Poem',
                       display_type: :text,
                       question: sec1q10)
sec1q10.answers << sec1q10a1


sec1q11 = Question.new(text: 'What is your birth date?',
                       pick: :one,
                       display_order: 11,
                       survey_section: basic_section)
sec1q11a1 = Answer.new(text: 'I was born on',
                       display_type: :date,
                       question: sec1q11)
sec1q11a2 = Answer.new(text: 'Refused',
                       question: sec1q11)
sec1q11.answers << sec1q11a1 << sec1q11a2


sec1q12 = Question.new(text: 'At what time were you born?',
                       pick: :any,
                       display_order: 12,
                       survey_section: basic_section)
sec1q12a1 = Answer.new(text: 'I was born at',
                       display_type: :time,
                       question: sec1q12)
sec1q12a2 = Answer.new(text: 'This time is approximate',
                       question: sec1q12)
sec1q12.answers << sec1q12a1 << sec1q12a2

basic_section += [sec1q1, sec1q2, sec1q3, sec1q4, sec1q5, sec1q6, sec1q7, sec1q8, sec1q9, sec1q10, sec1q11, sec1q12]
everything_survey.sections << basic_section

# -------------------------------------------------------------------
groups_section = SurveySection.new(title: 'Groups',
                                   survey: everything_survey)

ggroup_how_interested = QuestionGroup.new(text: 'How interested are you in the following?',
                                          display_type: 'grid')
sec_groups_q1 = Question.new(text: 'births',
                             pick: :one,
                             survey_section: groups_section)
sec_groups_q1_a1 = Answer.new(text: 'indifferent',
                              display_order: 0,
                              question: sec_groups_q1)
sec_groups_q1_a2 = Answer.new(text: 'neutral',
                              display_order: 1,
                              question: sec_groups_q1)
sec_groups_q1_a3 = Answer.new(text: 'interested',
                              display_order: 2,
                              question: sec_groups_q1)
sec_groups_q1.answers << sec_groups_q1_a1 << sec_groups_q1_a2 << sec_groups_q1_a3

sec_groups_q2 = Question.new(text: 'weddings',
                             pick: :one,
                             survey_section: groups_section)
sec_groups_q2_a1 = Answer.new(text: 'indifferent',
                              display_order: 0,
                              question: sec_groups_q2)
sec_groups_q2_a2 = Answer.new(text: 'neutral',
                              display_order: 1,
                              question: sec_groups_q2)
sec_groups_q2_a3 = Answer.new(text: 'interested',
                              display_order: 2,
                              question: sec_groups_q2)
sec_groups_q2.answers << sec_groups_q2_a1 << sec_groups_q2_a2 << sec_groups_q2_a3

sec_groups_q3 = Question.new(text: 'funerals',
                             pick: :one,
                             survey_section: groups_section)
sec_groups_q3_a1 = Answer.new(text: 'indifferent',
                              display_order: 0,
                              question: sec_groups_q3)
sec_groups_q3_a2 = Answer.new(text: 'neutral',
                              display_order: 1,
                              question: sec_groups_q3)
sec_groups_q3_a3 = Answer.new(text: 'interested',
                              display_order: 2,
                              question: sec_groups_q3)
sec_groups_q3.answers << sec_groups_q3_a1 << sec_groups_q3_a2 << sec_groups_q3_a3

ggroup_how_interested.questions << sec_groups_q1 << sec_groups_q2 << sec_groups_q3

# ---------------------------
ggroup_family = QuestionGroup.new(text: 'Tell us about your family',
                                  display_type: 'repeater')

group_fam_q1 = Question.new(text: 'Relation',
                            display_type: :dropdown,
                            pick: :one,
                            display_order: 2,
                            survey_section: groups_section,
                            question_group: ggroup_family)
group_fam_q1_a1 = Answer.new(text: 'Parent',
                             display_order: 0,
                             question: group_fam_q1)
group_fam_q1_a2 = Answer.new(text: 'Sibling',
                             display_order: 1,
                             question: group_fam_q1)
group_fam_q1_a3 = Answer.new(text: 'Child',
                             display_order: 2,
                             question: group_fam_q1)
group_fam_q1.answers << group_fam_q1_a1 << group_fam_q1_a2 << group_fam_q1_a3

group_fam_q2 = Question.new(text: 'Name',
                            display_order: 3,
                            survey_section: groups_section,
                            question_group: ggroup_family)
group_fam_q2_a1 = Answer.new(text: 'Name',
                             display_type: :string,
                             question: group_fam_q2)
group_fam_q2.answers << group_fam_q2_a1

group_fam_q3 = Question.new(text: 'Quality of your relationship',
                            display_order: 4,
                            survey_section: groups_section,
                            question_group: ggroup_family)
group_fam_q3_a1 = Answer.new(text: 'Quality of your relationship',
                             display_type: :string,
                             question: group_fam_q3)
group_fam_q3.answers << group_fam_q3_a1

ggroup_family.questions << group_fam_q1 << group_fam_q2 << group_fam_q3


ggroup_dropit = QuestionGroup.new(text: "Drop it like it's hot",
                                  display_type: 'question_group')
group_fam_q4 = Question.new(text: 'Like Snoop Dogg said',
                            display_type: :label,
                            survey_section: groups_section,
                            question_group: ggroup_dropit)

group_fam_q5 = Question.new(text: 'What to drop',
                            display_type: :dropdown,
                            pick: :one,
                            survey_section: groups_section,
                            question_group: ggroup_dropit)
group_fam_q5_a1 = Answer.new(text: 'It',
                             question: group_fam_q5)
group_fam_q5_a2 = Answer.new(text: 'Hot potato',
                             question: group_fam_q5)
group_fam_q5_a3 = Answer.new(text: 'And give me 10',
                             question: group_fam_q5)
group_fam_q5.answers << group_fam_q5_a1 << group_fam_q5_a2 << group_fam_q5_a3

ggroup_dropit.questions << group_fam_q4 << group_fam_q5

groups_section += [sec_groups_q1, sec_groups_q2, sec_groups_q3, group_fam_q1, group_fam_q2, group_fam_q3, group_fam_q4, group_fam_q5]
everything_survey.sections << groups_section

#-----------------------------------------------------------------------------
#
dependencies_section = SurveySection.new(title: 'Dependencies',
                                         survey: everything_survey)

dep_group_greetings = QuestionGroup.new(text: 'Greetings',
                                        display_type: 'question_group')

depq1 = Question.new(text: 'Anybody there?',
                     pick: :one,
                     display_order: 1,
                     survey_section: dependencies_section,
                     question_group: dep_group_greetings)
depq1_a_yes = Answer.new(text: 'Yes',
                         question: depq1)
depq1_a_no = Answer.new(text: 'No',
                        question: depq1)
depq1.answers << depq1_a_yes << depq1_a_no
dep_group_greetings.questions << depq1

depq2 = Question.new(text: 'Who are you?',
                     display_order: 2,
                     survey_section: dependencies_section,
                     question_group: dep_group_greetings)
dep_q2 = Dependency.new(question: depq2,
                        rule: "A")
depq2.dependency = dep_q2
dep_con_q2 = DependencyCondition.new(dependent_question: depq1,
                                     question: depq2,
                                     rule_key: 'A',
                                     operator: '==',
                                     answer: depq1_a_yes,
                                     dependency: depq2)
dep_q2.dependency_conditions << dep_con_q2

depq2_a1 = Answer.new(text: 'Answer',
                      display_type: :string,
                      question: depq2)
depq2.answers << depq2_a1
dep_group_greetings.questions << depq2

depq3 = Question.new(text: 'Weird.. Must be talking to myself..',
                     pick: :one,
                     display_order: 3,
                     survey_section: dependencies_section,
                     question_group: dep_group_greetings)
dep_q3 = Dependency.new(question: depq3,
                        rule: "A")
depq3.dependency = dep_q3

dep_con_q3 = DependencyCondition.new(dependent_question: depq1,
                                     question: depq3,
                                     rule_key: 'A',
                                     operator: '==',
                                     answer: depq1_a_no)
dep_q3.dependency_conditions << dep_con_q3

depq3_a_maybe = Answer.new(text: 'Maybe',
                           question: depq3)
depq3_a_huh = Answer.new(text: 'Huh?',
                         question: depq3)
depq3.answers << depq3_a_maybe << depq3_a_huh

dep_group_greetings.questions << depq3

# ----------------------------------
dep_group_anybody_no = QuestionGroup.new(text: 'No?',
                                         display_type: 'question_group')
dependency_anybody_no = Dependency.new(question_group: dep_group_anybody_no,
                                       rule: 'A')
dep_group_anybody_no.dependency = dependency_anybody_no

depq4 = Question.new(text: 'Who is talking?',
                     pick: :one,
                     survey_section: dependencies_section,
                     question_group: dep_group_anybody_no)

depcon_q4 = DependencyCondition.new(dependency: dependency_anybody_no,
                                    dependent_question: depq1,
                                    rule_key: 'A',
                                    question: depq4,
                                    operator: '==',
                                    answer: depq1_a_no)
depq4.dependency = depcon_q4

depq4_a1 = Answer.new(text: 'You are',
                      display_type: :string,
                      question: depq4)
depq4_a2 = Answer.new(text: 'Are you nuts?',
                      display_type: :string,
                      question: depq4)
depq4.answers << depq4_a1 << depq4_a2

dep_group_anybody_no.questions << depq4

depq5 = Question.new('It feels like it',
                     display_type: :label,
                     survey_section: dependencies_section)
dependency_depq5 = Dependency.new(question: depq5,
                                  rule: 'A')
depq5.dependency = depq5
depcon_q5 = DependencyCondition.new(dependency: dependency_depq5,
                                    dependent_question: depq4,
                                    rule_key: 'A',
                                    question: depq5,
                                    operator: '==',
                                    answer: depq4_a2)

depq6 = Question.new('How do you cool your home?',
                     pick: :one,
                     survey_section: dependencies_section)
depq6_a1 = Answer.new(text: 'Fans',
                      question: depq6)
depq6_a2 = Answer.new(text: 'Window AC',
                      question: depq6)
depq6_a3 = Answer.new(text: 'Central AC',
                      question: depq6)
depq6_a4 = Answer.new(text: 'Passive',
                      question: depq6)
depq6.answers << depq6_a1 << depq6_a2 << depq6_a3 << depq6_a4

depq7 = Question.new('How much does it cost to run your non-passive cooling solutions?',
                     survey_section: dependencies_section)
dependency_depq7 = Dependency.new(question: depq7,
                                  rule: 'A')
depq7.dependency = depq7
depcon_q7 = DependencyCondition.new(dependency: dependency_depq7,
                                    dependent_question: depq6,
                                    rule_key: 'A',
                                    question: depq7,
                                    operator: '!=',
                                    answer: depq6_a4)
depq7_a1 = Answer.new(text: '$',
                      display_type: :float,
                      question: depq7)
depq7.answers << depq7_a1


depq8 = Question.new('How do you heat your home?',
                     pick: :any,
                     survey_section: dependencies_section)
depq8_a1 = Answer.new(text: 'Forced air',
                      question: depq8)
depq8_a2 = Answer.new(text: 'Radiators',
                      question: depq8)
depq8_a3 = Answer.new(text: 'Oven',
                      question: depq8)
depq8_a4 = Answer.new(text: 'Passive',
                      question: depq8)
depq8.answers << depq8_a1 << depq8_a2 << depq8_a3 << depq8_a4

depq9 = Question.new('How much does it cost to run your non-passive heating solutions?',
                     survey_section: dependencies_section)
dependency_depq9 = Dependency.new(question: depq9,
                                  rule: 'A and B')
depq9.dependency = depq9
depcon_a_q9 = DependencyCondition.new(dependency: dependency_depq9,
                                      dependent_question: depq8,
                                      rule_key: 'A',
                                      question: depq9,
                                      operator: '!=',
                                      answer: depq8_a4)
depcon_b_q9 = DependencyCondition.new(dependency: dependency_depq9,
                                      dependent_question: depq8,
                                      rule_key: 'B',
                                      question: depq9,
                                      operator: 'count>0')
depq9_a1 = Answer.new(text: '$',
                      display_type: :float,
                      question: depq9)
depq9.answers << depq9_a1


depq10 = Question.new('How much do you spend on air filters each year?',
                      survey_section: dependencies_section)
dependency_depq10 = Dependency.new(question: depq10,
                                   rule: 'A')
depq10.dependency = depq10
depcon_a_q10 = DependencyCondition.new(dependency: dependency_depq10,
                                       dependent_question: depq8,
                                       rule_key: 'A',
                                       question: depq10,
                                       operator: '-=',
                                       answer: depq8_a1)
depq10_a1 = Answer.new(text: '$',
                       display_type: :float,
                       question: depq10)
depq10.answers << depq10_a1


depq11 = Question.new('How many times do you count a day',
                      pick: :any,
                      survey_section: dependencies_section)
depq11_a1 = Answer.new(text: 'Once for me',
                       question: depq11)
depq11_a2 = Answer.new(text: 'Once for you',
                       question: depq11)
depq11_a3 = Answer.new(text: 'Once for everyone',
                       question: depq11)
depq11.answers << depq11_a1 << depq11_a2 << depq11_a3

depq12 = Question.new('Good!',
                      display_type: :label,
                      survey_section: dependencies_section)
dependency_depq12 = Dependency.new(question: depq12,
                                   rule: 'A')
depq12.dependency = depq12
depcon_a_q12 = DependencyCondition.new(dependency: dependency_depq12,
                                       dependent_question: depq11,
                                       rule_key: 'A',
                                       question: depq12,
                                       operator: 'count==1')

depq13 = Question.new('Twice as good!',
                      display_type: :label,
                      survey_section: dependencies_section)
dependency_depq13 = Dependency.new(question: depq13,
                                   rule: 'A')
depq13.dependency = depq13
depcon_a_q13 = DependencyCondition.new(dependency: dependency_depq13,
                                       dependent_question: depq11,
                                       rule_key: 'A',
                                       question: depq13,
                                       operator: 'count==2')

depq14 = Question.new('Thanks for counting!',
                      display_type: :label,
                      survey_section: dependencies_section)
dependency_depq14 = Dependency.new(question: depq14,
                                   rule: 'A or B or C')
depq14.dependency = depq14
depcon_a_q14_a = DependencyCondition.new(dependency: dependency_depq14,
                                         dependent_question: depq11,
                                         rule_key: 'A',
                                         question: depq14,
                                         operator: '==',
                                         answer: depq11_a1)
depcon_a_q14_b = DependencyCondition.new(dependency: dependency_depq14,
                                         dependent_question: depq11,
                                         rule_key: 'B',
                                         question: depq14,
                                         operator: '==',
                                         answer: depq11_a2)
depcon_a_q14_c = DependencyCondition.new(dependency: dependency_depq14,
                                         dependent_question: depq11,
                                         rule_key: 'C',
                                         question: depq14,
                                         operator: '==',
                                         answer: depq11_a3)

depq15 = Question.new('Yay for everyone!',
                      display_type: :label,
                      survey_section: dependencies_section)
dependency_depq15 = Dependency.new(question: depq15,
                                   rule: 'A')
depq15.dependency = depq15
depcon_a_q15 = DependencyCondition.new(dependency: dependency_depq15,
                                       dependent_question: depq11,
                                       rule_key: 'A',
                                       question: depq15,
                                       operator: 'count>2')

dependencies_section.questions += [depq1, depq2, depq3, depq4, depq5, depq6, depq7, depq8, depq9, depq10, depq11, depq12, depq13, depq14, depq15]
everything_survey.sections << dependencies_section

#------------------------------------------------------------------------------
#
special_section = SurveySection.new(title: 'Special',
                                    survey: everything_survey)

mustache_group = QuestionGroup.new(text: 'Regarding {{name}}',
                                   help_text: 'Answer all you know about {{name}}',
                                   display_type: 'question_group')

mustache_q1 = Question.new('Where does {{name}} live?',
                           pick: :one,
                           help_text: "If you don't know where {{name}} lives, skip the question",
                           question_group: mustache_group,
                           survey_section: special_section)
mustache_q1a1 = Answer.new(text: '{{name}} lives on North Pole',
                           question: mustache_q1)
mustache_q1a2 = Answer.new(text: '{{name}} lives on South Pole',
                           question: mustache_q1)
mustache_q1a3 = Answer.new(text: "{{name}} doesn't exist",
                           question: mustache_q1)
mustache_q1.answers << mustache_q1a1 << mustache_q1a2 << mustache_q1a3

special_q2 = Question.new('Now think about {{thing}}',
                          display_type: :label,
                          help_text: "Yes, {{thing}}",
                          survey_section: special_section)

special_q3 = Question.new('What is your home phone number?',
                          survey_section: special_section)
special_q3a1 = Answer.new(text: "phone",
                          display_type: :string,
                          input_mask: '(999)999-9999',
                          input_mask_placeholder: '#',
                          question: special_q3)
special_q3.answers << special_q3a1

special_q4 = Question.new('What is your cell phone number?',
                          survey_section: special_section)
special_q4a1 = Answer.new(text: "phone",
                          display_type: :string,
                          input_mask: '(999)999-9999',
                          question: special_q4)
special_q4.answers << special_q4a1

special_q5 = Question.new('What are your favorite letters?',
                          survey_section: special_section)
special_q5a1 = Answer.new(text: "letters",
                          display_type: :string,
                          input_mask: 'aaaaaaaaa',
                          question: special_q5)
special_q5.answers << special_q5a1

special_q6 = Question.new('What is your name?',
                          display_type: :hidden,
                          survey_section: special_section)
special_q6a1 = Answer.new(text: "Answer",
                          help_text: "(e.g. Count Von Count)",
                          question: special_q6)
special_q6.answers << special_q6a1

special_group_friends = QuestionGroup.new(text: 'Friends',
                                          display_type: :hidden)
special_q7 = Question.new('Who are your friends?',
                          question_group: special_group_friends,
                          survey_section: special_section)
special_q7a1 = Answer.new(text: "Answer",
                          question: special_q7)
special_q7.answers << special_q7a1

special_q8 = Question.new('What is your favorite number?',
                          pick: :one,
                          custom_class: 'hidden',
                          survey_section: special_section)
special_q8a1 = Answer.new(text: "One",
                          question: special_q8)
special_q8a2 = Answer.new(text: "Two",
                          question: special_q8)
special_q8a3 = Answer.new(text: "Three!",
                          question: special_q8)
special_q8.answers << special_q8a1 << special_q8a2 << special_q8a3

special_q9 = Question.new('WAre there any other types of heat you use regularly during the heating season to heat your home?',
                          pick: :any,
                          survey_section: special_section)
special_q9a1 = Answer.new(text: "Electric",
                          question: special_q9)
special_q9a2 = Answer.new(text: "Gas - propane or LP",
                          question: special_q9)
special_q9a3 = Answer.new(text: "Oil",
                          question: special_q9)
special_q9a4 = Answer.new(text: "Wood",
                          question: special_q9)
special_q9a5 = Answer.new(text: "Kerosene or diesel",
                          question: special_q9)
special_q9a6 = Answer.new(text: "Coal or coke",
                          question: special_q9)
special_q9a7 = Answer.new(text: "Solar energy",
                          question: special_q9)
special_q9a8 = Answer.new(text: "Heat pump",
                          question: special_q9)
special_q9a9 = Answer.new(text: "No other heating source",
                          is_exclusive: true,
                          question: special_q9)
special_q9a10 = Answer.new(text: "Other",
                           question: special_q9)
special_q9a11 = Answer.new(text: "Refused",
                           is_exclusive: true,
                           question: special_q9)
special_q9a12 = Answer.new(text: "Don't know",
                           is_exclusive: true,
                           question: special_q9)
special_q9.answers += [special_q9a1, special_q9a2, special_q9a3, special_q9a4, special_q9a5, special_q9a6, special_q9a7, special_q9a8, special_q9a9, special_q9a10, special_q9a11, special_q9a12]


special_q10 = Question.new('What is your favorite food?',
                           help_text: "just say beef",
                           survey_section: special_section)
special_q10a1 = Answer.new(text: "food",
                           display_type: :string,
                           default_value: 'beef',
                           question: special_q10)
special_q10.answers << special_q10a1

special_q11 = Question.new('Which way?',
                           survey_section: special_section)
special_q11a1 = Answer.new(text: "/assets/surveyor/next.gif",
                           display_type: :image,
                           question: special_q11)
special_q11a2 = Answer.new(text: "/assets/surveyor/prev.gif",
                           display_type: :image,
                           question: special_q11)
special_q11.answers << special_q11a1 << special_q11a2

special_section.questions += [ mustache_q1, special_q2, special_q3, special_q4, special_q5,
                               special_q6, special_q7, special_q8, special_q9, special_q10, special_q11]

everything_survey.sections << special_section

everything_survey.save!
