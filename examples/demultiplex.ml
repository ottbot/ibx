open Core.Std
open Async.Std
open Ibx.Std

module Console = Textutils.Console

let make_tick_printer ~id ~symbol ~color = stage (fun tick ->
  Format.fprintf
    Format.str_formatter "@[<h 0>\\<%s\\>@ id=%s@ symbol=%s@ %a@]"
    (Time.to_string_trimmed ~zone:Time.Zone.local (Time.now ()))
    (Query_id.to_string id)
    symbol Market_data.pp tick;
  Format.close_box ();
  let unescape = unstage (String.Escaping.unescape ~escape_char:'\\') in
  let output = unescape (Format.flush_str_formatter ()) in
  if Console.is_color_tty ()
  then Console.Ansi.printf [`Bright; color] "%s\n%!" output
  else print_endline output;
  return ())
;;

let () =
  Command.async_or_error
    ~summary:"Print market data for Apple, Microsoft and Google"
    Command.Spec.(Common.common_args () +> Common.duration_arg ())
    (fun do_log host port client_id duration () ->
      Common.with_tws ~do_log ~host ~port ~client_id (fun tws ->
        let print_ticks symbol color =
          Tws.contract_details_exn tws ~currency:`USD
            ~security_type:`Stock (Symbol.of_string symbol)
          >>= fun details ->
          let data = Option.value_exn (Pipe.peek details) in
          Tws.market_data_exn tws ~contract:(Contract_data.contract data)
          >>= fun (ticks, id) ->
          upon (Clock.after duration) (fun () ->
            Tws.cancel_market_data tws id
          );
          Pipe.iter ticks ~f:(unstage (make_tick_printer ~id ~symbol ~color))
        in
        let symbols, colors = ["AAPL"; "MSFT"; "GOOG"], [`Red; `Green; `Blue] in
        Deferred.all_unit (List.map2_exn symbols colors ~f:print_ticks)
      )
    )
  |> Command.run
