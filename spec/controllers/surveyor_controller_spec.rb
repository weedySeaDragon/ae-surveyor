require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'rails_helper'

# FIXME: get 'user' table/AR working
describe SurveyorController, type: :controller  do

  include Surveyor::Engine.routes.url_helpers
  before do
    @routes = Surveyor::Engine.routes
  end

  let!(:survey)           { FactoryBot.create(:survey, :title => "Alphabet", :access_code => "alpha", :survey_version => 0)}
  let!(:survey_beta)      { FactoryBot.create(:survey, :title => "Alphabet", :access_code => "alpha", :survey_version => 1)}
  let!(:response_set)      { FactoryBot.create( :response_set, :survey => survey, :access_code => "pdq" )}
  let!(:response_set_beta) { FactoryBot.create(:response_set, :survey => survey_beta, :access_code => "rst")}

  before { allow(ResponseSet).to receive(:create).and_return(response_set) }

  # match '/', :to                                     => 'surveyor#new', :as    => 'available_surveys', :via => :get
  # match '/:survey_code', :to                         => 'surveyor#create', :as => 'take_survey', :via       => :post
  # match '/:survey_code', :to                         => 'surveyor#export', :as => 'export_survey', :via     => :get
  # match '/:survey_code/:response_set_code', :to      => 'surveyor#show', :as   => 'view_my_survey', :via    => :get
  # match '/:survey_code/:response_set_code/take', :to => 'surveyor#edit', :as   => 'edit_my_survey', :via    => :get
  # match '/:survey_code/:response_set_code', :to      => 'surveyor#update', :as => 'update_my_survey', :via  => :put

  # context "#new" do
  #   def do_get
  #     get :new
  #   end
  #   it "renders new" do
  #     do_get
  #     response.should be_success
  #     response.should render_template('new')
  #   end
  #   it "assigns surveys_by_access_code" do
  #     do_get
  #     assigns(:surveys_by_access_code).should == {"alpha" => [survey_beta,survey]}
  #   end
  # end
  #
  # context "#create" do
  #
  #   def do_post(params = {})
  #     post :create, {:survey_code => "alpha"}.merge(params)
  #   end
  #
  #   it "finds latest version" do
  #     do_post
  #     assigns(:survey).should == survey_beta
  #   end
  #
  #   it "finds specified survey_version" do
  #     do_post :survey_version => 0
  #     assigns(:survey).should == survey
  #   end
  #
  #   it "creates a new response_set" do
  #     ResponseSet.should_receive(:create)
  #     do_post
  #   end
  #
  #   it "should redirects to the new response_set" do
  #     do_post
  #     response.should redirect_to( edit_my_survey_path(:survey_code => "alpha", :response_set_code  => "pdq"))
  #   end
  #
  #   context "with failures" do
  #     it "redirect to #new on failed ResponseSet#create" do
  #       ResponseSet.should_receive(:create).and_return(false)
  #       do_post
  #       response.should redirect_to(available_surveys_path)
  #     end
  #     it "redirect to #new on failed Survey#find" do
  #       do_post :survey_code => "missing"
  #       response.should redirect_to(available_surveys_path)
  #     end
  #   end
  #
  #   context "with javascript check, assigned in session" do
  #
  #     it "enabled" do
  #       do_post :surveyor_javascript_enabled => "true"
  #       session[:surveyor_javascript].should_not be_nil
  #       session[:surveyor_javascript].should == "enabled"
  #     end
  #
  #     it "disabled" do
  #       post :create, :survey_code => "xyz", :surveyor_javascript_enabled => "not_true"
  #       session[:surveyor_javascript].should_not be_nil
  #       session[:surveyor_javascript].should == "not_enabled"
  #     end
  #   end
  # end
  #
  # context "#show" do
  #
  #   def do_get(params = {})
  #     get :show, {:survey_code => "alpha", :response_set_code => "pdq"}.merge(params)
  #   end
  #
  #   it "renders show" do
  #     do_get
  #     response.should be_success
  #     response.should render_template('show')
  #   end
  #
  #   it "finds ResponseSet with includes" do
  #     ResponseSet.should_receive(:includes).with(:responses => [:question, :answer]).and_return(response_set)
  #     response_set.should_receive(:where).with(:access_code => "pdq").and_return(response_set)
  #     response_set.should_receive(:first).and_return(response_set)
  #     do_get
  #   end
  #   it "redirects for missing response set" do
  #     do_get :response_set_code => "DIFFERENT"
  #     response.should redirect_to(available_surveys_path)
  #   end
  #   it "assigns earlier survey_version" do
  #     response_set
  #     do_get
  #     assigns[:response_set].should == response_set
  #     assigns[:survey].should == survey
  #   end
  #   it "assigns later survey_version" do
  #     response_set_beta
  #     do_get :response_set_code => "rst"
  #     assigns[:response_set].should == response_set_beta
  #     assigns[:survey].should == survey_beta
  #   end
  # end
  #
  # context "#edit" do
  #   def do_get(params = {})
  #     survey.sections = [FactoryBot.create(:survey_section, :survey => survey)]
  #     get :edit, {:survey_code => "alpha", :response_set_code => "pdq"}.merge(params)
  #   end
  #   it "renders edit" do
  #     do_get
  #     response.should be_success
  #     response.should render_template('edit')
  #   end
  #   it "assigns survey and response set" do
  #     do_get
  #     assigns[:survey].should == survey
  #     assigns[:response_set].should == response_set
  #   end
  #   it "redirects for missing response set" do
  #     do_get :response_set_code => "DIFFERENT"
  #     response.should redirect_to(available_surveys_path)
  #   end
  #   it "assigns dependents if javascript not enabled" do
  #     controller.stub(:get_unanswered_dependencies_minus_section_questions).and_return([FactoryBot.create(:question)])
  #     session[:surveyor_javascript].should be_nil
  #     do_get
  #     assigns[:dependents].should_not be_empty
  #   end
  #   it "does not assign dependents if javascript is enabled" do
  #     controller.stub(:get_unanswered_dependencies_minus_section_questions).and_return([FactoryBot.create(:question)])
  #     session[:surveyor_javascript] = "enabled"
  #     do_get
  #     assigns[:dependents].should be_empty
  #   end
  #   it "assigns earlier survey_version" do
  #     do_get
  #     assigns[:response_set].should == response_set
  #     assigns[:survey].should == survey
  #   end
  #   it "assigns later survey_version" do
  #     survey_beta.sections = [FactoryBot.create(:survey_section, :survey => survey_beta)]
  #     do_get :response_set_code => "rst"
  #     assigns[:survey].should == survey_beta
  #     assigns[:response_set].should == response_set_beta
  #
  #   end
  # end
  #
  # context "#update" do
  #   let(:responses_ui_hash) { {} }
  #   let(:update_params) {
  #     {
  #       :survey_code => "alpha",
  #       :response_set_code => "pdq"
  #     }
  #   }
  #   shared_examples "#update action" do
  #     before do
  #       ResponseSet.stub_chain(:includes, :where, :first).and_return(response_set)
  #       responses_ui_hash['11'] = {'api_id' => 'something', 'answer_id' => '56', 'question_id' => '9'}
  #     end
  #     it "saves responses" do
  #       response_set.should_receive(:update_from_params).with(responses_ui_hash)
  #       do_put(:r => responses_ui_hash)
  #     end
  #     it "does not fail when there are no responses" do
  #       lambda { do_put }.should_not raise_error
  #     end
  #     context "with update exceptions" do
  #       it 'retries the update on a constraint violation' do
  #         response_set.should_receive(:update_from_params).ordered.with(responses_ui_hash).and_raise(ActiveRecord::StatementInvalid.new('statement invalid'))
  #         response_set.should_receive(:update_from_params).ordered.with(responses_ui_hash)
  #
  #         expect { do_put(:r => responses_ui_hash) }.to_not raise_error
  #       end
  #
  #       it 'only retries three times' do
  #         response_set.should_receive(:update_from_params).exactly(3).times.with(responses_ui_hash).and_raise(ActiveRecord::StatementInvalid.new('statement invalid'))
  #
  #         expect { do_put(:r => responses_ui_hash) }.to raise_error(ActiveRecord::StatementInvalid)
  #       end
  #
  #       it 'does not retry for other errors' do
  #         response_set.should_receive(:update_from_params).once.with(responses_ui_hash).and_raise('Bad news')
  #
  #         expect { do_put(:r => responses_ui_hash) }.to raise_error('Bad news')
  #       end
  #     end
  #   end
  #
  #   context "with form submission" do
  #     def do_put(extra_params = {})
  #       put :update, update_params.merge(extra_params)
  #     end
  #
  #     it_behaves_like "#update action"
  #     it "redirects to #edit without params" do
  #       do_put
  #       response.should redirect_to(edit_my_survey_path(:survey_code => "alpha", :response_set_code => "pdq"))
  #     end
  #     it "completes the found response set on finish" do
  #       do_put :finish => 'finish'
  #       response_set.reload.should be_complete
  #     end
  #     it 'flashes completion' do
  #       do_put :finish => 'finish'
  #       flash[:notice].should == "Completed survey"
  #     end
  #     it "redirects for missing response set" do
  #       do_put :response_set_code => "DIFFERENT"
  #       response.should redirect_to(available_surveys_path)
  #       flash[:notice].should == "Unable to find your responses to the survey"
  #     end
  #   end
  #
  #   context 'with ajax' do
  #     def do_put(extra_params = {})
  #       xhr :put, :update, update_params.merge(extra_params)
  #     end
  #
  #     it_behaves_like "#update action"
  #     it "returns dependencies" do
  #       ResponseSet.stub_chain(:includes, :where, :first).and_return(response_set)
  #       response_set.should_receive(:all_dependencies).and_return({"show" => ['q_1'], "hide" => ['q_2']})
  #
  #       do_put
  #       JSON.parse(response.body).should == {"show" => ['q_1'], "hide" => ["q_2"]}
  #     end
  #     it "returns 404 for missing response set" do
  #       do_put :response_set_code => "DIFFERENT"
  #       response.status.should == 404
  #     end
  #   end
  # end
  #
  # context "#delete_response" do
  #   let(:survey_section) { FactoryBot.create :survey_section, :survey => survey }
  #   let(:question)       { FactoryBot.create :question, :survey_section => survey_section }
  #   let(:answer)         { FactoryBot.create :answer }
  #
  #
  #   it "should set response_set" do
  #     delete :delete_response, :survey_code => survey.access_code, :response_set_code => "pdq", :question_id => question.id
  #     assigns(:response_set).should eql response_set
  #   end
  #
  #   context "with reponses" do
  #     before :each do
  #       response_set.responses.create :question_id => question.id, :answer_id => answer.id
  #     end
  #
  #     it "should delete responses only for this response_set" do
  #       expect do
  #         delete :delete_response, :survey_code => survey.access_code, :response_set_code => "pdq", :question_id => question.id, :format => :js
  #       end.to change{ response_set.responses.reload.length }.by(-1)
  #     end
  #
  #     context "without dependencies" do
  #       it "should return show & hide empty" do
  #         delete :delete_response, :survey_code => survey.access_code, :response_set_code => "pdq", :question_id => question.id, :format => :js
  #         result = JSON.parse(response.body)
  #         result["show"].should be_empty
  #         result["hide"].should be_empty
  #       end
  #     end
  #
  #     context "with dependencies" do
  #       before(:each) do
  #         @section = Factory(:survey_section)
  #         # Questions
  #         @do_you_like_pie = Factory(:question, :text => "Do you like pie?", :survey_section => @section)
  #         @what_flavor = Factory(:question, :text => "What flavor?", :survey_section => @section)
  #         @what_bakery = Factory(:question, :text => "What bakery?", :survey_section => @section)
  #         # Answers
  #         @do_you_like_pie.answers << Factory(:answer, :text => "yes", :question_id => @do_you_like_pie.id)
  #         @do_you_like_pie.answers << Factory(:answer, :text => "no", :question_id => @do_you_like_pie.id)
  #         @what_flavor.answers << Factory(:answer, :response_class => :string, :question_id => @what_flavor.id)
  #         @what_bakery.answers << Factory(:answer, :response_class => :string, :question_id => @what_bakery.id)
  #         # Dependency
  #         @what_flavor_dep = Factory(:dependency, :rule => "A", :question_id => @what_flavor.id)
  #         Factory(:dependency_condition, :rule_key => "A", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_flavor_dep.id)
  #         @what_bakery_dep = Factory(:dependency, :rule => "B", :question_id => @what_bakery.id)
  #         Factory(:dependency_condition, :rule_key => "B", :question_id => @do_you_like_pie.id, :operator => "==", :answer_id => @do_you_like_pie.answers.first.id, :dependency_id => @what_bakery_dep.id)
  #         # Responses
  #         @response_set = Factory(:response_set)
  #         @response_set.responses << Factory(:response, :question_id => @do_you_like_pie.id, :answer_id => @do_you_like_pie.answers.first.id, :response_set_id => @response_set.id)
  #         @response_set.responses << Factory(:response, :string_value => "pecan pie", :question_id => @what_flavor.id, :answer_id => @what_flavor.answers.first.id, :response_set_id => @response_set.id)
  #       end
  #
  #       it "should return hide with dependecies" do
  #         delete :delete_response, :survey_code => survey.access_code, :response_set_code => "pdq", :question_id => @do_you_like_pie.id, :format => :js
  #         result = JSON.parse(response.body)
  #         result["show"].should be_empty
  #         result["hide"].should be_present
  #         result["hide"].length.should eql 2
  #         result["hide"].should include "q_#{@what_flavor.id}"
  #         result["hide"].should include "q_#{@what_bakery.id}"
  #       end
  #     end
  #   end
  #
  #   context "without responses" do
  #     it "should not delete any response when the question has no responses" do
  #       another_question = FactoryBot.create :question, :survey_section => survey_section
  #       FactoryBot.create :response, :response_set => response_set, :question_id => another_question.id, :answer_id => answer.id
  #       expect do
  #         delete :delete_response, :survey_code => survey.access_code, :response_set_code => "pdq", :question_id => question.id, :format => :js
  #       end.to change{ Response.count }.by(0)
  #     end
  #   end
  #
  # end
  #
  # context "#export" do
  #   #render_views
  #
  #   let(:json) {
  #     get :export, :survey_code => survey.access_code, :format => 'json'
  #     JSON.parse(response.body)
  #   }
  #
  #   context "question inside and outside a question group" do
  #     def question_text(refid)
  #       <<-SURVEY
  #         q "Where is a foo?", :pick => :one, :help_text => 'Look around.', :reference_identifier => #{refid.inspect},
  #           :data_export_identifier => 'X.FOO', :common_namespace => 'F', :common_identifier => 'f'
  #         a_L 'To the left', :data_export_identifier => 'X.L', :common_namespace => 'F', :common_identifier => 'l'
  #         a_R 'To the right', :data_export_identifier => 'X.R', :common_namespace => 'F', :common_identifier => 'r'
  #         a_O 'Elsewhere', :string
  #
  #         dependency :rule => 'R'
  #         condition_R :q_bar, "==", :a_1
  #       SURVEY
  #     end
  #     let(:survey_text) {
  #       <<-SURVEY
  #         survey 'xyz' do
  #           section 'Sole' do
  #             q_bar "Should that other question show up?", :pick => :one
  #             a_1 'Yes'
  #             a_2 'No'
  #
  #             #{question_text('foo_solo')}
  #
  #             group do
  #               #{question_text('foo_grouped')}
  #             end
  #           end
  #         end
  #       SURVEY
  #     }
  #
  #     let(:survey) { Surveyor::Parser.new.parse(survey_text) } # FIXME: cannot parse; get it working or change it here
  #     let(:solo_question_json)    { json['sections'][0]['questions_and_groups'][1] }
  #     let(:grouped_question_json) { json['sections'][0]['questions_and_groups'][2]['questions'][0] }
  #
  #     it "produces identical JSON except for API IDs and question reference identifers" do
  #       solo_question_json['answers'].to_json.should be_json_eql( grouped_question_json['answers'].to_json).excluding("uuid", "reference_identifier")
  #       solo_question_json['dependency'].to_json.should be_json_eql( grouped_question_json['dependency'].to_json).excluding("uuid", "reference_identifier")
  #       solo_question_json.to_json.should be_json_eql( grouped_question_json.to_json).excluding("uuid", "reference_identifier")
  #     end
  #     it "produces the expected reference identifier for the solo question" do
  #       solo_question_json['reference_identifier'].should == 'foo_solo'
  #     end
  #     it "produces the expected reference identifer for the question in the group" do
  #       grouped_question_json['reference_identifier'].should == 'foo_grouped'
  #     end
  #   end
  #
  # end

end
