defmodule KoombeaScraper.Repo.Migrations.CreatePagesAndLinks do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :title, :text
      add :url, :text
      add :status, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:pages, [:url])

    create table(:links) do
      add :name, :text
      add :url, :text
      add :page_id, references(:pages, on_delete: :delete_all)
    end

    create unique_index(:links, [:page_id, :url, :name])
  end
end
