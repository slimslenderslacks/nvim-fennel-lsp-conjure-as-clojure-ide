(module config.init
  {autoload {core aniseed.core
             nvim aniseed.nvim
             util config.util
             str aniseed.string}})

;generic mapping leaders configuration
(nvim.set_keymap :n :<space> :<nop> {:noremap true})
(nvim.set_keymap :t :<C-h> "<c-\\><c-n><c-w>h" {})
(nvim.set_keymap :t :<C-j> "<c-\\><c-n><c-w>j" {})
(nvim.set_keymap :t :<C-k> "<c-\\><c-n><c-w>k" {})
(nvim.set_keymap :t :<C-l> "<c-\\><c-n><c-w>l" {})
(nvim.set_keymap :n :<C-h> "<c-w>h" {})
(nvim.set_keymap :n :<C-j> "<c-w>j" {})
(nvim.set_keymap :n :<C-k> "<c-w>k" {})
(nvim.set_keymap :n :<C-l> "<c-w>l" {})
;; so that terminal mode can use esc
(nvim.set_keymap :t :<ESC> "<c-\\><c-n>" {:noremap true})
(set nvim.g.mapleader ",")
(set nvim.g.maplocalleader ",")

; terminal
(nvim.set_keymap :n :<leader>term ":sp<CR>:term<CR>a" {:noremap true})

; in terminal mode c-\ c-n is Esc
(nvim.set_keymap :n :<leader>clj ":vs<CR>:term<CR>:file clj-repl<CR>aclj -A:test:cider-clj<CR><c-\\><c-n>" {:noremap true})
(nvim.set_keymap :n :<leader>bclj ":vs<CR>:buffer clj-repl<CR>" {:noremap true})
; back and forth in buffers
(nvim.set_keymap :n :<leader><tab> ":bnext<CR>" {:noremap true})
(nvim.set_keymap :n "<leader>`" ":bprev<CR>" {:noremap true})
; quit without losing windows
(nvim.set_keymap :n :<leader>q ":bp<bar>sp<bar>bn<bar>bd<CR>" {})
; close window
(nvim.set_keymap :n "<leader>wc" "<c-w>c<CR>" {:noremap true})

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
