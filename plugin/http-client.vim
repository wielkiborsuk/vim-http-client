if !has('python')
  echo 'Error: this plugin requires vim compiled with python support.'
  finish
endif

execute 'pyfile ' . fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/http_client.py'

function! s:DoHTTPRequest()
  python do_request_from_buffer()
endfunction

command! -nargs=0 HTTPClientDoRequest call <SID>DoHTTPRequest()
