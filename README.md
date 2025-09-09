# KoombeaScraper

## Some Considerations

To implement auth logic Phoenix offers a powerful code generator (mix phx.gen.auth), but I opted for a manual, minimalist implementation for clarity and readability. The phx.gen.auth generator is excellent for production applications, but it adds a considerable amount of code (controllers, views, contexts, emails) that is not necessary for the specific requirements of this test. By implementing it manually, the authentication code is concise and focuses exclusively on registration and login.

For handling background jobs, I am using a manually created Dynamic Supervisor. In a production environment, I would use a more robust solution like Oban, which provides better queuing, retries, and visibility into job execution.

For test fixtures, I've created manual helper functions. In a larger-scale project, I would use a library like ExMachina to streamline the creation of test data and improve the maintainability of the test suite.

Migrations, I update the migration files for simplicity, but the correct way to do it is to create new migrations files