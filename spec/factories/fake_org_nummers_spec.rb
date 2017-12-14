require_relative 'fake_org_nummers'

require 'spec_helper'

require 'orgnummer'


RSpec.describe FakeOrgNummers do

  it 'org number string is always 10 digits' do
    10.times do
      expect(described_class.generate).to match(/\d\d\d\d\d\d\d\d\d\d/)
    end
  end

  it 'returns a single string org nummer by default' do
    expect(described_class.generate).to be_a String
  end

  it 'returns an array of string org nummers if any number other than 1 is the argument' do
    expect(described_class.generate(0)).to be_a Array
    expect(described_class.generate(2)).to be_a Array
    expect(described_class.generate(-1)).to be_a Array
  end

  it 'is a valid OrgNummer according to the OrgNummer gem' do
    100.times do
      generated_orgnr = described_class.generate
      expect(Orgnummer.new(generated_orgnr).valid?).to be_truthy
    end

  end

end
