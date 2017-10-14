(require 'url)
(require 'json)
(require 'request)
(require 'sound-wav)

(defvar timer)
(defvar azan (make-hash-table :test 'equal))

(defun read-a-list (key alist)
  (cdr (assoc key alist)))

(defun read-azan (key data)
  (read-a-list key (elt (cdr (assoc 'items data )) 0)))

(defconst api-key "")

(defun store-azan-to-hash (key data)
  (puthash key (read-azan key data) azan))

(defun store-azan (data)
  (progn
    (store-azan-to-hash 'fajr data)
    (store-azan-to-hash 'dhuhr data)
    (store-azan-to-hash 'asr data)
    (store-azan-to-hash 'maghrib data)
    (store-azan-to-hash 'isha data)))

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

(defun display-azan (time)
  (progn
    (cancel-timer timer)
    (switch-to-buffer time)
    (insert time)
    (sound-wav-play (expand-file-name "azan.wav"))
    (read-string "kill buffer ? (enter)")
    (kill-buffer time)))

(defun azan-handler ()
  (let* ((time-now (get-time-hh-mm)))
    (cond
     ((string= (gethash 'fajr azan) time-now) (display-azan "subuh"))
     ((string= (gethash 'dhuhr azan) time-now) (display-azan "dzuhur"))
     ((string= (gethash 'asr azan) time-now) (display-azan "ashar"))
     ((string= (gethash 'maghrib azan) time-now) (display-azan "maghrib"))
     ((string= (gethash 'isha azan) time-now) (display-azan "isya")))))

(defun set-timer ()
  (setq timer (run-at-time 0 1 'azan-handler)))

(set-timer)



