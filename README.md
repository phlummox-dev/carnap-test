
# carnap-test

A docker image for testing [Carnap](https://github.com/gleachkr/Carnap).

Installs build tools (e.g., ghcjs) and removes dependencies on PostgreSQL.
(Instead, an SQLite database is used.)

## instructions

Assuming you have Docker installed:

-   Pull and run the docker image, exposing port 3000:

    ```
    docker pull phlummox/carnap-test:0.1
    docker -D run -p 3000:3000 -it --rm phlummox/carnap-test:0.1
    ```
-   Go to <http://localhost:3000> in your browser.
-   The project may take a while to build; once it does, a welcome
    screen will display in your browser.
-   Register a new user with the ID "`gleachkr@gmail.com`".
-   Go to <http://localhost:3000/master_admin>, and promote the user
    to an instructor.
-   Click on the email address in the top-right corner of the page;
    this will take you to the user page, from which you can go to
    the "Instructor" page if desired.
-   Alternatively, you can explore the exercises included in the
    [Book](http://localhost:3000/book) link.


