require 'spec_helper'

def wsusserver_approvalrule(params = {})
  defaults = {
    ensure: :present,
    name: 'CustomApprovalRule',
  }
  described_class.new(**defaults.merge(params))
end

describe Puppet::Type.type(:wsusserver_approvalrule) do
  subject { wsusserver_approvalrule }

  describe 'parameter :name' do

    it 'is a parameter' do
      expect(described_class.attrtype(:name)).to eq(:param)
    end

    it 'is the namevar' do
      expect(subject.parameters[:name]).to be_isnamevar
    end

    it 'has documentation' do
      expect(described_class.attrclass(:name).doc).not_to eq("\n\n")
    end

    it 'cannot be set to nil' do
      expect {
        subject[:name] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for name})
    end
    # This protects against
    # vscode_extension{ 's': ensure => present, extension_name => '', }
    it 'cannot be set to an empty string' do
      expect {
        subject[:name] = ''
      }.to raise_error(Puppet::Error, %r{A non-empty approval rule name must})
    end

    ['^', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '=', '+', '[', ']', '{', '}', '\\', '|', ';', ':', '\'', '"', '<', '>', '/'].each do |invalid_character|
      it "cannot contain the #{invalid_character} character" do
        expect {
          subject[:name] = invalid_character
      }.to raise_error(Puppet::Error, %r{The approval rule name cannot contain any of the characters})
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

    [:present, :absent].each do |ensure_value|
      it "can set be set to #{ensure_value}" do
        expect {
          subject[:ensure] = ensure_value
        }.not_to raise_error
      end
    end

    it 'cannot be set to an empty string' do
      expect {
        subject[:ensure] = ''
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'cannot be set to nil' do
      expect {
        subject[:ensure] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for ensure})
    end
  end

  describe 'property :rule_id' do
    it 'is a property' do
      expect(described_class.attrtype(:rule_id)).to eq(:property)
    end

    it 'has documentation' do
      expect(described_class.attrclass(:rule_id).doc).not_to eq("\n\n")
    end
  end

  describe 'property :enabled' do
    it 'is a property' do
      expect(described_class.attrtype(:enabled)).to eq(:property)
    end

    it 'has documentation' do
      expect(described_class.attrclass(:enabled).doc).not_to eq("\n\n")
    end

    [true, false].each do |enabled_value|
      it "can set be set to #{enabled_value}" do
        expect {
          subject[:enabled] = enabled_value
        }.not_to raise_error
      end
    end

    it 'cannot be set to an empty string' do
      expect {
        subject[:ensure] = ''
      }.to raise_error(Puppet::Error, %r{Invalid value})
    end

    it 'cannot be set to nil' do
      expect {
        subject[:ensure] = nil
      }.to raise_error(Puppet::Error, %r{Got nil value for ensure})
    end
  end

  describe 'property :products' do
    it 'is a property' do
      expect(described_class.attrtype(:products)).to eq(:property)
    end

    it 'has documentation' do
      expect(described_class.attrclass(:products).doc).not_to eq("\n\n")
    end

  end
end
