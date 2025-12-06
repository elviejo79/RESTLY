(require 'org)

(require 'package)
(package-initialize)
(require 'htmlize nil t) ;; try to load; don’t error if missing

(setq org-export-babel-evaluate nil
      org-confirm-babel-evaluate nil
      )


(let* ((file (car command-line-args-left))
       (backend (intern (or (cadr command-line-args-left) "html"))))
  (unless file
    (princ "usage: emacs --batch -l org-export-no-babel.el FILE.org [html|latex|md|...]\n"
           #'external-debugging-output)
    (kill-emacs 2))
  (find-file file)
  (condition-case err
      (pcase backend
        ('html  (org-html-export-to-html))
        ('latex (progn (require 'ox-latex) (org-latex-export-to-pdf)))
        ('md    (progn (require 'ox-md) (org-md-export-to-markdown)))
        (_      (org-export-to-file backend
                  (concat (file-name-sans-extension file) "." (symbol-name backend)))))
    (error
     (princ (format "org export error: %S\n" err) #'external-debugging-output)
     (kill-emacs 1))))
