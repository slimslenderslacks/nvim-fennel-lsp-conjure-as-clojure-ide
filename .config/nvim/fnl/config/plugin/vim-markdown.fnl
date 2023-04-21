(module config.plugin.vim-markdown
  {autoload {nvim aniseed.nvim
             os os}})

(set nvim.g.vim_markdown_conceal_code_blocks 1)
(set nvim.g.vim_markdown_fenced_languages ["clj=clojure"])


