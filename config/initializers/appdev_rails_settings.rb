# AppDev Rails Settings (Phase 1 - Beginner)
# Consolidated Rails configuration for local learning environments only.
#
# Security note: this file intentionally does *not* relax Rails defaults in
# production. Public deployments should keep CSRF protection, open-redirect
# protection, and strict browser framing behavior enabled.

if Rails.env.development? || Rails.env.test?
  Rails.application.configure do
    # Allow unsafe redirects for beginner local exercises only.
    config.action_controller.raise_on_open_redirects = false

    # Allow envoy.fyi to frame local learning apps.
    config.content_security_policy do |policy|
      policy.frame_ancestors :self, "https://envoy.fyi"
    end
  end

  # Phase 1 beginner-friendly settings for local/test work only.
  Rails.application.config.action_controller.default_protect_from_forgery = false
  Rails.application.config.active_record.belongs_to_required_by_default = false
end
