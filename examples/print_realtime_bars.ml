open Core
open Async
open Ibx

let () =
  Command.async_or_error ~summary:"Print real-time bars"
    Command.Spec.(
      Common.common_args ()
      +> Common.period_arg ()
      +> Common.currency_arg ()
      +> anon ("STOCK-SYMBOL" %: Arg_type.create Symbol.of_string)
    )
    (fun do_logging host port client_id period currency symbol () ->
       Tws.with_client_or_error ~do_logging ~host ~port ~client_id (fun tws ->
         let stock = Contract.stock ~currency symbol in
         Tws.realtime_bars_exn tws ~bar_size:`Fifteen_sec ~contract:stock
         >>= fun (bars, id) ->
         upon (after period) (fun () ->
           Tws.cancel_market_depth tws id
         );
         Pipe.iter_without_pushback bars ~f:(fun bar ->
           Format.printf "@[%a@]@\n%!" Bar.pp bar)
       )
    )
  |> Command.run
