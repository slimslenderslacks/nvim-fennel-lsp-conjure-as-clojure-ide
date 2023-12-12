(module config.nano-copilot
  {autoload {core aniseed.core
             nvim aniseed.nvim
             str aniseed.string
             util slim.nvim
             curl plenary.curl}})

(defn open [lines]
  (let [buf (nvim.create_buf false true)]
    (nvim.buf_set_text buf 0 0 0 0 lines) 
    (util.open-win buf {:title "Docker Copilot"})
    buf))

(comment
  (open ["hey"]))

(defn openselection []
  (open (util.get-current-buffer-selection)))

(nvim.set_keymap :v :<leader>ai ":lua require('config.nano-copilot').openselection()<CR>" {})

(defn ollama [system-prompt prompt cb]
  (curl.post 
    "http://localhost:11434/api/generate"
    {:body (vim.json.encode {:model "mistral"
                             :prompt prompt
                             :system system-prompt 
                             :stream true})
     :stream (fn [_ chunk _]
               (cb (. (vim.json.decode chunk) "response")))}))

(defn execute-prompt [prompt]
  (var tokens [])
  (let [lines (str.split prompt "\n")
        buf (open lines)]
    ;; run the LLM
    (let [t (util.show-spinner buf (core.inc (core.count lines))) ]
      (nvim.buf_set_lines buf -1 -1 false ["" ""])
      (ollama "" prompt 
              (fn [s] 
                (vim.schedule 
                  (fn [] 
                    (t:stop)
                    (set tokens (core.concat tokens [s]))
                    (nvim.buf_set_lines buf (core.inc (core.count lines)) -1 false (str.split (str.join tokens) "\n")))))))))

(comment
  (execute-prompt "What does a Dockerfile look like?")
  (vim.fn.input "Question: "))

(defn copilot []
  (let [prompt (..
                 "I have a question about this: "
                 (vim.fn.input "Question: ")       
                 "\n\n Here is the code:\n```\n"
                 (str.join "\n" (util.get-current-buffer-selection))
                 "\n```\n")]
    (execute-prompt prompt)))

(nvim.set_keymap :v :<leader>ai ":lua require('config.nano-copilot').copilot()<CR>" {})

;; I need a function that adds strings in python
;; My Docker Image should package a Node app based on a package.json file

(defn options [cb]
  (let [prompts ["Ask_about_code" "Ask_about_documentation" "Explain_some_code" "Generate_some_code"]]
    (vim.ui.select 
      prompts 
      {:prompt "Select a prompt:"
       :format (fn [item] (item:gsub "_" " "))}
      (fn [selected _] (when selected (cb selected))))))

(comment
  (options (fn [selected] (core.println selected))))

