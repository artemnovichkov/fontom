require_relative 'helper/match_helper.rb'

desc 'Create all certificates and profiles via match'
lane :rsb_match_init do
  types = %w[appstore development adhoc]
  types.each do |type|
    rsb_match_for_type(
      app_identifier: ENV['BUNDLE_ID'],
      type: type
    )

    bundle_id_extensions = ENV['BUNDLE_ID_EXTENSIONS']
    next unless bundle_id_extensions
    bundle_id_extensions.split(', ').each do |bundle_id_extension|
      rsb_match_for_type(
        app_identifier: bundle_id_extension,
        type: type
      )
    end
  end
end

desc 'Download all certificates and profiles via match'
lane :rsb_match do
  types = %w[appstore development adhoc]
  types.each do |type|
    rsb_match_for_type(
      app_identifier: ENV['BUNDLE_ID'],
      type: type,
      force: false,
      readonly: true
    )

    bundle_id_extensions = ENV['BUNDLE_ID_EXTENSIONS']
    next unless bundle_id_extensions
    bundle_id_extensions.split(', ').each do |bundle_id_extension|
      rsb_match_for_type(
        app_identifier: bundle_id_extension,
        type: type,
        force: false,
        readonly: true
      )
    end
  end
end