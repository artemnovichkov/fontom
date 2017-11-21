require_relative 'plist_helper.rb'

# Updating bundle display name with build number.
private_lane :rsb_update_display_name_with_build_number do
  plist_path = ENV['INFOPLIST_PATH']

  name = "#{bundle_name} #{build_number}"
  set_info_plist_value(
    path: plist_path,
    key: 'CFBundleDisplayName',
    value: name
  )
end

# Updating bundle display name.
private_lane :rsb_update_display_name_with_clean do
  plist_path = ENV['INFOPLIST_PATH']
  set_info_plist_value(
    path: plist_path,
    key: 'CFBundleDisplayName',
    value: bundle_name
  )
end