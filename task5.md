# Task 5

data persisting, router and named routes

## description

the next task would be data persistence. For now, not in the database but in your state.

for this please take a look at the "Provider" package.

also,please take a look at the router and named routes
named routes belong to the normal Navigator package or class

the order-page can replace your main screen

app opens -> you land on the order page, you can add products and users through additional pages

as a small hint, the State is always held in the respective Controller..

## GPTs Answer (skip down for my conclusion)

Here’s an overview of the key concepts you’ve mentioned:

* * *

### **What is the Provider Package?**

The `provider` package is a state management solution in Flutter that helps manage and share application state efficiently. It is built on top of Flutter’s `InheritedWidget` and is widely regarded as one of the easiest and most effective ways to manage state in Flutter apps.

**Key Benefits:**

1. **Scoped State Management:** Makes state available only where needed, reducing unnecessary rebuilds.
2. **Easy Dependency Injection:** Dependencies can be injected and made available throughout the widget tree.
3. **Separation of Concerns:** Helps decouple business logic from UI code.

**Example Use Case:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MyApp(),
    ),
  );
}

class Counter extends ChangeNotifier {
  int value = 0;

  void increment() {
    value++;
    notifyListeners(); // Notifies listeners to rebuild
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Counter>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Counter App")),
      body: Center(child: Text('Count: ${counter.value}')),
      floatingActionButton: FloatingActionButton(
        onPressed: counter.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

* * *

### **What is Router and Named Routes?**

Flutter’s routing system is used to navigate between different pages (or screens).

1. **Router:** A mechanism that determines how navigation is handled in your app.

    * The default routing system in Flutter uses the `Navigator` class.
    * You can use custom navigation logic or a package like `go_router` for more advanced routing.
2. **Named Routes:** Named routes allow you to define and reference routes with a string identifier, improving code readability and maintainability.

**Defining Named Routes:**

```dart
void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/orders': (context) => OrderPage(),
      '/products': (context) => ProductPage(),
    },
  ));
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/orders'); // Navigate using named route
          },
          child: Text("Go to Orders"),
        ),
      ),
    );
  }
}
```

* * *

### **How Can I Save State?**

State can be saved using different mechanisms in Flutter:

#### 1\. **Using the Provider Package:**

The `Provider` package can hold and manage application state. Use `ChangeNotifier` for mutable state management.

```dart
class Cart extends ChangeNotifier {
  List<String> _items = [];

  List<String> get items => _items;

  void addItem(String item) {
    _items.add(item);
    notifyListeners(); // Notify widgets that are listening
  }
}
```

#### 2\. **Local State:**

For simple widgets, use local state by utilizing `StatefulWidget`:

```dart
class MyCounter extends StatefulWidget {
  @override
  _MyCounterState createState() => _MyCounterState();
}

class _MyCounterState extends State<MyCounter> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Counter: $_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### 3\. **Using Persistent Storage (Optional):**

For more permanent storage, use shared preferences or local databases. For now, as per your task, store data only in memory.

* * *

### **Implementation for the Task**

Here’s a basic setup for your described task:

1. The app opens with the `OrderPage`.
2. Users and products can be added via additional pages.
3. State is managed in the respective controllers.

* * *

**Main Entry Point:**

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/orders',
      routes: {
        '/orders': (context) => OrderPage(),
        '/addProduct': (context) => AddProductPage(),
        '/addUser': (context) => AddUserPage(),
      },
    );
  }
}
```

**Order Controller:**

```dart
class OrderController extends ChangeNotifier {
  final List<String> _orders = [];

  List<String> get orders => _orders;

  void addOrder(String order) {
    _orders.add(order);
    notifyListeners();
  }
}
```

**Order Page:**

```dart
class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: ListView.builder(
        itemCount: orders.orders.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(orders.orders[index]));
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addProduct",
            onPressed: () => Navigator.pushNamed(context, '/addProduct'),
            child: Icon(Icons.add_shopping_cart),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "addUser",
            onPressed: () => Navigator.pushNamed(context, '/addUser'),
            child: Icon(Icons.person_add),
          ),
        ],
      ),
    );
  }
}
```

**Add Product Page:**

```dart
class AddProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductController>(context, listen: false);
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                products.addProduct(controller.text);
                Navigator.pop(context);
              },
              child: Text("Add Product"),
            ),
          ],
        ),
      ),
    );
  }
}
```

This structure uses named routes, `Provider`, and state controllers effectively. You can expand on it as needed. Let me know if you need further assistance!

* * *

## my conclusion

as i understand **provider package:**
the provider package is something like a "state saving" package which ability is also to share the state across other widgets.

as i understand **Router and Named Routes:**
A router is a way to handle the navigation inside an app.
Named routes are as i see a simplified way to get to other pages of the app, instead of running all pages in like one app, its like "an app inside an app"

as i understand how to **persist/save the state:**
i need to utilize the provider package and use the ChangeNotifier for the state management
