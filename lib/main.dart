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
	final List<String> _lines = [];
	int editingLine = 0;

	@override
	void initState() {
		super.initState();
		_lines.add("Add some \\( \\LaTeX \\) here!");
		editingLine = 1;
	}

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
							TeXView(
								child: TeXViewGroup(
									children: [
										for (int i = 0; i < editingLine; i += 1)
											TeXViewGroupItem(
												id: i.toString(),
												child: TeXViewDocument(_lines[i]),
											),
									],
									onTap: (id) => {
										print(id),
										setState(() {
											editingLine = int.parse(id);
										})
									},
								),
								renderingEngine: const TeXViewRenderingEngine.katex(),
							),
							TextFormField(
								autofocus: true,
								initialValue: _lines[editingLine],
								decoration: const InputDecoration(
									border: OutlineInputBorder(),
									hintText: 'Enter LaTeX equation',
								),
								onChanged: (text) {
									setState(() {
										_lines[editingLine] = text;
									});
								},
								onFieldSubmitted: (text) {
									setState(() {
										_lines.add("");
										editingLine = _lines.length - 1;
									});
									print("Done editing!");
								},
							),
							TeXView(
								child: TeXViewGroup(
									children: [
										for (int i = editingLine + 1; i < _lines.length; i += 1)
											TeXViewGroupItem(
												id: i.toString(),
												child: TeXViewDocument(_lines[i]),
											),
									],
									onTap: (id) => {
										print(id),
										setState(() {
											editingLine = int.parse(id);
										})
									},
								),
								renderingEngine: const TeXViewRenderingEngine.katex(),
							),
							const SizedBox(height: 16.0),
						],
					),
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					setState(() {
						_lines.add("new line");
						editingLine = _lines.length - 1;
					});
				},
				child: const Icon(Icons.add),
			),
		);
	}
}
