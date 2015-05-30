open Core.Std
open Async.Std
open Ibx.Std

let () =
  let basedir = Core.Std.Unix.getcwd () in
  let logfile = basedir ^/ "ibx.log" in
  Log.Global.set_level `Debug;
  Log.Global.set_output [Log.Output.file `Text ~filename:logfile]
;;

module Client_id = struct
  let default = Client_id.of_int_exn 0
  let arg_type = Command.Spec.Arg_type.create Client_id.of_string
end

let common_args () =
  Command.Spec.(
    empty
    +> flag "-enable-logging" no_arg
      ~doc:" enable logging"
    +> flag "-host" (optional_with_default "127.0.0.1" string)
      ~doc:" hostname of TWS or Gateway (default localhost)"
    +> flag "-port" (optional_with_default 4001 int)
      ~doc:" TWS port 7496 or Gateway port 4001 (default 4001)"
    +> flag "-client-id" (optional_with_default Client_id.default Client_id.arg_type)
      ~doc:" client id of TWS or Gateway (default 0)"
  )

let duration_arg () =
  Command.Spec.(
    flag "-duration"
      (optional_with_default (sec 30.) time_span)
      ~doc:" duration of the data stream (default 30s)"
  )

module Currency = struct
  let arg_type = Command.Spec.Arg_type.create Currency.of_string
end

let currency_arg () =
  Command.Spec.(
    flag "-currency" (optional_with_default `USD Currency.arg_type)
      ~doc:" contract's currency"
  )

module Bar_span = struct
  let arg_type = Command.Spec.Arg_type.create Bar_span.of_string
end

let bar_span_arg () =
  Command.Spec.(
    flag "-span" (optional_with_default (`Year 1) Bar_span.arg_type)
      ~doc:" the time covered by the historical data request"
  )

module Bar_size = struct
  let arg_type = Command.Spec.Arg_type.create Bar_size.of_string
end

let bar_size_arg () =
  Command.Spec.(
    flag "-size" (optional_with_default `One_day Bar_size.arg_type)
      ~doc:" the size of the bars that will be returned"
  )

let sma_period_arg () =
  Command.Spec.(
    flag "-sma" (optional int)
      ~doc:" the look-back period of the simple moving average"
  )
