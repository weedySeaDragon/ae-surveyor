# encoding: UTF-8

require 'rails_helper'

# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(__dir__, 'shared_examples')

describe Answer, type: :model do
  let(:the_survey) { create(:survey) }
  let(:the_survey_section) { create(:survey_section, survey: the_survey) }
  let(:q) { create(:question, survey_section: the_survey_section) }
  let(:answer) { create(:answer, question: q) }

  context "when creating" do

    it { answer.should be_valid }

    it "deletes validation when deleted" do
      v_id = FactoryBot.create(:validation, :answer => answer).id
      answer.destroy
      Validation.find_by_id(v_id).should be_nil
    end
  end

  context "with mustache text substitution" do
    require 'mustache'

    let(:mustache_context) { Class.new(::Mustache) {
      def site
        "Northwestern";
      end


      ;


      def foo
        "bar";
      end } }

    it "subsitutes Mustache context variables" do
      answer.text = "You are in {{site}}"
      answer.in_context(answer.text, mustache_context).should == "You are in Northwestern"
      answer.text_for(nil, mustache_context).should == "You are in Northwestern"

      answer.help_text = "{{site}} is your site"
      answer.in_context(answer.help_text, mustache_context).should == "Northwestern is your site"
      answer.help_text_for(mustache_context).should == "Northwestern is your site"

      answer.default_value = "{{site}}"
      answer.in_context(answer.default_value, mustache_context).should == "Northwestern"
      answer.default_value_for(mustache_context).should == "Northwestern"
    end
  end

  context "with translations" do
    require 'yaml'
    let(:survey) { FactoryBot.create(:survey) }
    let(:survey_section) { FactoryBot.create(:survey_section) }
    let(:survey_translation) {
      FactoryBot.create(:survey_translation, :locale => :es, :translation => {
        :questions => {
          :name => {
            :answers => {
              :name => {
                :help_text => "Mi nombre es..."
              }
            }
          }
        }
      }.to_yaml)
    }
    let(:question) { FactoryBot.create(:question, :reference_identifier => "name") }
    before do
      answer.reference_identifier = "name"
      answer.help_text = "My name is..."
      answer.text = nil
      answer.question = question
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end
    it "returns its own translation" do
      answer.translation(:es)[:help_text].should == "Mi nombre es..."
    end
    it "returns translations in views" do
      answer.help_text_for(nil, :es).should == "Mi nombre es..."
    end
    it "returns its own default values" do
      answer.translation(:de).should == { "text" => nil, "help_text" => "My name is...", "default_value" => nil }
    end
    it "returns default values in views" do
      answer.help_text_for(nil, :de).should == "My name is..."
    end
  end



  it_behaves_like 'split will split the text' do
    let(:survey_item) { FactoryBot.create(:answer) }
  end


  context "for views" do

    it_behaves_like 'text_for' do
      let(:survey_item) { answer }
    end


    it "#default_value_for" do
      skip
    end

    it "#help_text_for" do
      skip
    end

    it "reports DOM ready #css_class from #custom_class" do
      answer.custom_class = "foo bar"
      answer.css_class.should == "foo bar"
    end

    it "reports DOM ready #css_class from #custom_class and #is_exclusive" do
      answer.custom_class = "foo bar"
      answer.is_exclusive = true
      answer.css_class.should == "exclusive foo bar"
    end

  end
end
