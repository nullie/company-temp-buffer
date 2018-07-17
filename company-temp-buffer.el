;; (require 'company)

(defvar-local company-candidates nil)
(defvar-local company-candidates-length 0)
(defvar-local company-selection 0)

(defvar-local company-temp-buffer "*Buffer*")
(defvar-local company-temp-buffer--candidates nil)
(defvar-local company-temp-buffer--selection-overlay nil)

(defun company-temp-buffer-frontend (command)
  (cl-case command
    (pre-command)
    (post-command)
    (show
     (temp-buffer-window-setup company-temp-buffer)
     (temp-buffer-window-show company-temp-buffer))
    (hide
     (company-temp-buffer-hide))
    (update
     (if (<= company-candidates-length 1)
         (company-temp-buffer-hide)
       (progn
         (let ((candidates company-candidates)
               (selection company-selection))
           (with-current-buffer company-temp-buffer
             (unless (eq candidates company-temp-buffer--candidates)
               (setq cursor-in-non-selected-windows nil)
               (setq company-temp-buffer--candidates candidates)
               (let ((inhibit-read-only t))
                 (erase-buffer)
                 (dolist (candidate candidates)
                   (company-temp-buffer-frontend--insert candidate)
                   (newline)))
               (resize-temp-buffer-window (get-buffer-window)))
             (goto-char (point-min))
             (forward-line selection)
             (let ((selection-point (point)))
               (if company-temp-buffer--selection-overlay
                   (move-overlay company-temp-buffer--selection-overlay selection-point (line-end-position))
                 (progn (setq company-temp-buffer--selection-overlay (make-overlay selection-point (line-end-position)))
                        (overlay-put company-temp-buffer--selection-overlay 'face 'highlight)))
               (set-window-point (get-buffer-window) selection-point)))))))))

(defun company-temp-buffer-hide ()
  (let ((win (get-buffer-window company-temp-buffer)))
    (if win (quit-window t win))))

(defun company-temp-buffer-frontend--insert (candidate)
  (insert candidate)
  (let ((meta (get-text-property 0 'meta candidate)))
    ; (insert (prin1-to-line meta))
    (when meta
      (insert " ")
      (let ((start (point))
            overlay)
        (insert meta)
        (setq overlay (make-overlay start (point)))
        (overlay-put overlay 'face 'font-lock-comment-face)))))

(provide 'company-temp-buffer)
