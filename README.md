# vim-http-client

Make HTTP requests from Vim with the HTTP format you already know, rather than wrestling with `curl -X POST -b cookie=$1 -F csrf_token=$2 -F "request={\"user_id\":123}" http://example.org`! Then parse the results right in Vim, syntax highlighted the way you expect!

![Demo](https://raw.githubusercontent.com/aquach/vim-http-client/master/examples/demo.gif)

See `examples/examples.txt` for other examples.

## Installation

vim-http-client requires Vim compiled with python support and the [python `requests` library](http://docs.python-requests.org/en/latest/).

You likely have Python support, but you can check with `vim --version | grep +python`. MacVim comes with Python support.

To check if you have the `requests` library, try `python -c 'import requests'`. If you get an error, try `pip install requests` to get the library. Many distros ship Python support with Vim and the `requests` library with Python.

Once you have these, use your favorite Vim plugin manager to install `aquach/vim-http-client`, or copy `plugin` and `doc` into your `.vim` folder.

## Usage

Put your cursor anywhere in a newline-delimited block of text and hit `<Leader>tt`. `vim-http-client` will parse the text into a HTTP request, execute it, and display its results will appear in a split. You can also directly invoke the HTTP client with `:call HTTPClientDoRequest()<cr>`. The format mirrors HTTP's format:


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
POST http://httpbin.org/post
{
  "data": ":foo",
  "otherkey": "hello"
}
```

Each variable lives in a separate commented line. Variables beginning with `:` are request variables only considered in the request block they live in. Variables beginning with `$` are global variables that affect all requests in the entire buffer. Local variables always override global variables.

```
# $endpoint = http://httpbin.org

GET $endpoint/get

# :request_var = 3
POST $endpoint/post

GET $endpoint/resource
```

Variables are substituted with simple string substitution.

If you'd like to pass form-encoded data, set your body like this:

```
<key-1>=<value-1>
<key-2>=<value-2>
...
<key-n>=<value-n>
```

You can also send files using absolute path to file: `!file(PATH_TO_FILE)` or by simply providing it's content: `!content(my file content)`.

Example:
```
POST http://httpbin.org/post
foo=vim rocks
bar=!file(/tmp/my_file.txt)
baz=!content(sample content)
```

You can also recall the last request by `<Leader>tr`. This works from anywhere, since the request parameters are saved in a global vim variable `g:http_client_last_request`. It's also possible to call the command directly as :call HTTPClientRepeatRequest()<cr>. Of course this only works after at least one call.


See `examples/examples.txt` for more examples.

The output appears in a new split. Based on the `Content-Type` header of the HTTP response, vim-http-client chooses a filetype for syntax highlighting. It currently supports XML, JSON, and HTML; all others will get `ft=text`.

## Configuration

#### g:http_client_bind_hotkey (default 1)

Controls whether or not `<Leader>tt` will run the HTTP client. Regardless of the setting, vim-http-client will not overwrite your existing `<Leader>tt` mapping if it exists.

#### g:http_client_json_ft (default 'javascript')

Sets the vim filetype when vim-http-client detects a JSON response. Though JSON-specific syntax highlighting like [vim-json](https://github.com/elzr/vim-json) provides prettier highlighting than the default Javascript highlighting, Javascript highlighting comes with Vim and is therefore a safer default. Use this setting to configure the filetype to your liking.

#### g:http_client_json_escape_utf (default 1)

By default json.dumps will escape any utf8 characters beyond ascii range. This option (if set to 0) allows you to get the actual special characters instead of \uxxxx encoded ones.

#### g:http_client_result_vsplit (default 1)

By default the request result appears in a vertical split. Setting this option to 0 displays the result in a horizontal split.


## Contributing

This plugin is currently quite simple. Contributions, suggestions, and feedback are all welcomed!
