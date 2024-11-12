import gleam/erlang
import gleam/int
import gleam/io
import gleam/result
import gleam/string

pub type GameState {
  Player1Wins(move: Move, beats: Move)
  Player2Wins(move: Move, beats: Move)
  Draw(move: Move)
}

pub type GameError {
  BadMove
  ReadError
}

pub type Move {
  Rock
  Paper
  Scissors
}

pub fn main() {
  display_startup_message()

  let player_1_move = read_move(player: 1)
  let player_2_move = read_move(player: 2)

  play(player_1_move, player_2_move)
  |> game_state_to_string
  |> io.println
}

pub fn read_move(player player: Int) -> Move {
  let move_result =
    erlang.get_line("* Player " <> int.to_string(player) <> "'s move: ")
    |> result.map_error(with: fn(_) { ReadError })
    |> result.try(apply: parse_move_string)

  case move_result {
    Ok(move) -> move
    Error(error) -> {
      error |> game_error_to_string |> io.println

      case error {
        BadMove -> read_move(player)
        ReadError -> panic
      }
    }
  }
}

pub fn play(player_1_move: Move, player_2_move: Move) -> GameState {
  case player_1_move, player_2_move {
    // Cases where player 1 wins
    Rock, Scissors -> Player1Wins(Rock, Scissors)
    Paper, Rock -> Player1Wins(Paper, Rock)
    Scissors, Paper -> Player1Wins(Scissors, Paper)
    // Cases where player 2 wins
    Scissors, Rock -> Player2Wins(Rock, Scissors)
    Rock, Paper -> Player2Wins(Paper, Rock)
    Paper, Scissors -> Player2Wins(Scissors, Paper)
    // Case where no player wins
    _, _ -> Draw(player_1_move)
  }
}

pub fn game_state_to_string(state: GameState) -> String {
  case state {
    Player1Wins(move, beats) ->
      player_wins_message(player: 1, winning_move: move, beats: beats)
    Player2Wins(move, beats) ->
      player_wins_message(player: 2, winning_move: move, beats: beats)
    Draw(move) ->
      "It's a draw! Both players played " <> move_to_string(move) <> "."
  }
}

pub fn move_to_string(move: Move) -> String {
  case move {
    Rock -> "Rock"
    Paper -> "Paper"
    Scissors -> "Scissors"
  }
}

pub fn game_error_to_string(error: GameError) -> String {
  case error {
    BadMove -> "Unknown move. Please try again."
    ReadError -> "There was an issue reading your input. Aborted."
  }
}

pub fn display_startup_message() {
  io.println("Rock, Paper, Scissors!")
  io.println("")
  io.println("Type either \"rock\", \"paper\", or \"scissors\" to play.")
  io.println("(tip: the numbers 0, 1, and 2 may be used as well.)")
  io.println("")
}

fn player_wins_message(
  player player_num: Int,
  winning_move move: Move,
  beats beats: Move,
) -> String {
  "Player "
  <> int.to_string(player_num)
  <> " wins! "
  <> move_to_string(move)
  <> " beats "
  <> move_to_string(beats)
  <> "!"
}

fn parse_move_string(move: String) -> Result(Move, GameError) {
  let move =
    move
    |> string.trim
    |> string.lowercase

  case move {
    "rock" | "0" -> Ok(Rock)
    "paper" | "1" -> Ok(Paper)
    "scissors" | "2" -> Ok(Scissors)
    _ -> Error(BadMove)
  }
}
