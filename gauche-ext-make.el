;;; gauche-ext-make.el --- gauche-ext make lisp


;;; History:
;; 

;;; Commentary:
;; 

;;; Code:



(setq ALL-MODULES 
      (list
       "gauche-browse.el"
       "gauche-config.el"
       "gauche-const.el"
       "gauche-env.el"
       "gauche-refactor.el"
       "refactor.el"
       "scm-browse.el"
       "scm-const.el"
       "scm-edit.el"
       "scm-env.el"
       ))

;; (when (memq system-type '(windows-nt))
;;   (setq ALL-MODULES
;; 	(append ALL-MODULES (list "fsvn-win.el")))
;;   (unless (featurep 'meadow)
;;     (setq ALL-MODULES
;; 	(append ALL-MODULES (list 
;; 			     "mw32cmp.el"
;; 			     "mw32script.el"
;; 			     )))))

(defun make-gauche-ext ()
  (gauche-ext-make-initialize))

(defun compile-gauche-ext ()
  (gauche-ext-make-initialize)
  (gauche-ext-make-compile))

(defun check-gauche-ext ()
  (gauche-ext-make-initialize)
  (gauche-ext-make-lint)
  (gauche-ext-make-compile)
  ;; see comment in `fsvn-test-excursion' at fsvn-test.el
  (condition-case err
      (progn
	(gauche-ext-make-test)
	(kill-emacs))
    (error
     (princ err)
     (kill-emacs 1))))

(defun install-gauche-ext ()
  (gauche-ext-make-initialize)
  (gauche-ext-make-install))

(defun what-where-gauche-ext ()
  (gauche-ext-make-initialize)
  (gauche-ext-make-install t))

(defun gauche-ext-make-initialize ()
  (let ((config (or (car command-line-args-left) "MAKE-CFG")))
    (setq load-path (cons "." load-path))
    (load config)))

(defun gauche-ext-make-compile ()
  (mapc
   (lambda (m)
     (byte-compile-file m))
   ALL-MODULES))

(defun gauche-ext-make-lint ()
  (elint-initialize)
  (mapc
   (lambda (module)
     (find-file module)
     (eval-buffer)
     (elint-current-buffer)
     (with-current-buffer "*Elint*"
       (message (replace-regexp-in-string "%" "%%" (buffer-string)))))
   ALL-MODULES))

(defun gauche-ext-make-install (&optional just-print)
  (unless (or just-print (file-directory-p INSTALL-DIR))
    (make-directory INSTALL-DIR t))
  (let (src dest elc el)
    (mapc
     (lambda (m)
       (setq el m)
       (setq elc (concat m "c"))
       (setq dest-el (expand-file-name el INSTALL-DIR))
       (setq dest-elc (expand-file-name elc INSTALL-DIR))
       (princ (format "%s -> %s\n" el dest-el))
       (princ (format "%s -> %s\n" elc dest-elc))
       (unless just-print
	 (mapc
	  (lambda (src-dest)
	    (let ((src (car src-dest))
		  (dest (cdr src-dest)))
	      (unless (file-exists-p src)
		(error "%s not exists." src))
	      (copy-file src dest t)
	      (set-file-modes dest ?\644)))
	  (list (cons el dest-el) (cons elc dest-elc)))))
     ALL-MODULES)))

(defun gauche-ext-make-test ()
  (mapc
   (lambda (m)
     (load-file m))
   ALL-MODULES)
  (load-file "gauche-ext-test.el")
  (princ "\n")
  (princ "-------------------------------------------------------------\n")
  (princ "Test completed\n")
  (princ "-------------------------------------------------------------\n")
  (princ "\n"))

;;; gauche-ext-make.el ends here
