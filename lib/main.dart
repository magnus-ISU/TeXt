import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

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
			darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.blue),
			themeMode: ThemeMode.system,
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

	Timer? _debounceTimer;

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
					text: "${_lines[i]} ",
					selection: TextSelection(
							baseOffset: _lines[i].length,
							extentOffset: _lines[i].length + 1));
			for (int j = i + 1; j < _lines.length - 1; j++) {
				if (_lines[j].trim().isEmpty) {
					_lines.removeAt(j);
				}
			}
			if (i == _lines.length - 2 && _lines[i].trim().isEmpty) {}
		});
	}

	void _saveFile() async {
		try {
			final file = await _localFile;
			await file.writeAsString(_lines.join('\n\n'));
		} catch (e) {
			// handle file save error
		}
	}

	void _debounceSave() {
		if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
		_debounceTimer = Timer(const Duration(milliseconds: 1500), () {
			_saveFile();
		});
	}

	Future<String> get _localPath async {
		final directory = await getApplicationDocumentsDirectory();
		return directory.path;
	}

	Future<File> get _localFile async {
		final path = await _localPath;
		return File('$path/scratch.tex');
	}

	Future<List<String>> _readLines() async {
		List<String> lines = [
			"Add some \\( \\LaTeX \\) here!",
			"This is a cool equation:\n\\[\n\\sum_{n=0}^\\infty b^n = \\frac 1 {1-b}\n\\]",
			"",
		];
		try {
			final file = await _localFile;
			if (file.existsSync()) {
				String contents = await file.readAsString();
				lines = contents.split('\n\n');
			}
			return lines;
		} catch (e) {
			return lines;
		}
	}

	@override
	void initState() {
		super.initState();
		_readLines().then((List<String> lines) {
			setState(() {
				_lines.clear();
				_lines.addAll(lines);
				setEditingLine(_lines.length - 1);
			});
		});
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
					title: const Text('TeXt'),
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
															style: const TeXViewStyle(
																	padding: TeXViewPadding.all(7))),
												),
										],
										onTap: (id) => {
											setEditingLine(int.parse(id)),
										},
									),
									style: TeXViewStyle(
										contentColor: MediaQuery.platformBrightnessOf(context) ==
														Brightness.dark
												? Colors.white70
												: Colors.black12,
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
										} else if (text.startsWith("\n\n")) {
											setState(() {
												_lines.insert(editingLine, "");
												setEditingLine(editingLine);
											});
										} else {
											setState(() {
												_lines[editingLine] = text.trim();
											});
											if (editingLine == _lines.length - 1) {
												if (text.trim().isNotEmpty) {
													setState(() {
														_lines.add("");
													});
												}
											}
											_debounceSave();
										}
									},
									onFieldSubmitted: (text) {
										setEditingLine(_lines.length - 1);
									},
								),
								TeXView(
									child: TeXViewGroup(
										children: [
											for (int i = editingLine; i < _lines.length - 1; i += 1)
												TeXViewGroupItem(
													id: i.toString(),
													child: TeXViewDocument(_lines[i],
															style: const TeXViewStyle(
																	padding: TeXViewPadding.all(7))),
												),
											TeXViewGroupItem(
												id: (_lines.length - 1).toString(),
												child: const TeXViewDocument("",
														style: TeXViewStyle(
																padding: TeXViewPadding.all(50),
																border: TeXViewBorder.only(
																		bottom: TeXViewBorderDecoration(
																	borderWidth: 2,
																	borderColor: Colors.blue,
																	borderStyle: TeXViewBorderStyle.dotted,
																)))),
											),
										],
										onTap: (id) => {
											if (editingLine != int.parse(id)) {
												setEditingLine(int.parse(id)),
											}
										},
									),
									style: TeXViewStyle(
										contentColor: MediaQuery.platformBrightnessOf(context) ==
														Brightness.dark
												? Colors.white70
												: Colors.black12,
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
