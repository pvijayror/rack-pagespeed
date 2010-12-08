$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rspec'
require 'fileutils'
require 'rack/pagespeed'
require 'tmpdir'

include Rack::Utils
alias :h :escape_html

def fixture name
  File.open(File.join(FIXTURES_PATH, name)).readlines.join
end

def page
  lambda { |env| [200, { 'Content-Type' => 'text/html' }, [fixture('complex.html').contents]] }
end

FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')
FIXTURES = Struct.new('HTML', :complex, :noscripts).new(
  Nokogiri::HTML(fixture('complex.html')),
  Nokogiri::HTML(fixture('noscripts.html'))
)
