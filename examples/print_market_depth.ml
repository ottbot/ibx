open Core
open Async
open Ibx

let () =
  Command.async_or_error ~summary:"Print market depth"
    Command.Spec.(
      Common.common_args ()
      +> Common.period_arg ()
      +> Common.currency_arg ()
      +> anon ("STOCK-SYMBOL" %: Arg_type.create Symbol.of_string)
    )
    (fun do_logging host port client_id period currency symbol () ->
       Tws.with_client_or_error ~do_logging ~host ~port ~client_id (fun tws ->
         Tws.market_depth_exn tws ~contract:(Contract.stock ~currency symbol )
         >>= fun (book_updates, id) ->
         upon (after period) (fun () ->
           Tws.cancel_market_depth tws id
         );
         Pipe.iter_without_pushback book_updates ~f:(fun book_update ->
           printf "%s\n%!" (Book_update.sexp_of_t book_update |> Sexp.to_string_hum))
       )
    )
  |> Command.run
