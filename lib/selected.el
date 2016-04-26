;; THIS BUFFER IS FOR NOTES YOU DON'T WANT TO SAVE, AND FOR LISP EVALUATION.
;; IF YOU WANT TO CREATE A FILE, VISIT THAT FILE WITH C-X C-F,
;; THEN ENTER THE TEXT IN THAT FILE'S OWN BUFFER.

;; Selected.el --- Keymap for when region is active
;; Copyright (C) 2016 Erik Sjöstrand
;; MIT License
;;
;; When `selected-minor-mode' is active, the keybindings in `selected-keymap'
;; will be enabled when tne region is active. This is useful for commands that
;; operates on the region, which you only want keybound when the region is
;; active.
;;
;; `selected-keymap' has no default bindings. Bind it yourself:
;; (define-key selected-keymap (kbd "u") #'upcase-region)

; (define-global-minor-mode global-selected-minor-mode selected-minor-mode
;   (lambda () (selected-minor-mode t))
;   :group 'convenience)

(defvar selected-keymap (make-sparse-keymap)
  "Keymap for `selected-minor-mode'. Add keys here that should be active when region is active.")

(define-minor-mode selected-region-active
  "Meant to activate when region becomes active. Not intended for the user. Use `selected-minor-mode'."
  :keymap selected-keymap
  (when selected-region-active
    (let ((major-selected-map
           (intern-soft (concat "selected-" (symbol-name major-mode) "-map"))))
      (if major-selected-map
          (setf (cdr (assoc 'selected-region-active minor-mode-map-alist))
                (let ((map (eval major-selected-map)))
                  (set-keymap-parent map selected-keymap)
                  map))
        (setf (cdr (assoc 'selected-region-active minor-mode-map-alist))
              selected-keymap)))))

(defun selected--on ()
  (selected-region-active 1))

(defun selected-off ()
  "Disables bindings in `selected-keymap' temporary."
  (interactive)
  (selected-region-active -1))

;;;###autoload
(define-minor-mode selected-minor-mode
  "If enabled activates the `selected-keymap' when the region is active."
  :lighter " sel"
  (if selected-minor-mode
      (progn
        (add-hook 'activate-mark-hook #'selected--on)
        (add-hook 'deactivate-mark-hook #'selected-off))
    (remove-hook 'activate-mark-hook #'selected--on)
    (remove-hook 'deactivate-mark-hook #'selected-off)
    (selected--off)))

(provide 'selected)
