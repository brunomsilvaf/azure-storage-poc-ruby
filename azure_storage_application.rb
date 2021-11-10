require './azure_storage_client'

azure_client = AzureStorageClient.new

puts "\nListing blobs:"
azure_client.list_blobs

puts "\nCreating blob:"
azure_client.upload_data_to_blob("qa/recordings/id-rb1/test.txt","Creating a blob")
azure_client.list_blobs

puts "\nGetting blob:"
azure_client.get_blob("qa/recordings/id-rb1/test.txt")

puts "\nOverwriting blob:"
azure_client.upload_data_to_blob("qa/recordings/id-rb1/test.txt","Blob with overwritten content")
azure_client.list_blobs

puts "\nGetting blob:"
azure_client.get_blob("qa/recordings/id-rb1/test.txt")

puts "\nGenerating SAS token for blob:"
azure_client.get_blob_link("qa/recordings/id-rb1/test.txt")

puts "\nChecking blobs metadata:"
azure_client.list_blobs_md5