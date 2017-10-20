;; -*- lexical-binding: t -*-
(require 'url)
(require 'json)
(require 'request)
(require 'sound-wav)

(defvar timer)
(defvar azan (make-hash-table :test 'equal))
(defvar is-already-azan '(('fajr . nil)
			  ('dhuhr . nil)
			  ('asr . nil)
			  ('maghrib . nil)
			  ('isha . nil)))
(defvar api-key "")

(defun read-a-list (key alist)
  (cdr (assoc key alist)))

(defun read-azan (key data)
  (read-a-list key (elt (cdr (assoc 'items data )) 0)))

(defun store-azan-to-hash (key data)
  (puthash key (read-azan key data) azan))

(defun store-azan (data)
  (dolist (element '(fajr dhuhr asr maghrib isha))
    (store-azan-to-hash element data)))

(request
  (concat "http://muslimsalat.com/bandung.json?key=" api-key) 
  :parser 'json-read
  :success (cl-function
 	   (lambda (&key data &allow-other-keys)
 	           (store-azan data))))

(defun trim-space (string)
  (let ((regex "\\`[ \n\t\r]*\\(\\(.\\|\n\\)*?\\)[ \n\t\r]*\\'"))
    (string-match regex string)
    (match-string 1 string)))

(defun get-time-hh-mm ()
  (trim-space (downcase (format-time-string "%l:%M %p"))))

(defun display-azan (azan time)
  (setf (alist-get azan is-already-azan) t)
  (switch-to-buffer time)
  (insert time)
  (setq buffer-read-only 1)
  (sound-wav-play (expand-file-name "azan.wav"))
  (read-string "kill buffer ? (enter)")
  (kill-buffer time))

(defun is-azan (current-azan current-time)
  (and
   (not (read-a-list current-azan is-already-azan))
   (string= (gethash current-azan azan) current-time)))

(defun azan-handler ()
  (let ((time-now (get-time-hh-mm)))
    (cond
     ((is-azan 'fajr time-now) (display-azan 'fajr "subuh"))
     ((is-azan 'dhuhr time-now) (display-azan 'dhuhr "dzuhur"))
     ((is-azan 'asr time-now) (display-azan 'asr "ashar"))
     ((is-azan 'maghrib time-now) (display-azan 'maghrib "maghrib"))
     ((is-azan 'isha time-now) (display-azan 'isha "isya")))))

(defun set-timer ()
  (setq timer (run-at-time 0 1 'azan-handler)))

(set-timer)
