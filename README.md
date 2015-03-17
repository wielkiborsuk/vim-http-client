# vim-http-client

With vim-http-client, you can make HTTP calls from Vim, using the HTTP format you already know rather than learning new command line tools fraught with complex flags and escaped quotes. You can also parse the results right in Vim, syntax highlighted the way you expect.

![Demo](https://raw.githubusercontent.com/aquach/vim-http-client/master/examples/demo.gif)

## Installation

vim-http-client requires Vim compiled with python support and the [python `requests` library](http://docs.python-requests.org/en/latest/).

To check if you have python support, try `vim --version | grep +python`.

To check if you have the `requests` library, try `python -c 'import requests'`. If nothing is printed, you have the library. Otherwise, try `pip install requests` to get it. Most distros of Ubuntu already have both Vim with python support and requests.

Once you have these, use your favorite Vim plugin manager to install `aquach/vim-http-client`.

## Usage

Put your cursor anywhere in a newline-delimited block of text and run `:HTTPClientDoRequest`. The text will be parsed and executed as a HTTP request, and its results will appear in a split.

```
# Comments start with #.
# First request.
<method> <url>
<header-name-1>: <header-value-1>
<header-name-2>: <header-value-2>
...
<header-name-n>: <header-value-n>
<body>

# Second request.
<method> <url>
<header-name-1>: <header-value-1>
<header-name-2>: <header-value-2>
...
<header-name-n>: <header-value-n>
<body>
```

Depending on where you put your cursor, the first or second request will execute. You can also substitute variables anywhere in the request:

```
# Second request.
# :foo = bar
# :asdf = 3
POST http://httpbin.org/post
{ "data": ":foo" }
```

Each variable lives in a separate line in a comment and always starts with a colon. Variables are substituted with simple string substitution.

The output appears in a new split. Syntax highlighting is interpreted from the `Content-Type` header of the result. It currently supports XML, JSON, and HTML; all others will get `ft=text`.

## Contributing

This plugin is so far very simple. Contributions, suggestions, and feedback are all welcomed!
