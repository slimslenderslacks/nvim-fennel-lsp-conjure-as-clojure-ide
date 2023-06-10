(module config.plugin.lspconfig
  {require {custom config.custom}
   autoload {nvim aniseed.nvim
             lsp lspconfig
             cmplsp cmp_nvim_lsp
             os os}})

;symbols to show for lsp diagnostics
(defn define-signs
  [prefix]
  (let [error (.. prefix "SignError")
        warn  (.. prefix "SignWarn")
        info  (.. prefix "SignInfo")
        hint  (.. prefix "SignHint")]
  (vim.fn.sign_define error {:text "x" :texthl error})
  (vim.fn.sign_define warn  {:text "!" :texthl warn})
  (vim.fn.sign_define info  {:text "i" :texthl info})
  (vim.fn.sign_define hint  {:text "?" :texthl hint})))

(if (= (nvim.fn.has "nvim-0.6") 1)
  (define-signs "Diagnostic")
  (define-signs "LspDiagnostics"))

;(nvim.command "au BufNewFile,BufRead */datalog/*/*.edn set filetype=datalog")

;server features
(let [handlers {"textDocument/publishDiagnostics"
                (vim.lsp.with
                  vim.lsp.diagnostic.on_publish_diagnostics
                  {:severity_sort true
                   :update_in_insert false
                   :underline true
                   :virtual_text false})
                "textDocument/hover"
                (vim.lsp.with
                  vim.lsp.handlers.hover
                  {:border "single"})
                "textDocument/signatureHelp"
                (vim.lsp.with
                  vim.lsp.handlers.signature_help
                  {:border "single"})
                "textDocument/codeLens"
                (vim.lsp.with
                  vim.lsp.codelens.on_codelens
                  {:border "single"})}
      capabilities (cmplsp.default_capabilities)
      on_attach (fn [client bufnr]
                  (do
                    (nvim.buf_set_keymap bufnr :n :gd "<Cmd>lua vim.lsp.buf.definition()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :K "<Cmd>lua vim.lsp.buf.hover()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>ld "<Cmd>lua vim.lsp.buf.declaration()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lt "<cmd>lua vim.lsp.buf.type_definition()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lh "<cmd>lua vim.lsp.buf.signature_help()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>ln "<cmd>lua vim.lsp.buf.rename()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>le "<cmd>lua vim.diagnostic.open_float()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>ll "<cmd>lua vim.diagnostic.setloclist()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lf "<cmd>lua vim.lsp.buf.format()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :v :<leader>lf "<cmd>lua vim.lsp.buf.format()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lj "<cmd>lua vim.diagnostic.goto_next()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lk "<cmd>lua vim.diagnostic.goto_prev()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>la "<cmd>lua vim.lsp.buf.code_action()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :v :<leader>la "<cmd>lua vim.lsp.buf.range_code_action()<CR> " {:noremap true})
                    (nvim.buf_set_keymap bufnr :n "<cmd>." "<cmd>lua vim.lsp.buf.range_code_action()<CR> " {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<alt>. "<cmd>lua vim.lsp.buf.range_code_action()<CR> " {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lcld "<cmd>lua vim.lsp.codelens.refresh()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lclr "<cmd>lua vim.lsp.codelens.run()<CR>" {:noremap true})
                    ;telescope
                    (nvim.buf_set_keymap bufnr :n :<leader>lw ":lua require('telescope.builtin').diagnostics()<cr>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>lr ":lua require('telescope.builtin').lsp_references()<cr>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>li ":lua require('telescope.builtin').lsp_implementations()<cr>" {:noremap true})
                    ;; start tailing lsp log
                    (nvim.buf_set_keymap bufnr :n :<leader>lx ":lua require('config.custom').tail_server_info()<cr>" {:noremap true})
                    ))]

  ;; To add support to more language servers check:
  ;; https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
  ;; typescript
  (lsp.tsserver.setup {:on_attach on_attach
                       :handlers handlers
                       :capabilities capabilities})


  ;; dockerfiles
  ;(lsp.dockerls.setup {:cmd  ["npx" "run" "/Users/slim/slimslenderslacks/dockerfile-language-server-nodejs/out/src/server.js" "--stdio"]
                       ;:on_attach on_attach
                       ;:handlers handlers
                       ;:capabilities capabilities})

  ;; Clojure
  (lsp.clojure_lsp.setup {:on_attach on_attach
                          :handlers handlers
                          :capabilities capabilities})

  ;; Nix
  (lsp.rnix.setup {:on_attach on_attach
                   :handlers handlers
                   :capabilities capabilities})

  ;; docker-lsp
  ;; ["java" "-jar" "/Users/slim/atmhq/lsp/target/docker-lsp-0.0.1-standalone.jar"]
  ;; ["docker" "run" "--rm" "--init" "-i" "-v" "/tmp:/tmp" "atomist/lsp"]
  (lsp.docker_lsp.setup {:cmd
                         (if (not (os.getenv "USE_DOCKER"))
                           (if (not (os.getenv "DOCKER_LSP_NATIVE"))
                             ["java" 
                              "--add-opens=java.base/java.nio=ALL-UNNAMED" 
                              "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED" 
                              "-jar" "/Users/slim/docker/lsp/docker-lsp-standalone.jar" 
                              "--pod-exe-path" "/Users/slim/docker/babashka-pod-docker/result/bin/babashka-pod-docker"
                              "--user" "jimclark106"]
                             ["docker"
                              "lsp"
                              "listen"
                              "--user" "jimclark106"])
                           ["docker" "run" 
                                     "--rm" "--init" "-i" 
                                     "-v" "/tmp:/tmp" 
                                     "-v" "/Users/slim:/Users/slim" 
                                     "-p" "1667:1667" 
                                     "atomist/lsp" 
                                     "--user" "jimclark106" 
                                     "--pat" "dckr_pat_zPNe318_pOB7i6NgVXD0PGvM6Yo" 
                                     "--workspace" "/Users/slim"])
                         :on_attach on_attach
                         :handlers handlers
                         :capabilities capabilities})

  (lsp.gopls.setup {:cmd ["gopls" "serve"]
                    :filetypes ["go" "gomod"]
                    :on_attach on_attach
                    :handlers handlers
                    :capabilities capabilities})
  )

(not true)
