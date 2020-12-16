require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(__dir__, '..', '..', 'lib', 'surveyor', 'helpers', 'surveyor_helper_methods')
require 'rails_helper'

RSpec.describe 'SurveyorHelperMethods' do

  let(:survey) { create(:survey) }
  let!(:survey_section) { create(:survey_section, survey: survey)}

  class H
    include Surveyor::Helpers::SurveyorHelperMethods
  end
  let(:helper) { H.new }

  describe "q_text" do

    context 'labels, images, depdencies, grouped questions' do

      it 'no question number; just the text surrounded by a span' do

        q2 = FactoryBot.create(:question, display_type: "label", survey_section: survey_section)
        q3 = FactoryBot.create(:question, dependency: FactoryBot.create(:dependency), survey_section: survey_section)
        q4 = FactoryBot.create(:question, display_type: "image", text: "something.jpg", survey_section: survey_section)
        q5 = FactoryBot.create(:question, question_group: FactoryBot.create(:question_group), survey_section: survey_section)

        expect(helper.q_text(q2)).to eq "<span class='question_text'>#{q2.text}</span>"
        expect(helper.q_text(q3)).to eq "<span class='question_text'>#{q3.text}</span>"
        expect(helper.q_text(q4)).to match(/<span class='question_text'><img src="\/(images|assets)\/something\.jpg" alt="Something" \/><\/span>/)
        expect(helper.q_text(q5)).to eq "<span class='question_text'>#{q5.text}</span>"
      end
    end


    context 'not a label, image, depdencies, or grouped question' do

      it 'is the question number and the text surrounded by a span' do
        q1 = FactoryBot.create(:question, question_group: nil, survey_section: survey_section)
        expect(helper.q_text(q1)).to eq "<span class='qnum'>1) </span><span class='question_text'>#{q1.text}</span>"
      end
    end

  end


  describe 'next_question_number' do

    it 'returns a <span> that surrounds the next question number' do
      q1 = FactoryBot.create(:question, display_order: 0)
      q2 = FactoryBot.create(:question, display_order: 1, display_type: "label")

      expect(helper.next_question_number(q1)).to eq "<span class='qnum'>1) </span>"
      expect(helper.next_question_number(q2)).to eq "<span class='qnum'>2) </span>"
    end
  end


  describe "with mustache text substitution" do
    require 'mustache'

    it "substitues values into Question#text" do

      mustache_context = Class.new(::Mustache) {
        def site
          "Northwestern";
        end


        def something_else
          "something new";
        end


        def group
          "NUBIC";
        end
      }

      q1 = FactoryBot.create(:question, text: "You are in {{site}}", question_group: nil, survey_section: survey_section)
      label = FactoryBot.create(:question, display_type: "label", text: "Testing {{something_else}}", question_group: nil, survey_section: survey_section)

      expect(helper.q_text(q1, mustache_context)).to eq "<span class='qnum'>1) </span><span class='question_text'>You are in Northwestern</span>"
      expect(helper.q_text(label, mustache_context)).to eq "<span class='question_text'>Testing something new</span>"
    end
  end


  describe "response methods" do

    it "should find or create responses, with index" do
      q1 = FactoryBot.create(:question, answers: [a = FactoryBot.create(:answer, text: "different")])
      q2 = FactoryBot.create(:question, answers: [b = FactoryBot.create(:answer, text: "strokes")])
      q3 = FactoryBot.create(:question, answers: [c = FactoryBot.create(:answer, text: "folks")])

      # user = FactoryBot.create(:user)
      #
      # rs = FactoryBot.create(:response_set, user: user)
      # r1 = FactoryBot.create(:response, question: q1, answer: a, response_set: rs)
      # r3 = FactoryBot.create(:response, question: q3, answer: c, response_group: 1, response_set: rs)
      # rs.responses << r1 << r3
      #
      # expect(helper.response_for(rs, nil)).to be_nil
      # expect(helper.response_for(nil, q1)).to be_nil
      # expect(helper.response_for(rs, q1)).to eq r1
      # expect(helper.response_for(rs, q1, a)).to eq r1
      #
      # rs_q2_resp = helper.response_for(rs, q2)

      # q2_response_set = Response.new(question: q2, response_set: rs).attributes.reject { |k, _v| k == "api_id" }
      #
      # expect(helper.response_for(rs, q2).attributes.reject { |k, _v| k == "api_id" }).to eq q2_response_set
      # expect(helper.response_for(rs, q2, b).attributes.reject { |k, _v| k == "api_id" }).to eq q2_response_set
      # expect(helper.response_for(rs, q3, c, "1")).to eq r3
    end

    it "should keep an index of responses" do
      expect(helper.response_idx).to eq "1"
      expect(helper.response_idx).to eq "2"
      expect(helper.response_idx(false)).to eq "2"
      expect(helper.response_idx).to eq "3"
    end

    it "should translate response class into attribute" do
      expect(helper.rc_to_attr(:string)).to eq :string_value
      expect(helper.rc_to_attr(:text)).to eq :text_value
      expect(helper.rc_to_attr(:integer)).to eq :integer_value
      expect(helper.rc_to_attr(:float)).to eq :float_value
      expect(helper.rc_to_attr(:datetime)).to eq :datetime_value
      expect(helper.rc_to_attr(:date)).to eq :date_value
      expect(helper.rc_to_attr(:time)).to eq :time_value
    end

    it "should translate response class into as" do
      expect(helper.rc_to_as(:string)).to eq :string
      expect(helper.rc_to_as(:text)).to eq :text
      expect(helper.rc_to_as(:integer)).to eq :number
      expect(helper.rc_to_as(:float)).to eq :string
      expect(helper.rc_to_as(:datetime)).to eq :string
      expect(helper.rc_to_as(:date)).to eq :string
      expect(helper.rc_to_as(:time)).to eq :string
    end
  end


  describe 'rc_to_as' do

    # it 'can override the results and then revert' do
    #   # TODO: what is this really testing?
    #
    #     module SurveyorHelper
    #       include Surveyor::Helpers::SurveyorHelperMethods
    #       alias :old_rc_to_as :rc_to_as
    #
    #       def rc_to_as(type_sym)
    #         case type_sym.to_s
    #           when /(integer|float)/ then
    #             :string
    #           when /(datetime)/ then
    #             :datetime
    #           else
    #             type_sym
    #         end
    #       end
    #     end
    #
    #     expect(helper.rc_to_as(:string)).to eq :string
    #     expect(helper.rc_to_as(:text)).to eq :text
    #     expect(helper.rc_to_as(:integer)).to eq :string
    #     expect(helper.rc_to_as(:float)).to eq :string
    #     expect(helper.rc_to_as(:datetime)).to eq :datetime # not string
    #     expect(helper.rc_to_as(:date)).to eq :date # not string
    #     expect(helper.rc_to_as(:time)).to eq :time
    #
    #     # Undo the override
    #     module SurveyorHelper
    #       include Surveyor::Helpers::SurveyorHelperMethods
    #
    #       def rc_to_as(type_sym)
    #         old_rc_to_as(type_sym)
    #       end
    #     end
    #
    #     # These should now revert to the original results (strings)
    #     expect(helper.rc_to_as(:datetime)).to eq :string
    #     expect(helper.rc_to_as(:date)).to eq :string
    #   end

  end
end
