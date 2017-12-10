require 'spec_helper'

describe 'wsusserver_approvalrule' do
  let(:type_class) { Puppet::Type.type(:wsusserver_approvalrule) }
  let(:parameters) { [:name] }
  let(:properties) { [:ensure, :enabled, :rule_id, :products] }

  it 'has expected parameters' do
    parameters.each do |parameter|
      expect(type_class.parameters).to include(parameter)
    end
  end

  it 'has expected properties' do
    properties.each do |property|
      expect(type_class.properties.map(&:name)).to be_include(property)
    end
  end

  [:present, :absent].each do |value|
    it "should accept #{value} as a value for :ensure" do
      expect { type_class.new(name: 'test', ensure: value) }.not_to raise_error # Notice this actually creates an instance of the type
    end
  end

  

  ['^', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '=', '+', '[', ']', '{', '}', '\\', '|', ';', ':', '\'', '"', '<', '>', '/'].each do |invalid_character|
    context "with a name that contains an invalid character of #{invalid_character}" do
      it 'throws a validation error' do
        expect { type_class.new(name: invalid_character) }.to raise_error(Puppet::Error, %r{The approval rule name cannot contain any of the characters})
      end
    end
  end

  [true, false].each do |value|
    it "should accept #{value} as a value for :enabled" do
      expect { type_class.new(name: 'test', ensure: :present, enabled: value) }.not_to raise_error
    end
  end

  it "should accept an empty array for :products" do
    expect { type_class.new(name: 'test', ensure: :present, products: []) }.not_to raise_error
  end

  it "should accept an array that contains string elements for :products" do
    expect { type_class.new(name: 'test', ensure: :present, products: ['Windows Server 2016', 's']) }.not_to raise_error
  end

  it "should return an array for products" do
    expect(type_class.new(name: 'test', ensure: :present, products: ['Windows Server 2016', 's'])[:products]).to eq ['Windows Server 2016', 's']
  end

  it "should return an array of products when passed a string" do
    expect(type_class.new(name: 'test', ensure: :present, products: 'Windows Server 2016')[:products]).to eq ['Windows Server 2016']
  end

  # context 'when products is not passed an array' do
  #   it "should throw a validation error" do
  #     expect { type_class.new(name: 'test', ensure: :present, products: 1 ) }.to raise_error(Puppet::Error, %r{The approval rule products must be a non-empty array of products.})
  #   end
  # end
  # This happens in the provider code.  Might want to move this later.
  it 'has the powershell provider registered with it' do
    expect(type_class.providers).to be_include(:powershell)
  end
end
