class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

 	http_basic_authenticate_with name: 'admin', password: 'secret'
  respond_to :json
  before_filter :check_format
	before_filter :add_allow_credentials_headers

	def add_allow_credentials_headers                                                                                                                                                                                                                                                        
	  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#section_5                                                                                                                                                                                                      
	  #                                                                                                                                                                                                                                                                                       
	  # Because we want our front-end to send cookies to allow the API to be authenticated                                                                                                                                                                                                   
	  # (using 'withCredentials' in the XMLHttpRequest), we need to add some headers so                                                                                                                                                                                                      
	  # the browser will not reject the response                                                                                                                                                                                                                                             
	  #response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'                                                                                                                                                                                                     
	  #response.headers['Access-Control-Allow-Credentials'] = 'true'
	  #response.headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		#response.headers['Access-Control-Request-Method'] = '*'

	end 

	def options                                                                                                                                                                                                                                                                              
	  head :status => 200, :'Access-Control-Allow-Headers' => 'accept, content-type'
	end

	def check_format
    render :nothing => true, :status => 406 unless params[:format] == 'json' || request.headers["Accept"] =~ /json/
  end

end