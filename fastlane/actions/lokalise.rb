# Source and Copyright: https://github.com/lokalise/lokalise-fastlane-actions

module Fastlane
  module Actions
    class LokaliseAction < Action
      def self.run(params)
        require 'net/http'
        require 'json'

        token = params[:api_token]
        project_identifier = params[:project_identifier]
        destination = params[:destination]
        clean_destination = params[:clean_destination]
        format = params[:format] ? params[:format] : "ios_sdk"
        bundle_structure = params[:bundle_structure] ? params[:bundle_structure] : "%LANG_ISO%.lproj/Localizable.%FORMAT%"
        include_comments = params[:include_comments]
        original_filenames = params[:use_original]
        replace_breaks = params[:replace_breaks] ? true : false

        body = {
          format: format,
          original_filenames: original_filenames,
          bundle_filename: "Localization.zip",
          bundle_structure: bundle_structure,
          all_platforms: true,
          export_empty_as: "base",
          export_sort: "a_z",
          include_comments: include_comments,
          replace_breaks: replace_breaks
          # async flag not needed for async-download endpoint
        }

        filter_langs = params[:languages]
        if filter_langs.kind_of? Array then
          body["filter_langs"] = filter_langs
        end

        tags = params[:tags]
        if tags.kind_of? Array then
          body["include_tags"] = tags
        end

        uri = URI("https://api.lokalise.com/api2/projects/#{project_identifier}/files/async-download")
        request = Net::HTTP::Post.new(uri)
        request.body = body.to_json
        request.add_field("x-api-token", token)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)

        jsonResponse = JSON.parse(response.body) rescue {}
        UI.error "Bad response 🉐\n#{response.body}" unless jsonResponse.kind_of? Hash

        # Expect async response with process_id
        if response.code == "200" && jsonResponse["process_id"].kind_of?(String)
          process_id = jsonResponse["process_id"]
          UI.message "Async export started. Process ID: #{process_id} ⏳"

          bundle_url = poll_process_for_bundle_url(
            token: token,
            project_identifier: project_identifier,
            process_id: process_id,
            max_attempts: 60,
            interval_seconds: 5
          )

          if bundle_url.nil?
            UI.error "Process did not finish successfully or bundle URL missing 📟"
            return
          end

          UI.message "Downloading localizations archive 📦"
          FileUtils.mkdir_p("lokalisetmp")
          fileURL = bundle_url
          uri = URI(fileURL)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          zipRequest = Net::HTTP::Get.new(uri)
          response = http.request(zipRequest)
          if response.content_type == "application/zip" || response.content_type == "application/octet-stream"
            FileUtils.mkdir_p("lokalisetmp")
            open("lokalisetmp/a.zip", "wb") { |file|
              file.write(response.body)
            }
            unzip_file("lokalisetmp/a.zip", destination, clean_destination)
            FileUtils.remove_dir("lokalisetmp")
            UI.success "Localizations extracted to #{destination} 📗 📕 📘"
          else
            UI.error "Response did not include ZIP"
          end
        elsif jsonResponse["error"].kind_of? Hash
          code = jsonResponse["error"]["code"]
          message = jsonResponse["error"]["message"]
          UI.error "Response error code #{code} (#{message}) 📟"
        else
          UI.error "Bad response 🉐\n#{jsonResponse}"
        end
      end

      def self.poll_process_for_bundle_url(token:, project_identifier:, process_id:, max_attempts:, interval_seconds:)
        require 'net/http'
        require 'json'
        attempts = 0
        while attempts < max_attempts
          attempts += 1
            uri = URI("https://api.lokalise.com/api2/projects/#{project_identifier}/processes/#{process_id}")
            request = Net::HTTP::Get.new(uri)
            request.add_field("x-api-token", token)
            request.add_field("accept", "application/json")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            response = http.request(request)

            json = JSON.parse(response.body) rescue {}

            if response.code == "200" && json["process"].kind_of?(Hash)
              process = json["process"]
              status = process["status"]
              UI.message "Process #{process_id} status: #{status}"
              case status
              when "finished"
                details = process["details"] || {}
                # Try known shapes for async-download details
                bundle_url = details["bundle_url"] ||
                             (details["bundle"].kind_of?(Hash) ? details["bundle"]["url"] : nil) ||
                             details["url"] ||
                             details["download_url"]

                if bundle_url.nil?
                  UI.message "Process finished but bundle_url not found. Details: #{details}"
                end
                return bundle_url
              when "failed"
                UI.error "Process #{process_id} failed ❌"
                return nil
              else
                # queued, in_progress -> continue
              end
            else
              UI.message "Unexpected process response (HTTP #{response.code}), retrying…"
            end

            sleep interval_seconds
        end
        UI.error "Timed out waiting for process #{process_id} ⏰"
        nil
      end

      def self.unzip_file(file, destination, clean_destination)
        require 'zip'
        require 'rubygems'
        Zip::File.open(file) { |zip_file|
          if clean_destination then
            UI.message "Cleaning destination folder ♻️"
            FileUtils.remove_dir(destination)
            FileUtils.mkdir_p(destination)
          end
          UI.message "Unarchiving localizations to destination 📚"
           zip_file.each { |f|
             f_path= File.join(destination, f.name)
             FileUtils.mkdir_p(File.dirname(f_path))
             FileUtils.rm(f_path) if File.file? f_path
             zip_file.extract(f, f_path)
           }

           # Flatten new bundle structure if present (Lokalise.bundle/Contents/Resources/*)
           bundle_resources_root = File.join(destination, 'Lokalise.bundle', 'Contents', 'Resources')
           if Dir.exist?(bundle_resources_root)
             UI.message "Flattening Lokalise.bundle structure (preserving existing resources) 📁"
             Dir.children(bundle_resources_root).each do |child|
               next unless child.end_with?('.lproj')
               src_lang_dir = File.join(bundle_resources_root, child)
               dest_lang_dir = File.join(destination, child)
               FileUtils.mkdir_p(dest_lang_dir)
               Dir.glob(File.join(src_lang_dir, '*')).each do |exported_file|
                 fname = File.basename(exported_file)
                 if fname =~ /^Localizable\.(strings|stringsdict)$/ || fname == 'internal_messages.json'
                   FileUtils.rm_f(File.join(dest_lang_dir, fname))
                   FileUtils.mv(exported_file, File.join(dest_lang_dir, fname))
                 else
                   # keep other existing files in dest_lang_dir; skip moving
                 end
               end
             end
             FileUtils.rm_rf(File.join(destination, 'Lokalise.bundle'))
           end
        }
      end


      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download Lokalise localization"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "LOKALISE_API_TOKEN",
                                       description: "API Token for Lokalise",
                                       verify_block: proc do |value|
                                          UI.user_error! "No API token for Lokalise given, pass using `api_token: 'token'`" unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_identifier,
                                       env_name: "LOKALISE_PROJECT_ID",
                                       description: "Lokalise Project ID",
                                       verify_block: proc do |value|
                                          UI.user_error! "No Project Identifier for Lokalise given, pass using `project_identifier: 'identifier'`" unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       description: "Localization destination",
                                       verify_block: proc do |value|
                                          UI.user_error! "Things are pretty bad" unless (value and not value.empty?)
                                          UI.user_error! "Directory you passed is in your imagination" unless File.directory?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :clean_destination,
                                       description: "Clean destination folder",
                                       optional: true,
                                       is_string: false,
                                       default_value: false,
                                       verify_block: proc do |value|
                                          UI.user_error! "Clean destination should be true or false" unless [true, false].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :languages,
                                       description: "Languages to download",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                          UI.user_error! "Language codes should be passed as array" unless value.kind_of? Array
                                       end),
          FastlaneCore::ConfigItem.new(key: :format,
                                        description: "File format (e.g. json, strings, xml). Must be file extension of any of the file formats we support. May also be <code>ios_sdk</code> or <code>android_sdk</code> for respective OTA SDK bundles",
                                        optional: true,
                                        is_string: true,
                                        default_value: "ios_sdk",
                                        verify_block: proc do |value|
                                          UI.user_error! "Format should be a string" unless value.kind_of? String
                                        end
                                      ),
            FastlaneCore::ConfigItem.new(key: :include_comments,
                                       description: "Include comments in exported files",
                                       optional: true,
                                       is_string: false,
                                       default_value: false,
                                       verify_block: proc do |value|
                                         UI.user_error! "Include comments should be true or false" unless [true, false].include? value
                                       end),
            FastlaneCore::ConfigItem.new(key: :bundle_structure,
                                        description: "Bundle structure, used when <code>original_filenames</code> set to <code>false</code>. Allowed placeholders are <code>%LANG_ISO%</code>, <code>%LANG_NAME%</code>, <code>%FORMAT%</code> and <code>%PROJECT_NAME%</code>)",
                                        optional: true,
                                        is_string: true,
                                        default_value: "%LANG_ISO%.lproj/Localizable.%FORMAT%",
                                        verify_block: proc do |value|
                                          UI.user_error! "Bundle structure should be a string" unless value.kind_of? String
                                        end
                                      ),                           
            FastlaneCore::ConfigItem.new(key: :use_original,
                                       description: "Use original filenames/formats (bundle_structure parameter is ignored then)",
                                       optional: true,
                                       is_string: false,
                                       default_value: false,
                                       verify_block: proc do |value|
                                         UI.user_error! "Use original should be true of false." unless [true, false].include?(value)
                                        end),
            FastlaneCore::ConfigItem.new(key: :tags,
                                        description: "Include only the keys tagged with a given set of tags",
                                        optional: true,
                                        is_string: false,
                                        verify_block: proc do |value|
                                          UI.user_error! "Tags should be passed as array" unless value.kind_of? Array
                                        end),
            FastlaneCore::ConfigItem.new(key: :replace_breaks,
                                        description: "Replace breaks",
                                        optional: true,
                                        is_string: false,
                                        default_value: false,
                                        verify_block: proc do |value|
                                          UI.user_error! "Replace break should be true or false" unless [true, false].include? value
                                        end),

        ]
      end

      def self.authors
        "Fedya-L"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform 
      end
    end
  end
end