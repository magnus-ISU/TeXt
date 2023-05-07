import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'WYSIWYG Text Editor with LaTeX Support',
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: MyHomePage(),
		);
	}
}

class MyHomePage extends StatefulWidget {
	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	final TextEditingController _textEditingController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('WYSIWYG Text Editor with LaTeX Support'),
			),
			body: Padding(
				padding: const EdgeInsets.all(8.0),
				child: SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							TextField(
								controller: _textEditingController,
								keyboardType: TextInputType.multiline,
								maxLines: null,
								decoration: const InputDecoration(
									hintText: 'Enter text with inline LaTeX equations',
								),
								onChanged: (text) {
									setState(() {});
								},
							),
							const SizedBox(height: 16.0),
							TeXView(
								child: TeXViewColumn(children: [
									TeXViewDocument(_textEditingController.text),
								]),
								renderingEngine: const TeXViewRenderingEngine.katex(),
							),
						],
					),
				),
			),
		);
	}
}
