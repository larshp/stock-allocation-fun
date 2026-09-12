CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_quantity TYPE menge_d.

    TYPES: BEGIN OF ty_allocation,
             requirement_id TYPE c LENGTH 20,
             lgort          TYPE lgort_d,
             quantity       TYPE ty_quantity,
           END OF ty_allocation.
    TYPES ty_allocation_tt TYPE STANDARD TABLE OF ty_allocation WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             requirement_id TYPE c LENGTH 20,
             requested_qty  TYPE ty_quantity,
             allocated_qty  TYPE ty_quantity,
             shortage_qty   TYPE ty_quantity,
             allocations    TYPE ty_allocation_tt,
           END OF ty_result.
    TYPES ty_result_tt TYPE STANDARD TABLE OF ty_result WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_policy,
             include_quality    TYPE abap_bool,
             include_blocked    TYPE abap_bool,
             include_restricted TYPE abap_bool,
             include_transit    TYPE abap_bool,
           END OF ty_policy.

    METHODS constructor
      IMPORTING
        io_stock_reader TYPE REF TO zif_stock_reader
        is_policy       TYPE ty_policy OPTIONAL.

    METHODS allocate
      IMPORTING
        iv_matnr         TYPE matnr
        iv_werks         TYPE werks_d
        it_requirements  TYPE zif_requirement_reader=>ty_requirement_tt
      RETURNING
        VALUE(rt_result) TYPE ty_result_tt.

    METHODS available_quantity
      IMPORTING
        iv_matnr           TYPE matnr
        iv_werks           TYPE werks_d
      RETURNING
        VALUE(rv_quantity) TYPE ty_quantity.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_available,
             lgort    TYPE lgort_d,
             quantity TYPE ty_quantity,
           END OF ty_available.
    TYPES ty_available_tt TYPE STANDARD TABLE OF ty_available WITH DEFAULT KEY.

    DATA mo_stock_reader TYPE REF TO zif_stock_reader.
    DATA ms_policy       TYPE ty_policy.

    METHODS build_availability
      IMPORTING
        iv_matnr            TYPE matnr
        iv_werks            TYPE werks_d
      RETURNING
        VALUE(rt_available) TYPE ty_available_tt.

    METHODS usable_quantity
      IMPORTING
        is_stock           TYPE zif_stock_reader=>ty_stock
      RETURNING
        VALUE(rv_quantity) TYPE ty_quantity.

ENDCLASS.


CLASS zcl_stock_allocator IMPLEMENTATION.

  METHOD constructor.
    mo_stock_reader = io_stock_reader.
    IF is_policy IS SUPPLIED.
      ms_policy = is_policy.
    ENDIF.
  ENDMETHOD.

  METHOD allocate.
    DATA lt_available TYPE ty_available_tt.
    DATA lt_sorted    TYPE zif_requirement_reader=>ty_requirement_tt.
    DATA ls_result    TYPE ty_result.
    DATA lv_remaining TYPE ty_quantity.
    DATA lv_take      TYPE ty_quantity.

    lt_available = build_availability( iv_matnr = iv_matnr
                                       iv_werks = iv_werks ).

    lt_sorted = it_requirements.
    SORT lt_sorted BY priority ASCENDING
                      requested_date ASCENDING
                      id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_requirement).
      CLEAR ls_result.
      ls_result-requirement_id = ls_requirement-id.
      ls_result-requested_qty = ls_requirement-requested_qty.
      lv_remaining = ls_requirement-requested_qty.

      LOOP AT lt_available ASSIGNING FIELD-SYMBOL(<ls_available>).
        IF lv_remaining <= 0.
          EXIT.
        ENDIF.
        IF <ls_available>-quantity <= 0.
          CONTINUE.
        ENDIF.

        lv_take = <ls_available>-quantity.
        IF lv_take > lv_remaining.
          lv_take = lv_remaining.
        ENDIF.

        APPEND VALUE #( requirement_id = ls_requirement-id
                        lgort          = <ls_available>-lgort
                        quantity       = lv_take ) TO ls_result-allocations.

        <ls_available>-quantity = <ls_available>-quantity - lv_take.
        lv_remaining = lv_remaining - lv_take.
      ENDLOOP.

      ls_result-allocated_qty = ls_requirement-requested_qty - lv_remaining.
      ls_result-shortage_qty  = lv_remaining.
      APPEND ls_result TO rt_result.
    ENDLOOP.
  ENDMETHOD.

  METHOD available_quantity.
    DATA lt_available TYPE ty_available_tt.

    lt_available = build_availability( iv_matnr = iv_matnr
                                       iv_werks = iv_werks ).

    LOOP AT lt_available INTO DATA(ls_available).
      rv_quantity = rv_quantity + ls_available-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_availability.
    DATA lt_stock TYPE zif_stock_reader=>ty_stock_tt.
    DATA lv_usable TYPE ty_quantity.

    lt_stock = mo_stock_reader->read_stock( iv_matnr = iv_matnr
                                            iv_werks = iv_werks ).

    LOOP AT lt_stock INTO DATA(ls_stock).
      lv_usable = usable_quantity( ls_stock ).
      IF lv_usable <= 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( lgort    = ls_stock-lgort
                      quantity = lv_usable ) TO rt_available.
    ENDLOOP.
  ENDMETHOD.

  METHOD usable_quantity.
    rv_quantity = is_stock-unrestricted_qty.

    IF ms_policy-include_quality = abap_true.
      rv_quantity = rv_quantity + is_stock-quality_qty.
    ENDIF.
    IF ms_policy-include_blocked = abap_true.
      rv_quantity = rv_quantity + is_stock-blocked_qty.
    ENDIF.
    IF ms_policy-include_restricted = abap_true.
      rv_quantity = rv_quantity + is_stock-restricted_qty.
    ENDIF.
    IF ms_policy-include_transit = abap_true.
      rv_quantity = rv_quantity + is_stock-in_transit_qty.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
