(defvar isya "20:24")

(defun get-time-hh-mm ()
  (let* ((splitted-time (split-string (format-time-string "%T") ":"))  
	 (hour (nth 0 splitted-time))
	 (minute (nth 1 splitted-time)))
    (concat hour ":" minute)))

(string= "20:43" (get-time))



