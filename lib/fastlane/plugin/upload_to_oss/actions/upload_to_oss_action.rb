require 'fastlane/action'
require_relative '../helper/upload_to_oss_helper'

module Fastlane
  module Actions

    module SharedValues
      OSS_IPA_OUTPUT_URL = :OSS_IPA_OUTPUT_URL
    end

    class UploadToOssAction < Action
      def self.run(params)
        UI.message("The upload_to_oss plugin is working!")

        ipa = params[:ipa]
        dsym = params[:dsym]
        endpoint = params[:endpoint]
        key = params[:key]
        secret = params[:secret]
        bucket = params[:bucket]
        object_path = params[:object_path]


        # Split the ipa path by "/"
        ipa_segments = ipa.split("/")
        # Get the last segment of the path
        ipa_name = ipa_segments[-1]

        object_key = object_path + '/' + ipa_name
        UI.message("oss object key #{object_key}!")

        require 'aliyun/oss'


        client = Aliyun::OSS::Client.new(
          :endpoint => endpoint,
          :access_key_id => key,
          :access_key_secret => secret
        )
    
        bucket_object = client.get_bucket(bucket)

        UI.message("put_object begin!")

        UI.message("upload dsym ...")
        result = bucket_object.put_object("#{object_path}/#{dsym.split("/")[-1]}", :file => dsym)
        UI.message("upload dsym over #{result}")

        UI.message("upload ipa ...")
        result = bucket_object.put_object(object_key, :file => ipa)

      if result 

        endpoint_host = URI.parse(endpoint).host
        ipa_url = "https://#{bucket}.#{endpoint_host}/#{object_key}"
        UI.message("put_object over!")

        Actions.lane_context[SharedValues::OSS_IPA_OUTPUT_URL] = ipa_url

        UI.message("lane_context OSS_IPA_OUTPUT_URL:#{Actions.lane_context[SharedValues::OSS_IPA_OUTPUT_URL]}")

      else 
        UI.error("upload fail")
      end

      end

      def self.description
        "上传ipa文件到oss"
      end

      def self.authors
        ["zhaozq"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.output
        [
          ['IPA_OUTPUT_PATH', 'ipa file oss url']
        ]
      end

      def self.details
        # Optional:
        "上传ipa文件到oss, 上传结果共享到 SharedValues::OSS_IPA_OUTPUT_URL"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                  env_name: "HAIER_ENTERPRISE_RESIGN_IPA",
                               description: ".ipa file for the build",
                                  optional: true,
                             default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :dsym,
                                  env_name: "HAIER_ENTERPRISE_RESIGN_DSYM",
                               description: "zipped .dsym package for the build ",
                                  optional: true,
                             default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                  env_name: "HAIER_ENTERPRISE_RESIGN_ENDPOINT",
                               description: "oss endpoint, default value http://oss-cn-qingdao.aliyuncs.com",
                                  optional: true,
                             default_value: "http://oss-cn-qingdao.aliyuncs.com"),

          FastlaneCore::ConfigItem.new(key: :key,
                                  env_name: "HAIER_ENTERPRISE_RESIGN_KEY",
                               description: "oss key",
                                  optional: true,
                             default_value: ENV['OSS_ACCESS_KEY_ID']),
          FastlaneCore::ConfigItem.new(key: :secret,
                                  env_name: "HAIER_ENTERPRISE_RESIGN_SECRET",
                               description: "oss secret",
                                  optional: true,
                             default_value: ENV['OSS_ACCESS_KEY_SECRET']),
          FastlaneCore::ConfigItem.new(key: :bucket,
                                  env_name: "HAIER_ENTERPRISE_RESIGN_BUCKET",
                               description: "oss bucket",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :object_path,
                                  env_name: "HAIER_ENTERPRISE_RESIGN_OBJECT_PATH",
                               description: "oss object key 'foo/bar/file', object path 'foo/bar'",
                                  optional: false,
                                      type: String),
          #TODO:  add verify_block
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        platform == :ios
      end
    end
  end
end
