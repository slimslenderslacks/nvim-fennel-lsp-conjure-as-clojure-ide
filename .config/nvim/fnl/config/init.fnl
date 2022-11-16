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
(nvim.set_keymap :n :<leader>term ":sp<CR>:term<CR>a" {:noremap true})

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
