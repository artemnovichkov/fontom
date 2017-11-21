require_relative '../helper/plist_helper.rb'

# Post message about new build with release notes to the slack channel.
private_lane :rsb_post_to_slack_channel do |options|
  slack_url = ENV['SLACK_URL']
  next unless slack_url

  release_notes = options[:release_notes]
  configuration = options[:configuration]

  next unless release_notes
  next unless configuration

  slack_message = "*Build #{build_number}* has been submitted"
  slack_message += " with `#{configuration}` configuration." if configuration
  slack_message = slack_message + "\n" + 'Release notes:' + "\n" + release_notes if release_notes && release_notes != ''

  slack(
    message: slack_message,
    default_payloads: []
  )
end