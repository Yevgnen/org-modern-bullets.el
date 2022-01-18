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

(defface org-modern-bullets
  '((t (:family "Courier")))
  "Face for Org bullets.")

(defvar org-modern-bullets--regex "^\\( *\\)?\\([+-]\\|[0-9]+\\.\\)?\\( +\\)") ; FIXME Support * bullets.

(defun org-modern-bullets--fontify-whitespace (beg end)
  (when (and beg end)
    (dolist (i (number-sequence beg (1- end)))
      (add-text-properties
       i
       (1+ i)
       `(display ,(propertize " " 'face 'org-modern-bullets))))))

(defun org-modern-bullets--fontify-bullet ()
  (if-let* ((beg (match-beginning 2))
            (end (match-end 2))
            (str (match-string-no-properties 2)))
      (dolist (i (number-sequence beg (1- end)))
        (add-text-properties
         i
         (1+ i)
         `(display ,(propertize (char-to-string (aref str (- i beg)))
                                'face 'org-modern-bullets))))))

(defun org-modern-bullets--fontify ()
  (with-silent-modifications
    ;; Prefix
    (org-modern-bullets--fontify-whitespace (match-beginning 1) (match-end 1))
    ;; Bullet
    (org-modern-bullets--fontify-bullet)
    ;; Suffix
    (org-modern-bullets--fontify-whitespace (match-beginning 3) (match-end 3))))

(defun org-modern-bullets--fontify-region (beg end)
  (save-excursion
    (goto-char beg)
    (while (re-search-forward org-modern-bullets--regex end t)
      (org-modern-bullets--fontify))))

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
          (jit-lock-register #'org-modern-bullets--fontify-region)
          (org-modern-bullets--fontify-region (point-min) (point-max)))
      (jit-lock-unregister #'org-modern-bullets--fontify-region)
      (org-modern-bullets--unfontify-region (point-min) (point-max)))
    (jit-lock-refontify)))

(provide 'org-modern-bullets)

;;; org-modern-bullets.el ends here
