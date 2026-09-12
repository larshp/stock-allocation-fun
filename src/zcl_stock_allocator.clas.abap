CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_quantity TYPE menge_d.

    TYPES: BEGIN OF ty_allocation,
             requirement_id TYPE c LENGTH 20,
             lgort          TYPE lgort_d,
             charg          TYPE c LENGTH 10,
             expiry_date    TYPE d,
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
             use_fefo           TYPE abap_bool,
             whole_sales_units  TYPE abap_bool,
           END OF ty_policy.

    METHODS constructor
      IMPORTING
        io_stock_reader  TYPE REF TO zif_stock_reader
        io_uom_converter TYPE REF TO zif_uom_converter OPTIONAL
        is_policy        TYPE ty_policy OPTIONAL.

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
             lgort       TYPE lgort_d,
             charg       TYPE c LENGTH 10,
             expiry_date TYPE d,
             sort_date   TYPE d,
             quantity    TYPE ty_quantity,
           END OF ty_available.
    TYPES ty_available_tt TYPE STANDARD TABLE OF ty_available WITH DEFAULT KEY.

    DATA mo_stock_reader  TYPE REF TO zif_stock_reader.
    DATA ms_policy        TYPE ty_policy.
    DATA mo_uom_converter TYPE REF TO zif_uom_converter.

    METHODS to_base_qty
      IMPORTING
        iv_matnr       TYPE matnr
        is_requirement TYPE zif_requirement_reader=>ty_requirement
      RETURNING
        VALUE(rv_qty)  TYPE ty_quantity.

    METHODS sales_unit_step
      IMPORTING
        iv_matnr       TYPE matnr
        is_requirement TYPE zif_requirement_reader=>ty_requirement
      RETURNING
        VALUE(rv_step) TYPE ty_quantity.

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
    IF io_uom_converter IS SUPPLIED.
      mo_uom_converter = io_uom_converter.
    ENDIF.
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
    DATA lv_step      TYPE ty_quantity.

    lt_available = build_availability( iv_matnr = iv_matnr
                                       iv_werks = iv_werks ).

    IF ms_policy-use_fefo = abap_true.
      " earliest expiry first, unknown expiry dates last
      SORT lt_available BY sort_date ASCENDING
                           lgort ASCENDING
                           charg ASCENDING.
    ENDIF.

    lt_sorted = it_requirements.
    SORT lt_sorted BY priority ASCENDING
                      requested_date ASCENDING
                      id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_requirement).
      CLEAR ls_result.
      ls_result-requirement_id = ls_requirement-id.
      ls_result-requested_qty = to_base_qty( iv_matnr       = iv_matnr
                                             is_requirement = ls_requirement ).
      lv_remaining = ls_result-requested_qty.
      lv_step = sales_unit_step( iv_matnr       = iv_matnr
                                 is_requirement = ls_requirement ).

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

        IF lv_step > 0.
          " only whole sales units may be taken from a single stock row
          lv_take = lv_take DIV lv_step.
          lv_take = lv_take * lv_step.
        ENDIF.
        IF lv_take <= 0.
          CONTINUE.
        ENDIF.

        APPEND VALUE #( requirement_id = ls_requirement-id
                        lgort          = <ls_available>-lgort
                        charg          = <ls_available>-charg
                        expiry_date    = <ls_available>-expiry_date
                        quantity       = lv_take ) TO ls_result-allocations.

        <ls_available>-quantity = <ls_available>-quantity - lv_take.
        lv_remaining = lv_remaining - lv_take.
      ENDLOOP.

      ls_result-allocated_qty = ls_result-requested_qty - lv_remaining.
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

  METHOD to_base_qty.
    rv_qty = is_requirement-requested_qty.
    IF is_requirement-unit IS INITIAL OR mo_uom_converter IS NOT BOUND.
      RETURN.
    ENDIF.

    rv_qty = mo_uom_converter->to_base_qty(
      iv_matnr = iv_matnr
      iv_meinh = is_requirement-unit
      iv_qty   = is_requirement-requested_qty ).
  ENDMETHOD.

  METHOD sales_unit_step.
    rv_step = 0.

    IF ms_policy-whole_sales_units <> abap_true
        OR is_requirement-unit IS INITIAL
        OR mo_uom_converter IS NOT BOUND.
      RETURN.
    ENDIF.

    rv_step = mo_uom_converter->to_base_qty( iv_matnr = iv_matnr
                                             iv_meinh = is_requirement-unit
                                             iv_qty   = 1 ).
    IF rv_step <= 0.
      rv_step = 0.
    ENDIF.
  ENDMETHOD.

  METHOD build_availability.
    DATA lt_stock  TYPE zif_stock_reader=>ty_stock_tt.
    DATA lv_usable TYPE ty_quantity.
    DATA lv_expiry TYPE d.

    lt_stock = mo_stock_reader->read_stock( iv_matnr = iv_matnr
                                            iv_werks = iv_werks ).

    LOOP AT lt_stock INTO DATA(ls_stock).
      lv_usable = usable_quantity( ls_stock ).
      IF lv_usable <= 0.
        CONTINUE.
      ENDIF.

      lv_expiry = ls_stock-expiry_date.
      IF lv_expiry IS INITIAL.
        lv_expiry = '99991231'.
      ENDIF.

      APPEND VALUE #( lgort       = ls_stock-lgort
                      charg       = ls_stock-charg
                      expiry_date = ls_stock-expiry_date
                      sort_date   = lv_expiry
                      quantity    = lv_usable ) TO rt_available.
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
