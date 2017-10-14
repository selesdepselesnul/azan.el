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

(defun store-adzan (data)
  (progn
    (puthash "fajr" (read-azan 'fajr data) adzan)
    (puthash "dhuhr" (read-azan 'dhuhr data) adzan)
    (puthash "asr" (read-azan 'asr data) adzan)
    (puthash "maghrib" (read-azan 'maghrib data) adzan)
    (puthash "isha" (read-azan 'isha data) adzan)))

(request
 (concat "http://muslimsalat.com/bandung.json?key=" api-key) 
 :parser 'json-read
 :success (cl-function
	   (lambda (&key data &allow-other-keys)
	           (store-adzan data))))

(defvar timer)

(defun get-time-hh-mm ()
  (downcase (format-time-string "%I:%M %p")))

(get-time-hh-mm)

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


