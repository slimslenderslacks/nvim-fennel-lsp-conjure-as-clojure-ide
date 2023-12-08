(module slim.nvim
  {autoload {nvim aniseed.nvim
             core aniseed.core
             str aniseed.string}})

(defn get-current-buffer-selection []
  (let [[_ s1 e1 _] (nvim.fn.getpos "'<")
        [_ s2 e2 _] (nvim.fn.getpos "'>")]
    (nvim.buf_get_text (nvim.buf.nr) (- s1 1) (- e1 1) (- s2 1) (- e2 1) {})))

(def win-opts 
  {:relative "editor" 
   :row 3 
   :col 3 
   :width 80 
   :height 40 
   :style "minimal"
   :border "rounded" 
   :title "my title"
   :title_pos "center"})

(defn open-win [buf opts]
  (let [win (nvim.open_win buf true (core.merge win-opts opts))]
    (nvim.set_option_value "filetype" "markdown" {:buf buf})
    (nvim.set_option_value "buftype" "nofile" {:buf buf})
    (nvim.set_option_value "wrap" true {:win win})
    (nvim.set_option_value "linebreak" true {:win win})))

(defn show-spinner [buf n]
  (var current-char 1)
  (let [characters ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
        format "> Generating %s"
        t (vim.loop.new_timer)]
    (t:start 100 100 (vim.schedule_wrap 
                       (fn [] 
                         (let [lines [(format:format (core.get characters current-char))]]
                           (nvim.buf_set_lines buf n (+ n 1) false lines)
                           (set current-char (+ (% current-char (core.count characters)) 1))))))
    t))

(comment
  (let [buf (nvim.create_buf false true)]
    (open-win buf {:title "hey"})
    (show-spinner buf)))
