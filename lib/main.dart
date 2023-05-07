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
	final TextEditingController editingController = TextEditingController();
	final List<String> _lines = [];
	int editingLine = 0;

	void setEditingLine(int i) {
		editingLine = i;
		editingController.text = _lines[i];
	}

	@override
	void initState() {
		super.initState();
		_lines.add("Add some \\( \\LaTeX \\) here!");
		_lines.add(
				"This is a cool equation: \\[ \\sum_{n=0}^\\infty b^n = \\frac 1 {1-b} \\]");
		_lines.add("This line has no cool equations :(");
		_lines.add("But this is a good opportunity to try other things too though");
		_lines.add("I just don't know if it is worth it");
		_lines.add("");
		_lines.add("But you can do whatever you want you know");
		setEditingLine(3);
	}

	Future<bool> onWillPop() async {
		if (editingLine == _lines.length - 1) {
			return true;
		}
		setState(() {
			setEditingLine(_lines.length - 1);
		});
		return false;
	}

	@override
	Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: onWillPop,
			child: Scaffold(
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
													child: TeXViewDocument(_lines[i],
															style: _lines[i].trim().isEmpty
																	? const TeXViewStyle(
																			padding: TeXViewPadding.all(25))
																	: const TeXViewStyle(
																			padding: TeXViewPadding.all(7))),
												),
										],
										onTap: (id) => {
											setState(() {
												setEditingLine(int.parse(id));
											})
										},
									),
									renderingEngine: const TeXViewRenderingEngine.katex(),
								),
								TextFormField(
									keyboardType: TextInputType.multiline,
									maxLines: null,
									autofocus: true,
									controller: editingController,
									decoration: const InputDecoration(
										border: OutlineInputBorder(),
										hintText: 'Enter LaTeX equation',
									),
									onChanged: (text) {
										if (text.endsWith("\n\n")) {
											text = text.trimRight();
											setState(() {
												_lines.insert(editingLine + 1, "");
												setEditingLine(editingLine + 1);
											});
										} else {
											setState(() {
												_lines[editingLine] = text;
											});
											if (editingLine == _lines.length - 1) {
												if (text.trim().isEmpty) {
													setState(() {
														_lines.add("");
													});
												}
											}
										}
									},
									onFieldSubmitted: (text) {
										setState(() {
											_lines.add("");
											setEditingLine(_lines.length - 1);
										});
									},
								),
								TeXView(
									child: TeXViewGroup(
										children: [
											for (int i = editingLine + 1; i < _lines.length; i += 1)
												TeXViewGroupItem(
													id: i.toString(),
													child: TeXViewDocument(_lines[i],
															style: _lines[i].trim().isEmpty
																	? const TeXViewStyle(
																			padding: TeXViewPadding.all(25))
																	: const TeXViewStyle(
																			padding: TeXViewPadding.all(7))),
												),
										],
										onTap: (id) => {
											setState(() {
												setEditingLine(int.parse(id));
											})
										},
									),
									renderingEngine: const TeXViewRenderingEngine.katex(),
								),
							],
						),
					),
				),
			),
		);
	}
}
