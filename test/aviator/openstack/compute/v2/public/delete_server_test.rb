require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/delete_server' do

    def create_request(session_data = get_session_data, &block)
      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'delete_server.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
                     config_file: Environment.path,
                     environment: 'openstack_member'
                   )
        @session.authenticate
      end

      @session
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      request = create_request {|p| p[:id] = 0 }

      klass.body?.must_equal false
      request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data.token }

      request = create_request {|p| p[:id] = 0 }

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request{|p| p[:id] = 0 }.http_method.must_equal :delete
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [
        :id
      ]
    end


    validate_attr :url do
      service_spec = get_session_data[:catalog].find{|s| s[:type] == 'compute' }
      server_id    = '105b09f0b6500d36168480ad84'
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'public'}[:url] }/servers/#{ server_id }"

      request = create_request do |params|
        params[:id] = server_id
      end

      request.url.must_equal url
    end


    validate_response 'valid server id is provided' do
      server    = session.compute_service.request(:list_servers).body[:servers].first
      server_id = server[:id]
      new_name  = 'Updated Server'

      response = session.compute_service.request :delete_server do |params|
        params[:id]   = server_id
      end

      response.status.must_equal 204
      response.headers.wont_be_nil
    end


    validate_response 'invalid server id is provided' do
      server_id = 'abogusserveridthatdoesnotexist'

      response = session.compute_service.request :delete_server do |params|
        params[:id]   = server_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end