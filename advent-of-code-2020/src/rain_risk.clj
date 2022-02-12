(ns rain-risk)

(defn parse-action [line]
  (case (first line)
    \N :north
    \S :south
    \E :east
    \W :west
    \L :left
    \R :right
    \F :forward))

(defn parse-value [line]
  (Integer/parseInt (subs line 1)))

(defn parse-line [line]
  {(parse-action line) (parse-value line)})

(defn add [v1 v2]
  (mapv + v1 v2))

(defn multiply [v n]
  (map #(* n %) v))

(defn advance [v to times]
  (add v (multiply to times)))

(defn unit [direction]
  (case direction :north [0 1] :east [1 0] :south [0 -1] :west [-1 0]))

(defn rotate-counterclockwise [v]
  (let [[x y] v] [(- y) x]))

(defn rotate-clockwise [v]
  (let [[x y] v] [y (- x)]))

(defn rotate [v degrees]
  (let [times (/ (Math/abs degrees) 90)
        rot (if (pos? degrees) rotate-counterclockwise rotate-clockwise)]
    ((apply comp (repeat times rot)) v)))

(defn move [ship instruction]
  (let [[position orientation] ship
        action (first (keys instruction))
        value (action instruction)]
    (case action
      :north [(advance position (unit :north) value) orientation]
      :south [(advance position (unit :south) value) orientation]
      :east  [(advance position (unit  :east) value) orientation]
      :west  [(advance position (unit  :west) value) orientation]

      :forward [(advance position orientation value) orientation]

      :left  [position (rotate orientation value)]
      :right [position (rotate orientation (- value))])))

(defn manhattan-distance-from-origin [ship]
  (let [[position] ship
        [x y] position]
    (+ (Math/abs x) (Math/abs y))))

(defn move-ship [input]
  (let [ship [[0 0] (unit :east)]]
    (->> input
         (map parse-line)
         (reduce move ship)
         manhattan-distance-from-origin)))

(defn move-with-waypoint [ship instruction]
  (let [[position waypoint] ship
        action (first (keys instruction))
        value (action instruction)]
    (case action
      :north [position (advance waypoint (unit :north) value)]
      :south [position (advance waypoint (unit :south) value)]
      :east  [position (advance waypoint (unit  :east) value)]
      :west  [position (advance waypoint (unit  :west) value)]

      :forward [(advance position waypoint value) waypoint]

      :left  [position (rotate waypoint value)]
      :right [position (rotate waypoint (- value))])))

(defn move-ship-with-waypoint [input]
  (let [ship [[0 0] [10 1]]]
    (->> input
         (map parse-line)
         (reduce move-with-waypoint ship)
         manhattan-distance-from-origin)))
