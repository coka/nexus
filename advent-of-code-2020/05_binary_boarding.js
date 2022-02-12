const fs = require("fs");
const readline = require("readline");

const bitMap = { F: 0, B: 1, L: 0, R: 1 };

const codeToNumber = (code) =>
  parseInt([...code].map((char) => bitMap[char]).join(""), 2);

const seatLocation = (seatCode) => [
  codeToNumber(seatCode.substring(0, 7)),
  codeToNumber(seatCode.substring(7)),
];

const seatId = (row, column) => row * 8 + column;

let highestId = 0;
const seatMap = {};

const reader = readline.createInterface({
  input: fs.createReadStream("input.txt"),
});

reader.on("line", (l) => {
  const [row, column] = seatLocation(l);

  const id = seatId(row, column);
  if (id > highestId) highestId = id;

  if (seatMap[row] === undefined) {
    seatMap[row] = [column];
  } else {
    seatMap[row].push(column);
  }
});

reader.on("close", () => {
  console.log(highestId);

  const xor = (arr) => arr.reduce((x, y) => x ^ y);
  const target = 3; // // ...01 and ...11 are taken
  for (const [row, seats] of Object.entries(seatMap)) {
    const takenSeats = xor(seats);
    if (takenSeats === target) {
      const allSeats = xor([...Array(8).keys()]);
      console.log(seatId(row, takenSeats ^ allSeats));
      break;
    }
  }
});
