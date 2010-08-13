require 'capistrano/recipes/deploy/strategy/copy'
require 'fileutils'
require 'tempfile'  # Dir.tmpdir

#implementing a capistrano deploy strategy that:
# - Expects a deploy_bucket it can read from and write to
# - Uses configuration[:s3_config] to find creds
# - Checks out the specified revision, and pushes each file to the S3 bucket
# - depends on the s3cmd command, perhaps installed with `gem install s3sync`

# Copyright 2010 Kurt Didenhover
# Distributed via MIT license
# Feedback appreciated: kdidenhover at [nospam] gmail dt com

module Capistrano
  module Deploy
    module Strategy

      class S3Bucket < Copy

        def deploy!
          logger.debug "getting (via #{copy_strategy}) revision #{revision} to #{destination}"
          logger.debug "#{configuration[:release_path]} #{File.basename(configuration[:release_path])}"
          put_package
          
          logger.debug "done!"
        end

        #!! implement me!
        # Performs a check on the remote hosts to determine whether everything
        # is setup such that a deploy could succeed.
        # def check!
        # end

    private
        def aws_environment
          @aws_environment ||= "AWS_ACCOUNT_NUMBER=#{configuration[:s3_config]['AWS_ACCOUNT_NUMBER']} AWS_ACCESS_KEY_ID=#{configuration[:s3_config]['AWS_ACCESS_KEY_ID']} AWS_SECRET_ACCESS_KEY=#{configuration[:s3_config]['AWS_SECRET_ACCESS_KEY']}"
        end
        # Responsible for ensuring that the package for the current revision is in the bucket
        def put_package
          set :release_name, revision
          
          # Do the checkout locally
          system(command)          

          Dir.chdir(destination)
          
          logger.trace "pushing repo contents to S3 bucket #{bucket_name}"
          system("s3sync -r --exclude='.git' #{destination}/ #{bucket_name}: ")
        end
        
        def bucket_name
          configuration[:deploy_s3_bucket]
        end
        
        def bucket
          @bucket ||= Bucket.find(bucket_name) or raise "Failed to find bucket #{configuration[:deploy_s3_bucket]}"
        end

        def initialize(config={})
          super(config)
          
          raise "Failed to find :s3_config" unless configuration[:s3_config]
          # Annoying that merge doesnt work because ENV isn't really a Hash:
          # ENV.merge(configuration[:s3_config])
          configuration[:s3_config].each_pair { |name, value| ENV[name] = value }
        end

      end
    end
  end
end