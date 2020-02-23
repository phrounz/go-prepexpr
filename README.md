**go-prepexpr** is an experimental Go preprocessor, coded in Perl, intended to add functional programming and expressiveness to Go.

The idea is that:
- The original code should compile (because I usually use go-plus on Atom and I want no error while editing).
  Hence prepexpr/prepexpr.go which is a "fake" package intended to deceive the compiler, it do not much except some arguments checking.
- The generated code should compile AND work.

### To test:

Don't simply `go run test.go` ! This will not work (even if it compile)!

Instead:

```
  $ mkdir generated_code
  $ perl prepexpr.pl test.go generated_code/test.go && go run generated_code/test.go
```
Note: on Windows, it requires to install Perl, for example using [Strawberry Perl](http://strawberryperl.com/)

### Disclaimer and issues

Note that it is a pretty bold and experimental package and is not well suited to production!!

Current problems:
  - The code generator is currently not able to detect comments or strings e.g. `/* prepexpr.Foo "prepexpr.Foo" */`
  - A prepexpr.Foo(...) statement must completely fit into a line of code.
  - You cannot nest prepexpr.Foo(...) statements.
  - You should now be able to have several prepexpr.Foo(...) statements in the same line of code, but this is not fully tested.
  - Issue with commas, e.g. not working: prepexpr.Ternary(true, []string{"my","list"}, []string{}).([]string)
  - Many other problems
