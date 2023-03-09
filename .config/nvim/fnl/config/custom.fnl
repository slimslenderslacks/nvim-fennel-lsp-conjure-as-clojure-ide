(module config.custom
  {autoload {nvim aniseed.nvim
             a aniseed.core
             lsp lspconfig
             cmplsp cmp_nvim_lsp}})

(defn tail_server_info []
  (let [clients (vim.lsp.get_active_clients)]
    (each [n client (pairs clients)]
      (if (= client.name "docker_lsp")
        (let [result (client.request_sync "docker/serverInfo/raw" {} 5000 15)]
          (print result.result.port result.result.log-path result.result.team-id)
          (nvim.command  (a.str "vs | :term bash -c \"tail -f " result.result.log-path "\"")))))))

(defn set_team_id [args]
  (let [clients (vim.lsp.get_active_clients)]
    (each [n client (pairs clients)]
      (if (= client.name "docker_lsp")
        (let [result (client.request_sync "docker/team-id" args 5000 15)]
          (print result))))))

(defn docker_server_info [args]
  (let [clients (vim.lsp.get_active_clients)]
    (each [n client (pairs clients)]
      (if (= client.name "docker_lsp")
        (let [result (client.request_sync "docker/serverInfo/show" args 5000 15)]
          (print result))))))

(defn docker_login [args]
  (let [clients (vim.lsp.get_active_clients)]
    (each [n client (pairs clients)]
      (if (= client.name "docker_lsp")
        (let [result (client.request_sync "docker/login" args 5000 15)]
          (print result))))))

(defn docker_logout [args]
  (let [clients (vim.lsp.get_active_clients)]
    (each [n client (pairs clients)]
      (if (= client.name "docker_lsp")
        (let [result (client.request_sync "docker/logout" args 5000 15)]
          (print result))))))

;(nvim.buf_set_keymap bufnr :n :<leader>lz ":lua clients = vim.lsp.get_active_clients() for k, client_data in ipairs(clients) do id = client_data.id end client = vim.lsp.get_client_by_id(id) result = client.request_sync(\"docker/serverInfo/raw\", {}, 5000, 15) print('port = ' .. result.result.port) print('log-path = ' .. result.result['log-path']) print('team-id = ' .. result.result['team-id'])<cr>" {:noremap true})

(nvim.create_user_command "DockerWorkspace" set_team_id {:nargs "?"})
(nvim.create_user_command "DockerServerInfo" docker_server_info {:nargs "?"})
(nvim.create_user_command "DockerLogin" docker_login {:nargs "?"})
(nvim.create_user_command "DockerLogout" docker_logout {:nargs "?"})
