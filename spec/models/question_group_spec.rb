# encoding: UTF-8

require 'rails_helper'
require 'yaml'

describe QuestionGroup, type: :model do
  let!(:survey) do
    s = create(:survey)
    s_translation = create(:survey_translation,
                           locale: :es,
                           survey: s,
                           translation: {
                             question_groups: {
                               goodbye: {
                                 text: "¡Adios!"
                               }
                             }
                           }.to_yaml)
    s.translations << s_translation

    s
  end
  let(:survey_section) { build(:survey_section, survey: survey) }

  let(:question_group) { build(:question_group) }
  let(:question) { create(:question, survey_section: survey_section, question_group: question_group) }

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

    let(:q_group) do
      qgroup = create(:question_group, text: 'Goodbye', reference_identifier: 'goodbye')
      qgroup.questions = [question]
      question.question_group = qgroup
      qgroup
    end

    it "returns its own translation" do
      # survey.translations << survey_translation
      expect(q_group.translation(:es)[:text]).to eq "¡Adios!"
    end

    it "returns its own default values" do
      expect(q_group.translation(:de)).to eq({ "text" => "Goodbye", "help_text" => nil })
    end
  end
end
