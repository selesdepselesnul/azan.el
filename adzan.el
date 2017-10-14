(require 'url)
(require 'json)
(require 'request)

(defvar adzan-time)

(defun read-a-list (key alist)
  (cdr (assoc key alist)))

(defun read-azan (key data)
  (read-a-list key (elt (cdr (assoc 'items data )) 0)))

(defvar adzan (make-hash-table :test 'equal))

(defconst api-key "")

(defun store-azan-to-hash (key data)
  (puthash key (read-azan key data) adzan))

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

(defvar timer)

(defun get-time-hh-mm ()
  (downcase (format-time-string "%l:%M %p")))

(defun display-adzan (time)
  (progn
    (cancel-timer timer)
    (switch-to-buffer time)
    (insert time)
    (read-string "kill buffer ? (enter)")
    (kill-buffer time)))

(defun adzan-handler ()
  (let* ((time-now (get-time-hh-mm)))
    (cond
     ((string= "05:44" time-now) (display-adzan "subuh"))
     ((string= "11:48" time-now) (display-adzan "dzuhur"))
     ((string= "15:43" time-now) (display-adzan "ashar"))
     ((string= "17:43" time-now) (display-adzan "maghrib"))
     ((string= "21:33" time-now) (display-adzan "isya")))))

(defun set-timer ()
  (setq timer (run-at-time 0 1 'adzan-handler)))

(set-timer)


