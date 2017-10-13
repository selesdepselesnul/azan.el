(defun get-time-hh-mm ()
  (let* ((splitted-time (split-string (format-time-string "%T") ":"))  
	 (hour (nth 0 splitted-time))
	 (minute (nth 1 splitted-time)))
    (concat hour ":" minute)))

(defun display-adzan (time)
  (progn
    (switch-to-buffer time)
    (insert time)))

(defun adzan-handler ()
  (let* ((time-now (get-time-hh-mm)))
    (cond ((string= "04:43" time-now) (message "subuh")
	   (string= "12:00" time-now) (message "dzuhur")
	   (string= "15:43" time-now) (message "ashar")
	   (string= "17:43" time-now) (message "maghrib")
	   (string= "21:33" time-now) (message "isya")))))

(run-at-time 0 1 'adzan-handler)


