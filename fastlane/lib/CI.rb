private_lane :rsb_trigger_ci_fastlane do
  require "json"

  json = JSON.parse(`curl -X GET trigger-ci:0a3261d0ba74395c0530827de2adae27@10.1.0.156:8080/crumbIssuer/api/json`)
  crumbField = json['crumbRequestField']
  crumb = json['crumb']
  
  app_token = ENV['CI_APP_TOKEN']
  app_name = ENV['CI_APP_NAME']  
  lane_name = URI.encode(Actions.lane_context[SharedValues::LANE_NAME])

  env = Actions.lane_context[Actions::SharedValues::ENVIRONMENT]
  env = 'default' unless env

  url = 'http://trigger-ci:0a3261d0ba74395c0530827de2adae27@10.1.0.156:8080/job/' + app_name + '/buildWithParameters?token=' + app_token + '&lane=' + lane_name + '&env=' + env
  sh('curl -X POST ' + '"' + url + '"' + " -H " + '"' + crumbField + ':' + crumb + '"')
end

def rsb_possible_to_trigger_ci_build?
  ENV['CI_APP_TOKEN'] && ENV['CI_APP_NAME'] && !is_ci?
end