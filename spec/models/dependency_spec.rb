require 'rails_helper'


describe Dependency, type: :model do

  describe 'validation' do

    it "factory is valid" do
      FactoryBot.create(:dependency).should be_valid
    end

    it "invalid without a rule" do
      dependency = FactoryBot.create(:dependency)
      dependency.rule = nil
      expect(dependency.valid?).to be_falsey
      expect(dependency.errors.size).to eq 2
      expect(dependency.errors.first.first).to eq :rule

      dependency.rule = " "
      expect(dependency.valid?).to be_falsey
      expect(dependency.errors.size).to eq 1
      expect(dependency.errors.first.first).to eq :rule
    end

    describe 'must have either a question or a question_group' do

      context 'no question' do

        it 'valid if it has a question group' do
          q_group = FactoryBot.create(:question_group)
          dependency = FactoryBot.create(:dependency, question_group: q_group)
          dependency.question = nil

          expect(dependency.valid?).to be_truthy
        end

        it 'invalid if no question group' do
          dependency = FactoryBot.create(:dependency)
          dependency.question = nil

          expect(dependency.valid?).to be_falsey
          expect(dependency.errors.details.keys).to match_array([:question_group, :question])
        end
      end

      context 'no question_group' do
        it 'valid if it has a question' do
          q = FactoryBot.create(:question)
          dependency = FactoryBot.create(:dependency, question: q,
                                         question_group: nil)
          expect(dependency.valid?).to be_truthy
        end

        it 'invalid if no question' do
          q = FactoryBot.create(:question)
          dependency = FactoryBot.create(:dependency, question: q,
                                         question_group: nil)
          dependency.question = nil
          expect(dependency.valid?).to be_falsey
          expect(dependency.errors.details.keys).to match_array([:question_group, :question])
        end
      end
    end


    it "invalid unless rule composed of only references and operators" do
      dependency = FactoryBot.create(:dependency)
      expect(dependency.valid?).to be_truthy

      dependency.rule = "foo"
      expect(dependency.valid?).to be_falsey
      expect(dependency.errors.details.keys).to match_array([:rule])

      dependency.rule = "1 to 2"
      expect(dependency.valid?).to be_falsey
      expect(dependency.errors.details.keys).to match_array([:rule])

      dependency.rule = "a and b"
      expect(dependency.valid?).to be_falsey
      expect(dependency.errors.details.keys).to match_array([:rule])
    end
  end


  describe "when evaluating dependency conditions of a question in a response set" do

    let(:q) { FactoryBot.create(:question) }

    let(:dep)  { Dependency.new(:rule => "A", question: q) }
    let(:dep2)  { Dependency.new(:rule => "A and B", question: q) }
    let(:dep3)  { Dependency.new(:rule => "A or B", question: q) }
    let(:dep4)  { Dependency.new(:rule => "!(A and B) and C", question: q) }

    before(:each) do
      dep_c = instance_double(DependencyCondition, :id => 1, :rule_key => "A", :to_hash => {:A => true})
      dep_c2 = instance_double(DependencyCondition, :id => 2, :rule_key => "B", :to_hash => {:B => false})
      dep_c3 = instance_double(DependencyCondition, :id => 3, :rule_key => "C", :to_hash => {:C => true})

      allow(dep).to receive(:dependency_conditions).and_return([dep_c])
      allow(dep2).to receive(:dependency_conditions).and_return([dep_c, dep_c2])
      allow(dep3).to receive(:dependency_conditions).and_return([dep_c, dep_c2])
      allow(dep4).to receive(:dependency_conditions).and_return([dep_c, dep_c2, dep_c3])
    end


    it 'is_met?' do
      expect(dep.is_met?('blorf')).to be_truthy
      dep2.is_met?('anything').should be_falsey
      dep3.is_met?('anything else').should be_truthy
      dep4.is_met?('flurb').should be_truthy
    end

    it "returns the proper keyed pairs from the dependency conditions" do
      dep.conditions_hash('blorf').should == {:A => true}
      dep2.conditions_hash('blorf').should == {:A => true, :B => false}
      dep3.conditions_hash('blorf').should == {:A => true, :B => false}
      dep4.conditions_hash('blorf').should == {:A => true, :B => false, :C => true}
    end
  end


  context 'with conditions' do
    pending
  end

end
