module Datenreinigung
  class Config
    @@config = nil

    def self.reload
      @@config = YAML.load(File.open(File.join(File.dirname(__FILE__),"config.yml")))
    end

    def self.[](attribute)
      @@config[attribute.to_s]
    end

    reload
  end
end