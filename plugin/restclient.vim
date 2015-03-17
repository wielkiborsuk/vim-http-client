import neovim
import re
import requests

METHOD_REGEX = re.compile("^(GET|POST|DELETE|PUT|HEAD|OPTIONS|PATCH) (.*)$")
HEADER_REGEX = re.compile("^([^ :]+): (.*)$")
VAR_REGEX = re.compile("^(:[^: ]+)\\s+=\\s+(.+)$")

# TODO: add in-line comments
# TODO: add highlighting
# TODO: add automatic json formatting
# TODO: optimize?
# TODO: make async?

@neovim.plugin
class RestClient(object):
    def __init__(self, vim):
        self.vim = vim
        # TODO: make one scratch buffer per file in rest_client mode
        self.scratch_buffer = None

    def message(self, msg):
        if type(msg) is not str:
            msg = str(msg)
        self.vim.command("echo '{}'".format(msg.replace("'", "''")))

    @staticmethod
    def is_comment(line):
        return line.startswith("#")

    @staticmethod
    def strip_comments(line):
        return line.split("#")[0]

    @staticmethod
    def replace_vars(string, variables):
        for var, val in variables.items():
            string = string.replace(var, val)
        return string

    @staticmethod
    def read_vars(buf):
        return dict((m.groups() for m in (VAR_REGEX.match(l) for l in buf) if m))

    @staticmethod
    def find_block(buf, line_num):
        length = len(buf)
        block_start = line_num
        while block_start > 0 and not RestClient.is_comment(buf[block_start]):
            block_start -= 1
        while block_start < length and (RestClient.is_comment(buf[block_start]) or not buf[block_start]):
            block_start += 1
        # block_start should now be on the first non-comment, non-empty line in the block

        block_end = line_num
        while block_end < length and not RestClient.is_comment(buf[block_end]):
            block_end += 1
        while block_end > 0 and RestClient.is_comment(buf[block_end]):
            block_end -= 1
        # block_end should now be on the last non-comment line in the block

        block = buf[block_start : block_end + 1]
        return block

    @neovim.command("RestClient", sync=True)
    def rest_client(self):
        win = self.vim.current.window
        line_num = win.cursor[0] - 1
        buf = win.buffer
        block = RestClient.find_block(buf, line_num)

        # TODO: consider only using variables defined above/in the current block
        variables = RestClient.read_vars(buf)

        method_url_match = METHOD_REGEX.match(block[0])
        if not method_url_match:
            self.message("could not find method/url!")
            return
        method, url = method_url_match.groups()
        url = RestClient.replace_vars(url, variables)

        headers = {}
        parse_line = 1
        while (parse_line < len(block)):
            header_match = HEADER_REGEX.match(block[parse_line])
            if header_match:
                header_name, header_value = header_match.groups()
                headers[header_name] = RestClient.replace_vars(header_value, variables)
                parse_line += 1
            else:
                break

        # skip blank lines
        while (parse_line < len(block) and re.match("^\s*$", block[parse_line])):
            parse_line += 1

        data = "\n".join(block[parse_line:])
        data = RestClient.replace_vars(data, variables)

        response = requests.request(method, url, headers=headers, data=data)
        display = (response.text.split("\n") +
                   ["", "// status code: {}".format(response.status_code)] +
                   ["// {}: {}".format(k, v) for k, v in response.headers.items()])
        self.scratch_buffer_with_contents(display)

    def scratch_buffer_with_contents(self, contents):
        if not self.scratch_buffer:
            self.vim.command("vnew")
            self.vim.command("setlocal buftype=nofile") # make it into a scratch buffer
            self.vim.command("set filetype=restclient-response")
            self.scratch_buffer = self.vim.current.buffer
        self.scratch_buffer[:] = contents


    # @neovim.autocmd('BufEnter', pattern='*.py', eval='expand("<afile>")',
    #                 sync=True)
    # def autocmd_handler(self, filename):
    #     self._increment_calls()
    #     self.vim.current.line = (
    #         'Autocmd: Called %s times, file: %s' % (self.calls, filename))

    # @neovim.function('Func')
    # def function_handler(self, args):
    #     self._increment_calls()
    #     self.vim.current.line = (
    #         'Function: Called %d times, args: %s' % (self.calls, args))

    # def _increment_calls(self):
    #     if self.calls == 5:
    #         raise Exception('Too many calls!')
    #     self.calls += 1

# def find(lst, pred):
#     for i, elem in enumerate(lst):
#         if pred(elem):
#             return i
#     return None

# def rfind(lst, pred):
#     for i, elem in enumerate_reversed(lst):
#         if pred(elem):
#             return i
#     return None

# def enumerate_reversed(lst):
#    for index in reversed(xrange(len(lst))):
#       yield index, lst[index]
