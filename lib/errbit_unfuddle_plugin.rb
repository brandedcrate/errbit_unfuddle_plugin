require 'errbit_unfuddle_plugin/version'
require 'errbit_unfuddle_plugin/unfuddle'
require 'errbit_unfuddle_plugin/issue_tracker'
require 'errbit_unfuddle_plugin/rails'

module ErrbitUnfuddlePlugin
  def self.root
    File.expand_path '../..', __FILE__
  end
end

ErrbitPlugin::Registry.add_issue_tracker(ErrbitUnfuddlePlugin::IssueTracker)
