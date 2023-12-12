(module dockerai
  {autoload {nvim aniseed.nvim
             core aniseed.core
             string aniseed.string}})

(vim.lsp.set_log_level "TRACE")
(def use-nix? true)

(defn jwt []
  (let [p (vim.system 
            ["docker-credential-desktop" "get"] 
            {:text true :stdin "https://index.docker.io/v1//access-token"})
        obj (p:wait)]
    (. (vim.json.decode (. obj :stdout)) :Secret)))

(defn decode-payload [s]
  (vim.json.decode
    (vim.base64.decode (.. (. (vim.split s "." {:plain true}) 2) "="))))

(comment
  (decode-payload (jwt)))

;err - error info dict or nil
;result - result key of the lsp response
;ctx - table of calling states
;config - handler defined config table
(defn prompt-handler [cb]
  (fn [err result ctx config]
    (if err
      ((. cb :error) (core.get err "extension/id") err)
      (let [content (. result :content)]
        (when (or 
                (core.get content :complete)
                (core.get content :function_call)
                (core.get content :content))
          ((. cb :content) 
           (core.get result "extension/id") 
           (if (core.get content :function_call)
             (core.update 
               content :function_call 
               (fn [fc] (core.assoc fc :arguments (vim.json.decode (core.get fc :arguments)))))
             content)))))))

(defn exit-handler [cb]
  (fn [err result ctx config]
    (if err
      ;; will never happen
      ((. cb :error) (core.get err "extension/id") err)
      ;; will have extension/id and exit
      ((. cb :exit) (core.get result "extension/id") result))))

(defn jwt-handler 
  [err result ctx config]
  (if err
    (core.println "jwt err: " err))
  (jwt))

(defn start [root-dir prompt-handler exit-handler]
  (let [docker-ai-lsp
        (vim.lsp.start_client {:name "docker-ai"
                               :cmd ["docker" "run"
                                     "--rm" "--init" "--interactive"
                                     "vonwig/labs-assistant-ml:staging"]
                               :root_dir (vim.fn.getcwd)
                               :handlers {"$/prompt" prompt-handler
                                          "$/exit" exit-handler}})
        docker-lsp
        (if use-nix?
          (vim.lsp.start_client {:name "docker-lsp"
                                 :cmd ["nix" "run"
                                       "/users/slim/docker/lsp/#clj"
                                       "--"
                                       "--pod-exe-path"
                                       "/Users/slim/.docker/cli-plugins/docker-pod"]
                                 :cmd_env {"DOCKER_LSP" "nix"}
                                 :root_dir (vim.fn.getcwd)
                                 :handlers {"docker/jwt" jwt-handler}})
          (vim.lsp.start_client {:name "docker-lsp"
                                 :cmd ["docker" "run"
                                       "--rm" "--init" "--interactive"
                                       "--mount" "type=volume,source=docker-lsp,target=/docker"
                                       "--mount" (.. "type=bind,source=" root-dir ",target=/project")
                                       "vonwig/lsp"
                                       "listen"
                                       "--workspace" "/docker"
                                       "--root-dir" root-dir]
                                 :root_dir (vim.fn.getcwd)
                                 :handlers {"docker/jwt" jwt-handler}}))]
    [docker-ai-lsp docker-lsp]))

(defn get-client-by-name [s]
  (core.some (fn [client] (when (= client.name s) client)) (vim.lsp.get_active_clients)) )

(defn stop-docker-ai []
  (vim.lsp.stop_client (. (get-client-by-name "docker-lsp") :id)  false)
  (vim.lsp.stop_client (. (get-client-by-name "docker-ai") :id) false))

(var registrations {})

(defn docker-ai-prompt [question-id callback prompt]
  (set registrations (core.assoc registrations question-id callback))
  (let [docker-ai-lsp (get-client-by-name "docker-ai")
        docker-lsp (get-client-by-name "docker-lsp")]
    (let [result (docker-ai-lsp.request_sync 
                   "prompt" 
                   (core.merge 
                     (. (docker-lsp.request_sync "docker/project-facts" {"vs-machine-id" ""} 60000) :result) 
                     {"extension/id" question-id
                      "question" {"prompt" prompt}}
                     {:dockerImagesResult []
                      :dockerPSResult []
                      :dockerDFResult []
                      :dockerCredential (let [k (jwt)] 
                                          {:jwt k
                                           :parsedJWT (decode-payload k)})
                      :platform {:arch "arm64"
                                 :platform "darwin"
                                 :release "23.0.0"}
                      :vsMachineId ""
                      :isProduction true
                      :notebookOpens 1
                      :notebookCloses 1
                      :notebookUUID ""
                      :dataTrackTimestamp 0}))] 
      (core.println result))))

(defn docker-ai-questions []
  (let [docker-ai-lsp (get-client-by-name "docker-ai")
        docker-lsp (get-client-by-name "docker-lsp")]
    (let [result (. (docker-lsp.request_sync "docker/project-facts" {"vs-machine-id" ""} 60000) :result)]
      (core.concat
        (. result :project/potential-questions)
        ["Summarize this project" 
         "Can you write a Dockerfile for this project"
         "How do I build this Docker project?"
         "Custom Question"]))))

(defn start-docker-ai []
  (let [cb {:exit (fn [id message]
                    ((. (. registrations id) :exit) id message)
                    ;; TODO remove the handler
                    )
            :error (fn [id message]
                     (core.println id message))
            :content (fn [id message]
                       ((. (. registrations id) :content) id message))}]
    (start 
      (vim.fn.getcwd)
      (prompt-handler cb)
      (exit-handler cb))))

(defn update-buf [buf lines]
  (vim.api.nvim_buf_call
    buf
    (fn [] (vim.api.nvim_put lines "" true true))))

(defn callback [buf]
  {:exit (fn [id message] (update-buf buf [id (vim.json.encode message) "----" ""]))
   :error (fn [id message] (update-buf buf [id (vim.json.encode message) "----" ""]))
   :content (fn [id message] (update-buf buf [id (vim.json.encode message) "----" ""]))})

(comment
  (def buf (vim.api.nvim_create_buf true true))
  
  (start-docker-ai) 
  (core.map (fn [client] (. client :name)) (vim.lsp.get_active_clients))
  (stop-docker-ai)

  (docker-ai-prompt "18" (callback buf) "Can you write a Dockerfile for this project?")
  (docker-ai-prompt "19" (callback buf) "Summarize this project")
  (docker-ai-prompt "21" (callback buf) "How do I dockerize my project")
  (docker-ai-prompt "22" (callback buf) "How do I build this Docker project?")
  )

