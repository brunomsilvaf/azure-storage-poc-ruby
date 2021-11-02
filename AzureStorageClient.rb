require 'azure/storage/blob'
require 'yaml'
require 'rest-client'
require 'json'

class AzureStorageClient

  def initialize
    config = YAML.load_file('config.yml')
    url = config['azure']['url']
    client_id = config['azure']['client_id']
    client_secret = config['azure']['client_secret']
    tenant_id = config['azure']['tenant_id']

    # can also be done with regex. storage and container names can be validated according to rules
    uri = URI.parse(url)
    @storage_account_name = uri.host.split('.').first
    @container_name = uri.path.split('/').last

    # how long the sas token is valid in seconds
    @token_expiry = 60*60

    # acquire access token
    token_url = "https://login.microsoftonline.com/" + tenant_id + "/oauth2/token"
    resp = RestClient.post(
      token_url,
      :grant_type    => 'client_credentials',
      :client_id     => client_id,
      :client_secret => client_secret,
      :resource      => 'https://storage.azure.com'
    )
    token = JSON.parse(resp)['access_token']

    # build credentials from access token and get blob client
    token_credential = Azure::Storage::Common::Core::TokenCredential.new token
    token_signer = Azure::Storage::Common::Core::Auth::TokenSigner.new token_credential
    client = Azure::Storage::Common::Client::new(storage_account_name: @storage_account_name, signer: token_signer)
    @blob_client = Azure::Storage::Blob::BlobService.new(client: client)
  end

  def list_containers
    @blob_client.list_containers.each { |a| puts a.name }
  end

  def create_container(container_name)
    @blob_client.create_container(container_name)
  end

  def delete_container(container_name)
    @blob_client.delete_container(container_name)
  end

  def list_blobs(container_name = @container_name)
    @blob_client.list_blobs(container_name).each { |a| puts a.name }
  end

  def list_blobs_md5(container_name = @container_name)
    @blob_client.list_blobs(container_name).each do
    |a|
      puts "name: " + a.name + " | md5: " + a.properties[:content_md5]
    end
  end

  def get_blob(container_name = @container_name, blob_name)
    _,body = @blob_client.get_blob(container_name, blob_name)
    puts body
  end

  def get_blob_link(container_name = @container_name, blob_name)
    user_delegation_key = @blob_client.get_user_delegation_key(Time.now.utc, Time.now.utc + @token_expiry)
    sas_generator = Azure::Storage::Common::Core::Auth::SharedAccessSignature.new(@storage_account_name, "", user_delegation_key)
    uri = @blob_client.generate_uri("#{container_name}/#{blob_name}")
    sas_token = sas_generator.signed_uri(uri, false, service: "b", permissions: "r", expiry: (Time.now.utc + @token_expiry).iso8601)
    puts sas_token
  end

  def upload_data_to_blob(container_name = @container_name, blob_name, content)
    @blob_client.create_block_blob(container_name, blob_name, content)
  end

  def delete_blob(container_name = @container_name, blob_name)
    @blob_client.delete_blob(container_name, blob_name)
  end
end