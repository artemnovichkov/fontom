require_relative '../helper/credentials_helper.rb'
require 'jira-ruby'

private_lane :rsb_move_jira_tickets do
  project = ENV['JIRA_PROJECT']
  jira_website = ENV['JIRA_WEBSITE']

  next unless jira_website
  next unless project

  to_status = ENV['JIRA_TO_STATUS']
  to_status = 'Test Build' unless to_status

  client = rsb_jira_client
  issues = rsb_jira_issues

  issues.each do |issue|
    transitions = client.Transition.all(issue: issue)
    transitions.each do |transition|
      next unless transition.name.downcase == to_status.downcase
      test_build_transition_id = transition.id
      transition = issue.transitions.build
      transition.save!('transition' => { 'id' => test_build_transition_id })
    end
  end
end

private_lane :rsb_jira_release_notes do
  issues = rsb_jira_issues  
  description = ''

  features = []
  fixes = []

  issues.each do |issue|
    if issue.issuetype.name == 'Bug'
      fixes.push(issue)
    else
      features.push(issue)
    end
  end

  unless features.empty?
    description += "\nFeatures:"
    features.each do |issue|
      description += "\n  #{issue.summary} (#{ENV['JIRA_WEBSITE']}/browse/#{issue.key})"
    end    
  end
  
  unless fixes.empty?
    description += "\n" unless description.empty?
    description += "\nFixes:"
    fixes.each do |issue|
      description += "\n  #{issue.summary} (#{ENV['JIRA_WEBSITE']}/browse/#{issue.key})"
    end
  end

  description
end

def rsb_jira_issues 
  from_status = ENV['JIRA_FROM_STATUS']
  from_status = 'Ready' unless from_status

  project = ENV['JIRA_PROJECT']
  client = rsb_jira_client
  issues = client.Issue.jql("project = #{project.shellescape} AND status = #{from_status.shellescape}")

  component = ENV['JIRA_COMPONENT']
  if component
    issues.select! do |issue|
      names = issue.components.map { |obj| obj.name }
      names.include? component
    end  
  end

  label = ENV['JIRA_TASK_LABEL']
  if label
    issues.select! do |issue|
      issue.labels.include? label
    end  
  end

  if ffreezing? 
    issues.select! do |issue|
      issue.issuetype.name == 'Bug'
    end  
  end

  issues
end

def rsb_jira_client
  Actions.verify_gem!('jira-ruby')

  jira_website = ENV['JIRA_WEBSITE']
  credentials = rsb_credentials('JIRA', jira_website)
  options = {
    site: jira_website,
    context_path: '',
    auth_type: :basic,
    username: credentials[:username],
    password: credentials[:password]
  }

  JIRA::Client.new(options)
end