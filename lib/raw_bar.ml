(* File: raw_bar.ml

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
  { stamp : Time.t;
    op : Price.t;
    hi : Price.t;
    lo : Price.t;
    cl : Price.t;
    vo : Volume.t;
    wap : Price.t;
    has_gaps : bool;
    count : int;
  }
with sexp, fields

let create = Fields.create

let ( = ) t1 t2 : bool =
  let use op = fun field ->
    op (Field.get field t1) (Field.get field t2)
  in
  Fields.for_all
    ~stamp:(use Time.(=))
    ~op:(use Price.(=.))
    ~hi:(use Price.(=.))
    ~lo:(use Price.(=.))
    ~cl:(use Price.(=.))
    ~vo:(use Volume.(=))
    ~wap:(use Price.(=.))
    ~has_gaps:(use (=))
    ~count:(use (=))

let field_name field = Fieldslib.Field.name field

let wrap_bar_spec bar_spec =
  Pickler.Spec.(
    wrap bar_spec
      (fun t ->
        `Args
          $ t.stamp
          $ t.op
          $ t.hi
          $ t.lo
          $ t.cl
          $ t.vo
          $ t.wap
          $ t.has_gaps
          $ t.count))

module Historical_bar = struct
  module Stamp = struct
    include Time
    let tws_of_t tm = Time.format tm "%Y%m%d  %H:%M:%S"
    let t_of_tws s =
      let unescape = unstage (String.Escaping.unescape ~escape_char:' ') in
      let s = if Int.(String.length s > 8) then unescape s else s^" 00:00:00" in
      Time.of_string s
    let val_type = Val_type.create tws_of_t t_of_tws
  end

  let pickler_spec () =
    Pickler.Spec.(
      Fields.fold
        ~init:(empty ())
        ~stamp:(fields_value (required Stamp.val_type))
        ~op:(fields_value (required Price.val_type))
        ~hi:(fields_value (required Price.val_type))
        ~lo:(fields_value (required Price.val_type))
        ~cl:(fields_value (required Price.val_type))
        ~vo:(fields_value (required Volume.val_type))
        ~wap:(fields_value (required Price.val_type))
        ~has_gaps:(fields_value (required bools))
        ~count:(fields_value (required int)))
    |> wrap_bar_spec

  let unpickler_spec () =
    Unpickler.Spec.(
      step (fun conv stamp op hi lo cl vo wap has_gaps count ->
        conv (create ~stamp ~op ~hi ~lo ~cl ~vo ~wap ~has_gaps ~count)
      )
      ++ value (required Stamp.val_type)
        ~name:(field_name Fields.stamp)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.op)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.hi)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.lo)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.cl)
      ++ value (required Volume.val_type)
        ~name:(field_name Fields.vo)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.wap)
      ++ value (required bools)
        ~name:(field_name Fields.has_gaps)
      ++ value (required int)
        ~name:(field_name Fields.count)
    )
end

module Realtime_bar = struct
  module Stamp = struct
    let tws_of_t t = Time.to_float t |> Float.to_string
    let t_of_tws s = Float.of_string s |> Time.of_float
    let val_type = Val_type.create tws_of_t t_of_tws
  end

  let pickler_spec () =
    Pickler.Spec.(
      Fields.fold
        ~init:(empty ())
        ~stamp:(fields_value (required Stamp.val_type))
        ~op:(fields_value (required Price.val_type))
        ~hi:(fields_value (required Price.val_type))
        ~lo:(fields_value (required Price.val_type))
        ~cl:(fields_value (required Price.val_type))
        ~vo:(fields_value (required Volume.val_type))
        ~wap:(fields_value (required Price.val_type))
        ~has_gaps:(fields_value skipped)
        ~count:(fields_value (required int)))
    |> wrap_bar_spec

  let unpickler_spec () =
    Unpickler.Spec.(
      step (fun conv stamp op hi lo cl vo wap count ->
        conv (create ~stamp ~op ~hi ~lo ~cl ~vo ~wap ~has_gaps:false ~count)
      )
      ++ value (required Stamp.val_type)
        ~name:(field_name Fields.stamp)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.op)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.hi)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.lo)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.cl)
      ++ value (required Volume.val_type)
        ~name:(field_name Fields.vo)
      ++ value (required Price.val_type)
        ~name:(field_name Fields.wap)
      ++ value (required int)
        ~name:(field_name Fields.count)
    )
end