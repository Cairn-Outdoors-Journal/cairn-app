# Adds the stage 5b native code to the Flutter iOS project:
# - ios/Shared/*.swift into Runner (and the widget)
# - Runner/CairnShortcuts.swift + Runner/LocationSpikePlugin.swift into Runner
# - a CairnCaptureWidget widget extension, embedded in Runner
# - App Group entitlements on both targets
require 'xcodeproj'

proj = Xcodeproj::Project.open('Runner.xcodeproj')
runner = proj.targets.find { |t| t.name == 'Runner' }
abort 'widget target already exists' if proj.targets.any? { |t| t.name == 'CairnCaptureWidget' }

shared = proj.main_group.new_group('Shared', 'Shared')
shared_refs = %w[CaptureLog.swift LocationCapture.swift CapturePointIntent.swift].map { |f| shared.new_reference(f) }
runner.add_file_references(shared_refs)

runner_group = proj.main_group['Runner']
runner_refs = %w[CairnShortcuts.swift LocationSpikePlugin.swift].map { |f| runner_group.new_reference(f) }
runner.add_file_references(runner_refs)
runner_group.new_reference('Runner.entitlements')

widget = proj.new_target(:app_extension, 'CairnCaptureWidget', :ios, '17.0')
group = proj.main_group.new_group('CairnCaptureWidget', 'CairnCaptureWidget')
widget.add_file_references([group.new_reference('CaptureWidgetBundle.swift')] + shared_refs)
group.new_reference('Info.plist')
group.new_reference('CairnCaptureWidget.entitlements')

widget.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.cairnjournal.app.CaptureWidget'
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = 'CairnCaptureWidget/Info.plist'
  s['CODE_SIGN_ENTITLEMENTS'] = 'CairnCaptureWidget/CairnCaptureWidget.entitlements'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['SWIFT_VERSION'] = '5.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  s['MARKETING_VERSION'] = '1.0'
  s['CURRENT_PROJECT_VERSION'] = '1'
  s['SKIP_INSTALL'] = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['OTHER_SWIFT_FLAGS'] = '$(inherited) -DCAIRN_EXTENSION'
  s['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
  s['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
end

runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

# Embed the extension. Flutter's "Thin Binary" script must run after the
# embed phase or Xcode reports a dependency cycle, so the embed phase goes
# right after Resources.
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
file = embed.add_file_reference(widget.product_reference, true)
file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
runner.build_phases.delete(embed)
resources_index = runner.build_phases.index(runner.resources_build_phase)
runner.build_phases.insert(resources_index + 1, embed)
runner.add_dependency(widget)

proj.save
puts runner.build_phases.map(&:display_name).inspect
