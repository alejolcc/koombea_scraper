defmodule KoombeaScraper.Repo.Migrations.CreatePagesAndLinks do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add :title, :string
      add :url, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:pages, [:url])

    create table(:links) do
      add :name, :string
      add :url, :string
      add :page_id, references(:pages, on_delete: :nothing)

      timestamps()
    end
  end
end
