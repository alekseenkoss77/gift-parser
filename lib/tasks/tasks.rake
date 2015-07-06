namespace :gift do
  task :treetop do 
    # Generate the parser from the treetop source
    print "Generating the parser..."
    system("tt #{File.expand_path('../src/gift_parser.treetop', __FILE__)}" )
    system("mv #{File.expand_path('../src/gift_parser.rb',__FILE__)} #{File.expand_path('../lib/gift_parser/gift_parser.rb',__FILE__)}" )
    puts "done."
  end
end
