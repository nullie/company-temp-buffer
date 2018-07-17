;; (require 'company)

(defvar-local company-candidates nil)
(defvar-local company-candidates-length 0)
(defvar-local company-selection 0)

(defvar-local company-temp-buffer "*Buffer*")
(defvar-local company-temp-buffer--candidates nil)

(defun company-temp-buffer-frontend (command)
  "`company-mode' frontend similar to a tooltip but based on overlays."
  (cl-case command
    (pre-command)
    (post-command)
    (show
                                        ;(display-buffer (get-buffer-create company-temp-buffer)))
     (temp-buffer-window-setup company-temp-buffer)
     (temp-buffer-window-show company-temp-buffer))
    (hide
     (company-temp-buffer-hide))
    (update
     (if (<= company-candidates-length 1)
         (company-temp-buffer-hide)
       (progn
         (let ((candidates company-candidates)
               (selection company-selection)
               selection-point)
           (with-current-buffer company-temp-buffer
                                        ; (with-selected-window (get-buffer-window company-temp-buffer)
             (let ((inhibit-read-only t))
               (setq cursor-in-non-selected-windows nil)
               (erase-buffer)
               (let ((n 0))
                 (dolist (candidate candidates)
                                        ; (insert candidate)
                   (if (eq n selection)
                       (progn
                         (setq selection-point (point))
                         (company-temp-buffer-frontend--insert candidate)
                         (let ((overlay (make-overlay selection-point (point))))
                           (overlay-put overlay 'face 'highlight))
                         )
                     (company-temp-buffer-frontend--insert candidate))
                   (newline)
                   (setq n (1+ n)))
                 (resize-temp-buffer-window (get-buffer-window company-temp-buffer))
                 ))
             (with-selected-window (get-buffer-window company-temp-buffer)
               (set-window-point (get-buffer-window company-temp-buffer) selection-point)
               (recenter)
         ))))))))

(defun company-temp-buffer-hide ()
  (let ((win (get-buffer-window company-temp-buffer)))
    (if win (quit-window t win))))
;; (defun company-temp-buffer-frontend (command)
;;   (cl-case command
;;     (show
;;      (with-output-to-temp-buffer company-temp-buffer
;;        (print "Hello, world!")))
;;     (hide
;;      (kill-buffer company-temp-buffer))))


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

(defun company-temp-buffer-frontend--transform-selection (candidate)
                                        ; (company-call-backend 'meta candidate))
  candidate)

(provide 'company-temp-buffer)
