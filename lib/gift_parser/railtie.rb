require 'gift'
require 'rails'

module Gift
  class Railtie < Rails::Railtie
    railtie_name :gift
    
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'../tasks/*.rake')].each { |f| load f }
    end
  end
end