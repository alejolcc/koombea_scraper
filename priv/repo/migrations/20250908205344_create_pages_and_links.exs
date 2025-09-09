defmodule KoombeaScraper.Repo.Migrations.CreatePagesAndLinks do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :title, :string
      add :url, :string
      add :status, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:pages, [:url])

    create table(:links) do
      add :name, :string
      add :url, :string
      add :page_id, references(:pages, on_delete: :delete_all)
    end
  end
end
