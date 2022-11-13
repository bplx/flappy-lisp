(load "~/quicklisp/setup.lisp")
(ql:quickload :cffi)
(ql:quickload :3d-vectors)
(ql:quickload :3d-matrices)
(load "./lib/cl-raylib/cl-raylib.asd")
(require "cl-raylib")

(defpackage :flappy
  (:use :cl :raylib :3d-vectors)
  (:export #:main))

(in-package :flappy)


(defclass pipes ()
  ((pipet
    :initarg :pipet
    :accessor pipes-pipet)
   (pipeb
    :initarg :pipeb
    :accessor pipes-pipeb)
   (collision
    :initarg :collision
    :accessor pipes-collision)
   (scored
    :initarg :scored
    :accessor pipes-scored)))
(defun make-pipes (pipet pipeb collision scored)
  (make-instance 'pipes :pipet pipet :pipeb pipeb :collision collision :scored scored))

(defun main ()


  
  (let ((screen-width 800)
	(screen-height 450)
	(title "flappy lisp"))
        (with-window (screen-width screen-height title)
		 (init-audio-device)
		 (let* ((box-a (make-rectangle :x 0 :y (/ screen-height 2)
					       :width 20 :height 20))
			(box-b (make-rectangle :x 0 :y (- screen-height (/ screen-height 5) )
					       :width screen-width :height (/ screen-height 5)))
			(box-c (make-rectangle :x 0 :y (- 50)
					       :width screen-width :height 50))
			(vely 0)
			(gravity 15)
			(dt 0)
			(jumpheight (- 300))
			(ready NIL)
			(died NIL)
			(score 1)
			(timer 0)
			(pipelist '())
			(randy NIL))

		   (set-target-fps 60)
		   
		   (defun die ()
		     (if (not died)
			 (progn
			   (setf ready NIL)
 			   (setf died T)
			   (setf vely 0))))

		   (loop


		    (setf dt (get-frame-time))
		    (if (window-should-close) (return))
		    (setf (rectangle-x box-a) 200)
		    (if (and ready (not died))
			(progn
			  (incf timer)
			  (if (>= timer 200)
			    (progn
			      (setf timer 0)
			      (setf randy (get-random-value -160 (+ (- screen-height) 80)))
			      (setf pipelist (append pipelist (list (make-pipes
						     (make-rectangle :x screen-width :y randy
									    :width 50 :height 400)	     
						     (make-rectangle :x screen-width :y (+ randy 500)
									    :width 50 :height 800)
						     (make-rectangle :x screen-width :y 0
								     :width 50 :height 800)
						     NIL))))))
			  
			  (if (is-key-pressed +key-space+)
			      (progn
				(setf vely jumpheight)))		

			  (setf vely (+ vely gravity))			  
			  			  
			  (if (or (check-collision-recs box-a box-b) (check-collision-recs box-a box-c)) (die) ))
		      
		      (progn
			   (if (not died) 
			       (if (is-key-pressed +key-space+)
				   (progn 
				     (setf ready T)
				     (setf score 0)
				     (setf vely 0)
				     (setf timer 0)
				     (setf vely jumpheight))))
			   (if (and died (not ready))
			       (progn
				 (if (not (check-collision-recs box-a box-b))
				     (setf vely (+ vely gravity))
				     (setf vely 0))
				 (if (is-key-pressed +key-space+)
				     (progn
				       (setf (rectangle-y box-a) (/ screen-height 2))
				       (setf vely 0)
				       (setf pipelist '())
				       (setf ready NIL)
				       (setf died NIL)))))))

		    (setf (rectangle-y box-a) (+ (* vely dt) (rectangle-y box-a)))
       
		    (with-drawing
		     (clear-background +skyblue+)
		      		     (draw-rectangle-rec box-b +green+)

				     (draw-rectangle-rec box-c +green+)
				     (loop for a in pipelist
					   DO
					   (if (not died)
					       (progn
						 (decf (rectangle-x (pipes-collision a)) 2)
						 (decf (rectangle-x (pipes-pipet a)) 2)
						 (decf (rectangle-x (pipes-pipeb a)) 2)))
					   (draw-rectangle-rec (pipes-pipet a) +blue+)
					   (draw-rectangle-rec (pipes-pipeb a) +green+)
					   (if (or (check-collision-recs box-a (pipes-pipet a))
						   (check-collision-recs box-a (pipes-pipeb a)))
					       (die))
					   (if (and (and (check-collision-recs box-a (pipes-collision a)) (not died)) (not (pipes-scored a)))
					       (progn
						 (setf (pipes-scored a) T)
						 (incf score))))
				     (draw-rectangle-rec box-a +gold+)
		     (if (not died)
			 (draw-text (if ready (write-to-string score) "space to start") 10 10 50 +black+)
		       (progn
			 (draw-text "ow owie you died. space to restart" 10 10 30 +black+)
			 (draw-text (concatenate 'string "your score was " (write-to-string score)) 10 40 20 +black+)))))))))
