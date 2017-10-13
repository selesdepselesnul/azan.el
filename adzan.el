(defvar timer)

(defun get-time-hh-mm ()
  (let* ((splitted-time (split-string (format-time-string "%T") ":"))  
	 (hour (nth 0 splitted-time))
	 (minute (nth 1 splitted-time)))
    (concat hour ":" minute)))

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


