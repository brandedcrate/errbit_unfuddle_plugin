require 'active_resource'

module ErrbitUnfuddlePlugin
  class Ticket < ActiveResource::Base
    self.format = :xml
  end

  def self.config(account, username, password)
    ErrbitUnfuddlePlugin::Ticket.site = "https://#{account}.unfuddle.com/api/v1/projects/:project_id"
    ErrbitUnfuddlePlugin::Ticket.user = username
    ErrbitUnfuddlePlugin::Ticket.password = password
  end
end
