# KoombeaScraper

## Some Considerations

To implmente auth logic Phoenix offers a powerful code generator (mix phx.gen.auth), but I opted for a manual, minimalist implementation for clarity and readability. The phx.gen.auth generator is excellent for production applications, but it adds a considerable amount of code (controllers, views, contexts, emails) that is not necessary for the specific requirements of this test. By implementing it manually, the authentication code is concise and focuses exclusively on registration and login.

In a large-scale production project, my default choice would be to use the official generator to leverage its robustness and complete feature set. However, for the context of this challenge, a custom-tailored approach was more appropriate.