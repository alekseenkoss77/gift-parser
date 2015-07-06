require "spec_helper"

describe Gift::Gift do
  it "create from string" do
    gift = Gift::Gift.new("This is a description")
    expect(gift.questions.length).to eq 1
    expect(gift.questions.first.class).to eq Gift::DescriptionQuestion
    expect(gift.questions.first.text).to eq "This is a description"
  end
  
  it "create from file" do
    gift = Gift::Gift.new(File.open(File.expand_path("spec/fixtures/gift.txt"))) 
    expect(gift.root.nil?).to be_falsey
    expect(gift.questions.length).to eq 8
  end
  
  it "raising error when input is bad" do
    expect { Gift::Gift.new("This is bad gift{}..") }
      .to raise_error(ArgumentError)
  end
  
  it "true_false question answers" do
    g = Gift::Gift.new(File.open(File.expand_path("spec/fixtures/gift.txt"))) 
    expect(g.questions[0].mark_answer(true)).to eq 100
    expect(g.questions[0].mark_answer(false)).to eq 0
  end
  
  it "multiple choice answers" do
    g = Gift::Gift.new(File.open(File.expand_path("spec/fixtures/gift.txt"))) 
    expect(g.questions[1].mark_answer("yellow")).to eq 100
    expect(g.questions[1].mark_answer("red")).to eq 0
    expect(g.questions[1].mark_answer("blue")).to eq 0
  end
  
  it "test fill in the blank" do
    g = Gift::Gift.new(File.open(File.expand_path("spec/fixtures/gift.txt"))) 
    expect(g.questions[2].mark_answer("two")).to eq 100
    expect(g.questions[2].mark_answer("2")).to eq 100
    expect(g.questions[2].mark_answer("red")).to eq 0
  end
  
  it "matching_question" do
    g = Gift::Gift.new(File.open(File.expand_path("spec/fixtures/gift.txt"))) 
    expect(g.questions[3].mark_answer({"cat" => "cat food", "dog" => "dog food"})).to eq 100
    expect(g.questions[3].mark_answer({"cat" => "dog food", "dog" => "cat food"})).to eq 0
  end
end