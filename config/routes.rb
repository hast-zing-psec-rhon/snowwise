Rails.application.routes.draw do
  # Render uses this endpoint as the production health check.
  # Rails::HealthController returns 200 when the app boots successfully.
  get("up", to: "rails/health#show", as: :rails_health_check)

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })

  root("resorts#index")
  get("/resort", to: "resorts#index")
  get("/resorts", to: "resorts#index", as: :resorts)
  get("/map", to: "maps#show", as: :map)
end
