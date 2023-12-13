(module snippets
  {autoload {ls luasnip}})

(ls.add_snippets 
  "all" [(ls.snippet "autoload" 
                     [(ls.text_node 
                        ["autoload {core aniseed.core"
                         "          nvim aniseed.nvim"
                         "          str aniseed.string"
                         "          util slim.nvim"
                         "          curl plenary.curl}"
                         "          dockerai dockerai"])])
         (ls.snippet "keymap"
                     [(ls.text_node
                        "(nvim.set_keymap :v :<leader>ai \":lua require('nano-copilot').openselection()<CR>\" {})")])])
