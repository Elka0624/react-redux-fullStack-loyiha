"use strict"
const clipboardy = require( "clipboardy" );
const vscode = require( "vscode" );
// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
const convertToSetter = ( text ) => {
	const _arr = Array.from( text );
	_arr.unshift( _arr.shift().toLocaleUpperCase() )
	return ['set'].concat( _arr ).join('');
}
/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
	const { window, commands, Position } = vscode;
	const useStateSetter = vscode.commands.registerCommand('extension.useStateSetter', () => {
		const editor = window.activeTextEditor;
		if( !editor ) return window.showErrorMessage( 'Need to using on activeTextEditor' );
		const clipboard = clipboardy.readSync();
		const selectedText = editor.document.getText( editor.selection )
		const isSelect = selectedText.length > 0;

		const result = convertToSetter( isSelect ? selectedText : clipboard );

		editor.edit(builder => {
			if( isSelect ) builder.delete(editor.selection)
			builder.insert(editor.selection.start, result)
		})
	});
	const useStateSnippet = vscode.commands.registerCommand('extension.useStateSnippet', () => {
		const editor = window.activeTextEditor;
		if( !editor ) return window.showErrorMessage( 'Need to using on activeTextEditor' );
		
		const clipboard = clipboardy.readSync();
		const selectedText = editor.document.getText( editor.selection )
		const isSelect = selectedText.length > 0;

		const resultGenerate = ( $1, $2 ) => {
			return `const [ ${$1}, ${$2} ] = React.useState\${2:<$3>}(\${1});\${0}`
		}

		window.showInputBox()
    .then(stateName => {
			// hello
			const _setter = convertToSetter( stateName );
			const result = resultGenerate( stateName, _setter );
			editor.edit(builder => {
				if( isSelect ) builder.delete(editor.selection)
				editor.insertSnippet(new vscode.SnippetString(result));
			})
		})
	});


	context.subscriptions.push( useStateSetter, useStateSnippet );
}


// this method is called when your extension is deactivated
function deactivate() {}

module.exports = {
	activate,
	deactivate
}
