alias KoombeaScraper.Repo
alias KoombeaScraper.Scraper
alias KoombeaScraper.Accounts
alias KoombeaScraper.Accounts.User
alias KoombeaScraper.Scraper.Link
alias KoombeaScraper.Scraper.Page

# If you have your own customization you'd like to include, you may add it to
# .iex.local.exs which will be ignored by git.
if File.exists?(".iex.local.exs") do
  Code.eval_file(".iex.local.exs")
end
