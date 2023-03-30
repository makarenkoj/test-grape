require 'rails_helper'
require 'support/shared_contexts/base'

describe AccommodationsFiltersService do
  include_context 'base'
  context 'filters accommodations' do
    let(:country1) { create(:country) }
    let(:country2) { create(:country) }
    let(:country3) { create(:country) }

    let(:city1) { create(:city, country: country1) }
    let(:city2) { create(:city, country: country2) }
    let(:city3) { create(:city, country: country3) }

    let(:option1) { create(:option) }
    let(:option2) { create(:option) }

    let!(:accommodation1) { create(:accommodation, :with_option, city: city1) }
    let!(:accommodation2) { create(:accommodation, :with_option, city: city2) }
    let!(:accommodation3) { create(:accommodation, :with_option, city: city3) }

    let!(:accommodation_option) { create(:accommodation_option, option: option1, accommodation: accommodation1) }

    it 'return with country filters' do
      expect(AccommodationsFiltersService.call(filters: { 'countries_ids' => [country1.id, country3.id] })).to include(accommodation1, accommodation3)
      expect(AccommodationsFiltersService.call(filters: { 'countries_ids' => [country2.id] })).to include(accommodation2)
    end

    it 'return with city filters' do
      expect(AccommodationsFiltersService.call(filters: { 'cities_ids' => [city3.id, city2.id] })).to include(accommodation2, accommodation3)
      expect(AccommodationsFiltersService.call(filters: { 'cities_ids' => [city1.id] })).to include(accommodation1)
    end

    it 'return with option filters' do
      expect(AccommodationsFiltersService.call(filters: { 'options_ids' => [accommodation2.options.last.id, accommodation3.options.last.id] })).to include(accommodation2, accommodation3)
      expect(AccommodationsFiltersService.call(filters: { 'options_ids' => [option1.id] })).to include(accommodation1)
      expect(AccommodationsFiltersService.call(filters: { 'options_ids' => [option2.id] }).size).to eql 0
    end

    it 'use all filters filters' do
      expect(AccommodationsFiltersService.call(filters: { 'countries_ids' => [country1.id], 'options_ids' => [option1.id], 'cities_ids' => [city1.id] })).to include(accommodation1)
      expect(AccommodationsFiltersService.call(filters: { 'countries_ids' => [country2.id], 'options_ids' => [accommodation2.options.last.id],
                                                          'cities_ids' => [city2.id] })).to include(accommodation2)
      expect(AccommodationsFiltersService.call(filters: { 'countries_ids' => [country1.id], 'options_ids' => [option1.id], 'cities_ids' => [city2.id] }).size).to eql 0
    end

    it 'without filters filters' do
      expect(AccommodationsFiltersService.call(filters: {})).to include(accommodation1, accommodation2, accommodation3)
      expect(AccommodationsFiltersService.call(filters: {}).size).to eql 3
    end
  end
end
