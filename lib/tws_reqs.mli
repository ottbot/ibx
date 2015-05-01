(* File: tws_reqs.mli

   IBX - OCaml implementation of the Interactive Brokers TWS API

   Copyright (C) 2013-  Oliver Gu
   email: gu.oliver@yahoo.com

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*)

(** TWS requests *)

(** {1 Connection and server} *)
(*****************************************************************************)

val req_server_time :
  (Query.Server_time.t, Response.Server_time.t) Ib.Request.t

(** {1 Market data} *)
(*****************************************************************************)

val req_market_data :
  (Query.Market_data.t, [ `Tick_price  of Response.Tick_price.t
                        | `Tick_size   of Response.Tick_size.t
                        | `Tick_option of Response.Tick_option.t
                        | `Tick_string of Response.Tick_string.t
                        ]) Ib.Streaming_request.t

val req_calc_option_price :
  (Query.Calc_option_price.t, Price.t option) Ib.Streaming_request.t

val req_calc_implied_volatility :
  (Query.Calc_implied_volatility.t, float option) Ib.Streaming_request.t

(** {1 Contract details} *)
(*****************************************************************************)

val req_contract_details :
  (Query.Contract_details.t, [ `Contract_data of Response.Contract_data.t
                             | `Contract_data_end
                             ]) Ib.Streaming_request.t

(** {1 Orders} *)
(*****************************************************************************)

val req_submit_order :
  (Query.Submit_order.t, Response.Order_status.t) Ib.Streaming_request.t

(** {1 Account and portfolio} *)
(*****************************************************************************)

val req_account_updates :
  (Query.Account_updates.t, [ `Update of Response.Account_update.t
                            | `Update_end of Account_code.t
                            ]) Ib.Streaming_request_without_id.t

val req_portfolio_updates :
  (Query.Portfolio_positions.t, [ `Update of Response.Portfolio_position.t
                                | `Update_end of Account_code.t
                                ]) Ib.Streaming_request_without_id.t

(** {1 Execution data} *)
(*****************************************************************************)

val req_executions :
  (Query.Executions.t, [ `Execution of Response.Execution.t
                       | `Executions_end
                       ]) Ib.Streaming_request.t

(** {1 Market depth} *)
(*****************************************************************************)

val req_market_depth :
  (Query.Market_depth.t, Response.Book_update.t) Ib.Streaming_request.t

(** {1 Historical data} *)
(*****************************************************************************)

val req_historical_data :
  (Query.Historical_data.t, Response.Historical_data.t) Ib.Streaming_request.t

(** {1 Realtime bars} *)
(*****************************************************************************)

val req_realtime_bars :
  (Query.Realtime_bars.t, Response.Realtime_bar.t) Ib.Streaming_request.t


(** {1 TAQ data} *)
(*****************************************************************************)

val req_taq_data :
  (Query.Market_data.t, [ `Tick_price of Response.Tick_price.t
                        | `Tick_size  of Response.Tick_size.t
                        ]) Ib.Streaming_request.t

(** {1 Snapshots} *)
(*****************************************************************************)

val req_snapshot :
  (Query.Market_data.t, [ `Tick_price of Response.Tick_price.t
                        | `Snapshot_end
                        ]) Ib.Streaming_request.t
