require_relative '../helper/plist_helper.rb'

# Start release branch.
private_lane :rsb_start_release_branch do |options|
  if options[:testflight_build]
    name = "rc-#{app_version}-#{build_number}"
  else
    name = "build-#{app_version}-#{build_number}" 
  end

  $current_release_branch = name

  if ffreezing? == true
    sh('git checkout master')    
  else
    sh('git checkout develop')
  end
  sh("git checkout -b release/#{name}")
end

# Close release branch.
private_lane :rsb_end_release_branch do
  name = $current_release_branch

  sh('git checkout develop')
  sh('git pull')
  sh("git merge release/#{name}")
  sh('git push')

  sh('git checkout master')
  sh('git pull')
  sh("git merge release/#{name}")
  sh('git push')

  sh("git tag #{name}")
  sh("git branch -d release/#{name}")

  push_git_tags

  if ffreezing? == true
    sh('git checkout master')    
  else
    sh('git checkout develop')
  end
end

# Remove release branch if error occurs.
private_lane :rsb_remove_release_branch do
  next unless $current_release_branch
  name = "release/#{$current_release_branch}"

  sh("git checkout develop")
  sh("git branch -D #{name}")
end