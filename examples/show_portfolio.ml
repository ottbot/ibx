open Core.Std
open Async.Std
open Ibx.Std

module Ascii_table = Textutils.Ascii_table

let show_portfolio updates =
  let module P = Portfolio_update in
  Ascii_table.output ~oc:stdout ~limit_width_to:120 [
    Ascii_table.Column.create ~align:Ascii_table.Align.left
      "Contract"
      (fun update ->
        sprintf "%s" (P.contract update |> Contract.to_string));
    Ascii_table.Column.create ~align:Ascii_table.Align.left
      "Exchange"
      (fun update ->
        sprintf "%s" (P.contract update |> Contract.exchange |> Exchange.to_string));
    Ascii_table.Column.create ~align:Ascii_table.Align.right
      "Position"
      (fun update ->
        sprintf "%d" (P.position update));
    Ascii_table.Column.create ~align:Ascii_table.Align.center
      "Currency"
      (fun update ->
        sprintf "%s" (P.contract update |> Contract.currency |> Currency.to_string));
    Ascii_table.Column.create ~align:Ascii_table.Align.right
      "Market Price"
      (fun update ->
        sprintf "%4.2f" (P.market_price update |> Price.to_float));
    Ascii_table.Column.create ~align:Ascii_table.Align.right
      "Market Value"
      (fun update ->
        sprintf "%4.2f" (P.market_value update |> Price.to_float));
    Ascii_table.Column.create ~align:Ascii_table.Align.right
      "Avg Cost"
      (fun update ->
        sprintf "%4.2f" (P.average_cost update |> Price.to_float));
    Ascii_table.Column.create ~align:Ascii_table.Align.right
      "Total P&L"
      (fun update ->
        sprintf "%4.2f"
          (Price.to_float (P.realized_pnl update) +.
           Price.to_float (P.unrealized_pnl update)));
  ] updates
;;

let () =
  Command.async_basic ~summary:"show portfolio"
    Command.Spec.(
      empty
      +> Common.logging_flag ()
      +> Common.host_arg ()
      +> Common.port_arg ()
      +> Common.client_id_arg ()
    )
    (fun do_log host port client_id () ->
      Common.with_tws ~do_log ~host ~port ~client_id (fun tws ->
        Tws.portfolio_updates_exn tws
        >>= fun updates -> Pipe.to_list updates >>| show_portfolio
      )
    )
  |> Command.run
