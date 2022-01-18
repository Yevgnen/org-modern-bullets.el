;;; org-modern-bullets.el ---  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Yevgnen Koh
;;
;; Author: Yevgnen Koh <wherejoystarts@gmail.com>
;; Version: 0.1.0
;; Keywords: org-mode
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;;
;;
;; See documentation on https://github.com/Yevgnen/org-modern-bullets.el.

;;; Code:

(require 'subr-x)

(defgroup org-modern-bullets nil
  "Make Org bullets look modern."
  :group 'org)

(defcustom org-modern-bullets-prefix-regex
  "^\\( *\\)"
  "Regex for bullet list prefix.")

(defcustom org-modern-bullets-bullet-regex
  "\\([*+-]\\|[0-9]+\\.\\)"
  "Regex for bullets.")

(defcustom org-modern-bullets-suffix-regex
  " "
  "Regex for bullet list suffix.")

(defcustom org-modern-bullets-alist
  '((?- . ?-)
    (?+ . ?+)
    (?* . ?*))
  "Bullets alist for prettifying.")

(defface org-modern-bullets
  '((t (:inherit org-indent)))
  "Face for Org bullets.")

(defvar org-modern-bullets--regex nil)

(defun org-modern-bullets--build-regex ()
  (setq org-modern-bullets--regex
        (concat org-modern-bullets-prefix-regex
                org-modern-bullets-bullet-regex
                org-modern-bullets-suffix-regex)))

(defun org-modern-bullets--get-replacement (thing)
  (if (numberp thing)
      (char-to-string (alist-get (string-to-char thing) org-modern-bullets-alist))
    thing))

(defun org-modern-bullets--fontify ()
  (with-silent-modifications
    (when-let* ((repl-str (org-modern-bullets--get-replacement (match-string-no-properties 2)))
                (repl-str (format "%s%s"
                                  (make-string (- (match-end 1) (match-beginning 1)) ? )
                                  repl-str))
                (pretty-repl-str (propertize repl-str 'face 'org-modern-bullets)))
      (add-text-properties
       (match-beginning 0) (1- (match-end 0))
       `(display ,pretty-repl-str))
      (add-text-properties
       (1- (match-end 0)) (match-end 0)
       `(display (space :align-to ,(- (match-end 0) (match-beginning 0))))))))

(defun org-modern-bullets--fontify-region (beg end)
  (save-excursion
    (goto-char beg)
    (while (re-search-forward org-modern-bullets--regex end t)
      (if (string= (match-string-no-properties 1) "*")
          (unless (= (match-beginning 0) (match-beginning 1))
            (org-modern-bullets--fontify))
        (org-modern-bullets--fontify)))))

(defun org-modern-bullets--unfontify-region (beg end)
  (save-excursion
    (goto-char beg)
    (while (re-search-forward org-modern-bullets--regex end t)
      (with-silent-modifications
        (remove-text-properties (match-beginning 0) (match-end 0)
                                '(display nil))))))

(define-minor-mode org-modern-bullets-mode
  "Minor mode for prettifying Org bullets."
  :lighter ""
  :keymap nil
  (when t
    (if org-modern-bullets-mode
        (progn
          (org-modern-bullets--build-regex)
          (setq org-indent-boundary-char 0)
          (jit-lock-register #'org-modern-bullets--fontify-region)
          (org-modern-bullets--fontify-region (point-min) (point-max)))
      (jit-lock-unregister #'org-modern-bullets--fontify-region)
      (org-modern-bullets--unfontify-region (point-min) (point-max)))
    (jit-lock-refontify)))

(provide 'org-modern-bullets)

;;; org-modern-bullets.el ends here
