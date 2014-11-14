module ErrbitUnfuddlePlugin
  class IssueTracker < ErrbitPlugin::IssueTracker
    LABEL = 'unfuddle'

    NOTE = ''

    FIELDS = [
      [:account, {
        :placeholder => "account-name (from account-name.unfuddle.com)"
      }],
      [:username, {
        :placeholder => "Your username"
      }],

      [:password, {
        :placeholder => "Your password"
      }],
      [:project_id, {
        :label       => "Ticket Project ID",
        :placeholder => "Project where tickets will be created"
      }],
      [:milestone_id, {
        :optional    => true,
        :label       => "Ticket Milestone ID",
        :placeholder => "Milestone where tickets will be created"
      }]
    ]

    def self.label
      LABEL
    end

    def self.note
      NOTE
    end

    def self.fields
      FIELDS
    end

    def self.body_template
      @body_template ||= ERB.new(File.read(
        File.join(
          ErrbitUnfuddlePlugin.root, 'views', 'unfuddle_issues_body.txt.erb'
        )
      ))
    end

    def url
      sprintf(
        "https://%s.unfuddle.com/projects/%s",
        params['account'],
        params['project_id']
      )
    end

    def configured?
      errors.empty?
    end

    def comments_allowed?; false; end

    def errors
      errors = []
      if self.class.fields.detect {|f| !f[1][:optional] && params[f[0].to_s].blank? }
        errors << [:base, 'You must specify your Account, Username, Password and Project ID']
      end
      errors
    end

    def create_issue(problem, reported_by = nil)
      ErrbitUnfuddlePlugin.config(params['account'], params['username'], params['password'])
      begin
        issue_options = {
          :project_id => params['project_id'],
          :summary => "[#{ problem.environment }][#{ problem.where }] #{problem.message.to_s.truncate(100)}",
          :priority => '5',
          :status => "new",
          :description => self.class.body_template.result(binding),
          'description-format' => 'textile'
        }

        if params['milestone_id'].present?
          issue_options[:milestone_id] = params['milestone_id']
        end

        issue = ErrbitUnfuddlePlugin::Ticket.create(issue_options)
        problem.update_attributes(
          :issue_link => File.join("#{url}/tickets/#{issue.id}"),
          :issue_type => self.class.label
        )
      rescue ActiveResource::UnauthorizedAccess
        raise ActiveResource::UnauthorizedAccess,
          "Could not authenticate with Unfuddle. Please check your username and password."
      end
    end
  end
end
