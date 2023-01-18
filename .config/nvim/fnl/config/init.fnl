(module config.init
  {autoload {core aniseed.core
             nvim aniseed.nvim
             util config.util
             str aniseed.string}})

; LEADERS!!
(set nvim.g.mapleader ",")
(set nvim.g.maplocalleader ",")

; Movement
; in terminal mode c-\ c-n is Esc
(nvim.set_keymap :n :<space> :<nop> {:noremap true})
(nvim.set_keymap :t :<C-h> "<c-\\><c-n><c-w>h" {})
(nvim.set_keymap :t :<C-j> "<c-\\><c-n><c-w>j" {})
(nvim.set_keymap :t :<C-k> "<c-\\><c-n><c-w>k" {})
(nvim.set_keymap :t :<C-l> "<c-\\><c-n><c-w>l" {})
(nvim.set_keymap :n :<C-h> "<c-w>h" {})
(nvim.set_keymap :n :<C-j> "<c-w>j" {})
(nvim.set_keymap :n :<C-k> "<c-w>k" {})
(nvim.set_keymap :n :<C-l> "<c-w>l" {})

; Resizing
(nvim.set_keymap :n :<C-Up> "resize -2<CR>" {})
(nvim.set_keymap :n :<C-Down> "resize +2<CR>" {})
(nvim.set_keymap :n :<C-Left> ":vertical resize -2<CR>" {})
(nvim.set_keymap :n :<C-Right> ":vertical resize +2<CR>" {})
(nvim.set_keymap :t :<C-Up> "<cmd>resize -2<CR>" {})
(nvim.set_keymap :t :<C-Down> "<cmd>resize +2<CR>" {})
(nvim.set_keymap :t :<C-Left> "<cmd>:vertical resize -2<CR>" {})
(nvim.set_keymap :t :<C-Right> "<cmd>:vertical resize +2<CR>" {})

; Buffers and Tabs
(nvim.set_keymap :n :<TAB> ":bn<CR>" {})
(nvim.set_keymap :n :<S-TAB> ":bp<CR>" {})
(nvim.set_keymap :n :<leader>bd ":bd<CR>" {})
; close window
(nvim.set_keymap :n "<leader>wc" "<c-w>c<CR>" {:noremap true})

; TERMINAL
;; so that terminal mode can use esc
(nvim.set_keymap :t :<ESC> "<c-\\><c-n>" {:noremap true})
; terminal
(nvim.set_keymap :n :<leader>term ":sp<CR>:term<CR>a" {:noremap true})

; REPL
(nvim.set_keymap :n :<leader>clj ":vs<CR>:term<CR>:file clj-repl<CR>aclj -A:test:cider-clj<CR><c-\\><c-n>" {:noremap true})
(nvim.set_keymap :n :<leader>cljc ":ConjureConnect<CR>" {:noremap true})
(nvim.set_keymap :n :<leader>bclj ":vs<CR>:buffer clj-repl<CR>" {:noremap true})
; quit without losing windows
(nvim.set_keymap :n :<leader>q ":bp<bar>sp<bar>bn<bar>bd<CR>" {})

;don't wrap lines
(nvim.ex.set :nowrap)
(nvim.ex.set :splitright)
(nvim.ex.set :splitbelow)
(nvim.ex.set :number)

;sets a nvim global options
(let [options
      {;settings needed for compe autocompletion
       :completeopt "menuone,noselect"
       ;case insensitive search
       :ignorecase true
       ;smart search case
       :smartcase true
       ;shared clipboard with linux
       :clipboard "unnamedplus"}]
  (each [option value (pairs options)]
    (core.assoc nvim.o option value)))

;import plugin.fnl
(require :config.plugin)
