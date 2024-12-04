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
        tables_screen.dart

    controllers/
        main_controller.dart
        tables_controller.dart

    services/
        platform_service.dart
        sqlmanage.dart
        web_entrypoint.dart
    
    models/
        base_table.dart
        orders_table.dart
        products_table.dart
        users_table.dart
```

* * *
a litttle overview what each folder does:

- **screens:** these are for visual output, like displaying things
- **controllers:** these handle the logic that is used and executed
- **services:** these are for external accesses, handling files, and/or anything that serves a purpose that helps logic and such to execute
- **models:** these are the frames for the tables that are created with the database manager, read, and written to. they will be imported in [sqlmanage.dart]

the reason why to split up main.dart into the visual (screen) part and the logic (controller) part: it enables the dev to adapt the code better than having all the code of different topics/tasks in one file.

## each part telling their prupose

Screen:
"I show you what I see. If I see a state, I display it as well, but I have no idea how it is executed."

Controller:
"I know how it is executed, but I can't see it. I know where to get the information, but I don’t care how, as long as I can read it."

Service:
"I have no idea how it is executed. I can only talk to a third party, and provide the Controller with information in a readable form, but I have no interest in or understanding of what this information is used for."

## Task State

DONE
