import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'TeXt',
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
		setState(() {
			for (int j = 0; j < i; j++) {
				if (_lines[j].trim().isEmpty) {
					_lines.removeAt(j);
					i--;
				}
			}
			editingLine = i;
			editingController.value = TextEditingValue(
				text: _lines[i],
				selection: TextSelection.collapsed(offset: _lines[i].length, affinity: TextAffinity.downstream),
			);
			for (int j = i + 1; j < _lines.length - 1; j++) {
				if (_lines[j].trim().isEmpty) {
					_lines.removeAt(j);
				}
			}
		});
	}

	@override
	void initState() {
		super.initState();
		_lines.add("Add some \\( \\LaTeX \\) here!");
		_lines.add("This is a cool equation:\n\\[\n\\sum_{n=0}^\\infty b^n = \\frac 1 {1-b}\n\\]");
		_lines.add("");
		setEditingLine(_lines.length - 1);
	}

	Future<bool> onWillPop() async {
		if (editingLine == _lines.length - 1) {
			return true;
		}
		setEditingLine(_lines.length - 1);
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
											setEditingLine(int.parse(id)),
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
										hintText: 'Enter LaTeX',
									),
									onChanged: (text) {
										if (text.endsWith("\n\n")) {
											setState(() {
												_lines.insert(editingLine + 1, "");
												setEditingLine(editingLine + 1);
											});
										} else {
											setState(() {
												_lines[editingLine] = text.trimRight();
											});
											if (editingLine == _lines.length - 1) {
												if (text.trim().isNotEmpty) {
													setState(() {
														_lines.add("");
													});
												}
											}
										}
									},
									onFieldSubmitted: (text) {
										setEditingLine(_lines.length - 1);
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
											setEditingLine(int.parse(id)),
										},
									),
									renderingEngine: const TeXViewRenderingEngine.katex(),
								),
								GestureDetector(
									child: const Padding(padding: EdgeInsets.all(30)),
									onTap: () {
										setEditingLine(_lines.length - 1);
									},
								),
							],
						),
					),
				),
			),
		);
	}
}
