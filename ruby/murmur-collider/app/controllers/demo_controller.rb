class DemoController < ApplicationController
  def index
    #params[:user].keys.each { |k| puts k.hash }
    render text: "OK"
  end
end
