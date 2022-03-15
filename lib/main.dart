import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const productsGrapQL = """query products{
  products(first: 10, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail{
          url
        }
      }
    }
  }
}""";

void main() {
  final HttpLink httpLink = HttpLink("https://demo.saleor.io/graphql/");
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
    ),
  );

  var app = GraphQLProvider(client: client, child: const MyApp());

  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Graphql',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Item page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Query(
        options: QueryOptions(document: gql(productsGrapQL)),
        builder: (QueryResult result, {fetchMore, refetch}) {
          // what fetchMore, refetch do? =>
          if (result.hasException) {
            return Text(result.exception.toString());
          }
          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final productList = result.data?['products']['edges'];
          // print(productList);
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Product',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: productList.length,
                  itemBuilder: (_, index) {
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.0),
                          width: 180,
                          height: 180,
                          child: Image.network(
                            productList[index]['node']['thumbnail']['url'],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3.0),
                          child: Text(
                            productList[index]['node']['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    childAspectRatio: 0.75,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
