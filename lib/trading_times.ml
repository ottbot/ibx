(* File: trading_day.ml

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

open Core.Std
open Tws_prot

type t =
  { date  : Date.t;
    hours : Time.Ofday.t list;
  } with sexp

let create ~date ~hours = { date; hours }

let start t ~zone = Time.of_date_ofday t.date (List.hd_exn t.hours) ~zone
let stop t ~zone = Time.of_date_ofday t.date (List.last_exn t.hours) ~zone

let t_of_tws s =
  let ofday_of_string s =
    let x = Int.of_string s in
    Time.Ofday.create ~hr:(x / 100) ~min:(x mod 100) ()
  in
  let l = String.split_on_chars s ~on:[':';'-';','] in
  { date  = List.hd_exn l |> Date.of_string;
    hours = List.tl_exn l |> List.map ~f:ofday_of_string }
;;

let tws_of_t t =
  let ofday_to_string ofday =
    let mins =
      Time.Ofday.to_span_since_start_of_day ofday
      |> Time.Span.to_min
      |> Float.to_int
    in
    String.concat
      [ mins / 60   |> sprintf "%02d"
      ; mins mod 60 |> sprintf "%02d" ]
  in
  let date_to_string = Date.to_string_iso8601_basic in
  let ofdays_to_string ofdays =
    List.map ofdays ~f:ofday_to_string
    |> List.foldi ~init:"" ~f:(fun i acc s ->
      if i mod 2 = 0 then acc^","^s else acc^"-"^s)
    |> String.chop_prefix_exn ~prefix:","
  in
  String.concat [ date_to_string t.date; ofdays_to_string t.hours ] ~sep:":"
;;

let val_type = Val_type.create tws_of_t t_of_tws
