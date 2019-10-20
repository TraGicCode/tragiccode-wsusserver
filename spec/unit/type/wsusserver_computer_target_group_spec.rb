require 'spec_helper'

def wsusserver_computer_target_group(params = {})
  defaults = {
    name: 'Development',
  }
  described_class.new(**defaults.merge(params))
end

describe Puppet::Type.type(:wsusserver_computer_target_group) do
  subject { wsusserver_computer_target_group }

  describe 'parameter :name' do
    it 'is a parameter' do
      expect(described_class.attrtype(:name)).to eq(:param)
    end

    it 'is the namevar' do
      expect(wsusserver_computer_target_group.parameters[:name]).to be_isnamevar
    end

    it 'has documentation' do
      expect(described_class.attrclass(:name).doc).not_to eq("\n\n")
    end

    it 'cannot be set to nil' do
      expect {
        wsusserver_computer_target_group[:name] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for name})
    end
    # This protects against
    # wsusserver_computer_target_group { 's': ensure => present, name => '', }
    it 'cannot be set to an empty string' do
      expect {
        wsusserver_computer_target_group[:name] = ''
      }.to raise_error(Puppet::Error, %r{A non-empty computer target group name must})
    end

    ['^', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '=', '+', '[', ']', '{', '}', '|', ';', ':', '\'', '"', '<', '>', '/'].each do |invalid_character|
      it "cannot contain the #{invalid_character} character" do
        expect {
          wsusserver_computer_target_group[:name] = invalid_character
        }.to raise_error(Puppet::Error, %r{The computer target group name cannot contain any of the characters})
      end
    end
  end

  describe 'property :ensure' do
    it 'is a property' do
      expect(described_class.attrtype(:ensure)).to eq(:property)
    end

    it 'has Puppet::Property::Ensure as a parent' do
      expect(described_class.attrclass(:ensure).superclass).to eq(Puppet::Property::Ensure)
    end

    it 'has documentation' do
      expect(described_class.attrclass(:ensure).doc).not_to eq("\n\n")
    end

    # it 'is required' do
    #   expect {
    #     described_class.new(name: 'test')
    #   }.to raise_error(Puppet::Error, %r{ensure is a required attribute})
    # end

    it 'defaults to present' do
      expect(wsusserver_computer_target_group[:ensure]).to eq(:present)
    end

    [:present, :absent].each do |ensure_value|
      it "can set be set to #{ensure_value}" do
        expect {
          wsusserver_computer_target_group[:ensure] = ensure_value
        }.not_to raise_error
      end
    end

    it 'cannot be set to an empty string' do
      expect {
        wsusserver_computer_target_group[:ensure] = ''
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'cannot be set to nil' do
      expect {
        wsusserver_computer_target_group[:ensure] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for ensure})
    end
  end

  describe 'property :id' do
    it 'is a property' do
      expect(described_class.attrtype(:id)).to eq(:property)
    end

    it 'has documentation' do
      expect(described_class.attrclass(:id).doc).not_to eq("\n\n")
    end
  end
end
