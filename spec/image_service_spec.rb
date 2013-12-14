require File.dirname(__FILE__) + '/../lib/image_service'

describe Tantrum::ImageService do
  before(:all) do
    YAML = Class.new
  end

  describe 'manipulate' do
    it "executes the correct manipulation" do
      YAML.stub(:load_file).and_return({"clients" => {"test_client" => {"templates" => {"test_template" => {"width" => 100, "height" => 100, "manipulation" => "resize_and_pad"}}}}})
      Tantrum::ImageService.any_instance.stub(:resize_and_pad).and_return("resized_image_content")
      service = Tantrum::ImageService.new
      
      content = service.manipulate("test_client", nil, "test_template")
      expect(content).to eq("resized_image_content")
    end
    
    it "raises for invalid manipulation" do
      YAML.stub(:load_file).and_return({"clients" => {"test_client" => {"templates" => {"test_template" => {"width" => 100, "height" => 100, "manipulation" => "invalid_manipulation"}}}}})
      service = Tantrum::ImageService.new
      
      expect { service.manipulate("test_client", nil, "test_template") }.to raise_error(RuntimeError, "An error has occured, invalid manipulation 'invalid_manipulation'")
    end
  end
end