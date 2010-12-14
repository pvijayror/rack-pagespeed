require File.dirname(__FILE__) + '/../spec_helper'

describe 'the combine_javascripts filter' do
  it "is called \"combine_javascripts\" as far as Config is concerned" do
    Rack::PageSpeed::Filters::CombineJavaScripts.name.should == 'combine_javascripts'
  end
  
  context 'initializing' do
    it "requires a store mechanism to be passed via :store" do
      expect { Rack::PageSpeed::Filters::CombineJavaScripts.new :public => FIXTURES_PATH }.to raise_error(ArgumentError)
    end
  end

  context 'execute!' do
    before :each do
      @filter = Rack::PageSpeed::Filters::CombineJavaScripts.new :public => FIXTURES_PATH, :store => mock_store
    end
    
    it 'cuts down the number of scripts in the fixtures from 4 to 2' do
      expect { @filter.execute! FIXTURES.complex }.to change { FIXTURES.complex.css('script[src$=".js"]:not([src^="http"])').count }.from(4).to(2)
    end
    
    it "stores the nodes' contents in the store passed through the initializer" do
      @filter.instance_variable_get(:@store).should_receive(:[]=).twice
      @filter.execute! FIXTURES.complex
    end
  end

  context 'yes, I test private methods, so what?' do
    before do
      @filter = Rack::PageSpeed::Filters::CombineJavaScripts.new :public => FIXTURES_PATH, :store => mock_store
    end

    it 'returns an array of arrays containing JS nodes that are next to each other in #group_siblings' do
      nodes = FIXTURES.complex.css('script[src$=".js"]:not([src^="http"]) + script[src$=".js"]:not([src^="http"])')
      result = @filter.send :group_siblings, nodes
      result.should == [[nodes[0].previous_element, nodes[0]], [nodes[1].previous_element, nodes[1]]]
    end

    it '#unique_id a key thats unique to the nodes combination of content + mtime' do
      nodes = FIXTURES.complex.css('script[src$=".js"]:not([src^="http"]) + script[src$=".js"]:not([src^="http"])')
      @filter.send(:unique_id, nodes).should == Digest::MD5.hexdigest(nodes.map { |node| file = @filter.send(:file_for, node); file.mtime.to_i.to_s + file.read }.join)
    end
  end
end