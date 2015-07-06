require "spec_helper"
require "fixtures/gift_examples"
require "gift"

def success_parse?(string)
  string << "\n\n"
  expect(parser.parse(string).nil?).to be_falsey
end

def fail_parse?(string)
  string << "\n\n"
  expect(parser.parse(string).nil?).to be_truthy
end

describe "syntax" do

  let(:parser) { GiftParser.new }

  it "success parse essay question" do
    success_parse?("Write an essay about something.{}")
  end

  it "success parse description question" do
    success_parse?("This is simply a description")
  end

  it "success parse true_false" do
    success_parse?("The sky is blue.{T}")
    success_parse?("The sky is blue.{TRUE}")
    success_parse?("The sky is green.{F}")
    success_parse?("The sky is blue.{FALSE}")
  end 
  
  it "success parse true false with feedback" do
    success_parse?("Grant is buried in Grant's tomb.{FALSE#No one is buried in Grant's tomb.}")       
  end
  
  it "success parse multiple_choice_question" do
    success_parse?("What color is the sky?{ = Blue ~Green ~Red }")
  end
  
  it "success parse multiple_choice_question with feedback" do
    success_parse?('What color is the sky?{ = Blue#Right ~Green ~Red#Very wrong}')
  end                                                    
  
  it "success parse test multiple choice on multiple lines" do
    test_text= <<EOS
    What color is the sky?{ 
    = Blue#Right 
    ~Green 
    ~Red
    #Very wrong
    }
EOS
    success_parse?(test_text)
  end

   it "test multiple choice with weights" do
    success_parse?('Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}')
  end
    
  it "success numeric" do
    success_parse?("How many pounds in a kilogram?{#2.2:0.1}")
  end
  
  it "success numeric question with multiple answer" do
    success_parse?("How many pounds in a kilogram?{# =2.2:0.1 =%50%2 }")
  end
  
  it "success parse numeric range question" do
    success_parse?("::Q5:: What is a number from 1 to 5? {#1..5}")
  end 
  
  it "success parse numeric negative number" do
    success_parse?("What is 6 - 10?{#-4}")
  end
   
  it "success parse short_answer" do
    success_parse?("Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
  end
  
  it "success parse matching_question" do
    test_text= <<EOS
    Match the following countries with their corresponding capitals. {
       =Canada -> Ottawa
       =Italy  -> Rome
       =Japan  -> Tokyo
       =India  -> New Delhi
       }
EOS
     success_parse?(test_text) 
  end
  
  it "success parse fill in question" do
    success_parse?("Little {~blue =red ~green } riding hood.\n") 
    success_parse?("Two plus two equals {=four =4}.\n")
  end
  
  it "success parse question_with_title" do
    success_parse?('::Colors 1:: Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}')
  end
  
  it "success parse question_with_comment" do
    success_parse?("//This is an easy one\n Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}")
  end
  
  it "success multiline_comments" do
    success_parse?(
      "//This is an easy one\n//With more than one line of comment\n" \
      "Which of these are primary colors?" \
      "{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}"
    )
  end
  
  it "that_questions_must_be_separated" do 
    test_text = <<EOS
    Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}
    Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}
EOS
    fail_parse?(test_text)
    
    test_text = <<EOS
        Who's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}
        
        Which of these are primary colors?{ ~%33%Blue ~%33%Yellow ~Beige ~%33%Red}
EOS
     success_parse?(test_text)
  end
  
  it "success escape_left_bracket" do
    success_parse?('Can a \{ be escaped?{=Yes ~No}')
    success_parse?('Can a \{ be escaped?{=Yes ~No\{ }')
  end
  
  it "success escape_right_bracket" do
    success_parse?('Can a \} be escaped?{=Yes \} can be escaped. ~No}') 
    
  end
  
  it "parse escape_tilde" do
    success_parse?('Can a \~ be escaped?{=Yes ~No \~ can\'t}')
  end
  
  it "parse escape_hash" do
    success_parse?('Can a \# be escaped?{=Yes \# can ~No}')
  end 
  
  it "parse escape_equals" do
    success_parse?('Can a \= be escaped?{=Yes ~No}')
  end
  
  it "parse escape_colon" do
    success_parse?('Can a \: be escaped?{=Yes \: can be escaped. ~No}')
  end
  
  it "parse escapes_in_title" do
    success_parse?('::\{This is in\: Brackets\}::Who\'s buried in Grant\'s tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}')
  end
  
  it "parse escapes_in_comment" do
    success_parse?("//Escapes in comments are redundant \\: since they end in a \n Question?{}")
  end
  
  it "parse with crlf_support" do
    success_parse?("Can we have DOS style line breaks?{\r\n=yes \r\n~no}\r\n \r\n And is it seen as a line_break?{TRUE}")
  end
  
  it "parse comment line break" do
    success_parse?("//Comment\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
    success_parse?("//Comment\r\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
  end
  
  it "parse dealing with blank lines at top of file" do
    success_parse?("\n    \n//Comment\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}")
  end
  
  it "parse dealing with blank lines at end of file" do
    success_parse?("//Comment\nWho's buried in Grant's tomb?{=Grant =Ulysses S. Grant =Ulysses Grant}\n \n    \n ")
  end
  
  it "parse title line breaks" do
   test_text= <<EOS
     ::Title::
     Match the following countries with their corresponding capitals. {
     =Canada -> Ottawa
     =Italy  -> Rome
     =Japan  -> Tokyo
     =India  -> New Delhi
     }
     
EOS
     success_parse?(test_text) 
  end
  
  
  it "parse single short answer" do
  test_text = <<EOS
    // ===Short Answer===
    What is your favorite color?{=blue}
EOS
    success_parse?(test_text)
  end
  
  it "parse multiple short_answer" do
  test_text = <<EOS
     ::Multiple Short Answer::
     What are your four favorite colors?{
       =%25%Blue
       =%25% Red
       =%25% Green
       =%25% pink
       =%25% azure
       =%25% gold
       }
EOS
    success_parse?(test_text)
  end
  
  it "parse moodle_examples" do
     GiftExamples.examples.each do |key, value|
       success_parse?(value)
     end                                                
  end

  it "can have commands" do
    success_parse?("$COMMAND=1\n\nQuestion text{}")
  end
  
  it "can have 100_percent" do
    success_parse?( "What are your four favorite colors?{=%100%Blue =%25% Red}")
  end
end