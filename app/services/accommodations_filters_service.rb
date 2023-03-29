class AccommodationsFiltersService
  FILTERS_TABLES = {
    options_ids: {
      table: :options,
      field: :id,
      query: "options.id IN (select unnest(:value::int[]))",
      convertor: ->(val) { "{#{val.join(', ')}}" }
    },
    cities_ids: {
      table: :cities,
      field: :id,
      query: "cities.id IN (select unnest(:value::int[]))",
      convertor: ->(val) { "{#{val.join(', ')}}" }
    },
    countries_ids: {
      table: :countries,
      field: :id,
      query: "countries.id IN (select unnest(:value::int[]))",
      convertor: ->(val) { "{#{val.join(', ')}}" }
    }
  }

  def self.call(filters: {} )
    accommodations = Accommodation.distinct
      .select('accommodations.*')
      .joins('LEFT JOIN users ON users.id = accommodations.user_id
                LEFT JOIN cities ON cities.id = accommodations.city_id
                LEFT JOIN countries ON countries.id = cities.country_id
                LEFT JOIN accommodation_options ON accommodation_options.accommodation_id = accommodations.id
                LEFT JOIN options ON options.id = accommodation_options.option_id
                LEFT JOIN bookings ON bookings.accommodation_id = accommodations.id')
      .all

    filters.each do |key, value|
      params = FILTERS_TABLES[key]
      convertor = params[:convertor]
      value = convertor.present? ? convertor.call(value) : value
      accommodations = accommodations.where(params[:query], value: value)
    end

    accommodations
  end
end
