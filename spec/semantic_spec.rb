require "spec_helper"
require "gift"

describe "semantic" do
  let(:parser) { GiftParser.new }

  it "parse description_question" do
    q = parser.parse("This is a description.\n\n").questions[0]
    expect(q.class).to eq Gift::DescriptionQuestion
    expect(q.text).to eq "This is a description."
  end

  it "parse essay question" do
    q = parser.parse("Write an essay on the toic of your choice{ }\n\n").questions[0]
    expect(q.class).to eq Gift::EssayQuestion
    expect(q.text).to eq "Write an essay on the toic of your choice"
  end

  it "parse true_false_question with true" do
    q = parser.parse("Is the sky blue?{T}\n\n").questions[0]
    expect(q.class).to eq Gift::TrueFalseQuestion
    expect(q.text).to eq "Is the sky blue?"
    expect(q.answers).to eq [{:value => true, :correct => true, :feedback => nil}]
  end

  it "parse true_false with false" do
    q = parser.parse("Is the sky green?{F}\n\n").questions[0]
    expect(q.text).to eq "Is the sky green?"
    expect(q.answers).to eq [{:value => false, :correct => true, :feedback => nil}]
  end

  it "parse true_false with feedback" do
    q = parser.parse("Is the sky green?{F#No It's blue.}\n\n").questions[0]
    expect(q.text).to eq "Is the sky green?"
    expect(q.answers).to eq [{:value => false, :correct => true, :feedback => "No It's blue."}]
  end

  it "parse multiple choice" do
    q = parser.parse("What color is the sky?{=blue ~green ~red}\n\n").questions[0]
    expect(q.class).to eq Gift::MultipleChoiceQuestion
    expect(q.text).to eq "What color is the sky?"
    expect(q.answers).to eq  [{:value => "blue", :correct => true, :feedback => nil}, 
                              {:value => "green", :correct => false, :feedback => nil},
                              {:value => "red", :correct => false, :feedback => nil}]
  end

  it "parse multiple choice with feedback" do
    q = parser.parse("What color is the sky?{=blue#Correct ~green#Wrong! ~red}\n\n").questions[0]
    expect(q.answers).to eq  [{:value => "blue", :correct => true, :feedback => "Correct"}, 
                              {:value => "green", :correct => false, :feedback => "Wrong!"},
                              {:value => "red", :correct => false, :feedback => nil}]
  end

  it "parse multiple_choice_question with weights" do
    q = parser.parse("What color is the sky?{=blue#Correct ~%50%green#Wrong! ~red}\n\n").questions[0]
    expect(q.answers).to eq  [{:value => "blue", :correct => true, :feedback => "Correct"}, 
                              {:value => "green", :correct => false, :feedback => "Wrong!", :weight => 50.0},
                              {:value => "red", :correct => false, :feedback => nil}]
  end

  it "test short_answer_question" do
    q = parser.parse(
      "Who's buried in Grant's tomb?{=Grant =Ulysses" \
      " S. Grant =Ulysses Grant}\n\n"
    ).questions[0]
    expect(q.class).to eq Gift::ShortAnswerQuestion
    expect(q.text).to eq "Who's buried in Grant's tomb?"
    expect(q.answers).to eq [{:feedback => nil, :value => "Grant", :correct => true}, 
                             {:feedback => nil, :value => "Ulysses S. Grant", :correct => true}, 
                             {:feedback => nil, :value => "Ulysses Grant" , :correct => true}]
  end
  
  it "test short_answer with weight" do
    q = parser.parse(
      "Name three colors of the rainbow?{=%33.3%red =%33.3%orange =%33.3%yellow" \
      " =%33.3%green =%33.3%blue =%33.3%indigo =%33.3%violet }\n\n"
    ).questions[0]
    q.answers.each do |a|
      expect(a[:weight]).to eq 33.3
    end
  end

  it "test numeric_question" do
    q = parser.parse("What is 3 + 4?{#7}\n\n").questions[0]
    expect(q.class).to eq Gift::NumericQuestion
    expect(q.answers).to eq [{:maximum => 7.0, :minimum => 7.0}]
  end
  
  it "test numeric with tolerance" do
    q = parser.parse("What is the value of PI?{#3.1:0.5}\n\n").questions[0]
    expect(q.answers).to eq [{:maximum => 3.6, :minimum => 2.6}]
  end
  
  it "test numeric range" do
    q = parser.parse("What is a number from 1 to 5? {#1..5}\n\n").questions[0]
    expect(q.answers).to eq [{:maximum => 1.0, :minimum => 5.0}]
  end
  
  it "test numeric multiple answers" do
    q = parser.parse("What is the value of PI?{#3.1415 =%50%3.1 =%25%3 }\n\n").questions[0]
    expect(q.answers).to eq [{:maximum => 3.1415, :minimum => 3.1415}, 
                             {:maximum => 3.1, :minimum => 3.1},
                             {:maximum => 3.0, :minimum => 3.0}]
  end
  
  it "test numeric neagitve numbers" do
    q = parser.parse("Calculate 2 - 6.{#-4.0}\n\n").questions[0]
    expect(q.answers).to eq [{:maximum => -4.0, :minimum => -4.0}]
  end

  it "test matching_question" do
    q = parser.parse(
      "Match the names. { =Charlie -> Chaplin =Groucho -> Marx" \
      " =Buster -> Keaton  =Stan -> Laurel }\n\n"
    ).questions[0]
    expect(q.class).to eq Gift::MatchQuestion 
    expect(q.text).to eq "Match the names."
    expect(q.answers).to eq({ "Charlie"=>"Chaplin", "Groucho"=>"Marx", "Buster"=>"Keaton", "Stan"=>"Laurel" })
  end
  
  it "test fill in question" do
    q = parser.parse("There were {=three} little pigs.\n\n").questions[0]
    expect(q.class).to eq Gift::FillInQuestion
    expect(q.text).to eq "There were %% little pigs."
    expect(q.answers).to eq [{:value => 'three', :correct => true, :feedback => nil}]
  end
  
  it "test title" do
    q = parser.parse("::Essay One:: Write an essay on the toic of your choice{ }\n\n").questions[0]
    expect(q.title).to eq "Essay One"
  end 
  
  it "test title from question" do
    q = parser.parse("Write an essay on the toic of your choice{ }\n\n").questions[0]
    expect(q.title).to eq q.text
  end
  
  it "test comment" do
    q = parser.parse("//Here's an easy one\nWrite an essay on the toic of your choice{ }\n\n").questions[0]
    expect(q.comment).to eq "Here's an easy one"
  end
  
  it "test command" do
    q = parser.parse("$COMMAND=1\n\nQuestion{}\n\n")
    expect(q.commands).to eq ["COMMAND=1"]
  end
 
  it "test category_setting" do
    q = parser.parse("$CATEGORY: food \n\nIs apple a food?{T}\n\n$CATEGORY: drink \n\nIs water drinkable?{T}\n\n" )
    expect(q.questions[0].category).to eq "food"
    expect(q.questions[1].category).to eq "drink"
  end
  
  it "test markup_type" do
    q = parser.parse("[textile] This *essay* is marked up in textile.{}\n\n").questions[0]
    expect(q.markup_language).to eq "textile"
    expect(q.text).to eq "This *essay* is marked up in textile."
  end  
end