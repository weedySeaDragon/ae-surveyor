# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResponseSet, type: :model do
  let(:a_survey) { FactoryBot.create(:survey) }
  let(:surv_section) do
    create(:survey_section, survey: a_survey,
                            title: 'section for entire RSpec')
  end

  let(:do_you_like_pie) do
    q = FactoryBot.create(:question,
                          text: 'Do you like pie?',
                          survey_section: surv_section,
                          correct_answer: nil)
    q.answers << FactoryBot.create(:answer, text: 'yes',
                                            question: q,
                                            question_id: q.id)
    q.answers << FactoryBot.create(:answer, text: 'no',
                                            question: q,
                                            question_id: q.id)
    q
  end

  let(:do_you_like_jam) do
    q = FactoryBot.create(:question,
                          text: 'Do you like jam?',
                          survey_section: surv_section)
    q.answers << FactoryBot.create(:answer, text: 'yes', question: q)
    q.answers << FactoryBot.create(:answer, text: 'no', question: q)
    q
  end

  let(:whats_wrong_with_you) { FactoryBot.create(:question, text: "What's wrong with you?", survey_section: surv_section) }

  let(:what_flavor) do
    q = FactoryBot.create(:question, text: 'What flavor?', survey_section: surv_section)
    q.answers << FactoryBot.create(:answer, response_class: :string,
                                            question: q,
                                            question_id: q.id)
    q.answers << FactoryBot.create(:answer, response_class: :string,
                                            question: q,
                                            question_id: q.id)
    q
  end

  let(:what_bakery) { FactoryBot.create(:question, text: 'What bakery?', survey_section: surv_section) }

  let(:no_pie_no_jam_depdency) do
    FactoryBot.create(:dependency,
                      rule: 'A or B',
                      question: whats_wrong_with_you,
                      question_id: whats_wrong_with_you.id)
  end

  let(:like_pie_dep_condition) do
    FactoryBot.create(:dependency_condition,
                      operator: '==',
                      rule_key: 'A',
                      question: do_you_like_pie,
                      answer: do_you_like_pie.answers.first,
                      dependency: no_pie_no_jam_depdency)
  end

  let(:like_jam_dep_condition) do
    FactoryBot.create(:dependency_condition,
                      operator: '==',
                      rule_key: '8',
                      question: do_you_like_jam,
                      answer: do_you_like_jam.answers.first,
                      dependency: no_pie_no_jam_depdency)
  end

  # --------------------------------------------------------------------------------

  describe 'validations' do
    let(:response_set) { FactoryBot.create(:response_set) }

    before(:each) do
      @radio_response_attributes = HashWithIndifferentAccess.new('1' => { 'question_id' => '1',
                                                                          'answer_id' => '1',
                                                                          'string_value' => 'XXL' },
                                                                 '2' => { 'question_id' => '2',
                                                                          'answer_id' => '6' },
                                                                 '3' => { 'question_id' => '3' })
      @checkbox_response_attributes = HashWithIndifferentAccess.new('1' => { 'question_id' => '9',
                                                                             'answer_id' => '11' },
                                                                    '2' => { 'question_id' => '9',
                                                                             'answer_id' => '12' })
      @other_response_attributes = HashWithIndifferentAccess.new('6' => { 'question_id' => '6',
                                                                          'answer_id' => '3',
                                                                          'string_value' => '' },
                                                                 '7' => { 'question_id' => '7',
                                                                          'answer_id' => '4',
                                                                          'text_value' => 'Brian is tired' },
                                                                 '5' => { 'question_id' => '5',
                                                                          'answer_id' => '5',
                                                                          'string_value' => '' })
    end

    it 'factory is valid' do
      expect(FactoryBot.create(:response_set)).to be_valid
    end

    it 'should have a unique code with length 10 that identifies the survey' do
      response_set.access_code.should_not be_nil
      response_set.access_code.length.should == 10
    end

    describe 'access_code' do
      let!(:rs1) { FactoryBot.create(:response_set, access_code: 'one') }
      let!(:rs2) { FactoryBot.create(:response_set, access_code: 'two') }

      # Regression test for #263
      it 'accepts an access code in the constructor' do
        rs = FactoryBot.create(:response_set)
        rs.access_code = 'eleven'
        rs.access_code.should == 'eleven'
      end

      # Regression test for #263
      it 'setter accepts a conflicting access code' do
        rs2.access_code = 'one'
        rs2.access_code.should == 'one'
      end

      it 'is invalid when conflicting' do
        rs2.access_code = 'one'
        expect(rs2).not_to be_valid
        expect(rs2.errors.details.keys).to match([:access_code])
      end
    end

    it 'is completable' do
      rs = FactoryBot.create(:response_set)
      rs.completed_at.should be_nil
      rs.complete!
      rs.completed_at.should_not be_nil
      rs.completed_at.is_a?(Time).should be_truthy
      rs.should be_complete
    end
  end


  describe 'update_from_params' do
    # ui_hash = values coming in from the (a) UI, e.g. surveyor_gui gem

    let(:rs) { FactoryBot.create(:response_set, num_responses: 0) }

    let(:ui_hash) { {} }
    let(:api_id) { 'ABCDEF-1234-567890' }

    let(:section) { surv_section }
    let(:question_id) { do_you_like_pie.id }
    let(:answer) { do_you_like_pie.answers.first }
    let(:answer_id) { answer.id }

    def ui_response(attrs = {})
      { 'question_id' => do_you_like_pie.id.to_s, 'api_id' => api_id }.merge(attrs)
    end

    def first_response_in_set(rs, api_id)
      # response_set_id criterion is to make sure a created response is
      # appropriately associated.
      Response.where(api_id: api_id, response_set_id: rs).first
    end

    shared_examples 'pick one or any' do
      it 'saves an answer alone' do
        ui_hash['3'] = ui_response('answer_id' => set_answer_id)
        rs.update_from_params(ui_hash)
        results = first_response_in_set(rs, api_id)
        expect(results.answer.id).to eq answer.id
      end

      it 'preserves the question' do
        ui_hash['4'] = ui_response('answer_id' => set_answer_id)
        rs.update_from_params(ui_hash)
        results = first_response_in_set(rs, api_id)
        expect(results.question.id).to eq do_you_like_pie.id
      end

      it 'interprets a blank answer as no response' do
        ui_hash['7'] = ui_response('answer_id' => blank_answer_id)
        rs.update_from_params(ui_hash)
        results = first_response_in_set(rs, api_id)
        expect(results).to be_nil
      end

      it 'interprets no answer_id as no response' do
        ui_hash['8'] = ui_response
        rs.update_from_params(ui_hash)
        results = first_response_in_set(rs, api_id)
        expect(results).to be_nil
      end

      orig = [
        ['string_value', 'foo', '', 'foo'],
        ['datetime_value', '10-01-2010 17:15', '', Time.zone.parse('10-01-2010 17:15')],
        ['date_value', '10/01/2010', '', '10/01/2010'],
        ['time_value', '17:15', '', '17:15'],
        ['integer_value', '9', '', 9],
        ['float_value', '4.0', '', 4.0],
        ['text_value', 'more than foo', '', 'more than foo']
      ].each do |value_type, set_value, blank_value, _expected_value|

        describe "plus #{value_type}" do
          it 'saves the value' do
            ui_hash['11'] = ui_response('answer_id' => set_answer_id, value_type => set_value)
            rs.update_from_params(ui_hash)

            # first_response_in_set.send(value_type).should == expected_value
            # results = first_response_in_set(rs, api_id)
            # expect(results.send(value_type)).to eq expected_value
          end

          it 'interprets a blank answer as no response' do
            ui_hash['18'] = ui_response('answer_id' => blank_answer_id, value_type => set_value)
            rs.update_from_params(ui_hash)
            results = first_response_in_set(rs, api_id)
            expect(results).to be_nil
          end

          it 'interprets a blank value as no response' do
            ui_hash['29'] = ui_response('answer_id' => set_answer_id,
                                        value_type => blank_value)
            rs.update_from_params(ui_hash)
            results = first_response_in_set(rs, api_id)
            expect(results).to be_nil
          end

          it 'interprets no answer_id as no response' do
            ui_hash['8'] = ui_response(value_type => set_value)
            rs.update_from_params(ui_hash)
            results = first_response_in_set(rs, api_id)
            expect(results).to be_nil
          end
        end
      end
    end

    shared_examples 'response interpretation' do
      it 'fails when api_id is not provided' do
        ui_hash['0'] = { 'question_id' => do_you_like_pie.id }
        expect { rs.update_from_params(ui_hash) }.to raise_error(/api_id missing from response 0/)
      end

      describe 'for a radio button' do
        let(:set_answer_id) { answer.id.to_s }
        let(:blank_answer_id) { '' }
        let(:response) { create(:response) }
        let(:rs) do
          resp_set = FactoryBot.create(:response_set, responses: [response])
          response.api_id = resp_set.api_id
          resp_set
        end
        include_examples 'pick one or any'
      end

      describe 'for a checkbox' do
        let(:set_answer_id) { ['', answer.id.to_s] }
        let(:blank_answer_id) { [''] }

        include_examples 'pick one or any'
      end
    end

    describe 'with a new response' do
      include_examples 'response interpretation'

      # After much effort I cannot produce this situation in a test, either with
      # with threads or separate processes. While SQLite 3 will nominally allow
      # for some coarse-grained concurrency, it does not appear to work with
      # simultaneous write transactions the way AR uses SQLite. Instead,
      # simultaneous write transactions always result in a
      # SQLite3::BusyException, regardless of the connection's timeout setting.
      it 'fails predicably when another response with the same api_id is created in a simultaneous open transaction'
    end

    describe 'with an existing response' do
      let!(:original_response) do
        rs.responses.create(question: do_you_like_pie, answer: answer).tap do |r|
          r.api_id = api_id # not mass assignable
          r.save!
        end
      end

      include_examples 'response interpretation'

      it 'fails when the existing response is for a different question' do
        diff_question = create(:question, survey_section: surv_section)
        ui_hash['76'] = ui_response('question_id' => diff_question.id, 'answer_id' => answer_id.to_s)

        expect { rs.update_from_params(ui_hash) }.to raise_error(/Illegal attempt to change question for response #{api_id}./)
      end
    end

    # clean_with_truncation is necessary because AR 3.0 can't roll back a nested
    # transaction with SQLite.
    it 'rolls back all changes on failure', :clean_with_truncation do
      ui_hash['0'] = ui_response('question_id' => '42', 'answer_id' => answer_id.to_s)
      ui_hash['1'] = { 'answer_id' => '7' } # no api_id

      begin
        rs.update_from_params(ui_hash)
        raise 'Expected error did not occur'
      rescue StandardError
      end

      expect(rs.reload.responses).to be_empty
    end
  end


  describe 'with dependencies' do

    let!(:what_flavor_dep) do
      FactoryBot.create(:dependency,
                        rule: 'A',
                        question: what_flavor,
                        question_id: what_flavor.id)
    end

    let!(:depc_do_you_like_pie_qa) do
      FactoryBot.create(:dependency_condition,
                        operator: '==',
                        rule_key: 'A',
                        question: do_you_like_pie,
                        answer: do_you_like_pie.answers.first,
                        dependency: what_flavor_dep)
    end

    # let!(:depc_what_flavor_depq) do
    #   FactoryBot.create(:dependency_condition,
    #                     operator: '==',
    #                     rule_key: 'A',
    #                     dependent_question: do_you_like_pie,
    #                     answer: do_you_like_pie.answers.first,
    #                     dependency: what_flavor_dep)
    # end

    let(:what_bakery_dep) do
      FactoryBot.create(:dependency, rule: 'B',
                                     question: what_bakery,
                                     question_id: what_bakery.id)
    end

    let!(:depc_ruleb_q) do
      FactoryBot.create(:dependency_condition,
                        rule_key: 'B',
                        operator: '==',
                        question: do_you_like_pie,
                        answer: do_you_like_pie.answers.first,
                        dependency: what_bakery_dep)
    end

    let(:response_set) do
      resp_set = FactoryBot.create(:response_set, survey: a_survey)
      resp_set.responses << FactoryBot.create(:response,
                                              question: do_you_like_pie,
                                              answer: do_you_like_pie.answers.first,
                                              response_set: resp_set)
      resp_set.responses << FactoryBot.create(:response, string_value: 'pecan pie',
                                                         question: what_flavor,
                                                         answer: what_flavor.answers.first,
                                                         response_set: resp_set)
      resp_set
    end


    it 'lists unanswered dependencies to show at the top of the next page (javascript turned off)' do
      expect(response_set.unanswered_dependencies).to match_array([what_bakery])
    end

    it 'lists answered and unanswered dependencies to show inline (javascript turned on)' do
      expect(response_set.all_dependencies[:show]).to match_array(["q_#{what_flavor.id}", "q_#{what_bakery.id}"])
    end

    it 'lists group as dependency' do
      # Question Group
      crust_group = FactoryBot.create(:question_group, text: 'Favorite Crusts')

      # Question
      what_crust_q = FactoryBot.create(:question, text: 'What is your favorite crust type?',
                                                question_group: crust_group,
                                                survey_section: surv_section)
      crust_group.questions << what_crust_q

      # Answers
      what_crust_q.answers << FactoryBot.create(:answer,
                                              response_class: :string,
                                              question: what_crust_q,
                                              question_id: what_crust_q.id)

      # Dependency and DependencyCondition
      crust_group_dep = FactoryBot.create(:dependency,
                                          rule: 'C',
                                          question_group: crust_group,
                                          question_group_id: crust_group.id,
                                          question: nil)
      FactoryBot.create(:dependency_condition,
                        rule_key: 'C',
                        question_id: do_you_like_pie.id,
                        operator: '==',
                        answer_id: do_you_like_pie.answers.first.id,
                        dependency_id: crust_group_dep.id)

      expect(response_set.unanswered_dependencies).to match_array([what_bakery, crust_group])
    end
  end

  describe 'dependency_conditions' do

    before do
      # Ensure the dependency conditions and dependencies exist
      like_jam_dep_condition
      like_pie_dep_condition

      # Responses

    end

    let(:response_set) do
      rs = FactoryBot.create(:response_set, num_responses: 0)
      rs.responses << FactoryBot.create(:response,
                                        question_id: do_you_like_pie.id,
                                        answer_id: do_you_like_pie.answers.last.id,
                                        response_set: rs,
                                        response_set_id: rs.id)
      rs
    end

    it 'should list all dependencies for answered questions' do
      dependency_conditions = response_set.send(:dependencies).last.dependency_conditions
      expect(dependency_conditions.size).to eq 2
      expect(dependency_conditions).to include(like_pie_dep_condition)
      expect(dependency_conditions).to include(like_jam_dep_condition)
    end

    it 'lists all dependencies for passed question_id' do
      # Questions
      like_ice_cream = FactoryBot.create(:question, text: 'Do you like ice_cream?',
                                                    survey_section: surv_section)
      what_flavor = FactoryBot.create(:question, text: 'What flavor?', survey_section: surv_section)

      # Answers
      like_ice_cream.answers << FactoryBot.create(:answer, text: 'yes', question_id: like_ice_cream.id)
      like_ice_cream.answers << FactoryBot.create(:answer, text: 'no', question_id: like_ice_cream.id)
      what_flavor.answers << FactoryBot.create(:answer, response_class: :string, question_id: what_flavor.id)

      # Dependency and DependencyCondition
      flavor_dependency = FactoryBot.create(:dependency, rule: 'C', question_id: what_flavor.id)
      FactoryBot.create(:dependency_condition, rule_key: 'A',
                        question_id: like_ice_cream.id, operator: '==',
                        answer_id: like_ice_cream.answers.first.id, dependency_id: flavor_dependency.id)


      dependency_conditions = response_set.send(:dependencies, like_ice_cream.id)
      expect(dependency_conditions).to match_array([flavor_dependency])
    end
  end

  def quiz_generate_responses(resp_set, num: 0,
                              quiz: false, correct: false)
    num.times do
      q = FactoryBot.create(:question, survey_section: surv_section)
      a = FactoryBot.create(:answer, question: q, response_class: 'answer')
      x = FactoryBot.create(:answer, question: q, response_class: 'answer')
      q.correct_answer = (quiz ? a : nil)
      resp_set.responses << FactoryBot.create(:response,
                                              question: q,
                                              answer: (correct ? a : x))
    end
    resp_set
  end

  describe 'as a quiz' do

    it 'reports correctness if it is a quiz' do
      rs = FactoryBot.create(:response_set, survey: a_survey, num_responses: 0)
      rs = quiz_generate_responses(rs, num: 3, quiz: true, correct: true)
      rs.correct?.should be_truthy
      rs.correctness_hash.should == { questions: 3, responses: 3, correct: 3 }
    end

    it 'reports incorrectness if it is a quiz' do
      rs = FactoryBot.create(:response_set, survey: a_survey, num_responses: 0)
      quiz_generate_responses(rs, num: 3, quiz: true, correct: false)
      rs.correct?.should be_falsey
      rs.correctness_hash.should == { questions: 3, responses: 3, correct: 0 }
    end

    it "reports correctness even if not a quiz" do
      rs = FactoryBot.create(:response_set, survey: a_survey, num_responses: 0)
      quiz_generate_responses(rs, num: 3, quiz: false)

      expect(rs).to be_correct
      expect(rs.correctness_hash).to eq({ questions: 3, responses: 3, correct: 3 })
    end
  end

  describe 'with mandatory questions' do
    #
    # before(:each) do
    #   @response_set = FactoryBot.create(:response_set, survey: a_survey)
    # end

    let(:response_set_manda_qs) { FactoryBot.create(:response_set, survey: a_survey, num_responses: 0) }

    def mandatory_q_generate_responses(count, mandatory = nil, responded = nil)
      count.times do |_i|
        q = FactoryBot.create(:question, survey_section: surv_section,
                                         is_mandatory: (mandatory == 'mandatory'))
        a = FactoryBot.create(:answer, question: q, response_class: 'answer')
        if responded == 'responded'
          response_set_manda_qs.responses << FactoryBot.create(:response, question: q, answer: a)
        end
      end
    end

    it 'should report progress without mandatory questions' do
      mandatory_q_generate_responses(3)
      response_set_manda_qs.mandatory_questions_complete?.should be_truthy
      response_set_manda_qs.progress_hash.should == { questions: 3, triggered: 3, triggered_mandatory: 0, triggered_mandatory_completed: 0 }
    end

    it 'should report progress with mandatory questions' do
      mandatory_q_generate_responses(3, 'mandatory', 'responded')
      response_set_manda_qs.mandatory_questions_complete?.should be_truthy
      response_set_manda_qs.progress_hash.should == { questions: 3, triggered: 3, triggered_mandatory: 3, triggered_mandatory_completed: 3 }
    end

    it 'should report progress with mandatory questions' do
      mandatory_q_generate_responses(3, 'mandatory', 'not-responded')
      response_set_manda_qs.mandatory_questions_complete?.should be_falsey
      response_set_manda_qs.progress_hash.should == { questions: 3, triggered: 3, triggered_mandatory: 3, triggered_mandatory_completed: 0 }
    end

    it 'should ignore labels and images' do
      # responder = FactoryBot.create(:user, email: "uemail-#{Time.now.to_i}@example.com")
      mandatory_q_generate_responses(3, 'mandatory', 'responded')
      FactoryBot.create(:question, survey_section: surv_section, display_type: 'label', is_mandatory: true)
      FactoryBot.create(:question, survey_section: surv_section, display_type: 'image', is_mandatory: true)
      response_set_manda_qs.mandatory_questions_complete?.should be_truthy
      response_set_manda_qs.progress_hash.should == { questions: 5, triggered: 5, triggered_mandatory: 5, triggered_mandatory_completed: 5 }
    end
  end


  describe 'with mandatory, dependent questions' do
    def mandatory_generate_responses(rs, num: 0,
                                     mandatory: false,
                                     dependent: false,
                                     triggered: false)

      dq = FactoryBot.create(:question, survey_section: surv_section,
                                        is_mandatory: mandatory)
      da = FactoryBot.create(:answer, question: dq, response_class: 'answer')
      dx = FactoryBot.create(:answer, question: dq, response_class: 'answer')

      num.times do
        q = FactoryBot.create(:question,
                              survey_section: surv_section,
                              is_mandatory: mandatory)
        a = FactoryBot.create(:answer, question: q, response_class: 'answer')

        if dependent
          d = FactoryBot.create(:dependency, question: q)
          dc = FactoryBot.create(:dependency_condition, dependency: d,
                                                        question: dq, answer: da)
        end

        rs.responses << FactoryBot.create(:response,
                                          response_set: rs,
                                          question: dq,
                                          answer: (triggered ? da : dx))
        rs.responses << FactoryBot.create(:response,
                                          response_set: rs,
                                          question: q,
                                          answer: a)
      end
      rs
    end

    it 'reports progress without mandatory questions' do
      responder = build(:user)
      rs = FactoryBot.create(:response_set, num_responses: 0, user: responder, survey: a_survey)
      rs = mandatory_generate_responses(rs, num: 3,
                                            mandatory: true, dependent: true)

      expect(rs.mandatory_questions_complete?).to be_truthy
      expect(rs.progress_hash).to eq({ questions: 4, triggered: 1, triggered_mandatory: 1, triggered_mandatory_completed: 1 })
    end

    it 'reports progress with mandatory questions' do
      responder = build(:user)
      rs = FactoryBot.create(:response_set, num_responses: 0, user: responder, survey: a_survey)
      rs = mandatory_generate_responses(rs, num: 3,
                                            mandatory: true,
                                            dependent: true,
                                            triggered: true)

      expect(rs.mandatory_questions_complete?).to be_truthy
      rs.progress_hash.should == { questions: 4, triggered: 4, triggered_mandatory: 4, triggered_mandatory_completed: 4 }
    end
  end


  describe 'exporting csv' do
    it 'should export a string with responses' do
      rset = FactoryBot.create(:response_set, survey: a_survey, num_responses: 0)
      rset = quiz_generate_responses(rset, num: 2, quiz: true, correct: true)

      expect(rset.responses.size).to eq 2

      csv = rset.to_csv
      expect(csv).to be_a String

      expect(csv).to match(/question.short_text/)
      expect(csv).to match(/What is your favorite color\?/)
      expect(csv).to match(/My favorite color is clear/)
    end
  end

  describe 'as_json' do
    let(:rs) do
      FactoryBot.create(:response_set, responses: [
                          FactoryBot.create(:response, question: FactoryBot.create(:question,
                                                                                   survey_section: surv_section),
                                                       answer: FactoryBot.create(:answer), string_value: '2')
                        ])
    end

    let(:js) { rs.as_json }

    it 'should include uuid, survey_id' do
      js[:uuid].should == rs.api_id
    end

    it 'should include responses with uuid, question_id, answer_id, value' do
      r0 = rs.responses[0]
      js[:responses][0][:uuid].should == r0.api_id
      js[:responses][0][:answer_id].should == r0.answer.api_id
      js[:responses][0][:question_id].should == r0.question.api_id
      js[:responses][0][:value].should == r0.string_value
    end
  end
end
