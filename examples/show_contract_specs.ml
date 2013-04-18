open Core.Std
open Async.Std
open Ibx.Std

let contracts : Contract.Type.t Contract.t list = [
  Contract.stock ~currency:`USD (Symbol.of_string "AAPL");
  Contract.stock ~currency:`EUR (Symbol.of_string "BMW");

  (* For current contracts check:
     http://www.cmegroup.com/trading/equity-index/us-index/
     e-mini-sandp500_product_calendar_futures.html
  *)
  Contract.futures
    ~exchange:`GLOBEX
    ~currency:`USD
    ~expiry:(Date.create_exn ~y:2013 ~m:Month.Jun ~d:21)
    (Symbol.of_string "ES");

  (* For current contracts check: http://finance.yahoo.com/q/op?s=GOOG *)
  Contract.option
    ~exchange:`CBOE
    ~currency:`USD
    ~option_right:`Call
    ~expiry:(Date.create_exn ~y:2013 ~m:Month.Jun ~d:21)
    ~strike:(Price.of_float 850.)
    (Symbol.of_string "GOOG");

  Contract.forex
    ~exchange:`IDEALPRO
    ~currency:`JPY
    (Symbol.of_string "USD");
]

let run () =
  Common.with_tws_client (fun tws ->
    Deferred.List.iter contracts ~f:(fun contract ->
      Tws.contract_specs_exn tws ~contract
      >>| fun con_specs ->
      printf "===== [ %s ] =====\n%!"
        (Contract.symbol contract |! Symbol.to_string);
      printf "%s\n\n%!"
        (Contract_specs.sexp_of_t con_specs |! Sexp.to_string_hum)))

let command =
  Command.async_basic ~summary:"show contract specifications"
    Command.Spec.(
      empty
      +> Common.logging_flag ()
      +> Common.host_arg ()
      +> Common.port_arg ()
    )
    (fun enable_logging host port () ->
      run ~enable_logging ~host ~port ()
      >>= function
      | Error e -> prerr_endline (Error.to_string_hum e); exit 1
      | Ok () -> return ()
    )

let () = Command.run command
