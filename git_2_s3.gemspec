Gem::Specification.new do |s|

  s.name = 'git-2-s3'
  s.version = '0.1.2'
  s.platform = Gem::Platform::RUBY
  s.summary = "A deployment strategy to S3 from github using capistrano"
  s.description = "A deployment strategy that takes a github repository and pushes the files into an S3 bucket using capistrano"

  s.files = Dir.glob("{bin,lib,examples,test}/**/*") + %w(README MIT-LICENSE)
  s.has_rdoc = true

  s.add_dependency 'capistrano', ">= 2.1.0"
  s.add_dependency 's3sync'

  s.author = "Kurt Didenhover"
  s.email = "kdidenhover@gmail.com"
  s.rubyforge_project = nil
  s.homepage = "http://github.com/heyaustria/git-2-s3"
end
