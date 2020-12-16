require 'rails_helper'

RSpec.describe Validation, type: :model do

  describe 'validation' do

    it "should be valid" do
      validation = build(:validation)
      validation.should be_valid
    end

    it "should be invalid without a rule" do
      validation = build(:validation)
      validation.rule = nil
      expect(validation.valid?).to be_falsey
      expect(validation.errors.size).to eq 2
      expect(validation.errors.first.first).to eq :rule
      validation.rule = ' '
      expect(validation.valid?).to be_falsey
      expect(validation.errors.size).to eq 1
      expect(validation.errors.first.first).to eq :rule
    end

    # this causes issues with building and saving
    it "invalid without an answer" do
      validation = create(:validation)
      validation.answer = nil
      expect(validation.valid?).to be_falsey
      expect(validation.errors.size).to eq 1
      expect(validation.errors.first.first).to eq :answer
    end

    it "invalid unless rule composed of only references and operators" do
      validation = build(:validation)
      validation.rule = "foo"
      # validation.should have(1).error_on(:rule)
      expect(validation.valid?).to be_falsey
      expect(validation.errors.size).to eq 1
      expect(validation.errors.first.first).to eq :rule

      validation.rule = "1 to 2"
      # validation.should have(1).error_on(:rule)
      expect(validation.valid?).to be_falsey
      expect(validation.errors.size).to eq 1
      expect(validation.errors.first.first).to eq :rule

      validation.rule = "a and b"
      # validation.should have(1).error_on(:rule)
      expect(validation.valid?).to be_falsey
      expect(validation.errors.size).to eq 1
      expect(validation.errors.first.first).to eq :rule
    end

  end

  describe "reporting status" do

    class FauxResponseSet
      attr_accessor :responses

      def initialize
        @responses = []
      end
    end


    def test_var(validation: {}, val_conditions: [], answer:, response:)
      v = build(:validation, { answer: answer, rule: "A" }.merge(validation))
      val_conditions.each do |vchash|
        build(:validation_condition, { validation: v, rule_key: "A" }.merge(vchash))
      end

      # rs = create(:response_set)
      rs = FauxResponseSet.new
      # r = create(:response, { answer: answer, question: answer.question }.merge(response))
      rs.responses << response
      val_conditions.each do |val_condition|
        allow(val_condition).to receive(:is_valid?).and_return(true)
      end

      v.is_valid?(rs)
    end


    describe 'conditions_hash' do

      xit 'finds the response in the response set for this answer' do
        answer = create(:answer, response_class: 'integer')
        validation = build(:validation, answer: answer,
                                       rule: 'A and B')

        valid_condition1 = build(:validation_condition,
                                             validation: validation,
                                             rule_key: 'A',
                                             operator: '>=', integer_value: 0)
        valid_condition2 = build(:validation_condition,
                                             validation: validation,
                                             rule_key: 'B', operator: '<=',
                                             integer_value: 120)
        rs = FauxResponseSet.new

        response = instance_double(Response)
        allow(response).to receive(:answer_id).and_return(answer.id)
        rs.responses << response

        allow_any_instance_of(ValidationCondition).to receive(:is_valid?).and_return(true)

        # Not able to get RSpec to recognize that these have been sent messages.
        # expect(valid_condition1).to receive(:to_hash).with(response).and_return({ A: true })
        # expect(valid_condition2).to receive(:to_hash).with(response).and_return({ B: true })
      end

      it 'calls validation_condition to return a hash for each condition' do
        answer = create(:answer, response_class: 'integer')
        validation = build(:validation, answer: answer,
                                       rule: 'A and B')

        valid_condition1 = create(:validation_condition,
                                           validation: validation,
                                           rule_key: 'A',
                                           operator: '>=', integer_value: 0)
        valid_condition2 = create(:validation_condition,
                                             validation: validation,
                                             rule_key: 'B', operator: '<=',
                                             integer_value: 120)
        rs = FauxResponseSet.new

        response = instance_double(Response)
        allow(response).to receive(:answer_id).and_return(answer.id)
        rs.responses << response

        allow_any_instance_of(ValidationCondition).to receive(:is_valid?).and_return(true)

        # Not able to get RSpec to recognize that these have been sent messages.
        # expect(valid_condition1).to receive(:to_hash).with(response).and_return({ A: true })
        # expect(valid_condition2).to receive(:to_hash).with(response).and_return({ B: true })

        expect(validation.conditions_hash(rs)).to eq({ A: true,
                                                       B: true })
      end
    end


    describe 'is_valid?' do

      let(:answer) { answer = create(:answer, response_class: 'integer') }
      let(:r_set) { FauxResponseSet.new }


      it 'turns the response set into a hash of conditions (ch)' do

        validation = build(:validation, answer: answer,
                                       rule: 'A and B')
        valid_condition1 = create(:validation_condition,
                                             validation: validation,
                                             rule_key: 'A',
                                             operator: '>=', integer_value: 0)
        valid_condition2 = create(:validation_condition,
                                             validation: validation,
                                             rule_key: 'B', operator: '<=',
                                             integer_value: 120)
        response = instance_double("Response")
        allow(response).to receive(:answer_id).and_return(answer.id)
        r_set.responses << response
        allow_any_instance_of(ValidationCondition).to receive(:is_valid?).and_return(true)

        expect(validation).to receive(:conditions_hash).with(r_set).and_call_original

        validation.is_valid?(r_set)
      end

      it 'excludes any AND or OR condtions from validation_conditions' do

      end

      it "creates a regular expression as all of the validation conditions OR'd together" do

      end

      it 'evaluates the regular expression created with the hash ' do

      end
    end

    xit "should validate a response by integer comparison" do
      answer = create(:answer, response_class: 'integer')
      response = instance_double("Response")
      allow(response).to receive(:answer_id).and_return(answer.id)
      allow(response).to receive(:integer_value).and_return(48)

      result = test_var(validation: { rule: 'A and B' },
                        val_conditions: [{ operator: '>=', integer_value: 0 },
                                         { rule_key: 'B', operator: '<=', integer_value: 120 }],
                        answer: answer,
                        response: response)
      expect(result).to be_truthy
    end

    xit "should validate a response by regexp" do
      answer = create(:answer, response_class: 'string')
      response = instance_double("Response")
      allow(response).to receive(:answer_id).and_return (answer.id)
      allow(response).to receive(:string_value).and_return('')

      result = test_var(answer: answer,
                        validation: {},
                        val_conditions: [{ operator: '=~',
                                           regexp: '/^[a-z]{1,6}$/' }],
                        response: response)
      expect(result).to be_falsey
    end
  end

  describe "conditions" do

    it "should destroy conditions when destroyed" do
      validation = build(:validation)
      build(:validation_condition, validation: validation, rule_key: "A")
      build(:validation_condition, validation: validation, rule_key: "B")
      build(:validation_condition, validation: validation, rule_key: "C")

      v_ids = validation.validation_conditions.map(&:id)
      validation.destroy
      v_ids.each { |id| expect(DependencyCondition.find_by_id(id)).to be_nil }
    end
  end

end
