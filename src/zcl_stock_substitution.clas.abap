CLASS zcl_stock_substitution DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_substitute,
             matnr    TYPE matnr,
             submatnr TYPE matnr,
             priority TYPE i,
           END OF ty_substitute.
    TYPES ty_substitute_tt TYPE STANDARD TABLE OF ty_substitute
      WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_availability,
             matnr     TYPE matnr,
             available TYPE menge_d,
           END OF ty_availability.
    TYPES ty_availability_tt TYPE STANDARD TABLE OF ty_availability
      WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_availability_result,
             requested_matnr TYPE matnr,
             own_available   TYPE menge_d,
             sub_available   TYPE menge_d,
             total_available TYPE menge_d,
             details         TYPE ty_availability_tt,
           END OF ty_availability_result.

    METHODS constructor
      IMPORTING
        io_stock_reader TYPE REF TO zif_stock_reader OPTIONAL.

    METHODS read_substitutes
      IMPORTING
        iv_matnr              TYPE matnr
      RETURNING
        VALUE(rt_substitutes) TYPE ty_substitute_tt.

    METHODS availability
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
      RETURNING
        VALUE(rs_result) TYPE ty_availability_result.

  PRIVATE SECTION.
    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
    DATA mo_allocator    TYPE REF TO zcl_stock_allocator.

ENDCLASS.


CLASS zcl_stock_substitution IMPLEMENTATION.

  METHOD constructor.
    IF io_stock_reader IS SUPPLIED.
      mo_stock_reader = io_stock_reader.
    ENDIF.
    IF mo_stock_reader IS NOT BOUND.
      mo_stock_reader = NEW zcl_stock_reader_mard( ).
    ENDIF.

    mo_allocator = NEW zcl_stock_allocator( io_stock_reader = mo_stock_reader ).
  ENDMETHOD.

  METHOD read_substitutes.
    SELECT matnr,
           submatnr,
           prio
      FROM zsubstitute
      INTO TABLE @DATA(lt_rules)
      WHERE matnr = @iv_matnr
      ORDER BY prio, submatnr.

    LOOP AT lt_rules INTO DATA(ls_rule).
      APPEND VALUE #( matnr    = ls_rule-matnr
                      submatnr = ls_rule-submatnr
                      priority = ls_rule-prio ) TO rt_substitutes.
    ENDLOOP.
  ENDMETHOD.

  METHOD availability.
    DATA lv_avail TYPE menge_d.

    rs_result-requested_matnr = iv_matnr.
    rs_result-own_available = mo_allocator->available_quantity(
      iv_matnr = iv_matnr
      iv_werks = iv_werks ).
    rs_result-total_available = rs_result-own_available.

    APPEND VALUE #( matnr     = iv_matnr
                    available = rs_result-own_available )
      TO rs_result-details.

    LOOP AT read_substitutes( iv_matnr ) INTO DATA(ls_substitute).
      lv_avail = mo_allocator->available_quantity(
        iv_matnr = ls_substitute-submatnr
        iv_werks = iv_werks ).

      rs_result-sub_available = rs_result-sub_available + lv_avail.
      rs_result-total_available = rs_result-total_available + lv_avail.

      APPEND VALUE #( matnr     = ls_substitute-submatnr
                      available = lv_avail ) TO rs_result-details.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
