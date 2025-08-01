require 'fastlane/action'
require 'uri'
require 'net/http'
require 'json'
require 'base64'

module Fastlane
  module Actions
    class LokaliseUploadAction < Action
      def self.run(params)
        project_id = params[:project_identifier]
        api_token = params[:api_token]
        file_path = params[:file_path]
        lang_iso = params[:lang_iso]
        filename = params[:filename] || File.basename(file_path)
        cleanup_mode = params[:cleanup_mode]
        use_automations = params[:use_automations]

        # Read and encode file
        file_data = File.read(file_path)
        base64_data = Base64.strict_encode64(file_data)

        # Prepare upload request
        url = URI("https://api.lokalise.com/api2/projects/#{project_id}/files/upload")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(url)
        request['accept'] = 'application/json'
        request['content-type'] = 'application/json'

        UI.message("Project ID: #{project_id}")
        request['x-api-token'] = api_token

        body = {
          cleanup_mode: cleanup_mode,
          use_automations: use_automations,
          filename: filename,
          lang_iso: lang_iso,
          data: base64_data
        }
        request.body = body.to_json

        UI.message("Uploading file to Lokalise...")
        response = http.request(request)
        result = JSON.parse(response.body)

        unless result["process"]
          UI.user_error!("Upload failed: #{result}")
        end

        process_id = result["process"]["process_id"]
        UI.message("Upload started. Process ID: #{process_id}")

        # Poll process endpoint
        process_url = URI("https://api.lokalise.com/api2/projects/#{project_id}/processes/#{process_id}")
        loop do
          sleep 2
          process_request = Net::HTTP::Get.new(process_url)
          process_request['X-Api-Token'] = api_token
          process_response = http.request(process_request)
          process_result = JSON.parse(process_response.body)

          status = process_result["process"]["status"]
          UI.message("Process status: #{status}")

          case status
          when "finished"
            UI.success("Lokalise upload finished successfully!")
            break
          when "failed"
            UI.user_error!("Lokalise upload failed: #{process_result["process"]["message"]}")
            break
          end
        end
      end

      def self.description
        "Uploads a localization file to Lokalise and waits for the import to finish."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                             env_name: "LOKALISE_API_TOKEN",
                             description: "API Token for Lokalise. NOTE: !Must have write permissions!",
                             verify_block: proc do |value|
                                UI.user_error! "No API token for Lokalise given, pass using `api_token: 'token'`" unless (value and not value.empty?)
                             end),
          FastlaneCore::ConfigItem.new(key: :project_identifier,
                             env_name: "LOKALISE_PROJECT_ID",
                             description: "Lokalise Project ID",
                             verify_block: proc do |value|
                                UI.user_error! "No Project Identifier for Lokalise given, pass using `project_identifier: 'identifier'`" unless (value and not value.empty?)
                             end),
          FastlaneCore::ConfigItem.new(key: :file_path, description: "Path to the localization file", optional: false),
          FastlaneCore::ConfigItem.new(key: :lang_iso, description: "Language ISO code (e.g., 'de')", optional: false),
          FastlaneCore::ConfigItem.new(key: :filename, description: "Filename as it should appear in Lokalise", optional: true),
          FastlaneCore::ConfigItem.new(key: :cleanup_mode, description: "Enable cleanup_mode (default: true)", type: Boolean, default_value: true),
          FastlaneCore::ConfigItem.new(key: :use_automations, description: "Enable use_automations (default: true)", type: Boolean, default_value: true)
        ]
      end

      def self.authors
        ["Martin Fiebig"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end