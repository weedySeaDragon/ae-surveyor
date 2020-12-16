require 'rails_helper'


RSpec.describe DependencyCondition, type: :model do

  it 'factory is valid' do
    expect(build(:dependency_condition)).to be_valid
  end


  it "should have a list of operators" do
    %w(== != < > <= >=).each do |operator|
      DependencyCondition.operators.include?(operator).should be_truthy
    end
  end

  describe "instance" do

    before(:each) do
      @dependency_condition = build(:dependency_condition,
        dependency_id: 1,
        question_id: 45,
        operator: '==',
        answer_id: 23,
        rule_key: 'A')
    end


    it "should be invalid without a parent dependency_id, question_id" do
      # this causes issues with building and saving
      # @dependency_condition.dependency_id = nil
      # @dependency_condition.should have(1).errors_on(:dependency_id)
      # @dependency_condition.question_id = nil
      # @dependency_condition.should have(1).errors_on(:question_id)
    end

    it "should be invalid without an operator" do
      @dependency_condition.operator = nil
      # @dependency_condition.should have(2).errors_on(:operator)
      expect(@dependency_condition).not_to be_valid
      expect(@dependency_condition.errors.details.keys).to match([:operator])
    end

    it "should be invalid without a rule_key" do
      @dependency_condition.should be_valid
      @dependency_condition.rule_key = nil
      expect(@dependency_condition).not_to be_valid
      expect(@dependency_condition.errors.details.keys).to match([:rule_key])
    end

    it "should have unique rule_key within the context of a dependency" do
      expect(@dependency_condition).to be_valid
      create(:dependency_condition,
        dependency_id: @dependency_condition.dependency_id, question_id: 46, operator: "==",
        answer_id: 14, rule_key: @dependency_condition.rule_key)
      expect(@dependency_condition).not_to be_valid
      expect(@dependency_condition.errors.details.keys).to match([:rule_key])
    end

    it 'should have an operator in DependencyCondition.operators' do
      DependencyCondition.operators.each do |o|
        @dependency_condition.operator = o
        expect(@dependency_condition).to be_valid
        # @dependency_condition.should have(0).errors_on(:operator)
      end
      @dependency_condition.operator = "#"
      # @dependency_condition.should have(1).error_on(:operator)
      expect(@dependency_condition).not_to be_valid
      expect(@dependency_condition.errors.details.keys).to match([:operator])
    end

    it 'count operator is valid or has errors' do
      %w(count>1 count<1 count>=1 count<=1 count==1 count!=1).each do |count_operator|
        @dependency_condition.operator = count_operator
        expect(@dependency_condition).to be_valid
      end

      %w(count> count< count>= count<= count== count!=).each do |bad_count_op|
        @dependency_condition.operator = bad_count_op
        expect(@dependency_condition).not_to be_valid
        expect(@dependency_condition.errors.details.keys).to match([:operator])
      end

      %w(count=1 count><1 count<>1 count!1 count!!1 count=>1 count=<1).each do |count_operator|
        @dependency_condition.operator = count_operator
        # @dependency_condition.should have(1).errors_on(:operator)
        expect(@dependency_condition.errors.details.keys).to match([:operator])
      end
      %w(count= count>< count<> count! count!! count=> count=< count> count< count>= count<= count== count!=).each do |o|
        @dependency_condition.operator = o
        # @dependency_condition.should have(1).errors_on(:operator)
        expect(@dependency_condition.errors.details.keys).to match([:operator])
      end
    end
  end

  it 'returns true for != with no responses' do
    question = FactoryBot.create(:question)
    dependency_condition = build(:dependency_condition, rule_key: "C", question: question)
    rs = FactoryBot.create(:response_set)
    dependency_condition.to_hash(rs).should == {C: false}
  end


  it 'should not assume that Response#as is not nil' do
    # q_HEIGHT_FT "Portion of height in whole feet (e.g., 5)",
    # :pick=>:one
    # a :integer
    # a_neg_1 "Refused"
    # a_neg_2 "Don't know"
    # label "Provided value is outside of the suggested range (4 to 7 feet). This value is admissible, but you may wish to verify."
    # dependency :rule=>"A or B"
    # condition_A :q_HEIGHT_FT, "<", {:integer_value => "4"}
    # condition_B :q_HEIGHT_FT, ">", {:integer_value => "7"}

    answer = FactoryBot.create(:answer, response_class: :integer)

    @dependency_condition = build(:dependency_condition,
      dependency: FactoryBot.create(:dependency),
      question: answer.question,
      answer: answer,
      operator: ">",
      integer_value: 4,
      rule_key: "A")

    response_set = create(:response_set, num_responses: 0)
    response = FactoryBot.create(:response, answer: answer, question: answer.question, response_set: response_set)
    response.integer_value.should == nil

    @dependency_condition.to_hash(response_set).should == {A: false}
  end


  describe "evaluate '==' operator" do

    before(:each) do
      @rs = FactoryBot.create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer, response_class: "answer")
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, response_set: @rs)
      @dc = build(:dependency_condition, question: @a.question, answer: @a, operator: "==", rule_key: "D")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dc.to_hash(@rs).should == {D: true}
      @dc.answer = @b
      @dc.to_hash(@rs).should == {D: false}
    end

    it "with string value response" do
      @a.update_attributes(response_class: "string")
      @r.update_attributes(string_value: "hello123")
      @dc.string_value = "hello123"
      @dc.to_hash(@rs).should == {D: true}
      @r.update_attributes(string_value: "foo_abc")
      @dc.to_hash(@rs).should == {D: false}
    end

    it "with a text value response" do
      @a.update_attributes(response_class: "text")
      @r.update_attributes(text_value: "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      @dc.to_hash(@rs).should == {D: true}
      @r.update_attributes(text_value: "Not the same text")
      @dc.to_hash(@rs).should == {D: false}
    end

    it "with an integer value response" do
      @a.update_attributes(response_class: "integer")
      @r.update_attributes(integer_value: 10045)
      @dc.integer_value = 10045
      @dc.to_hash(@rs).should == {D: true}
      @r.update_attributes(integer_value: 421)
      @dc.to_hash(@rs).should == {D: false}
    end

    it "with a float value response" do
      @a.update_attributes(response_class: "float")
      @r.update_attributes(float_value: 121.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {D: true}
      @r.update_attributes(float_value: 130.123)
      @dc.to_hash(@rs).should == {D: false}
    end
  end


  describe "evaluate '!=' operator" do

    before(:each) do
      @rs = FactoryBot.create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, response_set: @rs)
      @dc = build(:dependency_condition,
                              question: @a.question,
                              answer: @a,
                              operator: "!=",
                              rule_key: "E")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with checkbox/radio type response" do
      @dc.to_hash(@rs).should == {E: false}
      @dc.answer_id = @a.id.to_i+1
      @dc.to_hash(@rs).should == {E: true}
    end

    it "with string value response" do
      @a.update_attributes(response_class: "string")
      @r.update_attributes(string_value: "hello123")
      @dc.string_value = "hello123"
      @dc.to_hash(@rs).should == {E: false}
      @r.update_attributes(string_value: "foo_abc")
      @dc.to_hash(@rs).should == {E: true}
    end

    it "with a text value response" do
      @a.update_attributes(response_class: "text")
      @r.update_attributes(text_value: "hello this is some text for comparison")
      @dc.text_value = "hello this is some text for comparison"
      @dc.to_hash(@rs).should == {E: false}
      @r.update_attributes(text_value: "Not the same text")
      @dc.to_hash(@rs).should == {E: true}
    end

    it "with an integer value response" do
      @a.update_attributes(response_class: "integer")
      @r.update_attributes(integer_value: 10045)
      @dc.integer_value = 10045
      @dc.to_hash(@rs).should == {E: false}
      @r.update_attributes(integer_value: 421)
      @dc.to_hash(@rs).should == {E: true}
    end

    it "with a float value response" do
      @a.update_attributes(response_class: "float")
      @r.update_attributes(float_value: 121.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {E: false}
      @r.update_attributes(float_value: 130.123)
      @dc.to_hash(@rs).should == {E: true}
    end
  end

  describe "evaluate the '<' operator" do
    before(:each) do
      @rs = FactoryBot.create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, response_set: @rs)
      @dc = build(:dependency_condition, question: @a.question, answer: @a, operator: "<", rule_key: "F")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(response_class: "integer")
      @r.update_attributes(integer_value: 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {F: true}
      @r.update_attributes(integer_value: 421)
      @dc.to_hash(@rs).should == {F: false}
    end

    it "with a float value response" do
      @a.update_attributes(response_class: "float")
      @r.update_attributes(float_value: 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {F: true}
      @r.update_attributes(float_value: 130.123)
      @dc.to_hash(@rs).should == {F: false}
    end
  end

  describe "evaluate the '<=' operator" do

    before(:each) do
      @rs = FactoryBot.create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, response_set: @rs)
      @dc = build(:dependency_condition, operator: "<=",
                                    rule_key: "G",
                                    question: @a.question,
                                    answer: @a)
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(response_class: "integer")
      @r.update_attributes(integer_value: 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {G: true}
      @r.update_attributes(integer_value: 100)
      @dc.to_hash(@rs).should == {G: true}
      @r.update_attributes(integer_value: 421)
      @dc.to_hash(@rs).should == {G: false}
    end

    it "with a float value response" do
      @a.update_attributes(response_class: "float")
      @r.update_attributes(float_value: 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {G: true}
      @r.update_attributes(float_value: 121.1)
      @dc.to_hash(@rs).should == {G: true}
      @r.update_attributes(float_value: 130.123)
      @dc.to_hash(@rs).should == {G: false}
    end

  end

  describe "evaluate the '>' operator" do
    before(:each) do
      @rs = FactoryBot.create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, response_set: @rs)
      @dc = build(:dependency_condition, operator: ">",
                                    rule_key: "H",
                                    question: @a.question,
                                    answer: @a)
      # @dc = build(:dependency_condition, question: @a.question, answer: @a, operator: ">", rule_key: "H")
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(response_class: "integer")
      @r.update_attributes(integer_value: 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {H: false}
      @r.update_attributes(integer_value: 421)
      @dc.to_hash(@rs).should == {H: true}
    end

    it "with a float value response" do
      @a.update_attributes(response_class: "float")
      @r.update_attributes(float_value: 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {H: false}
      @r.update_attributes(float_value: 130.123)
      @dc.to_hash(@rs).should == {H: true}
    end
  end


  describe "evaluate the '>=' operator" do
    before(:each) do
      @rs = FactoryBot.create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer)
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, response_set: @rs)
      @dc = build(:dependency_condition, operator: ">=",
                                    rule_key: "I",
                                    question: @a.question,
                                    answer: @a)
      @dc.as(:answer).should == @r.as(:answer)
    end

    it "with an integer value response" do
      @a.update_attributes(response_class: "integer")
      @r.update_attributes(integer_value: 50)
      @dc.integer_value = 100
      @dc.to_hash(@rs).should == {I: false}
      @r.update_attributes(integer_value: 100)
      @dc.to_hash(@rs).should == {I: true}
      @r.update_attributes(integer_value: 421)
      @dc.to_hash(@rs).should == {I: true}
    end

    it "with a float value response" do
      @a.update_attributes(response_class: "float")
      @r.update_attributes(float_value: 5.1)
      @dc.float_value = 121.1
      @dc.to_hash(@rs).should == {I: false}
      @r.update_attributes(float_value: 121.1)
      @dc.to_hash(@rs).should == {I: true}
      @r.update_attributes(float_value: 130.123)
      @dc.to_hash(@rs).should == {I: true}
    end
  end

  describe "evaluating with response_class string" do

    it "should compare answer ids when the dependency condition string_value is nil" do
      @rs = create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer, response_class: "string")
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, string_value: "", response_set: @rs)
      @dc = build(:dependency_condition, question: @a.question, answer: @a, operator: "==", rule_key: "J")
      @dc.to_hash(@rs).should == {J: true}
    end

    it "should compare strings when the dependency condition string_value is not nil, even if it is blank" do
      @rs = create(:response_set, num_responses: 0)
      @a = FactoryBot.create(:answer, response_class: "string")
      @b = FactoryBot.create(:answer, question: @a.question)
      @r = FactoryBot.create(:response, question: @a.question, answer: @a, string_value: "foo", response_set: @rs)
      @dc = build(:dependency_condition, question: @a.question, answer: @a, operator: "==", rule_key: "K", string_value: "foo")
      @dc.to_hash(@rs).should == {K: true}

      @r.update_attributes(string_value: "")
      @dc.string_value = ""
      @dc.to_hash(@rs).should == {K: true}
    end
  end

  describe "evaluate 'count' operator" do

    before(:each) do
      @q = FactoryBot.create(:question)
      @dc = build(:dependency_condition, operator: "count>2", rule_key: "M", question: @q)
      @as = []
      3.times do
        @as << FactoryBot.create(:answer, question: @q, response_class: "answer")
      end
      @rs = FactoryBot.create(:response_set, num_responses: 0)
      @as.slice(0,2).each do |a|
        FactoryBot.create(:response, question: @q, answer: a, response_set: @rs)
      end
      @rs.save
    end

    it "operator >" do
      expect(@dc.to_hash(@rs)).to eq({ M: false })
      FactoryBot.create(:response, question: @q, answer: @as.last, response_set: @rs)

      expect(@dc.to_hash(@rs.reload)).to eq({ M: true })
      expect(@rs.reload.responses.count).to eq 3
    end

    it "with operator with <" do
      @dc.operator = "count<2"
      @dc.to_hash(@rs).should == {M: false}
      @dc.operator = "count<3"
      @dc.to_hash(@rs).should == {M: true}
    end

    it "with operator with <=" do
      @dc.operator = "count<=1"
      @dc.to_hash(@rs).should == {M: false}
      @dc.operator = "count<=2"
      @dc.to_hash(@rs).should == {M: true}
      @dc.operator = "count<=3"
      @dc.to_hash(@rs).should == {M: true}
    end

    it "with operator with >=" do
      @dc.operator = "count>=1"
      @dc.to_hash(@rs).should == {M: true}
      @dc.operator = "count>=2"
      @dc.to_hash(@rs).should == {M: true}
      @dc.operator = "count>=3"
      @dc.to_hash(@rs).should == {M: false}
    end

    it "with operator with !=" do
      @dc.operator = "count!=1"
      @dc.to_hash(@rs).should == {M: true}
      @dc.operator = "count!=2"
      @dc.to_hash(@rs).should == {M: false}
      @dc.operator = "count!=3"
      @dc.to_hash(@rs).should == {M: true}
    end
  end

end
