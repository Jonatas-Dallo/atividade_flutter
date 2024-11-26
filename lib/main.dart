import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CrudPage(),
    );
  }
}

class CrudPage extends StatefulWidget {
  @override
  _CrudPageState createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  //Controller do CRUD pro server.js
  final TextEditingController idController = TextEditingController(text: '0');
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController custoController = TextEditingController(text: '0');
  final TextEditingController vendaController = TextEditingController(text: '0');
  List<dynamic> dataList = [];

  //GET = /produtos
  //POST = /produto
  //PUT = /produto/id
  //DELETE = /produto/id

  //funções que acessam a rota e fazem suas respectivas funções, é preciso apertar o botão GET para atualizar e as ver as mudanças exceto com o Delete

  //OBS: PUT por algum motivo da tela vermelha quando é feito, mas basta clicar em voltar e apertar GET que atualiza normalmente
  //Não consegui descobrir o motivo, o erro é esse: Another exception was thrown: type 'Null' is not a subtype of type 'String'

  //GET
  Future<void> getData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/produtos'));

      if (response.statusCode == 200) {
        print('Resposta do servidor: ${response.body}');

        // salva a lista que vem na variavel dinamina criada lá em cima
        setState(() {
          dataList = json.decode(response.body);
        });
      } else {
        print('Erro ao carregar dados: ${response.statusCode} e body: ${response.body}');
      }
    } catch (error) {
      print('Erro ao realizar GET: $error');
    }
  }

  //POST
  Future<void> postData() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/produto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nomeController.text,
          'precoCusto': int.parse(custoController.text),
          'precoVenda': int.parse(vendaController.text),
          'categoria': categoriaController.text,
        }),

        // preenche com os valores que estão atualmente no controller acessavel pelo .text como no exemplo abaixo.
        // o int.parse foi colocado para salvar como INT, visto que no exemplo em server.js está como INT, suspeito que o erro do PUT esteja relacionado pois antes de mudar pra INT não dava ele

        //body: json.encode({
        //  "nome": "teste",
        //  "precoCusto": 22,
        //  "precoVenda": 33,
        //  "categoria": "azul"
        //}),

        // precoCusto e precoVenda em INT lá no server.js

        //let produtos = [
        //  { id: 1, nome: 'Produto A', precoCusto: 10, precoVenda: 20, categoria: 'Categoria 1' },
        //  { id: 2, nome: 'Produto B', precoCusto: 15, precoVenda: 30, categoria: 'Categoria 2' }
        //];
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Mensagem'),
            content: Text(data['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  getData();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {}
  }

  //PUT
  Future<void> putData() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/produto/${idController.text}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': nomeController.text,
          'precoCusto': int.parse(custoController.text),
          'precoVenda': int.parse(vendaController.text),
          'categoria': categoriaController.text,
        }),
      );

      // assim como POST manda o body pro backend e atualiza, mas por motivos que desconheço enquanto faz isso a tela ficar vermelha dando erro
      // ainda sim está funcionando, basta voltar no botão do celular e dar GET que o PUT terá sido feito, o problema é algo na hora de renderizar envolvendo TYPE que tentei descobrir mas n consegui
      

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Mensagem'),
            content: Text(data['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  getData();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Erro ao realizar PUT: $error');
    }
  }

  //DELETE
  Future<void> deleteData() async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/produto/${idController.text}'),
      );

      // o mais simples depois do GET, apenas chama o endpoint delete passando o id na rota e apaga

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Mensagem'),
            content: Text(data['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  getData();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Erro ao excluir');
      }
    } catch (error) {
      print('Erro ao realizar DELETE: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Prova'),
      ),

      // permite rolar a pagina pra baixo
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // área de input mudando os controllers
              Text('Id'),
              TextField(
                controller: idController,
                decoration: InputDecoration(),
                readOnly: true,
              ),
              SizedBox(height: 16),
              Text('Nome'),
              TextField(
                controller: nomeController,
                decoration: InputDecoration(),
              ),
              SizedBox(height: 16),
              Text('Preço Custo'),
              TextField(
                controller: custoController,
                decoration: InputDecoration(),
              ),
              SizedBox(height: 16),
              Text('Preço Venda'),
              TextField(
                controller: vendaController,
                decoration: InputDecoration(),
              ),
              SizedBox(height: 16),
              Text('Categoria'),
              TextField(
                controller: categoriaController,
                decoration: InputDecoration(),
              ),

              //botões com as funções do CRUD
              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(onPressed: getData, child: Text('GET')),
                  SizedBox(width: 5),
                  ElevatedButton(onPressed: postData, child: Text('POST')),
                  SizedBox(width: 5),
                  ElevatedButton(onPressed: putData, child: Text('PUT')),
                  SizedBox(width: 5),
                  ElevatedButton(onPressed: deleteData, child: Text('DELETE')),
                ],
              ),

              //parte que monta a lista trazida no get
              SizedBox(height: 16),
              Container(
                height: 400,
                child: ListView(
                  children: dataList.map((item) {
                    return ListTile(
                      title: Text(item['nome']),
                      subtitle: Text(item['categoria']),
                      trailing: Text(item['id'].toString()),
                      onTap: () {
                        setState(() {
                          idController.text = item['id'].toString();
                          nomeController.text = item['nome'];
                          custoController.text = item['precoCusto'].toString();
                          vendaController.text = item['precoVenda'].toString();
                          categoriaController.text = item['categoria'];
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
