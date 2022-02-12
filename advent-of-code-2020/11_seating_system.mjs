import fs from "fs";

function encode(string) {
  const encoding = [];
  for (let i = 0; i < string.length; i++) {
    if (string[i] === "L") {
      encoding.push(false);
    } else {
      encoding.push(undefined);
    }
  }
  return encoding;
}

function getNeighbors(row, col, seats) {
  const neighbors = [];
  for (let dy = -1; dy <= 1; dy++) {
    for (let dx = -1; dx <= 1; dx++) {
      if (dx === 0 && dy === 0) continue; // neighborhood center
      const seatRow = seats[row + dy];
      if (seatRow === undefined) continue; // out of bounds
      neighbors.push(seatRow[col + dx]);
    }
  }
  return neighbors;
}

function countOccupied(seats) {
  return seats.filter((s) => s).length;
}

function tick(seats) {
  const next = [];
  for (let row = 0; row < rows; row++) {
    next.push([]);
    for (let col = 0; col < cols; col++) {
      const seat = seats[row][col];
      if (seat === undefined) {
        next[row].push(undefined);
        continue;
      }
      const occupiedNeighbors = countOccupied(getNeighbors(row, col, seats));
      if (seat === false && occupiedNeighbors === 0) {
        next[row].push(true);
        continue;
      }
      if (seat === true && occupiedNeighbors >= 4) {
        next[row].push(false);
        continue;
      }
      next[row].push(seat);
    }
  }
  return next;
}

function getVisible(row, col, seats) {
  const visible = [];
  for (let dy = -1; dy <= 1; dy++) {
    for (let dx = -1; dx <= 1; dx++) {
      if (dx === 0 && dy === 0) continue; // our seat
      let seat;
      let dirx = dx;
      let diry = dy;
      while (seat === undefined) {
        let r = row + diry;
        if (r < 0 || r === rows) break;
        let c = col + dirx;
        if (c < 0 || c === cols) break;
        seat = seats[r][c];
        dirx += dx;
        diry += dy;
      }
      visible.push(seat);
    }
  }
  return visible;
}

function tickWithRays(seats) {
  const next = [];
  for (let row = 0; row < rows; row++) {
    next.push([]);
    for (let col = 0; col < cols; col++) {
      const seat = seats[row][col];
      if (seat === undefined) {
        next[row].push(undefined);
        continue;
      }
      const occupiedVisibleSeats = countOccupied(getVisible(row, col, seats));
      if (seat === false && occupiedVisibleSeats === 0) {
        next[row].push(true);
        continue;
      }
      if (seat === true && occupiedVisibleSeats >= 5) {
        next[row].push(false);
        continue;
      }
      next[row].push(seat);
    }
  }
  return next;
}

function seatsChanged(seats1, seats2) {
  const gridSize = seats1.length;
  for (let row = 0; row < gridSize; row++) {
    for (let col = 0; col < gridSize; col++) {
      if (seats1[row][col] !== seats2[row][col]) {
        return true;
      }
    }
  }
  return false;
}

let seats = fs
  // .readFileSync("input/11_example.txt") // 37 // 26
  .readFileSync("input/11.txt") // 2261 // 2039
  .toString()
  .split("\n")
  .slice(0, -1) // trim last empty line
  .map(encode);

const rows = seats.length;
const cols = seats[0].length; // assume at least one row, and a rectangular grid
let nextSeats = tickWithRays(seats);
while (seatsChanged(seats, nextSeats)) {
  seats = nextSeats;
  nextSeats = tickWithRays(seats);
}

console.log(countOccupied(seats.flat()));
