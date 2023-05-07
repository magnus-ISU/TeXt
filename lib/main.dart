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
							for (var i = 0; i < _lines.length; i++)
								_editingFlags[i]
										? TextFormField(
												autofocus: true,
												initialValue: _lines[i],
												decoration: const InputDecoration(
													border: OutlineInputBorder(),
													hintText: 'Enter LaTeX equation',
												),
												onChanged: (text) {
													setState(() {
														_lines[i] = text;
													});
												},
												onFieldSubmitted: (text) {
													setState(() {
														_editingFlags[i] = false;
													});
													print("Done editing!");
												},
											)
										: GestureDetector(
												behavior: HitTestBehavior.translucent,
												onTapUp: (tap) {
													Offset i = tap.localPosition;
													print(i.distance.toString() + " " + i.dy.toString());
												},
												child: TeXView(
													child: TeXViewGroup(
														children: [
															TeXViewGroupItem(
																id: i.toString(),
																child: TeXViewDocument(_lines[i]),
															),
														],
														onTap: (id) => {
															print(id),
															setState(() {
																_editingFlags[int.parse(id)] = true;
															})
														},
													),
													renderingEngine: const TeXViewRenderingEngine.katex(),
												),
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
						_editingFlags.add(false);
					});
				},
				child: const Icon(Icons.add),
			),
		);
	}
}
