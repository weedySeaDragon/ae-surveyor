require 'rails_helper'


RSpec.describe ValidationCondition, type: :model do

  describe 'validation' do

    it "factory is valid" do
      build(:validation_condition).should be_valid
    end

    it "should be invalid without an operator" do
      validation_condition = build(:validation_condition)
      validation_condition.operator = nil
      validation_condition.validate
      expect(validation_condition.errors.size).to eq 2
      expect(validation_condition.errors.first.first).to eq :operator
    end

    it "should be invalid without a rule_key" do
      validation_condition = build(:validation_condition)
      validation_condition.rule_key = nil
      expect(validation_condition.valid?).to be_falsey
      expect(validation_condition.errors.size).to eq 1
      expect(validation_condition.errors.first.first).to eq :rule_key
    end

    it "should have unique rule_key within the context of a validation" do
      validation_condition = build(:validation_condition)

      create(:validation_condition, validation: FactoryBot.build(:validation),
                                               validation_id: 2, rule_key: "2")
      validation_condition.rule_key = "2" #rule key uniquness is scoped by validation_id
      validation_condition.validation_id = 2
      expect(validation_condition.valid?).to be_falsey
      expect(validation_condition.errors.size).to eq 1
      expect(validation_condition.errors.first.first).to eq :rule_key
    end

    it "should have an operator in Surveyor::Common::OPERATORS" do
      validation_condition = build(:validation_condition)
      Surveyor::Common::OPERATORS.each do |o|
        validation_condition.operator = o
        expect(validation_condition.errors.size).to eq 0
      end

      validation_condition.operator = "#"
      validation_condition.validate
      expect(validation_condition.errors.size).to eq 1
      expect(validation_condition.errors.first.first).to eq :operator
    end
  end


  describe 'validating responses' do

    describe 'validate a response with a Regular Expression' do

      let(:string_class_answer) { FactoryBot.build(:answer, response_class: 'string') }

      it '/^[a-z]{1,6}$/' do
        v_condition = build(:validation_condition,
                                        operator: '=~',
                                        regexp: /^[a-z]{1,6}$/.to_s) # string of length 6, all letters

        response = instance_double(Response, string_value: 'clear')
        allow(response).to receive(:answer).and_return(string_class_answer)

        allow(response).to receive(:as).with('string').and_return('clear')
        expect(v_condition.is_valid?(response)).to be_truthy

        allow(response).to receive(:as).with('string').and_return('8')
        expect(v_condition.is_valid?(response)).to be_falsey

        allow(response).to receive(:as).with('string').and_return('blorfflurb')
        expect(v_condition.is_valid?(response)).to be_falsey
      end


      describe 'validate  by integer comparison' do
        let(:int_class_answer) { FactoryBot.build(:answer, response_class: 'integer') }

        it 'response > 3' do
          v_condition = build(:validation_condition,
                                          operator: '>',
                                          integer_value: 3)
          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(int_class_answer)

          allow(response).to receive(:as).with('integer').and_return(4)
          expect(v_condition.is_valid?(response)).to be_truthy
        end

        it 'response <= 256' do
          v_condition = build(:validation_condition,
                                          operator: '<=',
                                          integer_value: 256)
          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(int_class_answer)

          allow(response).to receive(:as).with('integer').and_return(512)
          expect(v_condition.is_valid?(response)).to be_falsey
        end
      end


      describe 'validate by (in)equality' do

        it '!=' do
          date_class_answer = FactoryBot.build(:answer, response_class: 'date')
          v_condition = build(:validation_condition,
                                          operator: '!=',
                                          datetime_value: Date.today + 1)
          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(date_class_answer)

          allow(response).to receive(:as).with('date').and_return(Date.today)
          expect(v_condition.is_valid?(response)).to be_truthy
        end

        it '==' do
          str_class_answer = FactoryBot.build(:answer, response_class: 'string')
          v_condition = build(:validation_condition,
                                          operator: '==',
                                          string_value: 'blorf')
          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(str_class_answer)

          allow(response).to receive(:as).with('string').and_return('flurb')
          expect(v_condition.is_valid?(response)).to be_falsey

          allow(response).to receive(:as).with('string').and_return('blorf')
          expect(v_condition.is_valid?(response)).to be_truthy
        end
      end
    end


    it 'to_hash' do
      validation_condition = build(:validation_condition, rule_key: "A")

      validation_condition.stub(:is_valid?).and_return(true)
      expect(validation_condition.to_hash("foo")).to eq({ A: true })

      validation_condition.stub(:is_valid?).and_return(false)
      expect(validation_condition.to_hash("foo")).to eq({ A: false })
    end


    describe 'validating responses by other responses' do

      def test_var(v_hash, a_hash, r_hash, ca_hash, cr_hash)
        ca = FactoryBot.build(:answer, ca_hash)
        cr = FactoryBot.build(:response, cr_hash.merge(answer: ca, question: ca.question))
        v = build(:validation_condition, v_hash.merge({question_id: ca.question.id, answer_id: ca.id}))
        a = FactoryBot.build(:answer, a_hash)
        r = FactoryBot.build(:response, r_hash.merge(answer: a, question: a.question))

        v.is_valid?(r)
      end

      describe "validate a response by integer comparison" do

        it ' > 3' do
          int_class_answer = FactoryBot.build(:answer, response_class: 'integer')
          v_condition = build(:validation_condition,
                                          operator: '>')

          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(int_class_answer)
          allow(response).to receive(:as).with('integer').and_return(4)

          existing_response = instance_double(Response)
          allow(existing_response).to receive(:answer).and_return(int_class_answer)
          allow(existing_response).to receive(:as).with('integer').and_return(3)
          allow(Response).to receive(:find_by_question_id_and_answer_id).and_return(existing_response)

          expect(v_condition.is_valid?(response)).to be_truthy
        end

        it '<= 4' do
          int_class_answer = FactoryBot.build(:answer, response_class: 'integer')
          v_condition = build(:validation_condition,
                                          operator: '<=')

          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(int_class_answer)
          allow(response).to receive(:as).with('integer').and_return(512)

          existing_response = instance_double(Response)
          allow(existing_response).to receive(:answer).and_return(int_class_answer)
          allow(existing_response).to receive(:as).with('integer').and_return(4)
          allow(Response).to receive(:find_by_question_id_and_answer_id).and_return(existing_response)

          expect(v_condition.is_valid?(response)).to be_falsey
        end
      end

      describe "should validate a response by (in)equality" do

        it '!=' do
          date_class_answer = FactoryBot.build(:answer, response_class: 'date')
          v_condition = build(:validation_condition,
                                          operator: '!=')
          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(date_class_answer)
          allow(response).to receive(:as).with('date').and_return(Date.today)

          existing_response = instance_double(Response)
          allow(existing_response).to receive(:answer).and_return(date_class_answer)
          allow(existing_response).to receive(:as).with('date').and_return(Date.today)
          allow(Response).to receive(:find_by_question_id_and_answer_id).and_return(existing_response)

          expect(v_condition.is_valid?(response)).to be_falsey

          allow(existing_response).to receive(:as).with('date').and_return(Date.today + 1)
          expect(v_condition.is_valid?(response)).to be_truthy
        end

        it '==' do
          str_class_answer = FactoryBot.build(:answer, response_class: 'string')
          v_condition = build(:validation_condition,
                                          operator: '==')
          response = instance_double(Response)
          allow(response).to receive(:answer).and_return(str_class_answer)
          allow(response).to receive(:as).with('string').and_return('flurb')

          existing_response = instance_double(Response)
          allow(existing_response).to receive(:answer).and_return(str_class_answer)
          allow(existing_response).to receive(:as).with('string').and_return('flurb')
          allow(Response).to receive(:find_by_question_id_and_answer_id).and_return(existing_response)

          expect(v_condition.is_valid?(response)).to be_truthy

          allow(existing_response).to receive(:as).with('string').and_return('blorf')
          expect(v_condition.is_valid?(response)).to be_falsey
        end
      end

      it "should not validate a response by regexp" do
        str_class_date = FactoryBot.build(:answer, response_class: 'date')
        v_condition = build(:validation_condition,
                                        operator: '=~')
        response = instance_double(Response)
        allow(response).to receive(:answer).and_return(str_class_date)
        allow(response).to receive(:as).with('date').and_return(Date.today)

        existing_response = instance_double(Response)
        allow(existing_response).to receive(:answer).and_return(str_class_date)
        allow(existing_response).to receive(:as).with('date').and_return(Date.today)
        allow(Response).to receive(:find_by_question_id_and_answer_id).and_return(existing_response)

        expect(v_condition.is_valid?(response)).to be_falsey

        str_class_answer = FactoryBot.build(:answer, response_class: 'string')
        v_condition = build(:validation_condition,
                                        operator: '=~')
        response = instance_double(Response)
        allow(response).to receive(:answer).and_return(str_class_answer)
        allow(response).to receive(:as).with('string').and_return('flurb')

        existing_response = instance_double(Response)
        allow(existing_response).to receive(:answer).and_return(str_class_answer)
        allow(existing_response).to receive(:as).with('string').and_return('flurb')
        allow(Response).to receive(:find_by_question_id_and_answer_id).and_return(existing_response)

        expect(v_condition.is_valid?(response)).to be_falsey
      end
    end

  end

end

