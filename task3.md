# Task 3

Structure optimisation

## current & wanted state

as of now the **current** file structure looks like this:

```txt
lib/
    database_viewer.dart
    main.dart
    sqlmanage.dart
    web_entrypoint.dart
```

* * *
but the **wanted** structure to have cleaner code should be like this as visualisation:

```txt
lib/
    screens/
        main_screen.dart

    controllers/
        main_controller.dart

    services/
        sqlmanage.dart
        web_entrypoint.dart
```

* * *
a litttle overview what each folder does:

- **screens:** these are for visual output, like displaying things
- **controllers:** these handle the logic that is used and executed
- **services:** these are for external accesses, handling files, and/or anything that serves a purpose that helps logic and such to execute

the reason why to split up main.dart into the visual (screen) part and the logic (controller) part: it enables the dev to adapt the code better than having all the code of different topics/tasks in one file.

## Task State

DONE
