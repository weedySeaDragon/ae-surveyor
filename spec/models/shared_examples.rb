RSpec.shared_examples 'text_for' do
  # This expects survey_item to be defined (e.g. with a let statement)

  it "#display_type == image" do
    survey_item.text = "rails.png"
    survey_item.display_type = :image

    text = survey_item.text_for
    expect(text).to match(/<img\s+(.)*\/>/)
    expect(text).to match(/alt="Rails"/)
    expect(text).to match(/src="\/(images|assets)\/rails\.png"/)
  end

  let(:text_string) { "This is the text." }

  it "preserves strings" do
    survey_item.text = text_string
    survey_item.text_for.should == text_string
  end

  it "(:pre) preserves strings" do
    survey_item.text = text_string
    survey_item.text_for(:pre).should == text_string
  end

  it "(:post) preserves strings" do
    survey_item.text_for(:post).should == ""
  end

  it "splits strings" do
    survey_item.text = "before|after|extra"
    survey_item.text_for.should == "before|after|extra"
  end

  it "(:pre) splits strings" do
    survey_item.text = "before|after|extra"
    survey_item.text_for(:pre).should == "before"
  end

  it "(:post) splits strings" do
    survey_item.text = "before|after|extra"
    survey_item.text_for(:post).should == "after|extra"
  end
end

# ======================================================
RSpec.shared_examples 'split will split the text' do
  # This expects survey_item to be defined (e.g. with a let statement)

  let(:text_string) { 'This is the text.' }


  it "#split preserves strings" do
    survey_item.text = text_string
    expect(survey_item.split(survey_item.text)).to eq text_string
  end

  it "#split(:pre) preserves strings" do
    survey_item.text = text_string
    survey_item.split(survey_item.text, :pre).should == text_string
  end

  it "#split(:post) preserves strings" do
    survey_item.text = text_string
    survey_item.split(survey_item.text, :post).should == ""
  end

  it "#split splits strings" do
    survey_item.text = "before|after|extra"
    survey_item.split(survey_item.text).should == "before|after|extra"
  end

  it "#split(:pre) splits strings" do
    survey_item.text = "before|after|extra"
    survey_item.split(survey_item.text, :pre).should == "before"
  end

  it "#split(:post) splits strings" do
    survey_item.text = "before|after|extra"
    survey_item.split(survey_item.text, :post).should == "after|extra"
  end
end
