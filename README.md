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
  - Can generate a compilation error "unused variable" if a variable declared outside a snippet is only used in a snippet.
  - The code generator is currently not able to detect comments, strings e.g. `/* prepexpr.Foo "prepexpr.Foo" */`
  - ```(.*)``` may eat several prepexpr.Foo() expressions, so you cannot have several of them on the same line of code,
    and not nest them.
  - Many other problems
