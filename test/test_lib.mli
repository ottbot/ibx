open Core
open Async
open Ibx

type test (** Type of a test. *)

(** [create_test name test_fun] creates a test from the function [test_fun].
    [test_fun] must return [unit] if the test succeeded or otherwise throw an
    exception. *)
val create_test : string -> (unit -> unit Deferred.t) -> test

(** Same as [create_test]. *)
val (>::) : string -> (unit -> unit Deferred.t) -> test

type suite (** Type of a test suite. *)

(** [create_suite name tests] creates a test suite consisting of all the tests
    in [tests]. *)
val create_suite : string -> test list -> suite

(** Same as [create_suite]. *)
val (>:::) : string -> test list -> suite

exception Assertion_failure of string

(** [assert_string_equal expected actual] compares two strings.
    @raise Assertion_failure if the strings are not equal. *)
val assert_string_equal : expected:string -> actual:string -> unit

(** [assert_error_equal expected actual] compares two errors.
    @raise Assertion_failure if the errors are not equal. *)
val assert_error_equal : expected:Error.t -> actual:Error.t -> unit

(** [assert_query_equal (module Q) expected actual] compares two queries.
    @raise Assertion_failure if the queries are not equal. *)
val assert_query_equal :
  (module Query_intf.S with type t = 'query)
  -> expected:'query
  -> actual:'query
  -> unit

(** [assert_response_equal (module R) expected actual] compares two responses.
    @raise Assertion_failure if the responses are not equal. *)
val assert_response_equal :
  (module Response_intf.S with type t = 'response)
  -> expected:'response
  -> actual:'response
  -> unit

(** [assert_wrapper_equal (module W) expected actual] compares two response
    wrappers.
    @raise Assertion_failure if the response wrappers are not equal. *)
val assert_wrapper_equal :
  (module Response_intf.Wrapper.S with type t = 'a)
  -> expected:'a
  -> actual:'a
  -> unit

(** [run name suites] runs all tests suites in [suites] for library [name].
    @return exit code [0] if all tests succeeded, otherwise [1]. *)
val run : string -> suite list -> int Deferred.t
