CLASS zcl_alloc_pallet_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             ok        TYPE abap_bool,
             too_high  TYPE abap_bool,
             too_heavy TYPE abap_bool,
           END OF ty_result.

    METHODS check
      IMPORTING
        iv_height        TYPE i
        iv_weight        TYPE menge_d
        iv_max_height    TYPE i
        iv_max_weight    TYPE menge_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_pallet_check IMPLEMENTATION.

  METHOD check.
    " A limit of zero means "no limit for this dimension", so a zero limit does
    " not reject a loaded pallet.
    IF iv_max_height > 0 AND iv_height > iv_max_height.
      rs_result-too_high = abap_true.
    ENDIF.

    IF iv_max_weight > 0 AND iv_weight > iv_max_weight.
      rs_result-too_heavy = abap_true.
    ENDIF.

    rs_result-ok = xsdbool( rs_result-too_high = abap_false
                        AND rs_result-too_heavy = abap_false ).
  ENDMETHOD.

ENDCLASS.
