# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionGroup do

  let(:question_group){ FactoryBot.create(:question_group) }


  context 'when creating' do

    it { question_group.should be_valid }

    it "#display_type = inline by default" do
      question_group.display_type = "inline"
      question_group.renderer.should == :inline
    end

    it "#renderer == 'default' when #display_type = nil" do
      question_group.display_type = nil
      question_group.renderer.should == :default
    end

    it "interprets symbolizes #display_type to #renderer" do
      question_group.display_type = "foo"
      question_group.renderer.should == :foo
    end

    it 'css_class is based on depdendent?, triggered? with custom css' do

      allow(question_group).to receive(:dependent?).and_return(true)
      allow(question_group).to receive(:triggered?).and_return(true)
      expect(question_group.css_class('blorf')).to eq 'g_dependent'

      allow(question_group).to receive(:dependent?).and_return(true)
      allow(question_group).to receive(:triggered?).and_return(false)
      expect(question_group.css_class('blorf')).to eq 'g_dependent g_hidden'

      allow(question_group).to receive(:dependent?).and_return(true)
      allow(question_group).to receive(:triggered?).and_return(false)
      question_group.custom_class = 'foo bar'
      expect(question_group.css_class('blorf')).to eq 'g_dependent g_hidden foo bar'
    end
  end

  context "with translations" do
    require 'yaml'
    let!(:survey){ FactoryBot.create(:survey) }
    let(:survey_section){ FactoryBot.create(:survey_section) }
    let(:survey_translation){

      FactoryBot.create(:survey_translation, :locale => :es, survey: survey, :translation => {
        :question_groups => {
          :goodbye => {
            :text => "¡Adios!"
          }
        }
      }.to_yaml)
    }

    let(:question){ FactoryBot.create(:question) }
    before do
      question_group.text = "Goodbye"
      question_group.reference_identifier = "goodbye"
      question_group.questions = [question]
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end

    it "returns its own translation" do
      question_group.translation(:es)[:text].should == "¡Adios!"
    end

    it "returns its own default values" do
      question_group.translation(:de).should == {"text" => "Goodbye", "help_text" => nil}
    end
  end
end
