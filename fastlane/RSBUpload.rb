import 'lib/jira.rb'
import 'lib/slack.rb'
import 'lib/gitflow.rb'
import 'lib/CI.rb'

import 'helper/provisioning_profiles_helper.rb'
import 'helper/match_helper.rb'
import 'helper/unit_testing_helper.rb'
import 'helper/display_name_helper.rb'
import 'helper/build_number_helper.rb'

default_platform :ios

platform :ios do

  before_all do |lane, options|
    Actions.lane_context[SharedValues::FFREEZING] = options[:ffreezing]
    skip_docs
  end

  after_all do |lane|
    clean_build_artifacts
  end

  error do |lane, exception|
    clean_build_artifacts
    rsb_remove_release_branch
  end

  ### LANES

  lane :rsb_fabric do |options|
    rsb_fabric_private(
      crashlytics_groups: [ENV['CRASHLYTICS_GROUP']]
    )
  end

  lane :rsb_testflight do |options|
    rsb_testflight_private(
      skip_submission: true
    )
  end

  lane :rsb_fabric_testflight do |options|
    rsb_fabric_testflight_private(
      crashlytics_groups: [ENV['CRASHLYTICS_GROUP']],
      skip_submission: true
    )
  end

  lane :rsb_add_devices do
    file_path = prompt(
      text: 'Enter the file path: '
    )

    register_devices(
      devices_file: file_path
    )
  end

  ### PRIVATE LANES

  private_lane :rsb_fabric_private do |options|
    if rsb_possible_to_trigger_ci_build?
      rsb_trigger_ci_fastlane
      next
    end

    if is_ci?
      setup_jenkins
    end

    ensure_git_status_clean
    rsb_start_release_branch(
      testflight_build: false
    )

    rsb_run_tests_if_needed
    rsb_stash_save_tests_output
    
    release_notes = rsb_release_notes

    rsb_stash_pop_tests_output
    rsb_commit_tests_output
    rsb_update_display_name_with_build_number
    rsb_update_provisioning_profiles(
      type: :adhoc
    )
    configuration = ENV['CONFIGURATION_ADHOC']
    rsb_build_and_archive(
      configuration: configuration
    )
    rsb_send_to_crashlytics(
      groups: options[:crashlytics_groups],
      notes: release_notes
    )

    rsb_move_jira_tickets
    rsb_post_to_slack_channel(
      configuration: configuration,
      release_notes: release_notes
    )
    if is_ci?
      reset_git_repo(force: true)
    end

    rsb_update_build_number
    rsb_update_display_name_with_build_number
    rsb_commit_build_number_changes
    rsb_end_release_branch
  end

  private_lane :rsb_testflight_private do |options|
    precheck_if_needed
    check_no_debug_code_if_needed

    if rsb_possible_to_trigger_ci_build?
      rsb_trigger_ci_fastlane
      next
    end

    if is_ci?
      setup_jenkins
    end

    ensure_git_status_clean
    rsb_start_release_branch(
      testflight_build: true
    )

    rsb_run_tests_if_needed
    rsb_stash_save_tests_output
    
    rsb_stash_pop_tests_output
    rsb_commit_tests_output
    rsb_update_display_name_with_clean
    rsb_update_provisioning_profiles(
      type: :appstore
    )
    rsb_build_and_archive(
      configuration: ENV['CONFIGURATION_APPSTORE']
    )
    rsb_send_to_testflight(
      skip_submission: options[:skip_submission]
    )
    if is_ci?
      reset_git_repo(force: true)
    end
    rsb_update_build_number
    rsb_update_display_name_with_build_number
    rsb_commit_build_number_changes
    rsb_end_release_branch
  end

  private_lane :rsb_fabric_testflight_private do |options|
    precheck_if_needed
    check_no_debug_code_if_needed

    if rsb_possible_to_trigger_ci_build?
      rsb_trigger_ci_fastlane
      next
    end

    if is_ci?
      setup_jenkins
    end

    ensure_git_status_clean
    rsb_start_release_branch(
      testflight_build: true
    )

    rsb_run_tests_if_needed
    rsb_stash_save_tests_output

    release_notes = rsb_release_notes
    
    rsb_stash_pop_tests_output
    rsb_commit_tests_output
    rsb_update_display_name_with_build_number
    rsb_update_provisioning_profiles(
      type: :adhoc
    )

    rsb_build_and_archive(
      configuration: ENV['CONFIGURATION_ADHOC']
    )

    rsb_move_jira_tickets
    rsb_send_to_crashlytics(
      groups: options[:crashlytics_groups],
      notes: release_notes
    )
    
    clean_build_artifacts
    rsb_update_display_name_with_clean
    rsb_update_provisioning_profiles(
      type: :appstore
    )
    rsb_build_and_archive(
      configuration: ENV['CONFIGURATION_APPSTORE']
    )
    rsb_send_to_testflight(
      skip_submission: options[:skip_submission]
    )
    if is_ci?
      reset_git_repo(force: true)
    end
    rsb_update_build_number
    rsb_update_display_name_with_build_number
    rsb_commit_build_number_changes
    rsb_end_release_branch
  end

  private_lane :rsb_build_and_archive do |options|
    configuration = options[:configuration]
    rsb_update_extensions_build_and_version_numbers_according_to_main_app
    gym(configuration: configuration)
  end

  private_lane :rsb_send_to_crashlytics do |options|
    crashlytics(
      groups: options[:groups],
      notes: options[:notes]
    )
  end

  private_lane :rsb_send_to_testflight do |options|
    pilot(
      ipa: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
      skip_submission: options[:skip_submission],
      skip_waiting_for_build_processing: true
    )
  end
end

module SharedValues
  FFREEZING = :FFREEZING  
end

def ffreezing? 
  Actions.lane_context[SharedValues::FFREEZING] == true
end

def rsb_release_notes
  if ENV['JIRA_WEBSITE'] && ENV['JIRA_PROJECT']
    release_notes = rsb_jira_release_notes
  else
    release_notes = prompt(
      text: 'Enter release notes: ',
      multi_line_end_keyword: 'END'
    )
  end
  release_notes
end

def precheck_if_needed
  precheck(app_identifier: ENV['BUNDLE_ID']) if ENV['NEED_PRECHECK'] == 'true'
end

def check_no_debug_code_if_needed    
  ensure_no_debug_code(text: 'TODO|FIXME', path: 'Classes/', extension: '.swift') if ENV['CHECK_DEBUG_CODE'] == 'true'
end