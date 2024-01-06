#!/usr/bin/env python3

# See https://github.com/tobywf/pasteboard

from   appscript import app
from   commonpy.network_utils import net
import json
import pasteboard
import sys

bbt_url = 'http://localhost:23119/better-bibtex/json-rpc'

# pb = pasteboard.Pasteboard()
# text = pb.get_contents()

app = app('DEVONthink 3')
if not app.isrunning():
    exit('DEVONthink is not running')

windows = app.think_window()
front_window = windows[0]
selected_docs = front_window.selection()

selected = selected_docs[0]
url = selected.URL()

# zotero://select/library/items/5A94F2PP
if url.startswith('zotero:'):
    key = url.split('/')[-1]

    headers = {'Content-Type': 'application/json', 'Accept' : 'application/json'}
    data = ('{"jsonrpc": "2.0", "method": "items.citationkey", '
            + '"params": [["' + key + '"]] }')

    (response, error) = net('post', bbt_url, headers = headers, data = data)
    if not error:
        bbt_output = json.loads(response.text)
        if 'result' in bbt_output and key in bbt_output['result']:
            print(bbt_output['result'][key])
            sys.exit(0)

print('no zotero URL in clipboard')
