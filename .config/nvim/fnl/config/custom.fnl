(module config.custom
  {autoload {nvim aniseed.nvim
             a aniseed.core
             lsp lspconfig
             cmplsp cmp_nvim_lsp}})

(defn tail_server_info []
  (let [clients (vim.lsp.get_active_clients)]
    (each [n client (pairs clients)]
      (let [result (client.request_sync "clojure/serverInfo/raw" {} 5000 15)]
        (print result.result.port result.result.log-path)
        (nvim.command  (a.str "vs | :term bash -c \"tail -f " result.result.log-path "\""))))))

