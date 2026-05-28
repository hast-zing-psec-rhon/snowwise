namespace :condition_scores do
  desc "Refresh the saved condition score for every resort"
  task refresh: :environment do
    refreshed_count = Conditions::RefreshAllScores.call

    puts "Refreshed #{refreshed_count} resort condition scores."
  end
end
