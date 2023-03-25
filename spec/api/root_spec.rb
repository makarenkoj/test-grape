require 'rails_helper'

describe Root do
  describe 'GET /' do
    before { get '/' }

    it { expect(response.status).to eq 200 }
  end
end
