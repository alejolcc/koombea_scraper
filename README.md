# KoombeaScraper

This is a web scraping application built with the Phoenix web framework for Koombea.

## Some Considerations

Here are some design choices and considerations made during development.

### Authentication
To implement auth logic Phoenix offers a powerful code generator (`mix phx.gen.auth`), but I opted for a manual, minimalist implementation for clarity and readability. The `phx.gen.auth` generator is excellent for production applications, but it adds a considerable amount of code (controllers, views, contexts, emails) that is not necessary for the specific requirements of this test. By implementing it manually, the authentication code is concise and focuses exclusively on registration and login.

### Background Jobs
For handling background jobs, I am using a manually created `GenServer` background job process. In a production environment, I would use a more robust solution like `Oban`, which provides better queuing, retries, and visibility into job execution.

### Test Fixtures
For test fixtures, I've created manual helper functions. In a larger-scale project, I would use a library like `ExMachina` to streamline the creation of test data and improve the maintainability of the test suite.

### Migrations
I update the migration files for simplicity, but the correct way to do it is to create new migration files.

### Pagination
The backend logic handles params to perform queries with pagination, but a proper pagination UI was not implemented as the instructions indicated it was not a priority.

## Setup

### Prerequisites

*   **asdf**: A command-line tool to manage multiple language runtime versions.
*   **Docker**: To run a PostgreSQL database.

### 1. Install Elixir and Erlang with asdf
Once `asdf` is installed, add the Elixir and Erlang plugins:

```shell
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
```

Now, install the Elixir and Erlang versions specified in the `.tool-versions` file:

```shell
asdf install
```

### 2. Start PostgreSQL with Docker
To run the application, you need a PostgreSQL database. You can easily start one using Docker:

```shell
docker run -d --name koombea_scraper_db -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres
```
This command will start a PostgreSQL container named koombea_scraper_db with the password postgres, and it will be accessible on port 5432.o

### 3. Configure and Run the Application
Install dependencies:

```shell
mix deps.get
```

Create and migrate the database:

```shell
mix ecto.reset
```

Start the Phoenix server:
```shell
mix phx.server
```

Now you can visit `localhost:4000` from your browser.

### 4. Using Docker

There is a docker compose with the db and the app server. You can start using 

Start the Phoenix server:
```shell
docker-compose up --build
```