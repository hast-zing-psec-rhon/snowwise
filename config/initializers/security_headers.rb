# Baseline browser security headers for public deployments.
# Keep this conservative: the current app is server-rendered and does not need
# camera, microphone, geolocation, cross-origin embedding, or referrer leakage.
Rails.application.configure do
  config.action_dispatch.default_headers.merge!(
    "X-Frame-Options" => "DENY",
    "X-Content-Type-Options" => "nosniff",
    "Referrer-Policy" => "strict-origin-when-cross-origin",
    "Permissions-Policy" => "camera=(), microphone=(), geolocation=(), payment=(), usb=()"
  )

  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.font_src :self, :data
    policy.img_src :self, :data, :https, "https://tile.openstreetmap.org"
    policy.object_src :none
    policy.script_src :self, :https, "https://unpkg.com"
    policy.style_src :self, :https, "https://unpkg.com", :unsafe_inline
    policy.connect_src :self
    policy.frame_ancestors :none
  end

  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
