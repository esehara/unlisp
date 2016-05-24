# Unlisp -- Ultra minimal Lisp

## Perpose

(TODO)

# Specification

## Base by list

`Unlisp` uses `list` this language supported, because We have not to make `lexer`.

Example:

```rb
# (+ 1 1)
["+", "1", "1"]
```

## Support types

`Unlisp` only supports types are `Integer`, `String`, `Function`, `List`. Yes, I know Lisp has more type, but It's no nessesary to make unlisp.

```rb
["type", "1"] # => Int
["type", "Hello, Unlisp"] # => String
["type", "+"] # => Function
["type", ["list" "1" "2" "3"]] => List
```

## Syntax

### Function

`Unlisp` only supports `def` keyword and `fn`. `def` means define variable, and `fn` is lambda like function.

```
(def <name> <body>)
(fn  <formal parameters> <body>)
```

Example:

```rb
["def", "x", "1"]
# fn closure
["fn", ["x"], ["fn", ["y"], ["+" "x" "y"]]]]
["def", "plus-one", ["fn" ["x"] ["+" "x" "1"]]]
```
