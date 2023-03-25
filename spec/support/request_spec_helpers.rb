module RequestSpecHelpers
  def json
    JSON.parse(response.body)
  end
end
