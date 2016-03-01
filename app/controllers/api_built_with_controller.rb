require 'utils'
require 'json'


class ApiBuiltWithController  < ApplicationController
  def get_info
    json = get_site_info(params)
    render json: JSON.generate(json)
  end
end