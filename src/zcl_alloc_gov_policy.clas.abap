CLASS zcl_alloc_gov_policy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS policy_of
      IMPORTING
        iv_level         TYPE i
      RETURNING
        VALUE(rv_policy) TYPE string.

    METHODS is_strict
      IMPORTING
        iv_policy    TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_policy        TYPE string
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_gov_policy IMPLEMENTATION.

  METHOD policy_of.
    " The level reads as a policy from strict through to relaxed.
    CASE iv_level.
      WHEN 1.
        rv_policy = 'STRICT'.
      WHEN 2.
        rv_policy = 'STANDARD'.
      WHEN 3.
        rv_policy = 'RELAXED'.
      WHEN OTHERS.
        rv_policy = 'UNKNOWN'.
    ENDCASE.
  ENDMETHOD.

  METHOD is_strict.
    " A strict policy demands the most of the allocation.
    rv_ok = xsdbool( iv_policy = 'STRICT' ).
  ENDMETHOD.

  METHOD reason.
    " Each policy carries the reason behind it.
    CASE iv_policy.
      WHEN 'STRICT'.
        rv_reason = 'audit required'.
      WHEN 'STANDARD'.
        rv_reason = 'review required'.
      WHEN 'RELAXED'.
        rv_reason = 'no review'.
      WHEN OTHERS.
        rv_reason = 'unknown'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
