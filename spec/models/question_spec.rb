# encoding: UTF-8

require 'rails_helper'


require File.join(__dir__, 'shared_examples')

describe Question do
  let(:the_survey) { create(:survey) }
  let(:the_survey_section) { create(:survey_section, survey: the_survey) }
  let(:question){ FactoryBot.create(:question, survey_section: the_survey_section) }

  context "when creating" do

    it "is invalid without #text" do
      question.text = nil
      expect(question.valid?).to be_falsey
      expect(question.errors.size).to eq 1
      expect(question.errors.first.first).to eq :text  # .should have(1).error_on :text
    end

    it "#is_mandantory == false by default" do
      question.mandatory?.should be_falsey
    end

    it "converts #pick to string" do
      question.pick.should == "none"
      question.pick = :one
      question.pick.should == "one"
      question.pick = nil
      question.pick.should == nil
    end

    it "#renderer == 'default' when #display_type = nil" do
      question.display_type = nil
      question.renderer.should == :default
    end

    it "has #api_id with 36 characters by default" do
      question.api_id.length.should == 36
    end

    it "#part_of_group? and #solo? are aware of question groups" do
      question.question_group = FactoryBot.create(:question_group)
      question.solo?.should be_falsey
      question.part_of_group?.should be_truthy

      question.question_group = nil
      question.solo?.should be_truthy
      question.part_of_group?.should be_falsey
    end
  end


  context 'with answers' do

    describe 'has expected answers, in order' do
      let(:answer_1){ FactoryBot.create(:answer, :display_order => 3, :text => "blue")}
      let(:answer_2){ FactoryBot.create(:answer, :display_order => 1, :text => "red")}
      let(:answer_3){ FactoryBot.create(:answer, :display_order => 2, :text => "green")}

      let(:q) {
        ques = FactoryBot.build(:question)
        [answer_1, answer_2, answer_3].each{|a| ques.answers << a; a.question = ques }
        ques
      }

      it do
        expect(q.answers.size).to eq 3
      end

      it 'gets answers in order' do
        sorted_ans = q.answers.sort_by(&:display_order).to_a
        expect(sorted_ans).to eq [answer_2, answer_3, answer_1]
        expect(sorted_ans.map(&:display_order)).to eq [1,2,3]
      end
    end

    it "deletes child answers when deleted" do
      q = FactoryBot.create(:question)
      ans1 = FactoryBot.create(:answer, :question => q, :display_order => 3, :text => "blue")
      q.answers << ans1
      ans2 = FactoryBot.create(:answer, :question => q, :display_order => 1, :text => "red")
      q.answers << ans2

      answer_ids = question.answers.map(&:id)
      question.destroy
      answer_ids.each{|id| Answer.find_by_id(id).should be_nil}
    end
  end


  describe 'triggered?' do

      context 'has a dependency' do

        it '= dependency is met' do
          dependency =  FactoryBot.create(:dependency)
          question.dependency = dependency

          expect(dependency).to receive(:is_met?).and_return(true)
          expect(question.triggered?('blorf')).to be_truthy

          expect(dependency).to receive(:is_met?).and_return(false)
          expect(question.triggered?('blorf')).to be_falsey
        end
      end

      context 'no dependency' do
        it 'is always true' do
          expect(question.triggered?('flurb')).to be_truthy
        end
      end
    end


  context "with mustache text substitution" do

    require 'mustache'
    let(:mustache_context){ Class.new(::Mustache){ def site; "Northwestern"; end; def foo; "bar"; end } }

    it "subsitutes Mustache context variables" do
      question.text = "You are in {{site}}"
      question.in_context(question.text, mustache_context).should == "You are in Northwestern"
    end

    it "substitues in views" do
      question.text = "You are in {{site}}"
      question.text_for(nil, mustache_context).should == "You are in Northwestern"
    end
  end

  context "with translations" do

    require 'yaml'
    let(:survey){ FactoryBot.create(:survey) }
    let(:survey_section){ FactoryBot.create(:survey_section) }

    let(:survey_translation){
      FactoryBot.create(:survey_translation, :locale => :es, :translation => {
        :questions => {
          :hello => {
            :text => "¡Hola!"
          }
        }
      }.to_yaml)
    }

    before do
      question.reference_identifier = "hello"
      question.survey_section = survey_section
      survey_section.survey = survey
      survey.translations << survey_translation
    end

    it "returns its own translation" do
      YAML.load(survey_translation.translation).should_not be_nil
      question.translation(:es)[:text].should == "¡Hola!"
    end

    it "returns its own default values" do
      question.translation(:de).should == {"text" => question.text, "help_text" => question.help_text}
    end

    it "returns translations in views" do
      question.text_for(nil, nil, :es).should == "¡Hola!"
    end

    it "returns default values in views" do
      question.text_for(nil, nil, :de).should == question.text
    end
  end


  it_behaves_like 'split will split the text' do
    let(:survey_item) { FactoryBot.create(:question) }
  end

  context "for views" do

    it_behaves_like 'text_for' do
      let(:survey_item) { question }
    end

    it "#help_text_for" do
      skip
    end
  end
end
